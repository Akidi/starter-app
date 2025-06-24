// src/lib/server/auth.ts - Updated with Redis caching
import type { RequestEvent } from '@sveltejs/kit';
import { eq } from 'drizzle-orm';
import { sha256 } from '@oslojs/crypto/sha2';
import { encodeBase64url, encodeHexLowerCase } from '@oslojs/encoding';
import { getWriteDb, getReadDb, getRedis } from '$lib/server/db';
import * as authSchema from '$lib/server/db/auth/schema';

const DAY_IN_MS = 1000 * 60 * 60 * 24;

// Redis cache configuration
const REDIS_CONFIG = {
	USER_CACHE_PREFIX: 'user:',
	LOGIN_COUNT_PREFIX: 'login_count:',
	CACHE_TTL: 60 * 60 * 24, // 24 hours
	MAX_LOGIN_COUNT: 5
} as const;

export const sessionCookieName = 'auth-session';

// Enhanced user type with cache info
export interface CachedUser {
	id: string;
	name: string;
	email: string;
	role: string;
	loginCount: number;
	cacheSource: 'redis' | 'database';
}

export function generateSessionToken() {
	const bytes = crypto.getRandomValues(new Uint8Array(18));
	const token = encodeBase64url(bytes);
	return token;
}

export async function createSession(token: string, userId: string) {
	try {
		const sessionId = encodeHexLowerCase(sha256(new TextEncoder().encode(token)));

		const session: typeof authSchema.session.$inferInsert = {
			id: undefined, // Let the database generate the CUID
			userId,
			sessionToken: sessionId,
			expiresAt: new Date(Date.now() + DAY_IN_MS * 30)
		};

		const [newSession] = await getWriteDb().insert(authSchema.session).values(session).returning();

		return newSession;
	} catch (error) {
		throw error;
	}
}

export async function validateSessionToken(token: string) {

	try {
		const sessionId = encodeHexLowerCase(sha256(new TextEncoder().encode(token)));

		const [result] = await getReadDb()
			.select({
				user: {
					id: authSchema.user.id,
					name: authSchema.user.name,
					email: authSchema.user.email,
					role: authSchema.user.role
				},
				session: authSchema.session
			})
			.from(authSchema.session)
			.innerJoin(authSchema.user, eq(authSchema.session.userId, authSchema.user.id))
			.where(eq(authSchema.session.sessionToken, sessionId));

		if (!result) {
			return { session: null, user: null };
		}

		const { session, user } = result;

		const sessionExpired = Date.now() >= session.expiresAt.getTime();
		if (sessionExpired) {
			await getWriteDb().delete(authSchema.session).where(eq(authSchema.session.id, session.id));
			return { session: null, user: null };
		}

		// Try to get user from Redis cache
		const cachedUser = await getCachedUser(user.id);

		let finalUser: CachedUser;

		if (cachedUser) {

			// Increment login count
			const newLoginCount = cachedUser.loginCount + 1;

			if (newLoginCount >= REDIS_CONFIG.MAX_LOGIN_COUNT) {
				await clearUserCache(user.id);

				// Load fresh from database
				finalUser = {
					...user,
					loginCount: 1,
					cacheSource: 'database'
				};

				// Cache the fresh data
				await cacheUser(finalUser);
			} else {
				// Update cache with new login count
				finalUser = {
					...cachedUser,
					loginCount: newLoginCount,
					cacheSource: 'redis'
				};
				await cacheUser(finalUser);
			}
		} else {

			// First time or cache expired - load from database
			finalUser = {
				...user,
				loginCount: 1,
				cacheSource: 'database'
			};

			// Cache for future requests
			await cacheUser(finalUser);
		}

		// Refresh session if needed
		const renewSession = Date.now() >= session.expiresAt.getTime() - DAY_IN_MS * 15;
		if (renewSession) {
			session.expiresAt = new Date(Date.now() + DAY_IN_MS * 30);
			await getWriteDb()
				.update(authSchema.session)
				.set({
					expiresAt: session.expiresAt,
					lastAccessed: new Date()
				})
				.where(eq(authSchema.session.id, session.id));
		}

		return { session, user: finalUser };
	} catch (error) {
		return { session: null, user: null };
	}
}

// Redis cache functions
async function getCachedUser(userId: string): Promise<CachedUser | null> {
	try {
		const redis = getRedis();
		const userKey = REDIS_CONFIG.USER_CACHE_PREFIX + userId;
		const loginCountKey = REDIS_CONFIG.LOGIN_COUNT_PREFIX + userId;

		const [userData, loginCount] = await Promise.all([
			redis.get(userKey),
			redis.get(loginCountKey)
		]);

		if (!userData) {
			return null;
		}

		const user = JSON.parse(userData);
		return {
			...user,
			loginCount: parseInt(loginCount || '0'),
			cacheSource: 'redis'
		};
	} catch (error) {
		return null;
	}
}

async function cacheUser(user: CachedUser): Promise<void> {
	try {
		const redis = getRedis();
		const userKey = REDIS_CONFIG.USER_CACHE_PREFIX + user.id;
		const loginCountKey = REDIS_CONFIG.LOGIN_COUNT_PREFIX + user.id;

		// Store user data and login count separately
		const userData = {
			id: user.id,
			email: user.email,
			name: user.name,
			role: user.role
		};

		await Promise.all([
			redis.setex(userKey, REDIS_CONFIG.CACHE_TTL, JSON.stringify(userData)),
			redis.setex(loginCountKey, REDIS_CONFIG.CACHE_TTL, user.loginCount.toString())
		]);

	} catch (error) {
		throw error;
	}
}

async function clearUserCache(userId: string): Promise<void> {
	try {
		const redis = getRedis();
		const userKey = REDIS_CONFIG.USER_CACHE_PREFIX + userId;
		const loginCountKey = REDIS_CONFIG.LOGIN_COUNT_PREFIX + userId;

		await Promise.all([redis.del(userKey), redis.del(loginCountKey)]);

	} catch (error) {
		throw error;
	}
}

// Admin function to manually clear cache
export async function clearAllUserCaches(): Promise<void> {
	try {
		const redis = getRedis();
		const userKeys = await redis.keys(REDIS_CONFIG.USER_CACHE_PREFIX + '*');
		const loginCountKeys = await redis.keys(REDIS_CONFIG.LOGIN_COUNT_PREFIX + '*');

		const allKeys = [...userKeys, ...loginCountKeys];

		if (allKeys.length > 0) {
			await redis.del(...allKeys);
		}
	} catch (error) {
		throw error;
	}
}

export type SessionValidationResult = Awaited<ReturnType<typeof validateSessionToken>>;

export async function invalidateSession(sessionId: string) {
	await getWriteDb().delete(authSchema.session).where(eq(authSchema.session.id, sessionId));
}

export function setSessionTokenCookie(event: RequestEvent, token: string, expiresAt: Date) {
	event.cookies.set(sessionCookieName, token, {
		expires: expiresAt,
		path: '/',
		httpOnly: true,
		secure: process.env.NODE_ENV === 'production',
		sameSite: 'lax'
	});
}

export function deleteSessionTokenCookie(event: RequestEvent) {
	event.cookies.delete(sessionCookieName, {
		path: '/',
		httpOnly: true,
		secure: process.env.NODE_ENV === 'production',
		sameSite: 'lax'
	});
}

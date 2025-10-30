// src/lib/server/auth.ts
import type { RequestEvent } from '@sveltejs/kit';
import { eq } from 'drizzle-orm';
import { sha256 } from '@oslojs/crypto/sha2';
import { encodeBase64url, encodeHexLowerCase } from '@oslojs/encoding';
import { getWriteDb, getReadDb } from '$lib/server/db';
import * as authSchema from '$lib/server/db/auth';

const DAY_IN_MS = 1000 * 60 * 60 * 24;

export const sessionCookieName = 'auth-session';

export function generateSessionToken() {
	const bytes = crypto.getRandomValues(new Uint8Array(18));
	const token = encodeBase64url(bytes);
	return token;
}

export async function createSession(token: string, userId: string) {
	const sessionId = encodeHexLowerCase(sha256(new TextEncoder().encode(token)));

	const session: typeof authSchema.session.$inferInsert = {
		id: undefined,
		userId,
		sessionToken: sessionId,
		expiresAt: new Date(Date.now() + DAY_IN_MS * 30)
	};

	const [newSession] = await getWriteDb().insert(authSchema.session).values(session).returning();

	return newSession;
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

		return { session, user };
	} catch (error) {
		console.log(error);
		return { session: null, user: null };
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

import { hash, verify } from '@node-rs/argon2';
import { fail, redirect } from '@sveltejs/kit';
import { eq } from 'drizzle-orm';
import * as auth from '$lib/server/auth';
import { getReadDb, getWriteDb } from '$lib/server/db';
import * as authSchema from '$lib/server/db/auth/schema/index';
import type { Actions, PageServerLoad } from './$types';

export const load: PageServerLoad = async (event) => {
	console.log('[DEBUG] Load function called');
	if (event.locals.user) {
		console.log('[DEBUG] User already authenticated, redirecting');
		return redirect(302, '/demo/lucia');
	}
	console.log('[DEBUG] No authenticated user, showing login page');
	return {};
};

export const actions: Actions = {
	login: async (event) => {
		console.log('[DEBUG] Login action started');

		try {
			const formData = await event.request.formData();
			const email = formData.get('email');
			const password = formData.get('password');

			console.log('[DEBUG] Form data received:', {
				email: email ? 'provided' : 'missing',
				password: password ? 'provided' : 'missing'
			});

			if (!validateEmail(email)) {
				console.log('[DEBUG] Email validation failed:', email);
				return fail(400, {
					message: 'Invalid email address'
				});
			}
			if (!validatePassword(password)) {
				console.log('[DEBUG] Password validation failed');
				return fail(400, { message: 'Invalid password (min 6, max 255 characters)' });
			}

			console.log('[DEBUG] Validation passed, querying database for user:', email);

			// Query the auth.users table using email
			const results = await getReadDb()
				.select()
				.from(authSchema.user)
				.where(eq(authSchema.user.email, email));

			console.log('[DEBUG] Database query completed, results count:', results.length);

			const existingUser = results.at(0);
			if (!existingUser) {
				console.log('[DEBUG] User not found in database');
				return fail(400, { message: 'Incorrect email or password' });
			}

			console.log('[DEBUG] User found, verifying password');

			// Verify password against password_hash column
			const validPassword = await verify(existingUser.passwordHash, password, {
				memoryCost: 19456,
				timeCost: 2,
				outputLen: 32,
				parallelism: 1
			});

			console.log('[DEBUG] Password verification result:', validPassword);

			if (!validPassword) {
				console.log('[DEBUG] Password verification failed');
				return fail(400, { message: 'Incorrect email or password' });
			}

			console.log('[DEBUG] Password verified, creating session');

			const sessionToken = auth.generateSessionToken();
			console.log('[DEBUG] Session token generated');

			const session = await auth.createSession(sessionToken, existingUser.id);
			console.log('[DEBUG] Session created:', { sessionId: session.id, userId: existingUser.id });

			auth.setSessionTokenCookie(event, sessionToken, session.expiresAt);
			console.log('[DEBUG] Session cookie set, redirecting');
		} catch (error) {
			console.error('[ERROR] Login action failed:', error);
			if (error instanceof Error) {
				console.error('[ERROR] Error message:', error.message);
				console.error('[ERROR] Stack trace:', error.stack);
			} else {
				console.error('[ERROR] Unknown error type:', typeof error);
			}
			return fail(500, { message: 'Internal server error during login' });
		}
		return redirect(302, '/demo/lucia');
	},
	register: async (event) => {
		console.log('[DEBUG] Register action started');

		try {
			const formData = await event.request.formData();
			const email = formData.get('email');
			const name = formData.get('name');
			const password = formData.get('password');

			console.log('[DEBUG] Registration form data received:', {
				email: email ? 'provided' : 'missing',
				name: name ? 'provided' : 'missing',
				password: password ? 'provided' : 'missing'
			});

			if (!validateEmail(email)) {
				console.log('[DEBUG] Email validation failed:', email);
				return fail(400, { message: 'Invalid email address' });
			}
			if (!validateName(name)) {
				console.log('[DEBUG] Name validation failed:', name);
				return fail(400, { message: 'Invalid name (min 2, max 50 characters)' });
			}
			if (!validatePassword(password)) {
				console.log('[DEBUG] Password validation failed');
				return fail(400, { message: 'Invalid password (min 6, max 255 characters)' });
			}

			console.log('[DEBUG] Validation passed, checking for existing user');

			// Check if user already exists
			const existingUsers = await getReadDb()
				.select()
				.from(authSchema.user)
				.where(eq(authSchema.user.email, email));

			console.log('[DEBUG] Existing user check completed, count:', existingUsers.length);

			if (existingUsers.length > 0) {
				console.log('[DEBUG] User already exists');
				return fail(400, { message: 'Email already registered' });
			}

			console.log('[DEBUG] Hashing password');

			const passwordHash = await hash(password, {
				memoryCost: 19456,
				timeCost: 2,
				outputLen: 32,
				parallelism: 1
			});

			console.log('[DEBUG] Password hashed, inserting user');

			// Insert into auth.users table with proper columns
			const insertResult = await getWriteDb()
				.insert(authSchema.user)
				.values({
					email,
					name,
					passwordHash,
					role: 'user' // Default role
				})
				.returning({ id: authSchema.user.id });

			console.log('[DEBUG] User inserted, result:', insertResult);

			const userId = insertResult[0].id;
			console.log('[DEBUG] New user ID:', userId);

			console.log('[DEBUG] Creating session for new user');

			const sessionToken = auth.generateSessionToken();
			const session = await auth.createSession(sessionToken, userId);

			console.log('[DEBUG] Session created for new user:', { sessionId: session.id, userId });

			auth.setSessionTokenCookie(event, sessionToken, session.expiresAt);
			console.log('[DEBUG] Registration complete, redirecting');
		} catch (error) {
			console.error('[ERROR] Registration failed:', error);
			if (error instanceof Error) {
				console.error('[ERROR] Error message:', error.message);
				console.error('[ERROR] Stack trace:', error.stack);
			} else {
				console.error('[ERROR] Unknown error type:', typeof error);
			}
			return fail(500, { message: 'An error has occurred during registration' });
		}
		return redirect(302, '/demo/lucia');
	}
};

function validateEmail(email: unknown): email is string {
	return (
		typeof email === 'string' &&
		email.length >= 3 &&
		email.length <= 255 &&
		/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)
	);
}

function validateName(name: unknown): name is string {
	return (
		typeof name === 'string' &&
		name.length >= 2 &&
		name.length <= 50 &&
		/^[a-zA-Z\s'-]+$/.test(name)
	);
}

function validatePassword(password: unknown): password is string {
	return typeof password === 'string' && password.length >= 6 && password.length <= 255;
}

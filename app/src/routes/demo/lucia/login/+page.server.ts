import { hash, verify } from '@node-rs/argon2';
import { fail, redirect } from '@sveltejs/kit';
import { eq } from 'drizzle-orm';
import { getReadDb, getWriteDb, user } from '$lib/server/db';
import { logger } from '$lib/server/logger';
import type { Actions, PageServerLoad } from './$types';
import { generateSessionToken, createSession, setSessionTokenCookie } from '$lib/server/auth';

export const load: PageServerLoad = async (event) => {
	logger.debug('Login page load function called');
	if (event.locals.user) {
		logger.debug('User already authenticated, redirecting', { userId: event.locals.user.id });
		return redirect(302, '/demo/lucia');
	}
	logger.debug('No authenticated user, showing login page');
	return {};
};

export const actions: Actions = {
	login: async (event) => {
		logger.debug('Login action started');

		try {
			const formData = await event.request.formData();
			const email = formData.get('email');
			const password = formData.get('password');

			logger.debug('Form data received', {
				email: email ? 'provided' : 'missing',
				password: password ? 'provided' : 'missing'
			});

			if (!validateEmail(email)) {
				logger.debug('Email validation failed', { email });
				return fail(400, {
					message: 'Invalid email address'
				});
			}
			if (!validatePassword(password)) {
				logger.debug('Password validation failed');
				return fail(400, { message: 'Invalid password (min 6, max 255 characters)' });
			}

			logger.debug('Validation passed, querying database', { email });

			// Query the users table using email
			const results = await getReadDb()
				.select()
				.from(user)
				.where(eq(user.email, email));

			logger.debug('Database query completed', { resultsCount: results.length });

			const existingUser = results.at(0);
			if (!existingUser) {
				logger.debug('User not found in database');
				return fail(400, { message: 'Incorrect email or password' });
			}

			logger.debug('User found, verifying password', { userId: existingUser.id });

			// Verify password against password_hash column
			const validPassword = await verify(existingUser.passwordHash, password, {
				memoryCost: 19456,
				timeCost: 2,
				outputLen: 32,
				parallelism: 1
			});

			logger.debug('Password verification completed', { valid: validPassword });

			if (!validPassword) {
				logger.debug('Password verification failed');
				return fail(400, { message: 'Incorrect email or password' });
			}

			logger.debug('Password verified, creating session');

			const sessionToken = generateSessionToken();
			logger.debug('Session token generated');

			const session = await createSession(sessionToken, existingUser.id);
			logger.debug('Session created', { sessionId: session.id, userId: existingUser.id });

			setSessionTokenCookie(event, sessionToken, session.expiresAt);
			logger.debug('Session cookie set, redirecting');
		} catch (error) {
			logger.error('Login action failed', error);
			return fail(500, { message: 'Internal server error during login' });
		}
		return redirect(302, '/demo/lucia');
	},
	register: async (event) => {
		logger.debug('Register action started');

		try {
			const formData = await event.request.formData();
			const email = formData.get('email');
			const name = formData.get('name');
			const password = formData.get('password');

			logger.debug('Registration form data received', {
				email: email ? 'provided' : 'missing',
				name: name ? 'provided' : 'missing',
				password: password ? 'provided' : 'missing'
			});

			if (!validateEmail(email)) {
				logger.debug('Email validation failed', { email });
				return fail(400, { message: 'Invalid email address' });
			}
			if (!validateName(name)) {
				logger.debug('Name validation failed', { name });
				return fail(400, { message: 'Invalid name (min 2, max 50 characters)' });
			}
			if (!validatePassword(password)) {
				logger.debug('Password validation failed');
				return fail(400, { message: 'Invalid password (min 6, max 255 characters)' });
			}

			logger.debug('Validation passed, checking for existing user');

			// Check if user already exists
			const existingUsers = await getReadDb()
				.select()
				.from(user)
				.where(eq(user.email, email));

			logger.debug('Existing user check completed', { count: existingUsers.length });

			if (existingUsers.length > 0) {
				logger.debug('User already exists');
				return fail(400, { message: 'Email already registered' });
			}

			logger.debug('Hashing password');

			const passwordHash = await hash(password, {
				memoryCost: 19456,
				timeCost: 2,
				outputLen: 32,
				parallelism: 1
			});

			logger.debug('Password hashed, inserting user');

			// Insert into users table with proper columns
			const insertResult = await getWriteDb()
				.insert(user)
				.values({
					email,
					name,
					passwordHash,
					role: 'user' // Default role
				})
				.returning({ id: user.id });

			const userId = insertResult[0].id;
			logger.debug('User inserted', { userId });

			logger.debug('Creating session for new user');

			const sessionToken = generateSessionToken();
			const session = await createSession(sessionToken, userId);

			logger.debug('Session created for new user', { sessionId: session.id, userId });

			setSessionTokenCookie(event, sessionToken, session.expiresAt);
			logger.debug('Registration complete, redirecting');
		} catch (error) {
			logger.error('Registration failed', error);
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

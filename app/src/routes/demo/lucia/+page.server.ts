import * as auth from '$lib/server/auth';
import { fail, redirect } from '@sveltejs/kit';
import { getRequestEvent } from '$app/server';
import { getRedis } from '$lib/server/db';
import type { Actions, PageServerLoad } from './$types';

const REDIS_CONFIG = {
	PAGE_VIEW_PREFIX: 'page_view:',
	CACHE_TTL: 60 * 60 * 24, // 24 hours
	MAX_VIEWS: 5
} as const;

export const load: PageServerLoad = async () => {
	const user = requireLogin();

	// Get current page view count from Redis
	const redis = await getRedis();
	const viewKey = REDIS_CONFIG.PAGE_VIEW_PREFIX + user.id;

	const currentViews = await redis.get(viewKey);
	const viewCount = currentViews ? parseInt(currentViews) : 0;

	// Check if adding 1 would exceed the limit
	let finalViewCount: number;
	let cacheSource: 'redis' | 'database';

	if (viewCount + 1 > REDIS_CONFIG.MAX_VIEWS) {
		// Reset counter and simulate database refresh
		finalViewCount = 1;
		cacheSource = 'database';
		await redis.set(viewKey, '1', { EX: REDIS_CONFIG.CACHE_TTL });
	} else {
		// Increment normally
		finalViewCount = viewCount + 1;
		cacheSource = 'redis';
		await redis.set(viewKey, finalViewCount.toString(), { EX: REDIS_CONFIG.CACHE_TTL });
	}

	return {
		user: {
			...user,
			loginCount: finalViewCount,
			cacheSource
		}
	};
};

export const actions: Actions = {
	logout: async (event) => {
		if (!event.locals.session) {
			return fail(401);
		}
		await auth.invalidateSession(event.locals.session.id);
		auth.deleteSessionTokenCookie(event);

		return redirect(302, '/demo/lucia/login');
	},

	clearCache: async (event) => {
		if (!event.locals.user) {
			return fail(401);
		}

		try {
			const redis = await getRedis();
			const viewKey = REDIS_CONFIG.PAGE_VIEW_PREFIX + event.locals.user.id;
			await redis.del(viewKey);
			return { success: true, message: 'Cache cleared successfully' };
		} catch (error) {
			console.error('Failed to clear cache:', error);
			return fail(500, { message: 'Failed to clear cache' });
		}
	}
};

function requireLogin() {
	const { locals } = getRequestEvent();

	if (!locals.user) {
		return redirect(302, '/demo/lucia/login');
	}

	return locals.user;
}

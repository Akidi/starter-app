import type { RequestHandler } from './$types';
import { getReadDb } from '$lib/server/db';
import { posts, authUsers } from '$lib/server/db/schema';
import { apiSuccess, apiError, handleApiError } from '$lib/utils/api';
import { requireAuth } from '$lib/server/middleware';
import { logger } from '$lib/server/logger';
import { ilike, or, sql } from 'drizzle-orm';

/**
 * GET /api/search
 * Search posts with autocomplete
 */
export const GET: RequestHandler = async (event) => {
	try {
		// Require authentication
		requireAuth(event);

		const query = event.url.searchParams.get('q') || '';
		const limit = parseInt(event.url.searchParams.get('limit') || '10');

		if (query.length < 2) {
			return apiSuccess([]);
		}

		logger.debug('Search API called', { query, limit });

		const db = getReadDb();

		// Search in title and content
		const results = await db
			.select({
				id: posts.id,
				title: posts.title,
				excerpt: posts.excerpt,
				status: posts.status,
				createdAt: posts.createdAt,
				authorName: authUsers.name
			})
			.from(posts)
			.leftJoin(authUsers, sql`${posts.authorId} = ${authUsers.id}`)
			.where(or(ilike(posts.title, `%${query}%`), ilike(posts.content, `%${query}%`))!)
			.limit(limit);

		logger.debug('Search results fetched', { query, count: results.length });

		return apiSuccess(results);
	} catch (error) {
		return handleApiError(error);
	}
};

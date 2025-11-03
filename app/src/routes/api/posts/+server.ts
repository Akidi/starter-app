import type { RequestHandler } from './$types';
import { getReadDb, getWriteDb } from '$lib/server/db';
import { posts } from '$lib/server/db/schema';
import { listPostsSchema, createPostSchema } from '$lib/validations';
import { apiSuccess, handleApiError } from '$lib/utils/api';
import { requireAuth } from '$lib/server/middleware';
import { logger } from '$lib/server/logger';
import { eq, desc, asc, or, ilike, count, and, sql } from 'drizzle-orm';

/**
 * GET /api/posts
 * List posts with pagination, filtering, and sorting
 */
export const GET: RequestHandler = async ({ url }) => {
	try {
		// Parse and validate query parameters
		const params = listPostsSchema.parse({
			page: url.searchParams.get('page'),
			limit: url.searchParams.get('limit'),
			status: url.searchParams.get('status'),
			authorId: url.searchParams.get('authorId'),
			search: url.searchParams.get('search'),
			sortBy: url.searchParams.get('sortBy'),
			sortOrder: url.searchParams.get('sortOrder')
		});

		logger.debug('Fetching posts with params', params);

		const db = getReadDb();

		// Build where conditions
		const conditions = [];

		if (params.status && params.status !== 'all') {
			conditions.push(eq(posts.status, params.status));
		}

		if (params.authorId) {
			conditions.push(eq(posts.authorId, params.authorId));
		}

		if (params.search) {
			conditions.push(
				or(
					ilike(posts.title, `%${params.search}%`),
					ilike(posts.content, `%${params.search}%`)
				)!
			);
		}

		const whereClause = conditions.length > 0 ? and(...conditions) : undefined;

		// Get total count
		const [{ totalCount }] = await db
			.select({ totalCount: count() })
			.from(posts)
			.where(whereClause);

		// Get paginated results
		const sortColumn = posts[params.sortBy];
		const orderBy = params.sortOrder === 'asc' ? asc(sortColumn) : desc(sortColumn);

		const offset = (params.page - 1) * params.limit;

		const results = await db
			.select()
			.from(posts)
			.where(whereClause)
			.orderBy(orderBy)
			.limit(params.limit)
			.offset(offset);

		logger.info('Posts fetched successfully', {
			count: results.length,
			total: totalCount,
			page: params.page
		});

		return apiSuccess(results, {
			page: params.page,
			limit: params.limit,
			total: totalCount,
			hasMore: offset + results.length < totalCount
		});
	} catch (error) {
		return handleApiError(error);
	}
};

/**
 * POST /api/posts
 * Create a new post
 */
export const POST: RequestHandler = async (event) => {
	try {
		// Require authentication
		const user = requireAuth(event);

		// Parse and validate request body
		const body = await event.request.json();
		const data = createPostSchema.parse(body);

		logger.debug('Creating new post', { title: data.title, userId: user.id });

		const db = getWriteDb();

		// Insert new post
		const [newPost] = await db
			.insert(posts)
			.values({
				...data,
				authorId: user.id,
				publishedAt: data.status === 'published' ? new Date() : null
			})
			.returning();

		logger.info('Post created successfully', { postId: newPost.id, title: newPost.title });

		return apiSuccess(newPost, undefined, 201);
	} catch (error) {
		return handleApiError(error);
	}
};

import type { RequestHandler } from './$types';
import { getReadDb, getWriteDb } from '$lib/server/db';
import { posts } from '$lib/server/db/schema';
import { updatePostSchema } from '$lib/validations';
import { apiSuccess, apiError, handleApiError } from '$lib/utils/api';
import { requireAuth, requireOwnership } from '$lib/server/middleware';
import { logger } from '$lib/server/logger';
import { eq } from 'drizzle-orm';

/**
 * GET /api/posts/[id]
 * Get a single post by ID
 */
export const GET: RequestHandler = async ({ params }) => {
	try {
		const { id } = params;

		logger.debug('Fetching post', { postId: id });

		const db = getReadDb();

		const [post] = await db.select().from(posts).where(eq(posts.id, id));

		if (!post) {
			return apiError('Post not found', 404, 'NOT_FOUND');
		}

		logger.debug('Post fetched successfully', { postId: id });

		return apiSuccess(post);
	} catch (error) {
		return handleApiError(error);
	}
};

/**
 * PUT /api/posts/[id]
 * Update a post
 */
export const PUT: RequestHandler = async (event) => {
	try {
		const { id } = event.params;

		// Check if post exists and get it
		const db = getReadDb();
		const [existingPost] = await db.select().from(posts).where(eq(posts.id, id));

		if (!existingPost) {
			return apiError('Post not found', 404, 'NOT_FOUND');
		}

		// Require authentication and ownership
		requireOwnership(event, existingPost.authorId);

		// Parse and validate request body
		const body = await event.request.json();
		const data = updatePostSchema.parse({ ...body, id });

		logger.debug('Updating post', { postId: id });

		const writeDb = getWriteDb();

		// Prepare update data
		const updateData: Record<string, unknown> = {
			...data,
			updatedAt: new Date()
		};

		// If status is changing to published and it wasn't published before
		if (data.status === 'published' && existingPost.status !== 'published') {
			updateData.publishedAt = new Date();
		}

		// Remove id from update data
		delete updateData.id;

		// Update post
		const [updatedPost] = await writeDb
			.update(posts)
			.set(updateData)
			.where(eq(posts.id, id))
			.returning();

		logger.info('Post updated successfully', { postId: id, title: updatedPost.title });

		return apiSuccess(updatedPost);
	} catch (error) {
		return handleApiError(error);
	}
};

/**
 * DELETE /api/posts/[id]
 * Delete a post
 */
export const DELETE: RequestHandler = async (event) => {
	try {
		const { id } = event.params;

		// Check if post exists and get it
		const db = getReadDb();
		const [existingPost] = await db.select().from(posts).where(eq(posts.id, id));

		if (!existingPost) {
			return apiError('Post not found', 404, 'NOT_FOUND');
		}

		// Require authentication and ownership
		requireOwnership(event, existingPost.authorId);

		logger.debug('Deleting post', { postId: id });

		const writeDb = getWriteDb();

		// Delete post
		await writeDb.delete(posts).where(eq(posts.id, id));

		logger.info('Post deleted successfully', { postId: id });

		return apiSuccess({ message: 'Post deleted successfully' });
	} catch (error) {
		return handleApiError(error);
	}
};

import type { Actions, PageServerLoad } from './$types';
import { fail, redirect } from '@sveltejs/kit';
import { getReadDb, getWriteDb } from '$lib/server/db';
import { posts, authUsers } from '$lib/server/db/schema';
import { createPostSchema, updatePostSchema } from '$lib/validations';
import { logger } from '$lib/server/logger';
import { eq, desc, asc, or, ilike, count, and, sql } from 'drizzle-orm';

// Helper to require login for this page
function requireLogin() {
	const { getContext } = require('svelte');
	const { locals } = getContext('event');
	if (!locals.user) return redirect(302, '/demo/lucia/login');
	return locals.user;
}

export const load: PageServerLoad = async (event) => {
	// Require authentication
	if (!event.locals.user) {
		return redirect(302, '/demo/lucia/login');
	}

	const user = event.locals.user;
	const url = event.url;

	// Parse query parameters
	const page = parseInt(url.searchParams.get('page') || '1');
	const limit = parseInt(url.searchParams.get('limit') || '10');
	const search = url.searchParams.get('search') || '';
	const status = url.searchParams.get('status') || 'all';
	const sortBy = (url.searchParams.get('sortBy') || 'createdAt') as
		| 'createdAt'
		| 'updatedAt'
		| 'title';
	const sortOrder = (url.searchParams.get('sortOrder') || 'desc') as 'asc' | 'desc';

	logger.debug('Loading CRUD page', { userId: user.id, page, limit, search, status });

	try {
		const db = getReadDb();

		// Build where conditions
		const conditions = [];

		// Non-admins can only see their own posts
		if (user.role !== 'admin') {
			conditions.push(eq(posts.authorId, user.id));
		}

		if (status && status !== 'all') {
			conditions.push(eq(posts.status, status as 'draft' | 'published' | 'archived'));
		}

		if (search) {
			conditions.push(
				or(ilike(posts.title, `%${search}%`), ilike(posts.content, `%${search}%`))!
			);
		}

		const whereClause = conditions.length > 0 ? and(...conditions) : undefined;

		// Get total count
		const [{ totalCount }] = await db
			.select({ totalCount: count() })
			.from(posts)
			.where(whereClause);

		// Get paginated results with author info
		const sortColumn = posts[sortBy];
		const orderBy = sortOrder === 'asc' ? asc(sortColumn) : desc(sortColumn);
		const offset = (page - 1) * limit;

		const results = await db
			.select({
				post: posts,
				author: {
					id: authUsers.id,
					name: authUsers.name,
					email: authUsers.email
				}
			})
			.from(posts)
			.leftJoin(authUsers, eq(posts.authorId, authUsers.id))
			.where(whereClause)
			.orderBy(orderBy)
			.limit(limit)
			.offset(offset);

		// Get post stats
		const [stats] = await db
			.select({
				total: count(),
				drafts: sql<number>`count(*) filter (where ${posts.status} = 'draft')`,
				published: sql<number>`count(*) filter (where ${posts.status} = 'published')`,
				archived: sql<number>`count(*) filter (where ${posts.status} = 'archived')`
			})
			.from(posts)
			.where(user.role !== 'admin' ? eq(posts.authorId, user.id) : undefined);

		logger.info('CRUD page loaded', {
			userId: user.id,
			postsCount: results.length,
			totalCount
		});

		return {
			user,
			posts: results,
			pagination: {
				page,
				limit,
				total: totalCount,
				hasMore: offset + results.length < totalCount,
				totalPages: Math.ceil(totalCount / limit)
			},
			filters: {
				search,
				status,
				sortBy,
				sortOrder
			},
			stats
		};
	} catch (error) {
		logger.error('Error loading CRUD page', error);
		throw error;
	}
};

export const actions: Actions = {
	/**
	 * Create a new post
	 */
	create: async (event) => {
		if (!event.locals.user) {
			return fail(401, { message: 'Authentication required' });
		}

		const user = event.locals.user;

		try {
			const formData = await event.request.formData();

			const data = createPostSchema.parse({
				title: formData.get('title'),
				slug: formData.get('slug'),
				content: formData.get('content'),
				excerpt: formData.get('excerpt') || undefined,
				status: formData.get('status') || 'draft',
				featured: formData.get('featured') === 'true'
			});

			logger.debug('Creating new post', { title: data.title, userId: user.id });

			const db = getWriteDb();

			const [newPost] = await db
				.insert(posts)
				.values({
					...data,
					authorId: user.id,
					publishedAt: data.status === 'published' ? new Date() : null
				})
				.returning();

			logger.info('Post created successfully', {
				postId: newPost.id,
				title: newPost.title
			});

			return { success: true, post: newPost };
		} catch (error) {
			logger.error('Error creating post', error);
			if (error instanceof Error) {
				return fail(400, { message: error.message });
			}
			return fail(500, { message: 'Failed to create post' });
		}
	},

	/**
	 * Update an existing post
	 */
	update: async (event) => {
		if (!event.locals.user) {
			return fail(401, { message: 'Authentication required' });
		}

		const user = event.locals.user;

		try {
			const formData = await event.request.formData();
			const id = formData.get('id') as string;

			if (!id) {
				return fail(400, { message: 'Post ID is required' });
			}

			// Check if post exists and user has permission
			const db = getReadDb();
			const [existingPost] = await db.select().from(posts).where(eq(posts.id, id));

			if (!existingPost) {
				return fail(404, { message: 'Post not found' });
			}

			if (user.role !== 'admin' && existingPost.authorId !== user.id) {
				return fail(403, { message: 'You do not have permission to edit this post' });
			}

			const data = updatePostSchema.parse({
				id,
				title: formData.get('title'),
				slug: formData.get('slug'),
				content: formData.get('content'),
				excerpt: formData.get('excerpt') || undefined,
				status: formData.get('status'),
				featured: formData.get('featured') === 'true'
			});

			logger.debug('Updating post', { postId: id });

			const writeDb = getWriteDb();

			const updateData: Record<string, unknown> = {
				...data,
				updatedAt: new Date()
			};

			// If status is changing to published and it wasn't published before
			if (data.status === 'published' && existingPost.status !== 'published') {
				updateData.publishedAt = new Date();
			}

			delete updateData.id;

			const [updatedPost] = await writeDb
				.update(posts)
				.set(updateData)
				.where(eq(posts.id, id))
				.returning();

			logger.info('Post updated successfully', { postId: id });

			return { success: true, post: updatedPost };
		} catch (error) {
			logger.error('Error updating post', error);
			if (error instanceof Error) {
				return fail(400, { message: error.message });
			}
			return fail(500, { message: 'Failed to update post' });
		}
	},

	/**
	 * Delete a post
	 */
	delete: async (event) => {
		if (!event.locals.user) {
			return fail(401, { message: 'Authentication required' });
		}

		const user = event.locals.user;

		try {
			const formData = await event.request.formData();
			const id = formData.get('id') as string;

			if (!id) {
				return fail(400, { message: 'Post ID is required' });
			}

			// Check if post exists and user has permission
			const db = getReadDb();
			const [existingPost] = await db.select().from(posts).where(eq(posts.id, id));

			if (!existingPost) {
				return fail(404, { message: 'Post not found' });
			}

			if (user.role !== 'admin' && existingPost.authorId !== user.id) {
				return fail(403, { message: 'You do not have permission to delete this post' });
			}

			logger.debug('Deleting post', { postId: id });

			const writeDb = getWriteDb();
			await writeDb.delete(posts).where(eq(posts.id, id));

			logger.info('Post deleted successfully', { postId: id });

			return { success: true };
		} catch (error) {
			logger.error('Error deleting post', error);
			if (error instanceof Error) {
				return fail(400, { message: error.message });
			}
			return fail(500, { message: 'Failed to delete post' });
		}
	}
};

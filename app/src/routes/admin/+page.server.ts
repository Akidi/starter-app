import type { PageServerLoad } from './$types';
import { getReadDb } from '$lib/server/db';
import { authUsers, userSessions, posts } from '$lib/server/db/schema';
import { logger } from '$lib/server/logger';
import { count, sql, desc } from 'drizzle-orm';

export const load: PageServerLoad = async () => {
	try {
		logger.debug('Loading admin dashboard');

		const db = getReadDb();

		// Get user statistics
		const [userStats] = await db
			.select({
				total: count(),
				admins: sql<number>`count(*) filter (where ${authUsers.role} = 'admin')`,
				moderators: sql<number>`count(*) filter (where ${authUsers.role} = 'moderator')`,
				users: sql<number>`count(*) filter (where ${authUsers.role} = 'user')`
			})
			.from(authUsers);

		// Get post statistics
		const [postStats] = await db
			.select({
				total: count(),
				published: sql<number>`count(*) filter (where ${posts.status} = 'published')`,
				drafts: sql<number>`count(*) filter (where ${posts.status} = 'draft')`,
				archived: sql<number>`count(*) filter (where ${posts.status} = 'archived')`
			})
			.from(posts);

		// Get active sessions count
		const [sessionStats] = await db
			.select({
				total: count(),
				active: sql<number>`count(*) filter (where ${userSessions.expiresAt} > now())`
			})
			.from(userSessions);

		// Get recent users (last 10)
		const recentUsers = await db
			.select({
				id: authUsers.id,
				name: authUsers.name,
				email: authUsers.email,
				role: authUsers.role,
				createdAt: authUsers.createdAt
			})
			.from(authUsers)
			.orderBy(desc(authUsers.createdAt))
			.limit(10);

		// Get recent posts with author info (last 10)
		const recentPosts = await db
			.select({
				id: posts.id,
				title: posts.title,
				status: posts.status,
				createdAt: posts.createdAt,
				authorName: authUsers.name
			})
			.from(posts)
			.leftJoin(authUsers, sql`${posts.authorId} = ${authUsers.id}`)
			.orderBy(desc(posts.createdAt))
			.limit(10);

		logger.info('Admin dashboard loaded successfully');

		return {
			stats: {
				users: userStats,
				posts: postStats,
				sessions: sessionStats
			},
			recentUsers,
			recentPosts
		};
	} catch (error) {
		logger.error('Error loading admin dashboard', error);
		throw error;
	}
};

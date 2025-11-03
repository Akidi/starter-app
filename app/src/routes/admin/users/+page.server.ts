import type { Actions, PageServerLoad } from './$types';
import { fail } from '@sveltejs/kit';
import { getReadDb, getWriteDb } from '$lib/server/db';
import { authUsers, userSessions } from '$lib/server/db/schema';
import { logger } from '$lib/server/logger';
import { eq, desc, or, ilike, count, and } from 'drizzle-orm';

export const load: PageServerLoad = async ({ url }) => {
	// Parse query parameters
	const page = parseInt(url.searchParams.get('page') || '1');
	const limit = parseInt(url.searchParams.get('limit') || '20');
	const search = url.searchParams.get('search') || '';
	const role = url.searchParams.get('role') || 'all';

	logger.debug('Loading admin users page', { page, limit, search, role });

	try {
		const db = getReadDb();

		// Build where conditions
		const conditions = [];

		if (role && role !== 'all') {
			conditions.push(eq(authUsers.role, role as 'admin' | 'user' | 'moderator'));
		}

		if (search) {
			conditions.push(
				or(ilike(authUsers.name, `%${search}%`), ilike(authUsers.email, `%${search}%`))!
			);
		}

		const whereClause = conditions.length > 0 ? and(...conditions) : undefined;

		// Get total count
		const [{ totalCount }] = await db
			.select({ totalCount: count() })
			.from(authUsers)
			.where(whereClause);

		// Get paginated results
		const offset = (page - 1) * limit;

		const users = await db
			.select({
				id: authUsers.id,
				name: authUsers.name,
				email: authUsers.email,
				role: authUsers.role,
				createdAt: authUsers.createdAt,
				updatedAt: authUsers.updatedAt
			})
			.from(authUsers)
			.where(whereClause)
			.orderBy(desc(authUsers.createdAt))
			.limit(limit)
			.offset(offset);

		logger.info('Admin users page loaded', {
			usersCount: users.length,
			totalCount
		});

		return {
			users,
			pagination: {
				page,
				limit,
				total: totalCount,
				hasMore: offset + users.length < totalCount,
				totalPages: Math.ceil(totalCount / limit)
			},
			filters: {
				search,
				role
			}
		};
	} catch (error) {
		logger.error('Error loading admin users page', error);
		throw error;
	}
};

export const actions: Actions = {
	/**
	 * Update user role
	 */
	updateRole: async ({ request }) => {
		try {
			const formData = await request.formData();
			const userId = formData.get('userId') as string;
			const newRole = formData.get('role') as string;

			if (!userId || !newRole) {
				return fail(400, { message: 'User ID and role are required' });
			}

			if (!['admin', 'user', 'moderator'].includes(newRole)) {
				return fail(400, { message: 'Invalid role' });
			}

			logger.debug('Updating user role', { userId, newRole });

			const db = getWriteDb();

			const [updatedUser] = await db
				.update(authUsers)
				.set({ role: newRole as 'admin' | 'user' | 'moderator', updatedAt: new Date() })
				.where(eq(authUsers.id, userId))
				.returning();

			if (!updatedUser) {
				return fail(404, { message: 'User not found' });
			}

			logger.info('User role updated successfully', { userId, newRole });

			return { success: true, user: updatedUser };
		} catch (error) {
			logger.error('Error updating user role', error);
			if (error instanceof Error) {
				return fail(400, { message: error.message });
			}
			return fail(500, { message: 'Failed to update user role' });
		}
	},

	/**
	 * Delete user
	 */
	deleteUser: async ({ request }) => {
		try {
			const formData = await request.formData();
			const userId = formData.get('userId') as string;

			if (!userId) {
				return fail(400, { message: 'User ID is required' });
			}

			logger.debug('Deleting user', { userId });

			const db = getWriteDb();

			// First, delete all user's sessions (cascade should handle this, but being explicit)
			await db.delete(userSessions).where(eq(userSessions.userId, userId));

			// Then delete the user
			await db.delete(authUsers).where(eq(authUsers.id, userId));

			logger.info('User deleted successfully', { userId });

			return { success: true };
		} catch (error) {
			logger.error('Error deleting user', error);
			if (error instanceof Error) {
				return fail(400, { message: error.message });
			}
			return fail(500, { message: 'Failed to delete user' });
		}
	}
};

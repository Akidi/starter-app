import type { RequestEvent } from '@sveltejs/kit';
import { apiError } from '$lib/utils/api';
import type { User } from '$lib/server/db/schema';

/**
 * Require authentication for API routes
 * Returns the authenticated user or throws an error response
 */
export function requireAuth(event: RequestEvent): User {
	const user = event.locals.user;

	if (!user) {
		throw apiError('Authentication required', 401, 'UNAUTHORIZED');
	}

	return user;
}

/**
 * Require specific role for API routes
 * Returns the authenticated user or throws an error response
 */
export function requireRole(event: RequestEvent, allowedRoles: string[]): User {
	const user = requireAuth(event);

	if (!allowedRoles.includes(user.role)) {
		throw apiError('Insufficient permissions', 403, 'FORBIDDEN');
	}

	return user;
}

/**
 * Check if user owns a resource
 */
export function requireOwnership(event: RequestEvent, resourceUserId: string): User {
	const user = requireAuth(event);

	// Admins can access any resource
	if (user.role === 'admin') {
		return user;
	}

	// Check ownership
	if (user.id !== resourceUserId) {
		throw apiError('You do not have permission to access this resource', 403, 'FORBIDDEN');
	}

	return user;
}

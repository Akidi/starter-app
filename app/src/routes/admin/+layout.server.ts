import type { LayoutServerLoad } from './$types';
import { redirect } from '@sveltejs/kit';

export const load: LayoutServerLoad = async ({ locals }) => {
	// Require authentication
	if (!locals.user) {
		return redirect(302, '/demo/lucia/login');
	}

	// Require admin role
	if (locals.user.role !== 'admin') {
		return redirect(302, '/?error=forbidden');
	}

	return {
		user: locals.user
	};
};

/**
 * Paraglide i18n server middleware stub
 * This is a placeholder until paraglide is properly initialized with message files
 */

import type { RequestEvent } from '@sveltejs/kit';

interface MiddlewareContext {
	request: Request;
	locale: string;
}

export function paraglideMiddleware(
	request: Request,
	callback: (context: MiddlewareContext) => Response | Promise<Response>
): Response | Promise<Response> {
	// Stub implementation - just passes through with default locale
	return callback({
		request,
		locale: 'en'
	});
}

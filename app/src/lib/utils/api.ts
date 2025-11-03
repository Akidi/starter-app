import { json, type NumericRange } from '@sveltejs/kit';
import { ZodError } from 'zod';
import { logger } from '$lib/server/logger';

// Standard API response types
export interface ApiResponse<T = unknown> {
	data?: T;
	error?: {
		message: string;
		code?: string;
		details?: unknown;
	};
	meta?: {
		page?: number;
		limit?: number;
		total?: number;
		hasMore?: boolean;
	};
}

// Success response helper
export function apiSuccess<T>(
	data: T,
	meta?: ApiResponse<T>['meta'],
	status: NumericRange<200, 299> = 200
) {
	return json<ApiResponse<T>>({ data, meta }, { status });
}

// Error response helper
export function apiError(
	message: string,
	status: NumericRange<400, 599> = 400,
	code?: string,
	details?: unknown
) {
	return json<ApiResponse>(
		{
			error: {
				message,
				code,
				details
			}
		},
		{ status }
	);
}

// Validation error helper (for Zod errors)
export function apiValidationError(error: ZodError) {
	const details = error.errors.map((e) => ({
		path: e.path.join('.'),
		message: e.message
	}));

	return json<ApiResponse>(
		{
			error: {
				message: 'Validation failed',
				code: 'VALIDATION_ERROR',
				details
			}
		},
		{ status: 400 }
	);
}

// Generic error handler
export function handleApiError(error: unknown) {
	logger.error('API error occurred', error);

	if (error instanceof ZodError) {
		return apiValidationError(error);
	}

	if (error instanceof Error) {
		return apiError(error.message, 500, 'INTERNAL_ERROR');
	}

	return apiError('An unexpected error occurred', 500, 'UNKNOWN_ERROR');
}

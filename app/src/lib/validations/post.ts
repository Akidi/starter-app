import { z } from 'zod';

// Base post schema
export const postSchema = z.object({
	title: z
		.string()
		.min(3, 'Title must be at least 3 characters')
		.max(200, 'Title must be less than 200 characters'),
	slug: z
		.string()
		.min(3, 'Slug must be at least 3 characters')
		.max(200, 'Slug must be less than 200 characters')
		.regex(/^[a-z0-9-]+$/, 'Slug must only contain lowercase letters, numbers, and hyphens'),
	content: z.string().min(10, 'Content must be at least 10 characters'),
	excerpt: z.string().max(500, 'Excerpt must be less than 500 characters').optional(),
	status: z.enum(['draft', 'published', 'archived']).default('draft'),
	featured: z.boolean().default(false)
});

// Schema for creating a new post (without authorId - will be set from session)
export const createPostSchema = postSchema;

// Schema for updating a post (all fields optional except id)
export const updatePostSchema = postSchema.partial().extend({
	id: z.string().min(1, 'Post ID is required')
});

// Schema for pagination and filtering
export const listPostsSchema = z.object({
	page: z.coerce.number().int().min(1).default(1),
	limit: z.coerce.number().int().min(1).max(100).default(10),
	status: z.enum(['draft', 'published', 'archived', 'all']).optional(),
	authorId: z.string().optional(),
	search: z.string().optional(),
	sortBy: z.enum(['createdAt', 'updatedAt', 'publishedAt', 'title']).default('createdAt'),
	sortOrder: z.enum(['asc', 'desc']).default('desc')
});

// Type exports
export type PostInput = z.infer<typeof postSchema>;
export type CreatePostInput = z.infer<typeof createPostSchema>;
export type UpdatePostInput = z.infer<typeof updatePostSchema>;
export type ListPostsInput = z.infer<typeof listPostsSchema>;

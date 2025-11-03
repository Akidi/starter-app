import { z } from 'zod';

// Email validation
export const emailSchema = z
	.string()
	.email('Invalid email address')
	.min(3, 'Email must be at least 3 characters')
	.max(255, 'Email must be less than 255 characters');

// Password validation
export const passwordSchema = z
	.string()
	.min(6, 'Password must be at least 6 characters')
	.max(255, 'Password must be less than 255 characters');

// Login schema
export const loginSchema = z.object({
	email: emailSchema,
	password: passwordSchema
});

// Registration schema
export const registerSchema = z.object({
	name: z
		.string()
		.min(2, 'Name must be at least 2 characters')
		.max(100, 'Name must be less than 100 characters'),
	email: emailSchema,
	password: passwordSchema
});

// Type exports
export type LoginInput = z.infer<typeof loginSchema>;
export type RegisterInput = z.infer<typeof registerSchema>;

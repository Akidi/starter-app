// src/lib/server/db/auth/schema.ts
import { text, timestamp, pgEnum, jsonb, inet, boolean, pgSchema } from 'drizzle-orm/pg-core';
import { sql } from 'drizzle-orm';

// Define the auth schema
export const authSchema = pgSchema('auth');

// Create enum for user roles in the auth schema
export const userRoleEnum = pgEnum('user_role', ['admin', 'user', 'moderator']);

// Auth schema tables
export const user = authSchema.table(
	'users',
	{
		id: text('id')
			.primaryKey()
			.default(sql`cuid()`),
		name: text('name').notNull(),
		email: text('email').notNull().unique(),
		passwordHash: text('password_hash').notNull(),
		role: userRoleEnum('role').notNull().default('user'),
		createdAt: timestamp('created_at', { withTimezone: true }).defaultNow(),
		updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow()
	},
	(table) => ({
		// Add constraint for password hash length
		passwordMinLength: sql`CONSTRAINT password_min_length CHECK (length(${table.passwordHash}) > 30)`
	})
);

export const userRoles = authSchema.table('user_roles', {
	id: text('id')
		.primaryKey()
		.default(sql`cuid()`),
	name: text('name').notNull().unique(),
	description: text('description'),
	permissions: jsonb('permissions').default(sql`'[]'::jsonb`),
	createdAt: timestamp('created_at', { withTimezone: true }).defaultNow()
});

export const userRoleAssignments = authSchema.table(
	'user_role_assignments',
	{
		id: text('id')
			.primaryKey()
			.default(sql`cuid()`),
		userId: text('user_id')
			.notNull()
			.references(() => user.id, { onDelete: 'cascade' }),
		roleId: text('role_id')
			.notNull()
			.references(() => userRoles.id, { onDelete: 'cascade' }),
		assignedBy: text('assigned_by').references(() => user.id),
		assignedAt: timestamp('assigned_at', { withTimezone: true }).defaultNow()
	},
	(table) => ({
		// Unique constraint to prevent duplicate role assignments
		uniqueUserRole: sql`UNIQUE(${table.userId}, ${table.roleId})`
	})
);

export const session = authSchema.table('user_sessions', {
	id: text('id')
		.primaryKey()
		.default(sql`cuid()`),
	userId: text('user_id')
		.notNull()
		.references(() => user.id, { onDelete: 'cascade' }),
	sessionToken: text('session_token').notNull().unique(),
	expiresAt: timestamp('expires_at', { withTimezone: true }).notNull(),
	createdAt: timestamp('created_at', { withTimezone: true }).defaultNow(),
	lastAccessed: timestamp('last_accessed', { withTimezone: true }).defaultNow(),
	ipAddress: inet('ip_address'),
	userAgent: text('user_agent')
});

export const apiKeys = authSchema.table('api_keys', {
	id: text('id')
		.primaryKey()
		.default(sql`cuid()`),
	userId: text('user_id')
		.notNull()
		.references(() => user.id, { onDelete: 'cascade' }),
	keyHash: text('key_hash').notNull().unique(),
	name: text('name').notNull(),
	permissions: jsonb('permissions').default(sql`'[]'::jsonb`),
	expiresAt: timestamp('expires_at', { withTimezone: true }),
	lastUsed: timestamp('last_used', { withTimezone: true }),
	isActive: boolean('is_active').default(true),
	createdAt: timestamp('created_at', { withTimezone: true }).defaultNow()
});

// Types for TypeScript
export type User = typeof user.$inferSelect;
export type NewUser = typeof user.$inferInsert;
export type Session = typeof session.$inferSelect;
export type NewSession = typeof session.$inferInsert;

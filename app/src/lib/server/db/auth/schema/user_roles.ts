import { jsonb, text, timestamp } from 'drizzle-orm/pg-core';
import { sql } from 'drizzle-orm';
import { authSchema } from './base';

export const userRoles = authSchema.table('user_roles', {
	id: text('id')
		.primaryKey()
		.default(sql`cuid()`),
	name: text('name').notNull().unique(),
	description: text('description'),
	permissions: jsonb('permissions').default(sql`'[]'::jsonb`),
	createdAt: timestamp('created_at', { withTimezone: true }).defaultNow()
});

import { text, timestamp, boolean } from 'drizzle-orm/pg-core';
import { sql } from 'drizzle-orm';
import { contentSchema, postStatusEnum } from './base';
import { user } from '../auth/user';

export const post = contentSchema.table('posts', {
	id: text('id')
		.primaryKey()
		.default(sql`cuid()`),
	title: text('title').notNull(),
	slug: text('slug').notNull().unique(),
	content: text('content').notNull(),
	excerpt: text('excerpt'),
	status: postStatusEnum('status').notNull().default('draft'),
	featured: boolean('featured').notNull().default(false),
	authorId: text('author_id')
		.notNull()
		.references(() => user.id, { onDelete: 'cascade' }),
	publishedAt: timestamp('published_at', { withTimezone: true }),
	createdAt: timestamp('created_at', { withTimezone: true }).defaultNow(),
	updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow()
});

export type Post = typeof post.$inferSelect;
export type NewPost = typeof post.$inferInsert;

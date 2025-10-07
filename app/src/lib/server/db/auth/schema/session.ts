import { inet, text, timestamp } from 'drizzle-orm/pg-core';
import { sql } from 'drizzle-orm';
import { authSchema } from './base';
import { user } from './user';

export const session = authSchema.table('user_sessions', {
  id: text('id').primaryKey().default(sql`cuid()`),
  userId: text('user_id')
    .notNull()
    .references(() => user.id, { onDelete: 'cascade' }),
  sessionToken: text('session_token').notNull().unique(),
  expiresAt: timestamp('expires_at', { withTimezone: true }).notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow(),
  lastAccessed: timestamp('last_accessed', { withTimezone: true }).defaultNow(),
  ipAddress: inet('ip_address'),
  userAgent: text('user_agent'),
});

export type Session = typeof session.$inferSelect;
export type NewSession = typeof session.$inferInsert;


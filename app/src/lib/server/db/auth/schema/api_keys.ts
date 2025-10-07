import { boolean, jsonb, text, timestamp } from 'drizzle-orm/pg-core';
import { sql } from 'drizzle-orm';
import { authSchema } from './base';
import { user } from './user';

export const apiKeys = authSchema.table('api_keys', {
  id: text('id').primaryKey().default(sql`cuid()`),
  userId: text('user_id')
    .notNull()
    .references(() => user.id, { onDelete: 'cascade' }),
  keyHash: text('key_hash').notNull().unique(),
  name: text('name').notNull(),
  permissions: jsonb('permissions').default(sql`'[]'::jsonb`),
  expiresAt: timestamp('expires_at', { withTimezone: true }),
  lastUsed: timestamp('last_used', { withTimezone: true }),
  isActive: boolean('is_active').default(true),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow(),
});


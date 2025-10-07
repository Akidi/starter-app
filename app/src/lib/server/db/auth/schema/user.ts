import { text, timestamp } from 'drizzle-orm/pg-core';
import { sql } from 'drizzle-orm';
import { authSchema, userRoleEnum } from './base';

export const user = authSchema.table(
  'users',
  {
    id: text('id').primaryKey().default(sql`cuid()`),
    name: text('name').notNull(),
    email: text('email').notNull().unique(),
    passwordHash: text('password_hash').notNull(),
    role: userRoleEnum('role').notNull().default('user'),
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow(),
    updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow(),
  },
  (table) => [sql`CONSTRAINT password_min_length CHECK (length(${table.passwordHash}) > 30)`]
);

export type User = typeof user.$inferSelect;
export type NewUser = typeof user.$inferInsert;


import { pgEnum, pgSchema } from 'drizzle-orm/pg-core';

// Shared auth schema and enums
export const authSchema = pgSchema('auth');

export const userRoleEnum = pgEnum('user_role', ['admin', 'user', 'moderator']);

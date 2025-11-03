import { pgEnum, pgSchema } from 'drizzle-orm/pg-core';

// Shared content schema and enums
export const contentSchema = pgSchema('content');

export const postStatusEnum = pgEnum('post_status', ['draft', 'published', 'archived']);

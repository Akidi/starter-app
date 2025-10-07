// src/lib/server/db/schema.ts
// Main schema index file that exports all schemas

// Export everything from auth schema
export * as auth from './auth/schema/index';

// Export everything from other schemas (when you create them)
// export * as inventory from './inventory/schema';
// export * as billing from './billing/schema';
// export * as migrations from './migrations/schema';

// For backwards compatibility, also export auth tables directly
export {
	user as authUsers,
	session as userSessions,
	userRoles,
	userRoleAssignments,
	apiKeys
} from './auth/schema/index';

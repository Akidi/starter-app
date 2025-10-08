import { text, timestamp } from 'drizzle-orm/pg-core';
import { sql } from 'drizzle-orm';
import { authSchema } from './base';
import { user } from './user';
import { userRoles } from './user_roles';

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
	(table) => [sql`UNIQUE(${table.userId}, ${table.roleId})`]
);

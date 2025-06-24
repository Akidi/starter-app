// src/lib/server/db/seed.ts
import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import { hash } from '@node-rs/argon2';
import * as schema from './schema.js';

// Use environment variables or fallback
const DATABASE_URL = process.env.DATABASE_URL || 'postgres://archon:password@localhost:5432/bp';

const client = postgres(DATABASE_URL);
const db = drizzle(client, { schema });

async function seed() {
	console.log('🌱 Seeding database...');

	try {
		// Hash passwords
		const adminPassword = await hash('wXBPPNmrAZ5pAlxKKznCKp_aBmOioOwL', {
			memoryCost: 19456,
			timeCost: 2,
			outputLen: 32,
			parallelism: 1
		});

		const devPassword = await hash('KdzjHnc8t805o2RK-DwryQealNcqOdPf', {
			memoryCost: 19456,
			timeCost: 2,
			outputLen: 32,
			parallelism: 1
		});

		// Insert users
		await db
			.insert(schema.authUsers)
			.values([
				{
					email: 'admin@bp.local',
					name: 'System Administrator',
					passwordHash: adminPassword,
					role: 'admin'
				},
				{
					email: 'developer@bp.local',
					name: 'Lead Developer',
					passwordHash: devPassword,
					role: 'user'
				}
			])
			.onConflictDoNothing();

		// Insert user roles
		await db
			.insert(schema.userRoles)
			.values([
				{
					name: 'super_admin',
					description: 'Super Administrator with full system access',
					permissions: [
						'users:create',
						'users:read',
						'users:update',
						'users:delete',
						'roles:manage',
						'system:configure',
						'audit:view'
					]
				},
				{
					name: 'admin',
					description: 'Administrator with user management access',
					permissions: ['users:create', 'users:read', 'users:update', 'roles:assign', 'audit:view']
				},
				{
					name: 'developer',
					description: 'Developer with development and testing access',
					permissions: [
						'users:read',
						'data:create',
						'data:read',
						'data:update',
						'data:delete',
						'system:debug'
					]
				}
			])
			.onConflictDoNothing();

		console.log('✅ Database seeded successfully!');
	} catch (error) {
		console.error('❌ Error seeding database:', error);
		throw error;
	} finally {
		await client.end();
	}
}

seed().catch((error) => {
	console.error(error);
	process.exit(1);
});

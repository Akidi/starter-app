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
		const [adminUser, devUser] = await db
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
			.onConflictDoNothing()
			.returning();

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

		// Insert demo posts (only if we have users)
		if (adminUser || devUser) {
			const authorId = adminUser?.id || devUser?.id;

			if (authorId) {
				await db
					.insert(schema.posts)
					.values([
						{
							title: 'Getting Started with the Starter App',
							slug: 'getting-started',
							content:
								'Welcome to the starter app! This is a comprehensive SvelteKit template with authentication, CRUD operations, and more. Explore the demos to see what\'s possible.',
							excerpt: 'Learn the basics of using this starter application',
							status: 'published',
							featured: true,
							authorId,
							publishedAt: new Date()
						},
						{
							title: 'Understanding the Database Architecture',
							slug: 'database-architecture',
							content:
								'This app uses PostgreSQL with Drizzle ORM. We have separate read and write connections for optimal performance. The database includes specialized roles for different operations.',
							excerpt: 'Deep dive into the database setup and connection strategy',
							status: 'published',
							authorId,
							publishedAt: new Date(Date.now() - 86400000) // 1 day ago
						},
						{
							title: 'Authentication and Session Management',
							slug: 'auth-sessions',
							content:
								'Session-based authentication is implemented using httpOnly cookies. Sessions are stored in PostgreSQL with automatic expiration and refresh.',
							excerpt: 'How authentication works in this application',
							status: 'published',
							authorId,
							publishedAt: new Date(Date.now() - 172800000) // 2 days ago
						},
						{
							title: 'Working with the CRUD Demo',
							slug: 'crud-demo-guide',
							content:
								'The CRUD demo showcases pagination, filtering, sorting, and full create/read/update/delete operations. It demonstrates best practices for data tables.',
							excerpt: 'Complete guide to the CRUD demonstration',
							status: 'published',
							authorId,
							publishedAt: new Date(Date.now() - 259200000) // 3 days ago
						},
						{
							title: 'File Upload Best Practices',
							slug: 'file-upload-practices',
							content:
								'Learn how to implement secure file uploads with validation, previews, and proper server-side handling. This demo shows drag-and-drop functionality.',
							excerpt: 'Implementing file uploads the right way',
							status: 'published',
							authorId,
							publishedAt: new Date(Date.now() - 345600000) // 4 days ago
						},
						{
							title: 'Building Multi-Step Forms',
							slug: 'multi-step-forms',
							content:
								'Multi-step forms require careful state management and validation. This demo shows progress tracking, back/forward navigation, and per-step validation.',
							excerpt: 'Creating wizard-style forms with progressive disclosure',
							status: 'draft',
							authorId
						},
						{
							title: 'Search and Autocomplete Implementation',
							slug: 'search-autocomplete',
							content:
								'Implement debounced search with keyboard navigation and result highlighting. Learn about performance optimization and UX best practices.',
							excerpt: 'Building a responsive search experience',
							status: 'draft',
							authorId
						},
						{
							title: 'Admin Panel Design Patterns',
							slug: 'admin-panel-patterns',
							content:
								'The admin panel demonstrates role-based access control, user management, and statistics dashboards. Learn how to protect routes and manage permissions.',
							excerpt: 'Creating admin interfaces with RBAC',
							status: 'published',
							authorId,
							publishedAt: new Date(Date.now() - 432000000) // 5 days ago
						},
						{
							title: 'Testing Strategies for SvelteKit',
							slug: 'testing-strategies',
							content:
								'Comprehensive testing includes component tests, E2E tests, and API tests. Learn about Vitest, Playwright, and Testing Library.',
							excerpt: 'How to test your SvelteKit application effectively',
							status: 'archived',
							authorId
						},
						{
							title: 'Deploying to Production',
							slug: 'production-deployment',
							content:
								'Production deployment involves Docker, environment configuration, database migrations, and monitoring. Follow the deployment guide for best practices.',
							excerpt: 'Steps to deploy your application to production',
							status: 'published',
							featured: true,
							authorId,
							publishedAt: new Date(Date.now() - 518400000) // 6 days ago
						}
					])
					.onConflictDoNothing();

				console.log('✅ Demo posts seeded successfully!');
			}
		}

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

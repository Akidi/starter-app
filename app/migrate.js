#!/usr/bin/env node
// migrate.js - Simple migration runner for production

import { readdir, readFile } from 'fs/promises';
import { join } from 'path';
import postgres from 'postgres';

async function runMigrations() {
	if (!process.env.DATABASE_URL) {
		console.error('DATABASE_URL not provided');
		process.exit(1);
	}

	const client = postgres(process.env.DATABASE_URL);

	try {
		console.log('🔄 Starting migration process...');

		// Create migrations tracking table
		await client`
      CREATE TABLE IF NOT EXISTS __drizzle_migrations__ (
        id SERIAL PRIMARY KEY,
        hash TEXT NOT NULL,
        created_at BIGINT NOT NULL
      )
    `;

		// Read migration files
		const migrationDir = join(__dirname, 'drizzle');
		const files = await readdir(migrationDir);
		const sqlFiles = files.filter((file) => file.endsWith('.sql')).sort();

		if (sqlFiles.length === 0) {
			console.log('ℹ️  No migration files found');
			return;
		}

		// Get applied migrations
		const applied = await client`
      SELECT hash FROM __drizzle_migrations__
    `;
		const appliedHashes = new Set(applied.map((row) => row.hash));

		// Apply pending migrations
		for (const file of sqlFiles) {
			const filePath = join(migrationDir, file);
			const sql = await readFile(filePath, 'utf-8');

			// Create a simple hash for the file (filename + first 100 chars)
			const hash = file + sql.substring(0, 100);

			if (appliedHashes.has(hash)) {
				console.log(`⏭️  Skipping ${file} (already applied)`);
				continue;
			}

			console.log(`📦 Applying ${file}...`);

			// Execute in transaction
			await client.begin(async (tx) => {
				// Split on statement breakpoint and execute each statement
				const statements = sql
					.split('--> statement-breakpoint')
					.map((stmt) => stmt.trim())
					.filter((stmt) => stmt && !stmt.startsWith('--'));

				for (const statement of statements) {
					await tx.unsafe(statement);
				}

				// Record migration
				await tx`
          INSERT INTO __drizzle_migrations__ (hash, created_at)
          VALUES (${hash}, ${Date.now()})
        `;
			});

			console.log(`✅ Applied ${file}`);
		}

		console.log('🎉 All migrations completed successfully');
	} catch (error) {
		console.error('❌ Migration failed:', error);
		process.exit(1);
	} finally {
		await client.end();
	}
}

// Run if called directly
if (require.main === module) {
	runMigrations();
}

export default { runMigrations };

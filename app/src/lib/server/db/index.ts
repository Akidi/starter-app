// src/lib/server/db/index.ts
import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import Redis from 'ioredis';
import * as schema from './auth/schema';
import { env } from '$env/dynamic/private';

let writeDb: ReturnType<typeof drizzle> | null = null;
let readDb: ReturnType<typeof drizzle> | null = null;
let redis: Redis | null = null;

export const getWriteDb = () => {
	if (!env.WRITE_DATABASE_URL) {
		throw new Error('WRITE_DATABASE_URL is not set');
	}

	if (!writeDb) {
		// Use app_api for write operations (can read/write application data)
		const writeUrl = env.WRITE_DATABASE_URL || env.DATABASE_URL;

		const client = postgres(writeUrl, {
			max: 10, // Smaller pool for writes
			idle_timeout: 20,
			connect_timeout: 10
		});
		writeDb = drizzle(client, { schema });
	}
	console.log('Connecting to write database as tinkerer user');

	return writeDb;
};

export const getReadDb = () => {
	if (!env.READ_DATABASE_URL) {
		throw new Error('READ_DATABASE_URL is not set');
	}

	if (!readDb) {
		// Use app_readonly for read operations (read-only access)
		const readUrl = env.READ_DATABASE_URL || env.DATABASE_URL;

		const client = postgres(readUrl, {
			max: 20, // Larger pool for reads
			idle_timeout: 30,
			connect_timeout: 10,
			prepare: false // Better for read-only workloads
		});
		readDb = drizzle(client, { schema });
	}
	console.log('Connecting to read database as lorekeeper user');

	return readDb;
};

export const getRedis = () => {
	if (!env.REDIS_URL) {
		throw new Error('REDIS_URL is not set');
	}

	if (!redis) {
		redis = new Redis(env.REDIS_URL, {
			maxRetriesPerRequest: 3,
			connectTimeout: 10000,
			commandTimeout: 5000,
			lazyConnect: true,
			enableAutoPipelining: true
		});
	}

	return redis;
};

// Convenience function - defaults to write DB for backwards compatibility
export const getDb = () => getWriteDb();

// Export schema and types
export * from './auth/schema';
export type { User, Session } from './auth/schema';

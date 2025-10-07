import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import { createClient } from 'redis';
import * as schema from './auth/schema/index';
import { env } from '$env/dynamic/private';

let writeDb: ReturnType<typeof drizzle> | null = null;
let readDb: ReturnType<typeof drizzle> | null = null;
let redis: ReturnType<typeof createClient> | null = null;

export const getWriteDb = () => {
	if (!env.WRITE_DATABASE_URL) {
		throw new Error('WRITE_DATABASE_URL is not set');
	}

	if (!writeDb) {
		console.log('Connecting to write database as tinkerer user');

		// Use app_api for write operations (can read/write application data)
		const writeUrl = env.WRITE_DATABASE_URL;

		const client = postgres(writeUrl, {
			max: 10, // Smaller pool for writes
			idle_timeout: 20,
			connect_timeout: 10
		});
		writeDb = drizzle(client, { schema });
	}

	return writeDb;
};

export const getReadDb = () => {
	if (!env.READ_DATABASE_URL || !env.DATABASE_URL) {
		throw new Error('READ_DATABASE_URL is not set');
	}

	if (!readDb) {
		console.log('Connecting to read database as lorekeeper user');

		// Use app_readonly for read operations (read-only access)
		const readUrl = env.READ_DATABASE_URL;

		const client = postgres(readUrl, {
			max: 20, // Larger pool for reads
			idle_timeout: 30,
			connect_timeout: 10,
			prepare: false // Better for read-only workloads
		});
		readDb = drizzle(client, { schema });
	}

	return readDb;
};

export const getRedis = async () => {
	if (!env.REDIS_URL) {
		throw new Error('REDIS_URL is not set');
	}

	if (!redis) {
		const url = new URL(env.REDIS_URL);

		console.log('Redis connection attempt:', {
			host: url.hostname,
			port: url.port,
			username: url.username,
			hasPassword: !!url.password
		});

		redis = createClient({
			url: env.REDIS_URL,
			username: url.username || 'default',
			password: url.password || undefined,
			socket: {
				connectTimeout: 10000,
				keepAlive: true,
				reconnectStrategy: (retries) => {
					if (retries > 3) return new Error('Max retries reached');
					return Math.min(retries * 100, 3000);
				}
			}
		});

		redis.on('error', (err) => console.error('Redis Client Error', err));
		redis.on('connect', () => console.log('Redis client connected'));
		redis.on('ready', () => console.log('Redis client ready'));
		redis.on('reconnecting', (params) =>
			console.warn('Redis client reconnecting', params)
		);
		redis.on('end', () => console.warn('Redis connection closed'));

		await redis.connect();
	}

	return redis;
};

// Convenience function - defaults to write DB for backwards compatibility
export const getDb = () => getWriteDb();

// Export schema and types
export * from './auth/schema/index';

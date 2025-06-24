// src/routes/health/+server.ts
import type { RequestHandler } from '@sveltejs/kit';
import { getDb } from '$lib/server/db';
import { sql } from 'drizzle-orm';

export const GET: RequestHandler = async () => {
	try {
		await getDb().execute(sql`SELECT 1`);
		return new Response(JSON.stringify({ status: 'ok' }), {
			status: 200,
			headers: { 'Content-Type': 'application/json' }
		});
	} catch (e) {
		return new Response(JSON.stringify({ status: 'error', message: (e as Error).message }), {
			status: 500,
			headers: { 'Content-Type': 'application/json' }
		});
	}
};

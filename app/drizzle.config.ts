import { defineConfig } from 'drizzle-kit';
import { config } from 'dotenv';
import { existsSync } from 'fs';
import { resolve } from 'path';

const envKey = process.env.DRIZZLE_ENV || process.env.NODE_ENV || 'dev';
const envFiles = [`.env.${envKey}`, '.env'];
const searchRoots: string[] = [];
let current = process.cwd();
for (let i = 0; i < 3; i += 1) {
	searchRoots.push(current);
	const parent = resolve(current, '..');
	if (parent === current) {
		break;
	}
	current = parent;
}

for (const root of searchRoots) {
	for (const file of envFiles) {
		const fullPath = resolve(root, file);
		if (existsSync(fullPath)) {
			config({ path: fullPath, override: false });
		}
	}
}

export default defineConfig({
	schema: './src/lib/server/db/schema.ts',
	dialect: 'postgresql',
	dbCredentials: {
		url: process.env.DATABASE_URL || ''
	},
	verbose: true,
	strict: true,
	schemaFilter: ['auth']
});

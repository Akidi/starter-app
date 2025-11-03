import type { Actions, PageServerLoad } from './$types';
import { fail, redirect } from '@sveltejs/kit';
import { logger } from '$lib/server/logger';
import { writeFile, mkdir } from 'fs/promises';
import { existsSync } from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const UPLOAD_DIR = path.join(__dirname, '../../../../../../uploads');
const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB
const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];

export const load: PageServerLoad = async ({ locals }) => {
	// Require authentication
	if (!locals.user) {
		return redirect(302, '/demo/lucia/login');
	}

	return {
		user: locals.user
	};
};

export const actions: Actions = {
	upload: async ({ request, locals }) => {
		if (!locals.user) {
			return fail(401, { message: 'Authentication required' });
		}

		try {
			const formData = await request.formData();
			const file = formData.get('file') as File;

			if (!file || file.size === 0) {
				return fail(400, { message: 'No file provided' });
			}

			// Validate file size
			if (file.size > MAX_FILE_SIZE) {
				return fail(400, {
					message: `File too large. Maximum size is ${MAX_FILE_SIZE / 1024 / 1024}MB`
				});
			}

			// Validate file type
			if (!ALLOWED_TYPES.includes(file.type)) {
				return fail(400, {
					message: `Invalid file type. Allowed types: ${ALLOWED_TYPES.join(', ')}`
				});
			}

			logger.debug('Processing file upload', {
				userId: locals.user.id,
				fileName: file.name,
				fileSize: file.size,
				fileType: file.type
			});

			// Ensure upload directory exists
			if (!existsSync(UPLOAD_DIR)) {
				await mkdir(UPLOAD_DIR, { recursive: true });
			}

			// Generate unique filename
			const timestamp = Date.now();
			const randomString = Math.random().toString(36).substring(2, 15);
			const ext = path.extname(file.name);
			const filename = `${timestamp}-${randomString}${ext}`;
			const filepath = path.join(UPLOAD_DIR, filename);

			// Convert file to buffer and write to disk
			const buffer = Buffer.from(await file.arrayBuffer());
			await writeFile(filepath, buffer);

			logger.info('File uploaded successfully', {
				userId: locals.user.id,
				filename,
				originalName: file.name,
				size: file.size
			});

			return {
				success: true,
				file: {
					name: file.name,
					size: file.size,
					type: file.type,
					savedAs: filename,
					url: `/uploads/${filename}`
				}
			};
		} catch (error) {
			logger.error('Error uploading file', error);
			if (error instanceof Error) {
				return fail(500, { message: error.message });
			}
			return fail(500, { message: 'Failed to upload file' });
		}
	}
};

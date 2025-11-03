import { test, expect } from '@playwright/test';

// Helper function to login before tests
async function login(page: any) {
	await page.goto('/demo/lucia/login');

	const timestamp = Date.now();
	const testEmail = `crud.test.${timestamp}@example.com`;
	const testPassword = 'TestPass123!';

	// Register a new user
	await page.getByLabel(/name/i).nth(1).fill('CRUD Test User');
	await page.getByLabel(/email/i).nth(1).fill(testEmail);
	await page.getByLabel(/password/i).nth(1).fill(testPassword);
	await page.getByRole('button', { name: /create account/i }).click();

	await page.waitForURL(/\/demo\/lucia/);
}

test.describe('CRUD Operations', () => {
	test('should display CRUD page when authenticated', async ({ page }) => {
		await login(page);
		await page.goto('/demo/crud');

		await expect(page).toHaveTitle(/crud/i);
		await expect(page.getByRole('heading', { name: /posts management/i })).toBeVisible();
	});

	test('should redirect to login when not authenticated', async ({ page }) => {
		await page.goto('/demo/crud');

		// Should redirect to login
		await expect(page).toHaveURL(/\/demo\/lucia\/login/);
	});

	test('should create a new post', async ({ page }) => {
		await login(page);
		await page.goto('/demo/crud');

		// Click create button
		await page.getByRole('button', { name: /create new post/i }).click();

		// Fill form
		await page.getByLabel(/title/i).fill('Test Post Title');
		await page.getByLabel(/slug/i).fill('test-post-title');
		await page.getByLabel(/content/i).fill('This is test content for the post');
		await page.getByLabel(/excerpt/i).fill('Test excerpt');

		// Submit
		await page.getByRole('button', { name: /create post/i }).click();

		// Should show success message
		await expect(page.getByText(/created successfully/i)).toBeVisible();

		// Should see the new post in the table
		await expect(page.getByText('Test Post Title')).toBeVisible();
	});

	test('should display pagination when there are many posts', async ({ page }) => {
		await login(page);

		// Create multiple posts via API (faster than UI)
		for (let i = 1; i <= 12; i++) {
			await page.request.post('/api/posts', {
				data: {
					title: `Pagination Test Post ${i}`,
					slug: `pagination-test-${i}`,
					content: `Content for post ${i}`,
					status: 'published'
				}
			});
		}

		await page.goto('/demo/crud');

		// Should show pagination controls
		await expect(page.getByRole('button', { name: /next/i })).toBeVisible();
	});

	test('should filter posts by status', async ({ page }) => {
		await login(page);
		await page.goto('/demo/crud');

		// Create a draft post
		await page.getByRole('button', { name: /create new post/i }).click();
		await page.getByLabel(/title/i).fill('Draft Post');
		await page.getByLabel(/slug/i).fill('draft-post');
		await page.getByLabel(/content/i).fill('Draft content');
		await page.locator('select[name="status"]').selectOption('draft');
		await page.getByRole('button', { name: /create post/i }).click();

		// Wait for creation
		await page.waitForTimeout(500);

		// Filter by drafts
		await page.locator('select[id="status"]').selectOption('draft');

		// Should only show draft posts
		await expect(page.getByText('Draft Post')).toBeVisible();
	});

	test('should search posts', async ({ page }) => {
		await login(page);
		await page.goto('/demo/crud');

		// Create a post with unique title
		await page.getByRole('button', { name: /create new post/i }).click();
		await page.getByLabel(/title/i).fill('Searchable Unique Post');
		await page.getByLabel(/slug/i).fill('searchable-unique');
		await page.getByLabel(/content/i).fill('Content');
		await page.getByRole('button', { name: /create post/i }).click();

		await page.waitForTimeout(500);

		// Search for it
		await page.getByPlaceholder(/search/i).fill('Searchable');

		// Should find the post
		await expect(page.getByText('Searchable Unique Post')).toBeVisible();
	});

	test('should edit a post', async ({ page }) => {
		await login(page);
		await page.goto('/demo/crud');

		// Create a post first
		await page.getByRole('button', { name: /create new post/i }).click();
		await page.getByLabel(/title/i).fill('Post to Edit');
		await page.getByLabel(/slug/i).fill('post-to-edit');
		await page.getByLabel(/content/i).fill('Original content');
		await page.getByRole('button', { name: /create post/i }).click();

		await page.waitForTimeout(500);

		// Click edit on the post
		await page.getByRole('button', { name: /edit/i }).first().click();

		// Update title
		await page.getByLabel(/title/i).clear();
		await page.getByLabel(/title/i).fill('Updated Post Title');

		// Save
		await page.getByRole('button', { name: /save changes/i }).click();

		// Should show success message
		await expect(page.getByText(/updated successfully/i)).toBeVisible();

		// Should see updated title
		await expect(page.getByText('Updated Post Title')).toBeVisible();
	});

	test('should delete a post', async ({ page }) => {
		await login(page);
		await page.goto('/demo/crud');

		// Create a post to delete
		await page.getByRole('button', { name: /create new post/i }).click();
		await page.getByLabel(/title/i).fill('Post to Delete');
		await page.getByLabel(/slug/i).fill('post-to-delete');
		await page.getByLabel(/content/i).fill('Will be deleted');
		await page.getByRole('button', { name: /create post/i }).click();

		await page.waitForTimeout(500);

		// Click delete
		await page.getByRole('button', { name: /delete/i }).first().click();

		// Confirm deletion
		await page.getByRole('button', { name: /delete post/i }).click();

		// Should show success message
		await expect(page.getByText(/deleted successfully/i)).toBeVisible();

		// Post should no longer be visible
		await expect(page.getByText('Post to Delete')).not.toBeVisible();
	});
});

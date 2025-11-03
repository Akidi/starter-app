import { test, expect } from '@playwright/test';

test.describe('Navigation and Routing', () => {
	test('should navigate to homepage', async ({ page }) => {
		await page.goto('/');

		await expect(page).toHaveTitle(/starter/i);
		await expect(page.getByRole('heading', { level: 1 })).toBeVisible();
	});

	test('should navigate to demos from homepage', async ({ page }) => {
		await page.goto('/');

		// Check for demo links
		await expect(page.getByRole('link', { name: /lucia/i })).toBeVisible();
		await expect(page.getByRole('link', { name: /crud/i })).toBeVisible();
	});

	test('should navigate to CRUD demo', async ({ page }) => {
		await page.goto('/');

		// Click CRUD demo link (will redirect to login if not authenticated)
		await page.getByRole('link', { name: /crud/i }).first().click();

		// Should either be on CRUD page or login page
		await expect(
			page.url().includes('/demo/crud') || page.url().includes('/demo/lucia/login')
		).toBeTruthy();
	});

	test('should navigate to upload demo', async ({ page }) => {
		await page.goto('/demo/upload');

		// Will redirect to login if not authenticated
		await expect(
			page.url().includes('/demo/upload') || page.url().includes('/demo/lucia/login')
		).toBeTruthy();
	});

	test('should navigate to wizard demo', async ({ page }) => {
		await page.goto('/demo/wizard');

		// Will redirect to login if not authenticated
		await expect(
			page.url().includes('/demo/wizard') || page.url().includes('/demo/lucia/login')
		).toBeTruthy();
	});

	test('should navigate to search demo', async ({ page }) => {
		await page.goto('/demo/search');

		// Will redirect to login if not authenticated
		await expect(
			page.url().includes('/demo/search') || page.url().includes('/demo/lucia/login')
		).toBeTruthy();
	});

	test('should show 404 page for non-existent route', async ({ page }) => {
		await page.goto('/this-page-does-not-exist');

		// Should show 404 error page
		await expect(page.getByText(/404/i)).toBeVisible();
		await expect(page.getByText(/page not found/i)).toBeVisible();
	});

	test('should have working back navigation on error page', async ({ page }) => {
		await page.goto('/');
		await page.goto('/non-existent-page');

		await expect(page.getByText(/404/i)).toBeVisible();

		// Click go back button
		await page.getByRole('button', { name: /go back/i }).click();

		// Should go back to homepage
		await expect(page).toHaveURL('/');
	});

	test('should have working home link on error page', async ({ page }) => {
		await page.goto('/non-existent-page');

		await expect(page.getByText(/404/i)).toBeVisible();

		// Click go home button
		await page.getByRole('link', { name: /go home/i }).click();

		// Should navigate to homepage
		await expect(page).toHaveURL('/');
	});

	test('should navigate between demo pages', async ({ page }) => {
		// Register and login first
		await page.goto('/demo/lucia/login');

		const timestamp = Date.now();
		await page.getByLabel(/name/i).nth(1).fill('Nav Test');
		await page.getByLabel(/email/i).nth(1).fill(`nav.${timestamp}@example.com`);
		await page.getByLabel(/password/i).nth(1).fill('TestPass123!');
		await page.getByRole('button', { name: /create account/i }).click();

		await page.waitForURL(/\/demo\/lucia/);

		// Navigate to CRUD
		await page.goto('/demo/crud');
		await expect(page.getByText(/posts management/i)).toBeVisible();

		// Navigate to upload
		await page.goto('/demo/upload');
		await expect(page.getByText(/file upload/i)).toBeVisible();

		// Navigate to wizard
		await page.goto('/demo/wizard');
		await expect(page.getByText(/multi-step/i)).toBeVisible();

		// Navigate to search
		await page.goto('/demo/search');
		await expect(page.getByText(/autocomplete/i)).toBeVisible();
	});

	test('should protect admin routes', async ({ page }) => {
		await page.goto('/admin');

		// Should redirect to login
		await expect(page).toHaveURL(/\/demo\/lucia\/login/);
	});
});

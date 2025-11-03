import { test, expect } from '@playwright/test';

test.describe('Authentication Flow', () => {
	test('should display login page', async ({ page }) => {
		await page.goto('/demo/lucia/login');

		await expect(page).toHaveTitle(/login/i);
		await expect(page.getByRole('heading', { name: /sign in/i })).toBeVisible();
	});

	test('should show validation errors for empty login form', async ({ page }) => {
		await page.goto('/demo/lucia/login');

		// Try to submit empty login form
		await page.getByRole('button', { name: /sign in/i }).click();

		// Should show validation errors
		await expect(page.locator('text=/email/i')).toBeVisible();
	});

	test('should register a new user successfully', async ({ page }) => {
		await page.goto('/demo/lucia/login');

		// Generate unique email
		const timestamp = Date.now();
		const testEmail = `test.user.${timestamp}@example.com`;

		// Fill registration form
		await page.getByLabel(/name/i).nth(1).fill('Test User');
		await page.getByLabel(/email/i).nth(1).fill(testEmail);
		await page.getByLabel(/password/i).nth(1).fill('TestPassword123!');

		// Submit registration
		await page.getByRole('button', { name: /create account/i }).click();

		// Should redirect to dashboard after successful registration
		await expect(page).toHaveURL(/\/demo\/lucia/);
		await expect(page.getByText(/welcome/i)).toBeVisible();
	});

	test('should login with existing credentials', async ({ page }) => {
		// First, register a user
		await page.goto('/demo/lucia/login');

		const timestamp = Date.now();
		const testEmail = `test.${timestamp}@example.com`;
		const testPassword = 'TestPass123!';

		// Register
		await page.getByLabel(/name/i).nth(1).fill('Test User');
		await page.getByLabel(/email/i).nth(1).fill(testEmail);
		await page.getByLabel(/password/i).nth(1).fill(testPassword);
		await page.getByRole('button', { name: /create account/i }).click();

		// Wait for redirect
		await page.waitForURL(/\/demo\/lucia/);

		// Logout
		await page.getByRole('button', { name: /logout/i }).click();

		// Go back to login
		await page.goto('/demo/lucia/login');

		// Login with created credentials
		await page.getByLabel(/email/i).first().fill(testEmail);
		await page.getByLabel(/password/i).first().fill(testPassword);
		await page.getByRole('button', { name: /sign in/i }).click();

		// Should be logged in
		await expect(page).toHaveURL(/\/demo\/lucia/);
		await expect(page.getByText(/welcome/i)).toBeVisible();
	});

	test('should show error for invalid login credentials', async ({ page }) => {
		await page.goto('/demo/lucia/login');

		// Try to login with invalid credentials
		await page.getByLabel(/email/i).first().fill('invalid@example.com');
		await page.getByLabel(/password/i).first().fill('wrongpassword');
		await page.getByRole('button', { name: /sign in/i }).click();

		// Should show error message
		await expect(page.getByText(/incorrect email or password/i)).toBeVisible();
	});

	test('should logout successfully', async ({ page }) => {
		// First login
		await page.goto('/demo/lucia/login');

		const timestamp = Date.now();
		const testEmail = `logout.test.${timestamp}@example.com`;

		// Register and login
		await page.getByLabel(/name/i).nth(1).fill('Logout Test');
		await page.getByLabel(/email/i).nth(1).fill(testEmail);
		await page.getByLabel(/password/i).nth(1).fill('TestPass123!');
		await page.getByRole('button', { name: /create account/i }).click();

		await page.waitForURL(/\/demo\/lucia/);

		// Logout
		await page.getByRole('button', { name: /logout/i }).click();

		// Should redirect to login page
		await expect(page).toHaveURL(/\/demo\/lucia\/login/);
	});
});

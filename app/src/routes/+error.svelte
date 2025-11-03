<script lang="ts">
	import { page } from '$app/state';
	import { Button } from '$lib/components/ui';
	import { Container, Stack } from '$lib/components/layout';

	// Get error details
	const status = page.status;
	const message = page.error?.message || 'An unexpected error occurred';

	// Error-specific content
	const errorContent: Record<number, { title: string; description: string; emoji: string }> = {
		404: {
			title: '404 - Page Not Found',
			description: "The page you're looking for doesn't exist or has been moved.",
			emoji: '🔍'
		},
		403: {
			title: '403 - Forbidden',
			description: "You don't have permission to access this resource.",
			emoji: '🚫'
		},
		401: {
			title: '401 - Unauthorized',
			description: 'Please log in to access this page.',
			emoji: '🔐'
		},
		500: {
			title: '500 - Server Error',
			description: 'Something went wrong on our end. Please try again later.',
			emoji: '💥'
		}
	};

	const content = errorContent[status] || {
		title: `Error ${status}`,
		description: message,
		emoji: '⚠️'
	};
</script>

<Container>
	<Stack gap="lg" style="margin-top: 4rem; margin-bottom: 4rem; text-align: center;">
		<div style="font-size: 6rem; line-height: 1;">{content.emoji}</div>

		<Stack gap="sm">
			<h1 style="font-size: 2.5rem; font-weight: 700; margin: 0;">
				{content.title}
			</h1>
			<p style="font-size: 1.25rem; color: var(--text-secondary); margin: 0;">
				{content.description}
			</p>
		</Stack>

		{#if message && status !== 404 && status !== 403 && status !== 401}
			<div
				style="background: var(--bg-secondary); padding: 1rem; border-radius: var(--radius-md); max-width: 40rem; margin: 0 auto;"
			>
				<p
					style="font-family: monospace; font-size: 0.875rem; color: var(--text-secondary); margin: 0; word-break: break-word;"
				>
					{message}
				</p>
			</div>
		{/if}

		<Stack gap="sm" style="margin-top: 1rem;">
			<div style="display: flex; gap: 1rem; justify-content: center; flex-wrap: wrap;">
				<a href="/">Go Home</a>

				{#if status === 401}
					<a href="/demo/lucia/login">Log In</a>
				{/if}

				<Button
					variant="ghost"
					onclick={() => {
						window.history.back();
					}}
				>
					Go Back
				</Button>
			</div>

			{#if status === 500}
				<Button
					variant="ghost"
					onclick={() => {
						window.location.reload();
					}}
				>
					Try Again
				</Button>
			{/if}
		</Stack>

		{#if import.meta.env.DEV}
			<details
				style="margin-top: 2rem; padding: 1rem; background: var(--bg-secondary); border-radius: var(--radius-md); text-align: left; max-width: 50rem; margin-left: auto; margin-right: auto;"
			>
				<summary style="cursor: pointer; font-weight: 600; margin-bottom: 0.5rem;">
					Debug Info (Development Only)
				</summary>
				<pre style="overflow: auto; font-size: 0.875rem; margin: 0;"><code
						>{JSON.stringify(
							{
								status,
								message,
								url: page.url.pathname,
								error: page.error
							},
							null,
							2
						)}</code
					></pre>
			</details>
		{/if}
	</Stack>
</Container>

<style>
	:global(body) {
		min-height: 100vh;
		display: flex;
		flex-direction: column;
	}
</style>

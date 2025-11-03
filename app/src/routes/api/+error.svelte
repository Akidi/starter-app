<script lang="ts">
	import { page } from '$app/stores';

	// For API routes, we want to return JSON instead of HTML
	// This is a fallback error handler for API routes

	const status = $page.status;
	const message = $page.error?.message || 'An unexpected error occurred';

	// This will never actually render because API routes should return JSON
	// But it's here as a fallback if something goes wrong
</script>

<svelte:head>
	<title>API Error {status}</title>
</svelte:head>

<div style="padding: 2rem; font-family: monospace;">
	<h1>API Error {status}</h1>
	<p>{message}</p>
	<p style="color: #666; font-size: 0.875rem;">
		API routes should return JSON responses. This HTML error page indicates an unexpected error in
		the error handling itself.
	</p>
</div>

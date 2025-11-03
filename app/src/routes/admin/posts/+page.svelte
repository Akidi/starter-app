<script lang="ts">
	import Button from '$lib/components/ui/Button/Button.svelte';
	import Stack from '$lib/components/layout/Stack.svelte';
	import Card from '$lib/components/ui/Card/Card.svelte';

	// Simple redirect to CRUD demo (admins see all posts there)
</script>

<svelte:head>
	<title>Post Management - Admin</title>
</svelte:head>

<Stack gap="lg">
	<div>
		<h2 style="font-size: 1.75rem; font-weight: 700; margin: 0 0 0.5rem 0;">Post Management</h2>
		<p style="color: var(--text-secondary); margin: 0;">
			Manage all posts across the application
		</p>
	</div>

	<Card>
		<Stack gap="md" style="text-align: center; padding: 2rem;">
			<div style="font-size: 4rem;">📝</div>
			<div>
				<h3 style="font-size: 1.5rem; font-weight: 600; margin: 0 0 0.5rem 0;">
					Post Management
				</h3>
				<p style="color: var(--text-secondary); margin: 0 0 1.5rem 0;">
					As an admin, you can manage all posts in the CRUD demo. You'll see posts from all users
					and have full edit/delete permissions.
				</p>
			</div>
			<div>
				<Button variant="primary" href="/demo/crud">Go to CRUD Demo</Button>
			</div>
		</Stack>
	</Card>

	<Card>
		<Stack gap="sm">
			<h3 style="font-size: 1.25rem; font-weight: 600; margin: 0;">Admin Capabilities</h3>
			<ul style="margin: 0; padding-left: 1.5rem; color: var(--text-secondary);">
				<li>View all posts from all users</li>
				<li>Edit any post regardless of author</li>
				<li>Delete any post</li>
				<li>Change post status (draft/published/archived)</li>
				<li>Filter and search across all content</li>
			</ul>
		</Stack>
	</Card>
</Stack>

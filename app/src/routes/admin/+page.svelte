<script lang="ts">
	import type { PageData } from './$types';
	import { Stack } from '$lib/components/layout';
	import { Card, Badge, Table } from '$lib/components/ui';

	interface Props {
		data: PageData;
	}

	let { data }: Props = $props();

	function formatDate(date: Date | null): string {
		if (!date) return '-';
		return new Date(date).toLocaleDateString('en-US', {
			year: 'numeric',
			month: 'short',
			day: 'numeric',
			hour: '2-digit',
			minute: '2-digit'
		});
	}

	function getRoleBadgeVariant(role: string): 'danger' | 'primary' | 'info' {
		switch (role) {
			case 'admin':
				return 'danger';
			case 'moderator':
				return 'info';
			default:
				return 'primary';
		}
	}

	function getStatusBadgeVariant(status: string): 'success' | 'warning' | 'info' {
		switch (status) {
			case 'published':
				return 'success';
			case 'draft':
				return 'warning';
			default:
				return 'info';
		}
	}
</script>

<svelte:head>
	<title>Admin Dashboard</title>
</svelte:head>

<Stack gap="lg">
	<div>
		<h2 style="font-size: 1.75rem; font-weight: 700; margin: 0 0 0.5rem 0;">Dashboard</h2>
		<p style="color: var(--text-secondary); margin: 0;">
			Overview of your application's key metrics
		</p>
	</div>

	<!-- Statistics Grid -->
	<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1rem;">
		<!-- User Stats -->
		<Card>
			<Stack gap="sm">
				<div style="display: flex; justify-content: space-between; align-items: center;">
					<div style="color: var(--text-secondary); font-size: 0.875rem;">Total Users</div>
					<div style="font-size: 2rem;">👥</div>
				</div>
				<div style="font-size: 2.5rem; font-weight: 700;">{data.stats.users.total}</div>
				<div style="display: flex; gap: 0.5rem; font-size: 0.875rem; color: var(--text-secondary);">
					<span>{data.stats.users.admins} Admin{data.stats.users.admins !== 1 ? 's' : ''}</span>
					<span>•</span>
					<span>{data.stats.users.moderators} Mod{data.stats.users.moderators !== 1 ? 's' : ''}</span>
					<span>•</span>
					<span>{data.stats.users.users} User{data.stats.users.users !== 1 ? 's' : ''}</span>
				</div>
			</Stack>
		</Card>

		<!-- Post Stats -->
		<Card>
			<Stack gap="sm">
				<div style="display: flex; justify-content: space-between; align-items: center;">
					<div style="color: var(--text-secondary); font-size: 0.875rem;">Total Posts</div>
					<div style="font-size: 2rem;">📝</div>
				</div>
				<div style="font-size: 2.5rem; font-weight: 700;">{data.stats.posts.total}</div>
				<div style="display: flex; gap: 0.5rem; font-size: 0.875rem; color: var(--text-secondary);">
					<span>{data.stats.posts.published} Published</span>
					<span>•</span>
					<span>{data.stats.posts.drafts} Draft{data.stats.posts.drafts !== 1 ? 's' : ''}</span>
					<span>•</span>
					<span>{data.stats.posts.archived} Archived</span>
				</div>
			</Stack>
		</Card>

		<!-- Session Stats -->
		<Card>
			<Stack gap="sm">
				<div style="display: flex; justify-content: space-between; align-items: center;">
					<div style="color: var(--text-secondary); font-size: 0.875rem;">Active Sessions</div>
					<div style="font-size: 2rem;">🔐</div>
				</div>
				<div style="font-size: 2.5rem; font-weight: 700;">{data.stats.sessions.active}</div>
				<div style="font-size: 0.875rem; color: var(--text-secondary);">
					{data.stats.sessions.total} total session{data.stats.sessions.total !== 1 ? 's' : ''}
				</div>
			</Stack>
		</Card>
	</div>

	<!-- Recent Activity -->
	<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(400px, 1fr)); gap: 1rem;">
		<!-- Recent Users -->
		<Card>
			<Stack gap="md">
				<h3 style="font-size: 1.25rem; font-weight: 600; margin: 0;">Recent Users</h3>

				{#if data.recentUsers.length === 0}
					<p style="color: var(--text-secondary); margin: 0;">No users yet</p>
				{:else}
					<Table>
						<thead>
							<tr>
								<th>User</th>
								<th>Role</th>
								<th>Joined</th>
							</tr>
						</thead>
						<tbody>
							{#each data.recentUsers as user}
								<tr>
									<td>
										<Stack gap="xs">
											<div style="font-weight: 600;">{user.name}</div>
											<div style="font-size: 0.875rem; color: var(--text-secondary);">
												{user.email}
											</div>
										</Stack>
									</td>
									<td>
										<Badge variant={getRoleBadgeVariant(user.role)} text={user.role} />
									</td>
									<td style="font-size: 0.875rem; color: var(--text-secondary);">
										{formatDate(user.createdAt)}
									</td>
								</tr>
							{/each}
						</tbody>
					</Table>
				{/if}
			</Stack>
		</Card>

		<!-- Recent Posts -->
		<Card>
			<Stack gap="md">
				<h3 style="font-size: 1.25rem; font-weight: 600; margin: 0;">Recent Posts</h3>

				{#if data.recentPosts.length === 0}
					<p style="color: var(--text-secondary); margin: 0;">No posts yet</p>
				{:else}
					<Table>
						<thead>
							<tr>
								<th>Title</th>
								<th>Status</th>
								<th>Created</th>
							</tr>
						</thead>
						<tbody>
							{#each data.recentPosts as post}
								<tr>
									<td>
										<Stack gap="xs">
											<div style="font-weight: 600;">{post.title}</div>
											<div style="font-size: 0.875rem; color: var(--text-secondary);">
												by {post.authorName || 'Unknown'}
											</div>
										</Stack>
									</td>
									<td>
										<Badge variant={getStatusBadgeVariant(post.status)} text={post.status} />
									</td>
									<td style="font-size: 0.875rem; color: var(--text-secondary);">
										{formatDate(post.createdAt)}
									</td>
								</tr>
							{/each}
						</tbody>
					</Table>
				{/if}
			</Stack>
		</Card>
	</div>

	<!-- Quick Actions -->
	<Card>
		<Stack gap="md">
			<h3 style="font-size: 1.25rem; font-weight: 600; margin: 0;">Quick Actions</h3>
			<div style="display: flex; gap: 1rem; flex-wrap: wrap;">
				<a
					href="/admin/users"
					style="padding: 1rem; border: 2px solid var(--border-primary); border-radius: var(--radius-md); text-decoration: none; flex: 1; min-width: 200px; hover:border-color: var(--color-primary); transition: border-color 0.2s;"
				>
					<Stack gap="xs">
						<div style="font-size: 1.5rem;">👥</div>
						<div style="font-weight: 600;">Manage Users</div>
						<div style="font-size: 0.875rem; color: var(--text-secondary);">
							View and edit user accounts
						</div>
					</Stack>
				</a>

				<a
					href="/admin/posts"
					style="padding: 1rem; border: 2px solid var(--border-primary); border-radius: var(--radius-md); text-decoration: none; flex: 1; min-width: 200px; hover:border-color: var(--color-primary); transition: border-color 0.2s;"
				>
					<Stack gap="xs">
						<div style="font-size: 1.5rem;">📝</div>
						<div style="font-weight: 600;">Manage Posts</div>
						<div style="font-size: 0.875rem; color: var(--text-secondary);">
							Moderate all content
						</div>
					</Stack>
				</a>

				<a
					href="/demo/crud"
					style="padding: 1rem; border: 2px solid var(--border-primary); border-radius: var(--radius-md); text-decoration: none; flex: 1; min-width: 200px; hover:border-color: var(--color-primary); transition: border-color 0.2s;"
				>
					<Stack gap="xs">
						<div style="font-size: 1.5rem;">🔨</div>
						<div style="font-weight: 600;">CRUD Demo</div>
						<div style="font-size: 0.875rem; color: var(--text-secondary);">
							Your personal posts
						</div>
					</Stack>
				</a>
			</div>
		</Stack>
	</Card>
</Stack>

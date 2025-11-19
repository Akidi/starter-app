<!-- src/routes/demo/lucia/+page.svelte - Complete Redis-enhanced dashboard -->
<script lang="ts">
	import { enhance } from '$app/forms';
	import type { PageServerData } from './$types';
	import type { User } from '$lib/server/db/auth';
	import { Container, Stack, Flex, CardGrid } from '$lib/components/layout';
	import { Alert, Badge, Button, Card } from '$lib/components/ui';

	// Extended user type with cache properties
	interface ExtendedUser extends User {
		loginCount: number;
		cacheSource: 'redis' | 'database';
	}

	interface ExtendedPageData extends PageServerData {
		user: ExtendedUser;
	}

	let { data }: { data: ExtendedPageData } = $props();
</script>

<Container>
	<Stack gap="xl">
		<Card padding="lg">
			{#snippet header()}
				<Flex justify="between" align="start" gap="md">
					<Stack gap="xs">
						<h1 class="page-title">
							Welcome, {data.user.name}!
						</h1>
						<p class="page-subtitle">
							You are successfully authenticated with Lucia + Redis caching
						</p>
					</Stack>
					<Flex gap="sm" wrap={true}>
						<form method="post" action="?/clearCache" use:enhance>
							<Button type="submit" variant="secondary" size="md">Clear Cache</Button>
						</form>
						<form method="post" action="?/logout" use:enhance>
							<Button type="submit" variant="danger" size="md">Sign out</Button>
						</form>
					</Flex>
				</Flex>
			{/snippet}

			<CardGrid minWidth="280px" gap="lg">
				<!-- User Info Card -->
				<Card title="User Information" padding="md">
					<Stack gap="md">
						<div class="info-item">
							<dt class="info-label">User ID</dt>
							<dd class="info-value font-mono">{data.user.id}</dd>
						</div>
						<div class="info-item">
							<dt class="info-label">Email</dt>
							<dd class="info-value">{data.user.email}</dd>
						</div>
						<div class="info-item">
							<dt class="info-label">Name</dt>
							<dd class="info-value">{data.user.name}</dd>
						</div>
						<div class="info-item">
							<dt class="info-label">Role</dt>
							<dd class="info-value">
								<Badge text={data.user.role} variant="primary" />
							</dd>
						</div>
					</Stack>
				</Card>

				<!-- Redis Cache Info Card -->
				<Card title="Cache Information" padding="md">
					<Stack gap="md">
						<div class="info-item">
							<dt class="info-label">Cache Source</dt>
							<dd class="info-value">
								{#if data.user.cacheSource}
									<Badge
										text={data.user.cacheSource === 'redis' ? '🚀 Redis Cache' : '🗄️ Database'}
										variant={data.user.cacheSource === 'redis' ? 'success' : 'warning'}
									/>
								{:else}
									<Badge text="🗄️ Database (Legacy)" variant="secondary" />
								{/if}
							</dd>
						</div>
						<div class="info-item">
							<dt class="info-label">Login Count</dt>
							<dd class="info-value">
								{#if data.user.loginCount}
									<Flex gap="sm" align="center">
										<span class="font-mono">{data.user.loginCount}/5</span>
										{#if data.user.loginCount >= 4}
											<span class="cache-warning"> (Cache will refresh next login) </span>
										{/if}
									</Flex>
								{:else}
									<span class="not-tracked">Not tracked (Legacy mode)</span>
								{/if}
							</dd>
						</div>
						<div class="info-item">
							<dt class="info-label">Redis Status</dt>
							<dd class="info-value">
								<Badge text="✓ Connected" variant="success" />
							</dd>
						</div>
					</Stack>
				</Card>

				<!-- Session Info Card -->
				<Card title="Session Information" padding="md">
					<Stack gap="md">
						<p class="session-text">
							Your session is active and secure. Redis caching improves performance by reducing
							database queries.
						</p>
						<Badge text="✓ Authenticated" variant="success" />
					</Stack>
				</Card>
			</CardGrid>

			<!-- Cache Testing Section -->
			<Alert type="info" title="Redis Cache Testing">
				<Stack gap="md">
					<p>
						This demo shows Redis caching in action! Try refreshing the page multiple times to see
						the login count increase. After 5 logins, the cache automatically refreshes from the
						database. You can also manually clear the cache using the "Clear Cache" button.
					</p>
					<Flex gap="sm" wrap={true}>
						<Button variant="ghost" size="sm" onclick={() => window.location.reload()}>
							🔄 Refresh Page (Simulate Login)
						</Button>
						<Button
							variant="ghost"
							size="sm"
							onclick={() => (window.location.href = '/demo/lucia/login')}
						>
							🔑 Re-login
						</Button>
						<Button
							variant="ghost"
							size="sm"
							onclick={() => console.log('User cache info:', JSON.stringify(data.user, null, 2))}
						>
							🔍 Debug Info
						</Button>
					</Flex>
				</Stack>
			</Alert>

			<!-- Original Lucia Demo Info -->
			<Alert type="success" title="Lucia Authentication Demo Enhanced">
				<p>
					This demo shows Lucia authentication working with your PostgreSQL database schema, now
					enhanced with Redis caching. The user data is stored in the <code class="inline-code"
						>auth.users</code
					>
					table and cached in Redis for performance.
				</p>
			</Alert>
		</Card>
	</Stack>
</Container>

<style>
	.page-title {
		font-size: var(--font-size-2xl);
		font-weight: var(--font-weight-bold);
		color: var(--text-primary);
		margin: 0;
	}

	.page-subtitle {
		font-size: var(--font-size-sm);
		color: var(--text-secondary);
		margin: 0;
	}

	.info-item {
		display: flex;
		flex-direction: column;
		gap: var(--space-xs);
	}

	.info-label {
		font-size: var(--font-size-sm);
		font-weight: var(--font-weight-medium);
		color: var(--text-secondary);
	}

	.info-value {
		font-size: var(--font-size-sm);
		color: var(--text-primary);
	}

	.font-mono {
		font-family:
			ui-monospace, SFMono-Regular, 'SF Mono', Menlo, Consolas, 'Liberation Mono', monospace;
	}

	.cache-warning {
		font-size: var(--font-size-xs);
		color: var(--color-warning);
	}

	.not-tracked {
		font-size: var(--font-size-xs);
		color: var(--text-tertiary);
	}

	.session-text {
		font-size: var(--font-size-sm);
		color: var(--text-secondary);
		margin: 0;
	}

	.inline-code {
		padding: 0.125rem var(--space-xs);
		font-family:
			ui-monospace, SFMono-Regular, 'SF Mono', Menlo, Consolas, 'Liberation Mono', monospace;
		font-size: var(--font-size-xs);
		background-color: var(--bg-secondary);
		border-radius: var(--radius-sm);
	}
</style>

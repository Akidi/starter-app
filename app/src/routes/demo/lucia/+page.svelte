<!-- src/routes/demo/lucia/+page.svelte - Complete Redis-enhanced dashboard -->
<script lang="ts">
	import { enhance } from '$app/forms';
	import type { PageServerData } from './$types';

	let { data }: { data: PageServerData } = $props();
</script>

<div class="min-h-screen bg-gray-50">
	<div class="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
		<div class="overflow-hidden rounded-lg bg-white shadow">
			<div class="px-4 py-5 sm:p-6">
				<div class="sm:flex sm:items-center sm:justify-between">
					<div>
						<h1 class="text-2xl font-bold text-gray-900">
							Welcome, {data.user.name}!
						</h1>
						<p class="mt-1 text-sm text-gray-600">
							You are successfully authenticated with Lucia + Redis caching
						</p>
					</div>
					<div class="flex space-x-3">
						<form method="post" action="?/clearCache" use:enhance>
							<button
								type="submit"
								class="inline-flex items-center rounded-md border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50 focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 focus:outline-none"
							>
								Clear Cache
							</button>
						</form>
						<form method="post" action="?/logout" use:enhance>
							<button
								type="submit"
								class="inline-flex items-center rounded-md border border-transparent bg-red-600 px-4 py-2 text-sm font-medium text-white hover:bg-red-700 focus:ring-2 focus:ring-red-500 focus:ring-offset-2 focus:outline-none"
							>
								Sign out
							</button>
						</form>
					</div>
				</div>

				<div class="mt-8 grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
					<!-- User Info Card -->
					<div class="rounded-lg bg-gray-50 p-6">
						<h3 class="mb-4 text-lg font-medium text-gray-900">User Information</h3>
						<dl class="space-y-2">
							<div>
								<dt class="text-sm font-medium text-gray-500">User ID</dt>
								<dd class="font-mono text-sm text-gray-900">{data.user.id}</dd>
							</div>
							<div>
								<dt class="text-sm font-medium text-gray-500">Email</dt>
								<dd class="text-sm text-gray-900">{data.user.email}</dd>
							</div>
							<div>
								<dt class="text-sm font-medium text-gray-500">Name</dt>
								<dd class="text-sm text-gray-900">{data.user.name}</dd>
							</div>
							<div>
								<dt class="text-sm font-medium text-gray-500">Role</dt>
								<dd class="text-sm text-gray-900">
									<span
										class="inline-flex items-center rounded-full bg-blue-100 px-2.5 py-0.5 text-xs font-medium text-blue-800"
									>
										{data.user.role}
									</span>
								</dd>
							</div>
						</dl>
					</div>

					<!-- Redis Cache Info Card -->
					<div class="rounded-lg bg-gray-50 p-6">
						<h3 class="mb-4 text-lg font-medium text-gray-900">Cache Information</h3>
						<dl class="space-y-2">
							<div>
								<dt class="text-sm font-medium text-gray-500">Cache Source</dt>
								<dd class="text-sm text-gray-900">
									{#if data.user.cacheSource}
										<span
											class="inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium {data
												.user.cacheSource === 'redis'
												? 'bg-green-100 text-green-800'
												: 'bg-yellow-100 text-yellow-800'}"
										>
											{data.user.cacheSource === 'redis' ? '🚀 Redis Cache' : '🗄️ Database'}
										</span>
									{:else}
										<span
											class="inline-flex items-center rounded-full bg-gray-100 px-2.5 py-0.5 text-xs font-medium text-gray-800"
										>
											🗄️ Database (Legacy)
										</span>
									{/if}
								</dd>
							</div>
							<div>
								<dt class="text-sm font-medium text-gray-500">Login Count</dt>
								<dd class="text-sm text-gray-900">
									{#if data.user.loginCount}
										<span class="font-mono">{data.user.loginCount}/5</span>
										{#if data.user.loginCount >= 4}
											<span class="ml-2 text-xs text-orange-600"
												>(Cache will refresh next login)</span
											>
										{/if}
									{:else}
										<span class="text-xs text-gray-500">Not tracked (Legacy mode)</span>
									{/if}
								</dd>
							</div>
							<div>
								<dt class="text-sm font-medium text-gray-500">Redis Status</dt>
								<dd class="text-sm text-gray-900">
									<span
										class="inline-flex items-center rounded-full bg-green-100 px-2.5 py-0.5 text-xs font-medium text-green-800"
									>
										✓ Connected
									</span>
								</dd>
							</div>
						</dl>
					</div>

					<!-- Session Info Card -->
					<div class="rounded-lg bg-gray-50 p-6">
						<h3 class="mb-4 text-lg font-medium text-gray-900">Session Information</h3>
						<p class="text-sm text-gray-600">
							Your session is active and secure. Redis caching improves performance by reducing
							database queries.
						</p>
						<div class="mt-4">
							<span
								class="inline-flex items-center rounded-full bg-green-100 px-2.5 py-0.5 text-xs font-medium text-green-800"
							>
								✓ Authenticated
							</span>
						</div>
					</div>
				</div>

				<!-- Cache Testing Section -->
				<div class="mt-8 rounded-lg border border-blue-200 bg-blue-50 p-4">
					<div class="flex">
						<div class="flex-shrink-0">
							<svg class="h-5 w-5 text-blue-400" viewBox="0 0 20 20" fill="currentColor">
								<path
									fill-rule="evenodd"
									d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z"
									clip-rule="evenodd"
								/>
							</svg>
						</div>
						<div class="ml-3">
							<h3 class="text-sm font-medium text-blue-800">Redis Cache Testing</h3>
							<p class="mt-1 text-sm text-blue-700">
								This demo shows Redis caching in action! Try refreshing the page multiple times to
								see the login count increase. After 5 logins, the cache automatically refreshes from
								the database. You can also manually clear the cache using the "Clear Cache" button.
							</p>
							<div class="mt-3 flex flex-wrap gap-2">
								<button
									onclick={() => window.location.reload()}
									class="rounded bg-blue-100 px-2 py-1 text-xs text-blue-800 transition-colors hover:bg-blue-200"
								>
									🔄 Refresh Page (Simulate Login)
								</button>
								<a
									href="/demo/lucia/login"
									class="rounded bg-blue-100 px-2 py-1 text-xs text-blue-800 transition-colors hover:bg-blue-200"
								>
									🔑 Re-login
								</a>
								<button
									onclick={() =>
										console.log('User cache info:', JSON.stringify(data.user, null, 2))}
									class="rounded bg-gray-100 px-2 py-1 text-xs text-gray-800 transition-colors hover:bg-gray-200"
								>
									🔍 Debug Info
								</button>
							</div>
						</div>
					</div>
				</div>

				<!-- Original Lucia Demo Info -->
				<div class="mt-6 rounded-lg border border-green-200 bg-green-50 p-4">
					<div class="flex">
						<div class="flex-shrink-0">
							<svg class="h-5 w-5 text-green-400" viewBox="0 0 20 20" fill="currentColor">
								<path
									fill-rule="evenodd"
									d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z"
									clip-rule="evenodd"
								/>
							</svg>
						</div>
						<div class="ml-3">
							<h3 class="text-sm font-medium text-green-800">Lucia Authentication Demo Enhanced</h3>
							<p class="mt-1 text-sm text-green-700">
								This demo shows Lucia authentication working with your PostgreSQL database schema,
								now enhanced with Redis caching. The user data is stored in the <code
									class="rounded bg-green-100 px-1 font-mono">auth.users</code
								> table and cached in Redis for performance.
							</p>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>

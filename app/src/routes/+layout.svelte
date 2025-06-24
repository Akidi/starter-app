<script lang="ts">
	import '../app.css';
	import { page } from '$app/stores';

	let { children } = $props();

	// Navigation items
	const navigation = [
		{ name: 'Home', href: '/' },
		{ name: 'Lucia Demo', href: '/demo/lucia' },
		{ name: 'Documentation', href: 'https://svelte.dev/docs/kit', external: true }
	];

	function isCurrentPage(href: string) {
		if (href === '/') {
			return $page.url.pathname === '/';
		}
		return $page.url.pathname.startsWith(href);
	}
</script>

<div class="min-h-screen bg-gray-50">
	<!-- Navigation -->
	<nav class="border-b border-gray-200 bg-white shadow-sm">
		<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
			<div class="flex h-16 justify-between">
				<div class="flex">
					<!-- Logo/Brand -->
					<div class="flex flex-shrink-0 items-center">
						<a href="/" class="text-xl font-bold text-gray-900"> Starter App </a>
					</div>

					<!-- Navigation Links -->
					<div class="hidden sm:ml-6 sm:flex sm:space-x-8">
						{#each navigation as item (item.name)}
							{#if item.external}
								<a
									href={item.href}
									target="_blank"
									rel="noopener noreferrer"
									class="inline-flex items-center border-b-2 border-transparent px-1 pt-1 text-sm font-medium text-gray-500 transition-colors hover:border-gray-300 hover:text-gray-700"
								>
									{item.name}
									<svg class="ml-1 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
										<path
											stroke-linecap="round"
											stroke-linejoin="round"
											stroke-width="2"
											d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"
										/>
									</svg>
								</a>
							{:else}
								<a
									href={item.href}
									class="inline-flex items-center border-b-2 px-1 pt-1 text-sm font-medium transition-colors {isCurrentPage(
										item.href
									)
										? 'border-blue-500 text-gray-900'
										: 'border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700'}"
								>
									{item.name}
								</a>
							{/if}
						{/each}
					</div>
				</div>

				<!-- Mobile menu button -->
				<div class="flex items-center sm:hidden">
					<button
						type="button"
						class="inline-flex items-center justify-center rounded-md p-2 text-gray-400 hover:bg-gray-100 hover:text-gray-500 focus:ring-2 focus:ring-blue-500 focus:outline-none focus:ring-inset"
						aria-controls="mobile-menu"
						aria-expanded="false"
					>
						<span class="sr-only">Open main menu</span>
						<svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path
								stroke-linecap="round"
								stroke-linejoin="round"
								stroke-width="2"
								d="M4 6h16M4 12h16M4 18h16"
							/>
						</svg>
					</button>
				</div>
			</div>
		</div>

		<!-- Mobile menu -->
		<div class="sm:hidden" id="mobile-menu">
			<div class="space-y-1 pt-2 pb-3">
				{#each navigation as item (item.name)}
					{#if item.external}
						<a
							href={item.href}
							target="_blank"
							rel="noopener noreferrer"
							class="block border-l-4 border-transparent py-2 pr-4 pl-3 text-base font-medium text-gray-500 hover:border-gray-300 hover:bg-gray-50 hover:text-gray-700"
						>
							{item.name}
						</a>
					{:else}
						<a
							href={item.href}
							class="block border-l-4 py-2 pr-4 pl-3 text-base font-medium {isCurrentPage(item.href)
								? 'border-blue-500 bg-blue-50 text-blue-700'
								: 'border-transparent text-gray-500 hover:border-gray-300 hover:bg-gray-50 hover:text-gray-700'}"
						>
							{item.name}
						</a>
					{/if}
				{/each}
			</div>
		</div>
	</nav>

	<!-- Main Content -->
	<main>
		{@render children()}
	</main>

	<!-- Footer -->
	<footer class="mt-auto border-t border-gray-200 bg-white">
		<div class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
			<div class="flex flex-col items-center justify-center space-y-4">
				<div class="flex space-x-6">
					<a
						href="https://kit.svelte.dev"
						target="_blank"
						rel="noopener noreferrer"
						class="text-gray-400 hover:text-gray-500"
					>
						<span class="sr-only">SvelteKit</span>
						<svg class="h-6 w-6" fill="currentColor" viewBox="0 0 24 24">
							<path
								d="M10.354 21.125a2.637 2.637 0 01-1.709-1.624c-.138-.434-.138-.9 0-1.33l.717-2.717L2.648 9.03a2.637 2.637 0 01.944-4.134c.312-.17.667-.256 1.026-.25l2.717.717 6.424-6.424a2.637 2.637 0 014.134.944c.17.312.256.667.25 1.026l-.717 2.717 6.424 6.424a2.637 2.637 0 01-.944 4.134 2.637 2.637 0 01-1.026.25l-2.717-.717-6.424 6.424z"
							/>
						</svg>
					</a>
					<a
						href="https://github.com/Akidi/starter-app"
						target="_blank"
						rel="noopener noreferrer"
						class="text-gray-400 hover:text-gray-500"
					>
						<span class="sr-only">GitHub</span>
						<svg class="h-6 w-6" fill="currentColor" viewBox="0 0 24 24">
							<path
								d="M12 0C5.374 0 0 5.373 0 12 0 17.302 3.438 21.8 8.207 23.387c.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23A11.509 11.509 0 0112 5.803c1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576C20.566 21.797 24 17.3 24 12c0-6.627-5.373-12-12-12z"
							/>
						</svg>
					</a>
				</div>
				<p class="text-sm text-gray-500">
					Built with SvelteKit • Powered by TypeScript • Styled with Tailwind CSS
				</p>
			</div>
		</div>
	</footer>
</div>

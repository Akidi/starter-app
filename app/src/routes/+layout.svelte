<script lang="ts">
	import '../app.css';
	import { Container, Stack, Cluster } from '$lib/components/layout';
	import type { NavItem } from '$lib/types/navigation';
	import { Navbar, ToastContainer } from '$lib/components/ui';

	let { children } = $props();

	// Navigation items using the NavItem type
	const navLinks: NavItem[] = [
		{ name: 'Home', href: '/' },
		{
			name: 'Demos',
			children: [
				{ name: 'Lucia', href: '/demo/lucia' },
				{ name: 'Paraglide', href: '/demo/paraglide' },
				{ name: 'Toasts', href: '/demo/toasts' }
			]
		},
		{ name: 'Documentation', href: 'https://svelte.dev/docs/kit', external: true }
	];
</script>

<ToastContainer />
<Stack class="app-layout" gap="md">
	<!-- Navigation -->
	<Navbar logo="Starter App" {navLinks} />

	<!-- Main Content -->
	<main class="main-content">
		<Container>
			{@render children()}
		</Container>
	</main>

	<!-- Footer -->
	<footer class="footer">
		<Container>
			<Stack gap="md" align="center">
				<Cluster gap="xl" justify="center">
					<a
						href="https://kit.svelte.dev"
						target="_blank"
						rel="noopener noreferrer"
						class="footer-link"
						aria-label="SvelteKit documentation"
					>
						<svg class="footer-icon" fill="currentColor" viewBox="0 0 24 24" aria-hidden="true">
							<path
								d="M10.354 21.125a2.637 2.637 0 01-1.709-1.624c-.138-.434-.138-.9 0-1.33l.717-2.717L2.648 9.03a2.637 2.637 0 01.944-4.134c.312-.17.667-.256 1.026-.25l2.717.717 6.424-6.424a2.637 2.637 0 014.134.944c.17.312.256.667.25 1.026l-.717 2.717 6.424 6.424a2.637 2.637 0 01-.944 4.134 2.637 2.637 0 01-1.026.25l-2.717-.717-6.424 6.424z"
							/>
						</svg>
					</a>
					<a
						href="https://github.com/Akidi/starter-app"
						target="_blank"
						rel="noopener noreferrer"
						class="footer-link"
						aria-label="GitHub repository"
					>
						<svg class="footer-icon" fill="currentColor" viewBox="0 0 24 24" aria-hidden="true">
							<path
								d="M12 0C5.374 0 0 5.373 0 12 0 17.302 3.438 21.8 8.207 23.387c.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23A11.509 11.509 0 0112 5.803c1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576C20.566 21.797 24 17.3 24 12c0-6.627-5.373-12-12-12z"
							/>
						</svg>
					</a>
				</Cluster>
				<p class="footer-text">
					Built with SvelteKit • Powered by TypeScript • Styled with Tailwind CSS
				</p>
			</Stack>
		</Container>
	</footer>
</Stack>

<style>
	:global(.app-layout) {
		min-height: 100vh;
		background-color: var(--bg-secondary);
	}

	.main-content {
		flex: 1;
		padding: var(--space-2xl) 0;
	}

	.footer {
		margin-top: auto;
		border-top: 1px solid var(--border-primary);
		background-color: var(--bg-primary);
		padding: var(--space-2xl) 0;
	}

	.footer-link {
		color: var(--text-disabled);
		transition: color var(--transition-fast);
	}

	.footer-link:hover {
		color: var(--text-secondary);
	}

	.footer-link:focus-visible {
		outline: 2px solid var(--border-focus);
		outline-offset: 2px;
		border-radius: var(--radius-sm);
	}

	.footer-icon {
		width: 1.5rem;
		height: 1.5rem;
	}

	.footer-text {
		font-size: var(--font-size-sm);
		color: var(--text-secondary);
		text-align: center;
		margin: 0;
	}
</style>

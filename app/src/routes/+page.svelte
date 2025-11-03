<script lang="ts">
	import Container from '$lib/components/layout/Container.svelte';
	import Stack from '$lib/components/layout/Stack.svelte';
	import Grid from '$lib/components/layout/Grid.svelte';
	import CardGrid from '$lib/components/layout/CardGrid.svelte';
	import Flex from '$lib/components/layout/Flex.svelte';
	import Card from '$lib/components/ui/Card/Card.svelte';
	import Button from '$lib/components/ui/Button/Button.svelte';
	import Badge from '$lib/components/ui/Badge/Badge.svelte';
	import Alert from '$lib/components/ui/Alert/Alert.svelte';
	import Hero from '$lib/components/Hero.svelte';

	// Feature cards data
	const features = [
		{
			title: 'SvelteKit',
			description: 'Modern web framework with the best developer experience and performance.',
			icon: '⚡',
			badge: 'Framework'
		},
		{
			title: 'TypeScript',
			description: 'Type-safe development with excellent IDE support and error catching.',
			icon: '🔷',
			badge: 'Language'
		},
		{
			title: 'Tailwind CSS',
			description: 'Utility-first CSS framework for rapid UI development.',
			icon: '🎨',
			badge: 'Styling'
		},
		{
			title: 'PostgreSQL',
			description: 'Powerful, reliable database with advanced features and performance.',
			icon: '🐘',
			badge: 'Database'
		},
		{
			title: 'Docker',
			description: 'Containerized development and deployment for consistency across environments.',
			icon: '🐳',
			badge: 'DevOps'
		},
		{
			title: 'Lucia Auth',
			description: 'Simple, flexible authentication library with session management.',
			icon: '🔐',
			badge: 'Security'
		}
	];

	const demos = [
		{
			title: '🔐 Authentication',
			description: 'Session-based auth with login, registration, and secure cookie management.',
			href: '/demo/lucia',
			external: false,
			badge: 'Auth'
		},
		{
			title: '📝 CRUD Operations',
			description: 'Complete data table with pagination, sorting, filtering, and full CRUD.',
			href: '/demo/crud',
			external: false,
			badge: 'Data'
		},
		{
			title: '📤 File Upload',
			description: 'Drag-and-drop file upload with validation, preview, and server handling.',
			href: '/demo/upload',
			external: false,
			badge: 'Files'
		},
		{
			title: '🪄 Multi-Step Wizard',
			description: 'Progressive form with step tracking, validation, and state management.',
			href: '/demo/wizard',
			external: false,
			badge: 'Forms'
		},
		{
			title: '🔍 Search Autocomplete',
			description: 'Debounced search with keyboard navigation and highlighted results.',
			href: '/demo/search',
			external: false,
			badge: 'Search'
		},
		{
			title: '🌐 Internationalization',
			description: 'Multi-language support with Paraglide (English/Spanish).',
			href: '/demo/paraglide',
			external: false,
			badge: 'i18n'
		},
		{
			title: '🔔 Toast Notifications',
			description: 'Toast notification system with auto-dismiss and queuing.',
			href: '/demo/toasts',
			external: false,
			badge: 'UI'
		},
		{
			title: '👑 Admin Panel',
			description: 'Role-based admin interface with user management and statistics.',
			href: '/admin',
			external: false,
			badge: 'Admin'
		}
	];

	const quickLinks = [
		{
			title: 'API Documentation',
			description: 'Explore the REST API endpoints with examples.',
			href: '/api/posts',
			external: false
		},
		{
			title: 'SvelteKit Documentation',
			description: 'Learn more about SvelteKit features and best practices.',
			href: 'https://svelte.dev/docs/kit',
			external: true
		},
		{
			title: 'GitHub Repository',
			description: 'View the source code and contribute to the project.',
			href: 'https://github.com/Akidi/starter-app',
			external: true
		}
	];
</script>

<svelte:head>
	<title>Starter App - SvelteKit Template</title>
	<meta
		name="description"
		content="A modern SvelteKit starter template with TypeScript, Tailwind CSS, PostgreSQL, and authentication."
	/>
</svelte:head>

<!-- Hero Section -->
<Hero
	title="Welcome to"
	highlight="Starter App"
	description="A modern, production-ready SvelteKit template with TypeScript, authentication, database setup, and containerized development environment."
>
	{#snippet actions()}
		<Button size="lg" onclick={() => window.location.href = '/demo/crud'}>
			Explore Live Demos
			<svg class="button-icon" fill="currentColor" viewBox="0 0 20 20">
				<path
					fill-rule="evenodd"
					d="M10.293 3.293a1 1 0 011.414 0l6 6a1 1 0 010 1.414l-6 6a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-4.293-4.293a1 1 0 010-1.414z"
					clip-rule="evenodd"
				/>
			</svg>
		</Button>
		<Button
			size="lg"
			variant="secondary"
			onclick={() => window.location.href = '/demo/lucia'}
		>
			Try Authentication
			<svg class="button-icon" fill="currentColor" viewBox="0 0 20 20">
				<path
					fill-rule="evenodd"
					d="M10.293 3.293a1 1 0 011.414 0l6 6a1 1 0 010 1.414l-6 6a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-4.293-4.293a1 1 0 010-1.414z"
					clip-rule="evenodd"
				/>
			</svg>
		</Button>
	{/snippet}
</Hero>

<!-- Features Section -->
<section class="section">
	<Container size="lg">
		<Stack gap="xl">
			<Stack gap="md" align="center" class="section-header">
				<h2 class="section-title">
					Built with Modern Technologies
				</h2>
				<p class="section-description">
					Everything you need to build a production-ready web application.
				</p>
			</Stack>

			<CardGrid minWidth="280px" gap="lg">
				{#each features as feature (feature.title)}
					<Card hoverable padding="lg">
						<Stack gap="md">
							<Flex justify="between" align="center">
								<Flex gap="md" align="center">
									<div class="feature-icon">
										{feature.icon}
									</div>
									<h3 class="feature-title">
										{feature.title}
									</h3>
								</Flex>
								<Badge text={feature.badge} variant="secondary" size="sm" />
							</Flex>
							<p class="feature-description">
								{feature.description}
							</p>
						</Stack>
					</Card>
				{/each}
			</CardGrid>
		</Stack>
	</Container>
</section>

<!-- Interactive Demos Section -->
<section class="section section-secondary">
	<Container size="lg">
		<Stack gap="xl">
			<Stack gap="md" align="center" class="section-header">
				<h2 class="section-title">
					Interactive Demos
				</h2>
				<p class="section-description">
					Explore production-ready patterns and implementations you can use immediately.
				</p>
			</Stack>

			<CardGrid minWidth="320px" gap="lg">
				{#each demos as demo (demo.title)}
					<Card
						hoverable
						clickable
						onclick={() => window.location.href = demo.href}
						padding="lg"
					>
						<Stack gap="md">
							<Flex justify="between" align="start">
								<h3 class="demo-title">
									{demo.title}
								</h3>
								<Badge text={demo.badge} variant="primary" size="sm" />
							</Flex>
							<p class="demo-description">
								{demo.description}
							</p>
						</Stack>
					</Card>
				{/each}
			</CardGrid>
		</Stack>
	</Container>
</section>

<!-- Quick Links Section -->
<section class="section">
	<Container size="lg">
		<Stack gap="xl">
			<Stack gap="md" align="center" class="section-header">
				<h2 class="section-title">
					Resources
				</h2>
				<p class="section-description">
					Documentation and additional resources to help you get started.
				</p>
			</Stack>

			<Grid columns={3} gap="lg">
				{#each quickLinks as link (link.title)}
					<Card
						hoverable
						clickable
						onclick={() => link.external ? window.open(link.href, '_blank') : window.location.href = link.href}
						padding="lg"
					>
						<Stack gap="sm">
							<Flex justify="between" align="start">
								<h3 class="link-title">
									{link.title}
								</h3>
								{#if link.external}
									<svg class="external-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
										<path
											stroke-linecap="round"
											stroke-linejoin="round"
											stroke-width="2"
											d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"
										/>
									</svg>
								{/if}
							</Flex>
							<p class="link-description">
								{link.description}
							</p>
						</Stack>
					</Card>
				{/each}
			</Grid>
		</Stack>
	</Container>
</section>

<!-- Getting Started Section -->
<section class="section section-secondary">
	<Container size="default">
		<Stack gap="xl">
			<Stack gap="md" align="center" class="section-header">
				<h2 class="section-title">
					Getting Started
				</h2>
				<p class="section-description">
					Start building your next application in minutes.
				</p>
			</Stack>

			<div class="code-block">
				<pre class="code-pre"><code># Clone the repository
git clone https://github.com/Akidi/starter-app.git

# Navigate to setup directory
cd starter-app/setup

# Run bootstrap script (PowerShell 7.2+)
./bootstrap.ps1 -AppName myapp -Environment dev

# Start development
cd ../
docker-compose up -d

# Access the app
# http://localhost:5173</code></pre>
			</div>

			<Grid columns={2} gap="lg">
				<Alert type="success" title="Production Ready">
					Includes Docker, PostgreSQL, Redis, authentication, testing, and deployment guides.
					Everything configured for immediate development.
				</Alert>
				<Alert type="info" title="Comprehensive Tests">
					60+ tests covering components, E2E flows, and API endpoints. Run with `pnpm test`.
				</Alert>
			</Grid>
		</Stack>
	</Container>
</section>

<style>
	.button-icon {
		width: 1.25rem;
		height: 1.25rem;
		margin-left: 0.5rem;
	}

	.section {
		background-color: var(--bg-primary);
		padding: 4rem 0;
	}

	.section-secondary {
		background-color: var(--bg-secondary);
	}

	.section-title {
		font-size: clamp(1.75rem, 4vw, 2.5rem);
		font-weight: 800;
		color: var(--text-primary);
	}

	.section-description {
		max-width: 42rem;
		font-size: 1.25rem;
		color: var(--text-secondary);
	}

	.feature-icon {
		width: 3rem;
		height: 3rem;
		display: flex;
		align-items: center;
		justify-content: center;
		border-radius: var(--radius-lg);
		background-color: var(--bg-secondary);
		font-size: 1.5rem;
	}

	.feature-title {
		font-size: var(--font-size-lg);
		font-weight: var(--font-weight-semibold);
		color: var(--text-primary);
		margin: 0;
	}

	.feature-description {
		color: var(--text-secondary);
		margin: 0;
	}

	.link-title {
		font-size: var(--font-size-lg);
		font-weight: var(--font-weight-semibold);
		color: var(--text-primary);
		margin: 0;
	}

	.link-description {
		color: var(--text-secondary);
		margin: 0;
	}

	.demo-title {
		font-size: var(--font-size-lg);
		font-weight: var(--font-weight-semibold);
		color: var(--text-primary);
		margin: 0;
	}

	.demo-description {
		color: var(--text-secondary);
		font-size: 0.875rem;
		margin: 0;
		line-height: 1.5;
	}

	.external-icon {
		width: 1rem;
		height: 1rem;
		color: var(--text-secondary);
		flex-shrink: 0;
	}

	.code-block {
		background-color: var(--code-bg);
		border: 1px solid var(--code-border);
		border-radius: var(--radius-lg);
		padding: var(--space-lg);
	}

	.code-pre {
		margin: 0;
		font-family: 'Monaco', 'Menlo', 'Courier New', monospace;
		font-size: 0.875rem;
		color: var(--code-text);
		overflow-x: auto;
	}
</style>
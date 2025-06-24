<script lang="ts">
	// Feature cards data
	const features = [
		{
			title: 'SvelteKit',
			description: 'Modern web framework with the best developer experience and performance.',
			icon: '⚡',
			color: 'text-orange-600 bg-orange-100'
		},
		{
			title: 'TypeScript',
			description: 'Type-safe development with excellent IDE support and error catching.',
			icon: '🔷',
			color: 'text-blue-600 bg-blue-100'
		},
		{
			title: 'Tailwind CSS',
			description: 'Utility-first CSS framework for rapid UI development.',
			icon: '🎨',
			color: 'text-cyan-600 bg-cyan-100'
		},
		{
			title: 'PostgreSQL',
			description: 'Powerful, reliable database with advanced features and performance.',
			icon: '🐘',
			color: 'text-indigo-600 bg-indigo-100'
		},
		{
			title: 'Docker',
			description: 'Containerized development and deployment for consistency across environments.',
			icon: '🐳',
			color: 'text-blue-600 bg-blue-100'
		},
		{
			title: 'Lucia Auth',
			description: 'Simple, flexible authentication library with session management.',
			icon: '🔐',
			color: 'text-green-600 bg-green-100'
		}
	];

	const quickLinks = [
		{
			title: 'Lucia Authentication Demo',
			description: 'Test the authentication system with login and registration.',
			href: '/demo/lucia',
			color: 'border-green-200 hover:border-green-300'
		},
		{
			title: 'SvelteKit Documentation',
			description: 'Learn more about SvelteKit features and best practices.',
			href: 'https://svelte.dev/docs/kit',
			external: true,
			color: 'border-orange-200 hover:border-orange-300'
		},
		{
			title: 'GitHub Repository',
			description: 'View the source code and contribute to the project.',
			href: 'https://github.com/Akidi/starter-app',
			external: true,
			color: 'border-gray-200 hover:border-gray-300'
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
<section class="bg-gradient-to-br from-blue-50 via-white to-cyan-50">
	<div class="mx-auto max-w-7xl px-4 py-16 sm:px-6 sm:py-24 lg:px-8">
		<div class="text-center">
			<h1 class="text-4xl font-extrabold tracking-tight text-gray-900 sm:text-5xl lg:text-6xl">
				Welcome to
				<span class="bg-gradient-to-r from-blue-600 to-cyan-600 bg-clip-text text-transparent">
					Starter App
				</span>
			</h1>
			<p class="mx-auto mt-6 max-w-2xl text-xl text-gray-600">
				A modern, production-ready SvelteKit template with TypeScript, authentication, database
				setup, and containerized development environment.
			</p>
			<div class="mt-10 flex flex-col justify-center gap-4 sm:flex-row">
				<a
					href="/demo/lucia"
					class="inline-flex items-center rounded-lg border border-transparent bg-blue-600 px-8 py-3 text-base font-medium text-white transition-colors hover:bg-blue-700 focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 focus:outline-none"
				>
					Try Authentication Demo
					<svg class="-mr-1 ml-2 h-5 w-5" fill="currentColor" viewBox="0 0 20 20">
						<path
							fill-rule="evenodd"
							d="M10.293 3.293a1 1 0 011.414 0l6 6a1 1 0 010 1.414l-6 6a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-4.293-4.293a1 1 0 010-1.414z"
							clip-rule="evenodd"
						/>
					</svg>
				</a>
				<a
					href="https://svelte.dev/docs/kit"
					target="_blank"
					rel="noopener noreferrer"
					class="inline-flex items-center rounded-lg border border-gray-300 bg-white px-8 py-3 text-base font-medium text-gray-700 transition-colors hover:bg-gray-50 focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 focus:outline-none"
				>
					View Documentation
					<svg class="-mr-1 ml-2 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							stroke-width="2"
							d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"
						/>
					</svg>
				</a>
			</div>
		</div>
	</div>
</section>

<!-- Features Section -->
<section class="bg-white py-16">
	<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
		<div class="text-center">
			<h2 class="text-3xl font-extrabold text-gray-900 sm:text-4xl">
				Built with Modern Technologies
			</h2>
			<p class="mx-auto mt-4 max-w-2xl text-xl text-gray-600">
				Everything you need to build a production-ready web application.
			</p>
		</div>

		<div class="mt-16 grid grid-cols-1 gap-8 sm:grid-cols-2 lg:grid-cols-3">
			{#each features as feature (feature.title)}
				<div class="rounded-xl bg-gray-50 p-6 transition-shadow hover:shadow-lg">
					<div class="flex items-center">
						<div class="flex-shrink-0">
							<div class="flex h-12 w-12 items-center justify-center rounded-lg {feature.color}">
								<span class="text-2xl">{feature.icon}</span>
							</div>
						</div>
						<div class="ml-4">
							<h3 class="text-lg font-medium text-gray-900">{feature.title}</h3>
						</div>
					</div>
					<p class="mt-4 text-gray-600">{feature.description}</p>
				</div>
			{/each}
		</div>
	</div>
</section>

<!-- Quick Links Section -->
<section class="bg-gray-50 py-16">
	<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
		<div class="text-center">
			<h2 class="text-3xl font-extrabold text-gray-900 sm:text-4xl">Quick Links</h2>
			<p class="mx-auto mt-4 max-w-2xl text-xl text-gray-600">
				Explore the features and get started with development.
			</p>
		</div>

		<div class="mt-12 grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
			{#each quickLinks as link (link.title)}
				<a
					href={link.href}
					{...link.external ? { target: '_blank', rel: 'noopener noreferrer' } : {}}
					class="block rounded-lg border-2 bg-white {link.color} p-6 transition-all hover:shadow-md"
				>
					<div class="flex items-start">
						<div class="flex-1">
							<h3 class="mb-2 text-lg font-semibold text-gray-900">
								{link.title}
								{#if link.external}
									<svg
										class="ml-1 inline-block h-4 w-4"
										fill="none"
										stroke="currentColor"
										viewBox="0 0 24 24"
									>
										<path
											stroke-linecap="round"
											stroke-linejoin="round"
											stroke-width="2"
											d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"
										/>
									</svg>
								{/if}
							</h3>
							<p class="text-gray-600">{link.description}</p>
						</div>
					</div>
				</a>
			{/each}
		</div>
	</div>
</section>

<!-- Getting Started Section -->
<section class="bg-white py-16">
	<div class="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8">
		<div class="text-center">
			<h2 class="text-3xl font-extrabold text-gray-900 sm:text-4xl">Getting Started</h2>
			<p class="mt-4 text-xl text-gray-600">Start building your next application in minutes.</p>
		</div>

		<div class="mt-12 overflow-x-auto rounded-lg bg-gray-900 p-6">
			<pre class="font-mono text-sm text-green-400"><code
					># Clone the repository
git clone https://github.com/Akidi/starter-app.git

# Install dependencies
cd starter-app/app
pnpm install

# Set up the development environment
./setup.ps1 -AppName myapp -Env dev

# Start development
docker-compose -f docker-compose.dev.yml up -d</code
				></pre>
		</div>

		<div class="mt-8 rounded-lg border border-blue-200 bg-blue-50 p-6">
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
					<h3 class="text-sm font-medium text-blue-800">Development Ready</h3>
					<p class="mt-1 text-sm text-blue-700">
						This template includes Docker containers for PostgreSQL, Redis, and the SvelteKit
						application. Everything is configured and ready for development.
					</p>
				</div>
			</div>
		</div>
	</div>
</section>

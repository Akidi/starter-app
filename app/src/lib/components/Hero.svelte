<script lang="ts">
	import type { Snippet } from 'svelte';
	import { Container, Stack, Flex } from '$lib/components/layout';

	interface Props {
		title: string;
		highlight?: string; // Optional highlighted portion of title
		description?: string;
		size?: 'sm' | 'md' | 'lg';
		align?: 'left' | 'center';
		gradient?: boolean; // Apply gradient to highlight text
		class?: string;
		actions?: Snippet; // Snippet for action buttons
		children?: Snippet; // Optional additional content
	}

	let {
		title,
		highlight,
		description,
		size = 'lg',
		align = 'center',
		gradient = true,
		class: className = '',
		actions,
		children
	}: Props = $props();

	const containerSize = {
		sm: 'default',
		md: 'lg',
		lg: 'lg'
	} as const;

	const stackAlign = {
		left: 'start',
		center: 'center'
	} as const;
</script>

<section class="hero {className}" data-size={size}>
	<Container size={containerSize[size]}>
		<Stack gap="xl" align={stackAlign[align]} class="hero-content">
			<Stack gap="lg" align={stackAlign[align]}>
				<h1 class="hero-title" data-size={size}>
					{title}
					{#if highlight}
						<span class="hero-highlight" data-gradient={gradient}>
							{highlight}
						</span>
					{/if}
				</h1>
				{#if description}
					<p class="hero-description">
						{description}
					</p>
				{/if}
			</Stack>

			{#if actions}
				<Flex gap="md" justify={align === 'center' ? 'center' : 'start'} wrap={true}>
					{@render actions()}
				</Flex>
			{/if}

			{#if children}
				{@render children()}
			{/if}
		</Stack>
	</Container>
</section>

<style>
	.hero {
		background: linear-gradient(
			to bottom right,
			var(--bg-primary),
			var(--bg-secondary),
			var(--bg-primary)
		);
	}

	.hero-title {
		font-weight: 800;
		line-height: 1.1;
		color: var(--text-primary);
		margin: 0;
	}

	.hero-title[data-size='sm'] {
		font-size: clamp(1.5rem, 4vw, 2rem);
	}

	.hero-title[data-size='md'] {
		font-size: clamp(1.75rem, 4.5vw, 2.75rem);
	}

	.hero-title[data-size='lg'] {
		font-size: clamp(2rem, 5vw, 3.5rem);
	}

	.hero-highlight[data-gradient='true'] {
		background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-400) 100%);
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
		background-clip: text;
	}

	.hero-highlight[data-gradient='false'] {
		color: var(--color-primary);
	}

	.hero-description {
		max-width: 42rem;
		font-size: 1.25rem;
		color: var(--text-secondary);
		margin: 0;
	}

	.hero[data-size='sm'] .hero-description {
		font-size: 1rem;
		max-width: 32rem;
	}

	.hero[data-size='md'] .hero-description {
		font-size: 1.125rem;
		max-width: 36rem;
	}
</style>

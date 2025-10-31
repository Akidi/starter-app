<script lang="ts">
	import type { Snippet } from 'svelte';
	import { Stack } from '$lib/components/layout';

	interface Props {
		title?: string;
		subtitle?: string;
		padding?: 'none' | 'sm' | 'md' | 'lg';
		style?: string;
		hoverable?: boolean;
		clickable?: boolean;
		onclick?: () => void;
		class?: string;
		header?: Snippet;
		children: Snippet;
		footer?: Snippet;
	}

	let {
		title,
		subtitle,
		padding = 'md',
		hoverable = false,
		clickable = false,
		style,
		onclick,
		class: className = '',
		header,
		children,
		footer
	}: Props = $props();

	const handleClick = () => {
		if (clickable && onclick) {
			onclick();
		}
	};

	const isInteractive = clickable || onclick;
</script>

{#if isInteractive}
	<button
		type="button"
		onclick={handleClick}
		data-card
		data-padding={padding}
		data-hoverable={hoverable || isInteractive ? 'true' : undefined}
		data-interactive="true"
		class={className}
	>
		{#if header || title}
			<div data-card-section="header">
				{#if header}
					{@render header()}
				{:else}
					<Stack gap="xs" class="card-heading">
						<h3 data-card-title>{title}</h3>
						{#if subtitle}
							<p data-card-subtitle>{subtitle}</p>
						{/if}
					</Stack>
				{/if}
			</div>
		{/if}

		<div data-card-section="body">
			{@render children()}
		</div>

		{#if footer}
			<div data-card-section="footer">
				{@render footer()}
			</div>
		{/if}
	</button>
{:else}
	<div
		data-card
		data-padding={padding}
		data-hoverable={hoverable ? 'true' : undefined}
		class={className}
		{style}
	>
		{#if header || title}
			<div data-card-section="header">
				{#if header}
					{@render header()}
				{:else}
					<Stack gap="xs" class="card-heading">
						<h3 data-card-title>{title}</h3>
						{#if subtitle}
							<p data-card-subtitle>{subtitle}</p>
						{/if}
					</Stack>
				{/if}
			</div>
		{/if}

		<div data-card-section="body">
			{@render children()}
		</div>

		{#if footer}
			<div data-card-section="footer">
				{@render footer()}
			</div>
		{/if}
	</div>
{/if}

<style>
	[data-card] {
		--card-padding: var(--space-lg);
		display: flex;
		flex-direction: column;
		width: 100%;
		background-color: var(--bg-primary);
		border: 1px solid var(--border-primary);
		border-radius: var(--radius-lg);
		box-shadow: var(--shadow-sm);
		color: var(--text-primary);
		text-align: left;
		transition:
			box-shadow var(--transition-fast),
			border-color var(--transition-fast),
			transform var(--transition-fast);
	}

	[data-card][data-padding='none'] {
		--card-padding: 0;
	}

	[data-card][data-padding='sm'] {
		--card-padding: var(--space-md);
	}

	[data-card][data-padding='md'] {
		--card-padding: var(--space-lg);
	}

	[data-card][data-padding='lg'] {
		--card-padding: var(--space-xl);
	}

	button[data-card] {
		cursor: pointer;
		padding: 0;
	}

	button[data-card]:focus-visible {
		outline: 2px solid var(--border-focus);
		outline-offset: 2px;
	}

	[data-card][data-hoverable='true']:hover {
		box-shadow: var(--shadow-md);
		transform: translateY(-1px);
	}

	[data-card][data-hoverable='true']:hover [data-card-section='footer'] {
		background-color: var(--bg-secondary);
	}

	[data-card-section] {
		padding: var(--card-padding);
	}

	[data-card-section='header'] {
		border-bottom: 1px solid var(--border-primary);
		display: flex;
		align-items: center;
		gap: var(--space-sm);
	}

	[data-card-section='footer'] {
		border-top: 1px solid var(--border-primary);
		background-color: var(--bg-secondary);
	}

	[data-card-title] {
		font-size: var(--font-size-lg);
		font-weight: var(--font-weight-semibold);
		color: var(--text-primary);
		margin: 0;
	}

	[data-card-subtitle] {
		font-size: var(--font-size-sm);
		color: var(--text-secondary);
		margin: 0;
	}

	[data-card-section='body'] {
		display: flex;
		flex-direction: column;
		gap: var(--space-sm);
	}

	:global([data-theme='dark']) [data-card] {
		box-shadow: var(--shadow-md);
	}
</style>
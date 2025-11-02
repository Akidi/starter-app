<script lang="ts">
	import type { Snippet } from 'svelte';

	interface Props {
		striped?: boolean;
		hover?: boolean;
		bordered?: boolean;
		compact?: boolean;
		class?: string;
		caption?: string;
		head?: Snippet;
		children: Snippet;
		foot?: Snippet;
	}

	let {
		striped = false,
		hover = true,
		bordered = false,
		compact = false,
		class: className = '',
		caption,
		head,
		children,
		foot
	}: Props = $props();
</script>

<div class="table-wrapper {className}">
	<table 
		class="table"
		data-compact={compact}
		data-bordered={bordered}
	>
		{#if caption}
			<caption class="table-caption">
				{caption}
			</caption>
		{/if}
		
		{#if head}
			<thead class="table-head">
				{@render head()}
			</thead>
		{/if}
		
		<tbody 
			class="table-body"
			data-striped={striped}
			data-hover={hover}
		>
			{@render children()}
		</tbody>

		{#if foot}
			<tfoot class="table-foot">
				{@render foot()}
			</tfoot>
		{/if}
	</table>
</div>

<style>
	.table-wrapper {
		overflow-x: auto;
		border-radius: var(--radius-lg);
		border: 1px solid var(--border-primary);
	}

	.table {
		min-width: 100%;
		border-collapse: collapse;
	}

	.table[data-bordered="true"] {
		border-spacing: 0;
	}

	.table-caption {
		padding: var(--space-md) var(--space-xl);
		text-align: left;
		font-size: var(--font-size-sm);
		font-weight: var(--font-weight-semibold);
		color: var(--text-primary);
		background-color: var(--bg-secondary);
	}

	.table-head {
		background-color: var(--bg-secondary);
	}

	.table-head :global(tr) {
		border-bottom: 1px solid var(--border-primary);
	}

	.table-body {
		background-color: var(--bg-primary);
	}

	.table-body :global(tr) {
		border-bottom: 1px solid var(--border-primary);
	}

	.table-body :global(tr:last-child) {
		border-bottom: none;
	}

	.table-body[data-striped="true"] :global(tr:nth-child(even)) {
		background-color: var(--bg-secondary);
	}

	.table-body[data-hover="true"] :global(tr:hover) {
		background-color: var(--bg-tertiary);
	}

	.table-foot {
		background-color: var(--bg-secondary);
	}

	.table-foot :global(tr) {
		border-top: 1px solid var(--border-primary);
	}

	.table :global(th) {
		padding: var(--space-md) var(--space-xl);
		text-align: left;
		text-transform: uppercase;
		font-size: var(--font-size-xs);
		font-weight: var(--font-weight-semibold);
		letter-spacing: 0.05em;
		color: var(--text-secondary);
	}

	.table :global(td) {
		padding: var(--space-lg) var(--space-xl);
		font-size: var(--font-size-sm);
		color: var(--text-primary);
	}

	.table[data-compact="true"] :global(th),
	.table[data-compact="true"] :global(td) {
		padding: var(--space-sm) var(--space-md);
	}
</style>

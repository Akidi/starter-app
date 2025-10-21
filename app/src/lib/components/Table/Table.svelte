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

<div class="overflow-x-auto rounded-lg border border-gray-200 {className}">
	<table 
		class="min-w-full divide-y divide-gray-200"
		class:table-compact={compact}
	>
		{#if caption}
			<caption class="px-6 py-3 text-left text-sm font-semibold text-gray-900 bg-gray-50">
				{caption}
			</caption>
		{/if}
		
		{#if head}
			<thead class="bg-gray-50">
				{@render head()}
			</thead>
		{/if}
		
		<tbody 
			class="divide-y divide-gray-200 bg-white"
			class:striped
			class:hover
		>
			{@render children()}
		</tbody>

		{#if foot}
			<tfoot class="bg-gray-50">
				{@render foot()}
			</tfoot>
		{/if}
	</table>
</div>

<style>
	.striped :global(tr:nth-child(even)) {
		background-color: rgb(249 250 251);
	}

	.hover :global(tr:hover) {
		background-color: rgb(243 244 246);
	}

	.table-compact :global(th),
	.table-compact :global(td) {
		padding: 0.5rem 0.75rem;
	}

	:global(th) {
		padding: 0.75rem 1.5rem;
		text-align: left;
		text-transform: uppercase;
		font-size: 0.75rem;
		font-weight: 600;
		letter-spacing: 0.05em;
		color: rgb(75 85 99);
	}

	:global(td) {
		padding: 1rem 1.5rem;
		font-size: 0.875rem;
		color: rgb(31 41 55);
	}
</style>
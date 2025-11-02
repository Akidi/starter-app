<script lang="ts">
	import type { Snippet } from "svelte";

	interface Props {
		columns?: number | 'auto';
		gap?: 'xs' | 'sm' | 'md' | 'lg' | 'xl';
		children: Snippet;
	}

	let { 
		columns = 'auto',
		gap = 'md',
		children 
	}: Props = $props();
</script>

<div class="grid" data-gap={gap} style="--columns: {columns}">
	{@render children()}
</div>

<style>
	.grid {
		display: grid;
		grid-template-columns: repeat(var(--columns), 1fr);
	}
	
	.grid[data-gap="xs"] { gap: var(--space-xs); }
	.grid[data-gap="sm"] { gap: var(--space-sm); }
	.grid[data-gap="md"] { gap: var(--space-md); }
	.grid[data-gap="lg"] { gap: var(--space-lg); }
	.grid[data-gap="xl"] { gap: var(--space-xl); }
</style>
<script lang="ts">
	import type { Snippet } from "svelte";

	interface Props {
		minWidth?: string;
		gap?: 'xs' | 'sm' | 'md' | 'lg' | 'xl';
		children: Snippet;
	}

	let { 
		minWidth = '280px',
		gap = 'md',
		children 
	}: Props = $props();
</script>

<div class="card-grid" data-gap={gap} style="--min-width: {minWidth}">
	{@render children()}
</div>

<style>
	.card-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(var(--min-width), 1fr));
	}
	
	.card-grid[data-gap="xs"] { gap: var(--space-xs); }
	.card-grid[data-gap="sm"] { gap: var(--space-sm); }
	.card-grid[data-gap="md"] { gap: var(--space-md); }
	.card-grid[data-gap="lg"] { gap: var(--space-lg); }
	.card-grid[data-gap="xl"] { gap: var(--space-xl); }
</style>
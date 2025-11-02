<script lang="ts">
	import type { Snippet } from "svelte";

	interface Props {
		columns?: number;
		gap?: 'xs' | 'sm' | 'md' | 'lg' | 'xl';
		children: Snippet;
	}

	let { 
		columns = 2,
		gap = 'md',
		children 
	}: Props = $props();
</script>

<div class="form-grid" style="--columns: {columns}" data-gap={gap}>
	{@render children()}
</div>

<style>
	.form-grid {
		display: grid;
		grid-template-columns: repeat(var(--columns), 1fr);
	}
	
	.form-grid[data-gap="xs"] { gap: var(--space-xs); }
	.form-grid[data-gap="sm"] { gap: var(--space-sm); }
	.form-grid[data-gap="md"] { gap: var(--space-md); }
	.form-grid[data-gap="lg"] { gap: var(--space-lg); }
	.form-grid[data-gap="xl"] { gap: var(--space-xl); }
	
	@media (max-width: 768px) {
		.form-grid {
			grid-template-columns: 1fr;
		}
	}
	
	/* Allow items to span full width */
	.form-grid > :global(.full-width) {
		grid-column: 1 / -1;
	}
</style>
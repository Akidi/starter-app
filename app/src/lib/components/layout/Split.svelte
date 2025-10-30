<script lang="ts">
	import type { Snippet } from "svelte";

	interface Props {
		ratio?: '1:1' | '1:2' | '2:1' | '1:3' | '3:1' | string;
		gap?: 'xs' | 'sm' | 'md' | 'lg' | 'xl';
		direction?: 'horizontal' | 'vertical';
		left: Snippet;
		right: Snippet;
	}

	let { 
		ratio = '1:1',
		gap = 'md',
		direction = 'horizontal',
		left,
		right 
	}: Props = $props();
	
	// Convert ratio string to CSS grid format
	let gridRatio = $derived(ratio.replace(':', 'fr ') + 'fr');
</script>

<div class="split" data-direction={direction} data-gap={gap} style="--ratio: {gridRatio}">
	<div class="split-panel">
		{@render left()}
	</div>
	<div class="split-panel">
		{@render right()}
	</div>
</div>

<style>
	.split {
		display: grid;
	}
	
	.split[data-direction="horizontal"] {
		grid-template-columns: var(--ratio);
	}
	
	.split[data-direction="vertical"] {
		grid-template-rows: var(--ratio);
	}
	
	.split[data-gap="xs"] { gap: var(--space-xs); }
	.split[data-gap="sm"] { gap: var(--space-sm); }
	.split[data-gap="md"] { gap: var(--space-md); }
	.split[data-gap="lg"] { gap: var(--space-lg); }
	.split[data-gap="xl"] { gap: var(--space-xl); }
</style>
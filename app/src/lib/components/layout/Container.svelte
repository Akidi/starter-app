<script lang="ts">
	import type { Snippet } from "svelte";

	interface Props {
		size?: 'sm' | 'default' | 'lg' | 'xl' | 'full';
		children: Snippet;
	}

	let { 
		size = 'default',
		children 
	}: Props = $props();
</script>

<div class="container" data-size={size}>
	{@render children()}
</div>

<style>
	.container {
		width: 100%;
		margin-inline: auto;
		padding-inline: var(--space-md);
	}
	
	.container[data-size="sm"] { max-width: 640px; }
	.container[data-size="default"] { max-width: 1024px; }
	.container[data-size="lg"] { max-width: 1280px; }
	.container[data-size="xl"] { max-width: 1536px; }
	.container[data-size="full"] { max-width: none; }
</style>
<script lang="ts">
	import type { Snippet } from "svelte";

	interface Props {
		above?: 'sm' | 'md' | 'lg' | 'xl';
		below?: 'sm' | 'md' | 'lg' | 'xl';
		children: Snippet;
	}

	let { 
		above,
		below,
		children 
	}: Props = $props();
</script>

<div class="show" data-above={above} data-below={below}>
	{@render children()}
</div>

<style>
	.show {
		display: contents;
	}
	
	/* Hide by default if above is set */
	.show[data-above="sm"] { display: none; }
	.show[data-above="md"] { display: none; }
	.show[data-above="lg"] { display: none; }
	.show[data-above="xl"] { display: none; }
	
	/* Show above breakpoint */
	@media (min-width: 640px) {
		.show[data-above="sm"] { display: contents; }
	}
	@media (min-width: 768px) {
		.show[data-above="md"] { display: contents; }
	}
	@media (min-width: 1024px) {
		.show[data-above="lg"] { display: contents; }
	}
	@media (min-width: 1280px) {
		.show[data-above="xl"] { display: contents; }
	}
	
	/* Show by default if below is set */
	.show[data-below="sm"] { display: contents; }
	.show[data-below="md"] { display: contents; }
	.show[data-below="lg"] { display: contents; }
	.show[data-below="xl"] { display: contents; }
	
	/* Hide below breakpoint */
	@media (min-width: 640px) {
		.show[data-below="sm"] { display: none; }
	}
	@media (min-width: 768px) {
		.show[data-below="md"] { display: none; }
	}
	@media (min-width: 1024px) {
		.show[data-below="lg"] { display: none; }
	}
	@media (min-width: 1280px) {
		.show[data-below="xl"] { display: none; }
	}
</style>
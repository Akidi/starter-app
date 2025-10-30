<script lang="ts">
	import type { Snippet } from "svelte";

	interface Props {
		top?: string | number;
		bottom?: string | number;
		zIndex?: number;
		children: Snippet;
	}

	let { 
		top = 0,
		bottom,
		zIndex = 10,
		children 
	}: Props = $props();
</script>

<div class="sticky" style:top style:bottom style:z-index={zIndex}>
	{@render children()}
</div>

<style>
	.sticky {
		position: sticky;
	}
</style>
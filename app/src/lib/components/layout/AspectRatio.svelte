<script lang="ts">
	import type { Snippet } from "svelte";

	interface Props {
		ratio?: '16/9' | '4/3' | '1/1' | '21/9' | '3/2' | string;
		children: Snippet;
	}

	let { 
		ratio = '16/9',
		children 
	}: Props = $props();
</script>

<div class="aspect-ratio" style="--ratio: {ratio}">
	{@render children()}
</div>

<style>
	.aspect-ratio {
		position: relative;
		aspect-ratio: var(--ratio);
	}
	
	.aspect-ratio > :global(*) {
		position: absolute;
		inset: 0;
		width: 100%;
		height: 100%;
		object-fit: cover;
	}
</style>
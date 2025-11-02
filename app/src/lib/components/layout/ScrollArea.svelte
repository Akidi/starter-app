<script lang="ts">
	import type { Snippet } from "svelte";

	interface Props {
		height?: string;
		maxHeight?: string;
		direction?: 'vertical' | 'horizontal' | 'both';
		children: Snippet;
	}

	let { 
		height,
		maxHeight,
		direction = 'vertical',
		children 
	}: Props = $props();
</script>

<div 
	class="scroll-area" 
	data-direction={direction}
	style:height
	style:max-height={maxHeight}
>
	{@render children()}
</div>

<style>
	.scroll-area {
		overflow: auto;
	}
	
	.scroll-area[data-direction="vertical"] {
		overflow-x: hidden;
		overflow-y: auto;
	}
	
	.scroll-area[data-direction="horizontal"] {
		overflow-x: auto;
		overflow-y: hidden;
	}
</style>
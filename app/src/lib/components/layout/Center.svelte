<script lang="ts">
	import type { Snippet } from "svelte";

	interface Props {
		inline?: boolean;
		class?: string;
		style?: string;
		children: Snippet;
	}

	let { 
		inline = false,
		class: className = '',
		style,
		children 
	}: Props = $props();
</script>

<div class="center {className}" {style} data-inline={inline}>
	{@render children()}
</div>

<style>
	.center {
		display: flex;
		justify-content: center;
		align-items: center;
	}
	
	.center[data-inline="true"] {
		display: inline-flex;
	}
</style>
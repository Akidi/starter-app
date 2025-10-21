<script lang="ts">
	import type { Snippet } from 'svelte';

	interface Props {
		class?: string;
		children: Snippet;
	}

	let {
		class: className = '',
		children
	}: Props = $props();
</script>

<div 
	class="border-b border-gray-200 {className}"
	role="tablist"
	aria-label="Tabs"
>
	<nav class="flex gap-1" aria-label="Tabs">
		{@render children()}
	</nav>
</div>
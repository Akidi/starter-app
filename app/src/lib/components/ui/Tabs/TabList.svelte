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
	class="tab-list {className}"
	role="tablist"
	aria-label="Tabs"
>
	<nav class="tab-nav" aria-label="Tabs">
		{@render children()}
	</nav>
</div>

<style>
	.tab-list {
		border-bottom: 1px solid var(--border-primary);
	}

	.tab-nav {
		display: flex;
		gap: var(--space-xs);
	}
</style>

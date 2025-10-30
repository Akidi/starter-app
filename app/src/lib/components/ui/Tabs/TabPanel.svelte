<script lang="ts">
	import { getContext } from 'svelte';
	import type { Snippet } from 'svelte';

	interface Props {
		id: string;
		class?: string;
		children: Snippet;
	}

	let {
		id,
		class: className = '',
		children
	}: Props = $props();

	const tabsContext = getContext<{
		activeTab: () => string;
	}>('tabs');

	const isActive = $derived(tabsContext.activeTab() === id);
</script>

{#if isActive}
	<div
		id="{id}-panel"
		role="tabpanel"
		aria-labelledby={id}
		tabindex={0}
		class="tab-panel {className}"
	>
		{@render children()}
	</div>
{/if}

<style>
	.tab-panel {
		padding: var(--space-lg) 0;
	}
</style>

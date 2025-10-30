<script lang="ts">
	import { setContext } from 'svelte';
	import type { Snippet } from 'svelte';

	interface Props {
		activeTab?: string;
		onTabChange?: (tabId: string) => void;
		class?: string;
		children: Snippet;
	}

	let {
		activeTab = $bindable(''),
		onTabChange,
		class: className = '',
		children
	}: Props = $props();

	const selectTab = (tabId: string) => {
		activeTab = tabId;
		onTabChange?.(tabId);
	};

	setContext('tabs', {
		activeTab: () => activeTab,
		selectTab
	});
</script>

<div class="w-full {className}">
	{@render children()}
</div>
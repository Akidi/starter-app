<script lang="ts">
	import { getContext } from 'svelte';

	interface Props {
		id: string;
		label: string;
		disabled?: boolean;
		class?: string;
	}

	let {
		id,
		label,
		disabled = false,
		class: className = ''
	}: Props = $props();

	const tabsContext = getContext<{
		activeTab: () => string;
		selectTab: (id: string) => void;
	}>('tabs');

	const isActive = $derived(tabsContext.activeTab() === id);

	const handleClick = () => {
		if (!disabled) {
			tabsContext.selectTab(id);
		}
	};
</script>

<button
	type="button"
	onclick={handleClick}
	disabled={disabled}
	role="tab"
	aria-selected={isActive}
	aria-controls="{id}-panel"
	tabindex={isActive ? 0 : -1}
	class="px-4 py-2 text-sm font-medium transition-colors border-b-2 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 {className}"
	class:border-blue-600={isActive}
	class:text-blue-600={isActive}
	class:border-transparent={!isActive}
	class:text-gray-600={!isActive && !disabled}
	class:hover:text-gray-900={!isActive && !disabled}
	class:hover:border-gray-300={!isActive && !disabled}
	class:text-gray-400={disabled}
	class:cursor-not-allowed={disabled}
>
	{label}
</button>
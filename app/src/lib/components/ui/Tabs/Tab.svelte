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
	class="tab {className}"
	class:active={isActive}
	class:disabled={disabled}
>
	{label}
</button>

<style>
	.tab {
		padding: var(--space-md) var(--space-lg);
		font-size: var(--font-size-sm);
		font-weight: var(--font-weight-medium);
		color: var(--text-secondary);
		background: transparent;
		border: none;
		border-bottom: 2px solid transparent;
		transition: all var(--transition-fast);
		cursor: pointer;
	}

	.tab:focus-visible {
		outline: none;
		box-shadow: var(--focus-ring);
	}

	.tab:not(.active):not(.disabled):hover {
		color: var(--text-primary);
		border-bottom-color: var(--border-secondary);
	}

	.tab.active {
		color: var(--color-primary);
		border-bottom-color: var(--color-primary);
	}

	.tab.disabled {
		color: var(--text-disabled);
		cursor: not-allowed;
		opacity: 0.5;
	}
</style>

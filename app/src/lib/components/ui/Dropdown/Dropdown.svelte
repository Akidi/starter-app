<script lang="ts">
	import type { Snippet } from 'svelte';
	import { onMount } from 'svelte';
	import { Button } from '$lib/components/ui';

	interface Props {
		label: string;
		align?: 'left' | 'right';
		buttonVariant?: 'primary' | 'secondary' | 'ghost';
		buttonSize?: 'sm' | 'md' | 'lg';
		disabled?: boolean;
		class?: string;
		children: Snippet;
	}

	let {
		label,
		align = 'left',
		buttonVariant = 'secondary',
		buttonSize = 'md',
		disabled = false,
		class: className = '',
		children
	}: Props = $props();

	let isOpen = $state(false);
	let dropdownElement = $state<HTMLDivElement>();

	const toggle = () => {
		if (!disabled) {
			isOpen = !isOpen;
		}
	};

	const close = () => {
		isOpen = false;
	};

	const handleClickOutside = (event: MouseEvent) => {
		if (dropdownElement && !dropdownElement.contains(event.target as Node)) {
			close();
		}
	};

	const handleEscape = (event: KeyboardEvent) => {
		if (event.key === 'Escape' && isOpen) {
			close();
		}
	};

	onMount(() => {
		document.addEventListener('click', handleClickOutside);
		document.addEventListener('keydown', handleEscape);

		return () => {
			document.removeEventListener('click', handleClickOutside);
			document.removeEventListener('keydown', handleEscape);
		};
	});

</script>

<div bind:this={dropdownElement} class="dropdown {className}">
	<Button
		variant={buttonVariant}
		size={buttonSize}
		onclick={toggle}
		{disabled}
		ariaLabel="Toggle dropdown menu"
		class="dropdown-trigger"
	>
		<span>{label}</span>
		<svg
			class="dropdown-icon"
			class:open={isOpen}
			fill="none"
			viewBox="0 0 24 24"
			stroke="currentColor"
			aria-hidden="true"
		>
			<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
		</svg>
	</Button>

	{#if isOpen}
		<div
			class="dropdown-menu dropdown-menu-{align}"
			role="menu"
			aria-orientation="vertical"
		>
			<div class="dropdown-content">
				{@render children()}
			</div>
		</div>
	{/if}
</div>

<style>
	.dropdown {
		position: relative;
		display: inline-block;
	}

	.dropdown :global(.dropdown-trigger) {
		display: inline-flex;
		align-items: center;
		gap: var(--space-sm);
	}

	.dropdown-icon {
		width: 1rem;
		height: 1rem;
		transition: transform var(--transition-fast);
	}

	.dropdown-icon.open {
		transform: rotate(180deg);
	}

	.dropdown-menu {
		position: absolute;
		z-index: 50;
		margin-top: var(--space-sm);
		min-width: 12rem;
		background-color: var(--bg-primary);
		border: 1px solid var(--border-primary);
		border-radius: var(--radius-md);
		box-shadow: var(--shadow-lg);
	}

	.dropdown-menu-left {
		left: 0;
	}

	.dropdown-menu-right {
		right: 0;
	}

	.dropdown-content {
		padding: var(--space-xs) 0;
	}
</style>
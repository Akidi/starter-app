<script lang="ts">
	import type { Snippet } from 'svelte';
	import { onMount } from 'svelte';

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

	const buttonVariants = {
		primary: 'bg-blue-600 text-white hover:bg-blue-700',
		secondary: 'border border-gray-300 bg-white text-gray-700 hover:bg-gray-50',
		ghost: 'bg-transparent text-gray-700 hover:bg-gray-100'
	};

	const buttonSizes = {
		sm: 'px-3 py-1.5 text-xs',
		md: 'px-4 py-2 text-sm',
		lg: 'px-6 py-3 text-base'
	};

	const alignmentClasses = {
		left: 'left-0',
		right: 'right-0'
	};
</script>

<div bind:this={dropdownElement} class="relative inline-block {className}">
	<button
		type="button"
		onclick={toggle}
		disabled={disabled}
		class="inline-flex items-center justify-center gap-2 rounded-md font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed {buttonVariants[buttonVariant]} {buttonSizes[buttonSize]}"
		aria-haspopup="true"
		aria-expanded={isOpen}
	>
		<span>{label}</span>
		<svg
			class="h-4 w-4 transition-transform"
			class:rotate-180={isOpen}
			fill="none"
			viewBox="0 0 24 24"
			stroke="currentColor"
			aria-hidden="true"
		>
			<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
		</svg>
	</button>

	{#if isOpen}
		<div
			class="absolute z-50 mt-2 min-w-48 rounded-md border border-gray-200 bg-white shadow-lg {alignmentClasses[align]}"
			role="menu"
			aria-orientation="vertical"
		>
			<div class="py-1">
				{@render children()}
			</div>
		</div>
	{/if}
</div>
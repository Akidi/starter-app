<script lang="ts">
	import type { Snippet } from 'svelte';

	interface Props {
		content: string;
		position?: 'top' | 'bottom' | 'left' | 'right';
		delay?: number;
		class?: string;
		children: Snippet;
	}

	let {
		content,
		position = 'top',
		delay = 200,
		class: className = '',
		children
	}: Props = $props();

	let isVisible = $state(false);
	let timeoutId: number;
	let wrapperId = `tooltip-trigger-${Math.random().toString(36).substr(2, 9)}`;

	const show = () => {
		timeoutId = window.setTimeout(() => {
			isVisible = true;
		}, delay);
	};

	const hide = () => {
		window.clearTimeout(timeoutId);
		isVisible = false;
	};

	const getPositionClasses = (pos: string) => {
		switch (pos) {
			case 'top':
				return 'bottom-full left-1/2 -translate-x-1/2 pb-2';
			case 'bottom':
				return 'top-full left-1/2 -translate-x-1/2 pt-2';
			case 'left':
				return 'right-full top-1/2 -translate-y-1/2 pr-2';
			case 'right':
				return 'left-full top-1/2 -translate-y-1/2 pl-2';
			default:
				return 'bottom-full left-1/2 -translate-x-1/2 pb-2';
		}
	};

	const getArrowPosition = (pos: string) => {
		switch (pos) {
			case 'top':
				return 'bottom-0 left-1/2 -translate-x-1/2 translate-y-full';
			case 'bottom':
				return 'top-0 left-1/2 -translate-x-1/2 -translate-y-full';
			case 'left':
				return 'right-0 top-1/2 -translate-y-1/2 translate-x-full';
			case 'right':
				return 'left-0 top-1/2 -translate-y-1/2 -translate-x-full';
			default:
				return 'bottom-0 left-1/2 -translate-x-1/2 translate-y-full';
		}
	};

	const getArrowBorder = (pos: string) => {
		switch (pos) {
			case 'top':
				return 'border-x-8 border-x-transparent border-t-8 border-t-gray-900';
			case 'bottom':
				return 'border-x-8 border-x-transparent border-b-8 border-b-gray-900';
			case 'left':
				return 'border-y-8 border-y-transparent border-l-8 border-l-gray-900';
			case 'right':
				return 'border-y-8 border-y-transparent border-r-8 border-r-gray-900';
			default:
				return 'border-x-8 border-x-transparent border-t-8 border-t-gray-900';
		}
	};
</script>

<span class="relative inline-block {className}">
	<span
		id={wrapperId}
		class="inline-block"
		onmouseenter={show}
		onmouseleave={hide}
		onfocus={show}
		onblur={hide}
		aria-describedby={isVisible ? `${wrapperId}-tooltip` : undefined}
        role="tooltip"
	>
		{@render children()}
	</span>

	{#if isVisible}
		<span
			id="{wrapperId}-tooltip"
			role="tooltip"
			class="absolute z-50 {getPositionClasses(position)}"
		>
			<span class="block px-3 py-2 text-sm font-medium text-white bg-gray-900 rounded-md shadow-lg whitespace-nowrap">
				{content}
			</span>
			<span
				class="absolute w-0 h-0 {getArrowPosition(position)} {getArrowBorder(position)}"
				aria-hidden="true"
			></span>
		</span>
	{/if}
</span>
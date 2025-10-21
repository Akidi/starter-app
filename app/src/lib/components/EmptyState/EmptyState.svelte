<script lang="ts">
	import type { Snippet } from 'svelte';
	import Button from '../Button/Button.svelte';

	interface Props {
		icon?: 'box' | 'folder' | 'search' | 'document' | 'users' | 'custom';
		title: string;
		description?: string;
		actionLabel?: string;
		onAction?: () => void;
		secondaryActionLabel?: string;
		onSecondaryAction?: () => void;
		customIcon?: Snippet;
		class?: string;
	}

	let {
		icon = 'box',
		title,
		description,
		actionLabel,
		onAction,
		secondaryActionLabel,
		onSecondaryAction,
		customIcon,
		class: className = ''
	}: Props = $props();

	const icons = {
		box: 'M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4',
		folder: 'M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z',
		search: 'M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z',
		document: 'M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z',
		users: 'M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z'
	};
</script>

<div 
	class="flex flex-col items-center justify-center py-12 px-4 text-center {className}"
	role="status"
	aria-live="polite"
>
	<div class="mb-4 rounded-full bg-gray-100 p-3">
		{#if icon === 'custom' && customIcon}
			{@render customIcon()}
		{:else if icon !== 'custom'}
			<svg 
				class="h-12 w-12 text-gray-400" 
				fill="none" 
				viewBox="0 0 24 24" 
				stroke="currentColor"
				aria-hidden="true"
			>
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d={icons[icon]} />
			</svg>
		{/if}
	</div>

	<h3 class="mb-2 text-lg font-semibold text-gray-900">
		{title}
	</h3>

	{#if description}
		<p class="mb-6 max-w-sm text-sm text-gray-600">
			{description}
		</p>
	{/if}

	{#if actionLabel && onAction}
		<div class="flex flex-col sm:flex-row gap-3">
			<Button variant="primary" onclick={onAction}>
				{actionLabel}
			</Button>
			{#if secondaryActionLabel && onSecondaryAction}
				<Button variant="secondary" onclick={onSecondaryAction}>
					{secondaryActionLabel}
				</Button>
			{/if}
		</div>
	{/if}
</div>
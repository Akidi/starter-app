<script lang="ts">
	import type { Snippet } from 'svelte';
	import Badge from '../Badge/Badge.svelte';

	interface Props {
		title: string;
		description?: string;
		badge?: string;
		badgeVariant?: 'blue' | 'green' | 'amber' | 'red' | 'gray' | 'purple';
		variant?: 'blue' | 'green' | 'amber' | 'purple' | 'gray';
		showBadge?: boolean;
		class?: string;
		children: Snippet;
	}

	let { 
		title, 
		description,
		badge = 'New',
		badgeVariant = 'blue',
		variant = 'blue',
		showBadge = true,
		class: className = '',
		children 
	}: Props = $props();

	const variantStyles = {
		blue: 'border-blue-200 bg-blue-50/40',
		green: 'border-green-200 bg-green-50/40',
		amber: 'border-amber-200 bg-amber-50/40',
		purple: 'border-purple-200 bg-purple-50/40',
		gray: 'border-gray-200 bg-gray-50/40'
	};
</script>

<div 
	class="rounded-lg border border-dashed p-4 {variantStyles[variant]} {className}"
	role="region"
	aria-label={title}
>
	<div class="flex items-center justify-between">
		<h3 class="text-sm font-semibold text-gray-900">{title}</h3>
		{#if showBadge}
			<Badge text={badge} variant={badgeVariant} size="sm" />
		{/if}
	</div>
	{#if description}
		<p class="mt-2 text-xs text-gray-600">{description}</p>
	{/if}
	<div class="mt-4">
		{@render children()}
	</div>
</div>
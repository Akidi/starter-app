<script lang="ts">
	import type { Snippet } from 'svelte';

	interface Props {
		title: string;
		description?: string;
		required?: boolean;
		collapsible?: boolean;
		defaultOpen?: boolean;
		error?: string;
		badge?: string;
		spacing?: 'tight' | 'normal' | 'relaxed';
		class?: string;
		children: Snippet;
		actions?: Snippet;
	}

	let { 
		title, 
		description, 
		required = false,
		collapsible = false,
		defaultOpen = true,
		error,
		badge,
		spacing = 'normal',
		class: className = '',
		children,
		actions
	}: Props = $props();

	let isOpen = $state(defaultOpen);

	const spacingClasses = {
		tight: 'mt-3 space-y-3',
		normal: 'mt-6 space-y-4',
		relaxed: 'mt-8 space-y-6'
	};

	const toggleOpen = () => {
		if (collapsible) {
			isOpen = !isOpen;
		}
	};

	const handleHeaderClick = (e: MouseEvent) => {
		// Only toggle if clicking the header itself, not child interactive elements
		if (e.target === e.currentTarget || (e.target as HTMLElement).closest('h2, p')) {
			toggleOpen();
		}
	};
</script>

<section 
	class="rounded-xl border bg-white shadow-sm {className}"
	class:border-gray-200={!error}
	class:border-red-300={error}
>
	{#if collapsible}
		<button
			type="button"
			class="flex w-full items-start justify-between p-6 text-left transition-colors hover:bg-gray-50"
			class:border-b={isOpen && !error}
			class:border-gray-200={isOpen && !error}
			onclick={handleHeaderClick}
			aria-expanded={isOpen}
		>
			<div class="flex-1 pointer-events-none">
				<div class="flex items-center gap-2">
					<h2 class="text-xl font-semibold text-gray-900">
						{title}
						{#if required}
							<span class="text-red-500" aria-label="required">*</span>
						{/if}
					</h2>
					{#if badge}
						<span class="inline-flex items-center rounded-full bg-blue-100 px-2.5 py-0.5 text-xs font-medium text-blue-800">
							{badge}
						</span>
					{/if}
				</div>
				{#if description}
					<p class="mt-1 text-sm text-gray-500">{description}</p>
				{/if}
				{#if error}
					<p class="mt-1 text-sm text-red-600" role="alert">{error}</p>
				{/if}
			</div>

			<div class="flex items-center gap-2">
				{#if actions}
					<div class="flex items-center gap-2 pointer-events-auto">
						{@render actions()}
					</div>
				{/if}
				<svg 
					class="h-5 w-5 text-gray-400 transition-transform pointer-events-none"
					class:rotate-180={!isOpen}
					fill="none" 
					viewBox="0 0 24 24" 
					stroke="currentColor"
					aria-hidden="true"
				>
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
				</svg>
			</div>
		</button>
	{:else}
		<div 
			class="flex items-start justify-between p-6"
			class:border-b={!error}
			class:border-gray-200={!error}
		>
			<div class="flex-1">
				<div class="flex items-center gap-2">
					<h2 class="text-xl font-semibold text-gray-900">
						{title}
						{#if required}
							<span class="text-red-500" aria-label="required">*</span>
						{/if}
					</h2>
					{#if badge}
						<span class="inline-flex items-center rounded-full bg-blue-100 px-2.5 py-0.5 text-xs font-medium text-blue-800">
							{badge}
						</span>
					{/if}
				</div>
				{#if description}
					<p class="mt-1 text-sm text-gray-500">{description}</p>
				{/if}
				{#if error}
					<p class="mt-1 text-sm text-red-600" role="alert">{error}</p>
				{/if}
			</div>

			{#if actions}
				<div class="flex items-center gap-2">
					{@render actions()}
				</div>
			{/if}
		</div>
	{/if}

	{#if isOpen}
		<div class="p-6 {spacingClasses[spacing]}">
			{@render children()}
		</div>
	{/if}
</section>
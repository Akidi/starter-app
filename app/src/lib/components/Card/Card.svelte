<script lang="ts">
	import type { Snippet } from 'svelte';

	interface Props {
		title?: string;
		subtitle?: string;
		padding?: 'none' | 'sm' | 'md' | 'lg';
		hoverable?: boolean;
		clickable?: boolean;
		onclick?: () => void;
		class?: string;
		header?: Snippet;
		children: Snippet;
		footer?: Snippet;
	}

	let {
		title,
		subtitle,
		padding = 'md',
		hoverable = false,
		clickable = false,
		onclick,
		class: className = '',
		header,
		children,
		footer
	}: Props = $props();

	const paddingClasses = {
		none: '',
		sm: 'p-3',
		md: 'p-6',
		lg: 'p-8'
	};

	const handleClick = () => {
		if (clickable && onclick) {
			onclick();
		}
	};

	const isInteractive = clickable || onclick;
</script>

{#if isInteractive}
	<button
		type="button"
		onclick={handleClick}
		class="w-full text-left rounded-lg border border-gray-200 bg-white shadow-sm transition-shadow {className}"
		class:hover:shadow-md={hoverable || isInteractive}
		class:cursor-pointer={isInteractive}
	>
		{#if header || title}
			<div class="border-b border-gray-200 {paddingClasses[padding]}">
				{#if header}
					{@render header()}
				{:else if title}
					<div>
						<h3 class="text-lg font-semibold text-gray-900">{title}</h3>
						{#if subtitle}
							<p class="mt-1 text-sm text-gray-600">{subtitle}</p>
						{/if}
					</div>
				{/if}
			</div>
		{/if}

		<div class={paddingClasses[padding]}>
			{@render children()}
		</div>

		{#if footer}
			<div class="border-t border-gray-200 bg-gray-50 {paddingClasses[padding]}">
				{@render footer()}
			</div>
		{/if}
	</button>
{:else}
	<div
		class="rounded-lg border border-gray-200 bg-white shadow-sm {className}"
		class:hover:shadow-md={hoverable}
		class:transition-shadow={hoverable}
	>
		{#if header || title}
			<div class="border-b border-gray-200 {paddingClasses[padding]}">
				{#if header}
					{@render header()}
				{:else if title}
					<div>
						<h3 class="text-lg font-semibold text-gray-900">{title}</h3>
						{#if subtitle}
							<p class="mt-1 text-sm text-gray-600">{subtitle}</p>
						{/if}
					</div>
				{/if}
			</div>
		{/if}

		<div class={paddingClasses[padding]}>
			{@render children()}
		</div>

		{#if footer}
			<div class="border-t border-gray-200 bg-gray-50 {paddingClasses[padding]}">
				{@render footer()}
			</div>
		{/if}
	</div>
{/if}
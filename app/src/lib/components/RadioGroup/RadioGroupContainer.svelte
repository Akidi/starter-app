<script lang="ts">
	import type { Snippet } from 'svelte';

	interface Props {
		legend: string;
		description?: string;
		error?: string;
		required?: boolean;
		class?: string;
		children: Snippet;
	}

	let {
		legend,
		description,
		error,
		required = false,
		class: className = '',
		children
	}: Props = $props();
</script>

<fieldset class="space-y-3 {className}">
	<legend class="text-sm font-semibold text-gray-900">
		{legend}
		{#if required}
			<span class="text-red-500" aria-label="required">*</span>
		{/if}
	</legend>

	{#if description && !error}
		<p class="text-xs text-gray-500">{description}</p>
	{/if}

	<div class="space-y-2">
		{@render children()}
	</div>

	{#if error}
		<p class="text-sm text-red-600" role="alert" aria-live="polite">{error}</p>
	{/if}
</fieldset>
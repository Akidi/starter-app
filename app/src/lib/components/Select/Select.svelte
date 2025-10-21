<script lang="ts">
	import type { Snippet } from 'svelte';

	interface Props {
		id: string;
		name: string;
		label: string;
		value?: string | null;
		placeholder?: string;
		required?: boolean;
		disabled?: boolean;
		error?: string;
		helpText?: string;
		children: Snippet;
		onchange?: (e: Event) => void;
	}

	let { 
		id, 
		name, 
		label, 
		value = $bindable(''), 
		placeholder,
		required = false, 
		disabled = false,
		error, 
		helpText, 
		onchange, 
		children 
	}: Props = $props();

	const handleChange = (e: Event) => {
		if (!(e.currentTarget instanceof HTMLSelectElement)) return;
		const target = e.currentTarget;
		value = target.value || null;
		onchange?.(e);
	};
</script>

<div class="w-full">
	<label for={id} class="block text-sm font-medium text-gray-700">
		{label}
		{#if required}
			<span class="text-red-500" aria-label="required">*</span>
		{/if}
	</label>
	
	<select
		{id}
		{name}
		{required}
		{disabled}
		value={value ?? ''}
		onchange={handleChange}
		class="mt-1 block w-full rounded-md border bg-white px-3 py-2 text-gray-900 focus:outline-none transition-colors appearance-none bg-no-repeat bg-right pr-10"
		class:border-gray-300={!error && !disabled}
		class:border-red-500={error}
		class:bg-gray-50={disabled}
		class:cursor-not-allowed={disabled}
		class:focus:border-blue-500={!error}
		class:focus:ring-1={!error}
		class:focus:ring-blue-500={!error}
		class:focus:border-red-500={error}
		class:focus:ring-red-500={error}
		style="background-image: url('data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22 width=%2224%22 height=%2224%22 viewBox=%220 0 24 24%22 fill=%22none%22 stroke=%22%23666%22 stroke-width=%222%22 stroke-linecap=%22round%22 stroke-linejoin=%22round%22%3E%3Cpolyline points=%226 9 12 15 18 9%22%3E%3C/polyline%3E%3C/svg%3E'); background-position: right 0.5rem center; background-size: 1.25rem;"
		aria-describedby={helpText || error ? `${id}-description` : undefined}
		aria-invalid={error ? true : undefined}
		aria-required={required ? true : undefined}
	>
		{#if placeholder}
			<option value="" disabled selected={!value}>
				{placeholder}
			</option>
		{/if}
		{@render children()}
	</select>
	
	{#if error}
		<p id="{id}-description" class="mt-1 text-sm text-red-600" role="alert" aria-live="polite">
			{error}
		</p>
	{:else if helpText}
		<p id="{id}-description" class="mt-1 text-xs text-gray-500">
			{helpText}
		</p>
	{/if}
</div>
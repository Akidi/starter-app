<script lang="ts">
	interface Props {
		id: string;
		name: string;
		label: string;
		value?: string;
		checked?: boolean;
		disabled?: boolean;
		required?: boolean;
		error?: string;
		helpText?: string;
		indeterminate?: boolean;
		onchange?: (e: Event) => void;
	}

	let { 
		id, 
		name, 
		label, 
		value = 'on', 
		checked = $bindable(false), 
		disabled = false,
		required = false,
		error,
		helpText,
		indeterminate = false,
		onchange 
	}: Props = $props();

	let inputElement = $state<HTMLInputElement>();

	$effect(() => {
		if (inputElement) {
			inputElement.indeterminate = indeterminate;
		}
	});

	const handleChange = (e: Event) => {
		if (!(e.currentTarget instanceof HTMLInputElement)) return;
		checked = e.currentTarget.checked;
		onchange?.(e);
	};
</script>

<div class="flex items-start gap-3">
	<div class="flex items-center h-5">
		<input
			bind:this={inputElement}
			{id}
			{name}
			type="checkbox"
			{value}
			{checked}
			{disabled}
			{required}
			onchange={handleChange}
			class="h-4 w-4 rounded border-gray-300 text-blue-600 transition-colors focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 focus:outline-none disabled:cursor-not-allowed disabled:opacity-50"
			class:border-red-500={error}
			aria-describedby={helpText || error ? `${id}-description` : undefined}
			aria-invalid={error ? true : undefined}
			aria-required={required ? true : undefined}
		/>
	</div>
	<div class="flex-1">
		<label 
			for={id} 
			class="text-sm font-medium cursor-pointer select-none"
			class:text-gray-700={!disabled && !error}
			class:text-gray-400={disabled}
			class:text-red-700={error}
		>
			{label}
			{#if required}
				<span class="text-red-500" aria-label="required">*</span>
			{/if}
		</label>
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
</div>
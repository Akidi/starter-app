<script lang="ts">
	import { Flex, Stack } from '$lib/components/layout';
	import { getFormContext } from '$lib/contexts/form-context.svelte';

	interface Props {
		id: string;
		name: string;
		label: string;
		type?: 'date' | 'datetime-local' | 'time' | 'month' | 'week';
		value?: string | null;
		min?: string;
		max?: string;
		required?: boolean;
		disabled?: boolean;
		readonly?: boolean;
		error?: string;
		helpText?: string;
		oninput?: (e: Event) => void;
		onblur?: (e: FocusEvent) => void;
		onfocus?: (e: FocusEvent) => void;
		class?: string;
	}

	let {
		id,
		name,
		label,
		type = 'date',
		value = $bindable(''),
		min,
		max,
		required = false,
		disabled = false,
		readonly = false,
		error,
		helpText,
		oninput,
		onblur,
		onfocus,
		class: className = ''
	}: Props = $props();

	let inputValue = $derived(value ?? '');

	const formContext = getFormContext();
	const isDisabled = $derived(disabled || (formContext?.isSubmitting ?? false));

	const handleInput = (e: Event) => {
		if (!(e.currentTarget instanceof HTMLInputElement)) return;
		value = e.currentTarget.value || null;
		oninput?.(e);
	};

	const handleBlur = (e: FocusEvent) => {
		onblur?.(e);
	};

	const handleFocus = (e: FocusEvent) => {
		onfocus?.(e);
	};
</script>

<Stack gap="xs" class={className}>
	<label for={id}>
		{label}
		{#if required}
			<span class="required-indicator">*</span>
		{/if}
	</label>

	<input
		{id}
		{name}
		{type}
		{required}
		disabled={isDisabled}
		{readonly}
		{min}
		{max}
		value={inputValue}
		oninput={handleInput}
		onblur={handleBlur}
		onfocus={handleFocus}
		class:has-error={error}
		aria-describedby={helpText || error ? `${id}-description` : undefined}
		aria-invalid={error ? true : undefined}
		aria-required={required ? true : undefined}
	/>

	{#if error}
		<p id="{id}-description" class="error-message" role="alert" aria-live="polite">
			{error}
		</p>
	{:else if helpText}
		<p id="{id}-description" class="help-text">
			{helpText}
		</p>
	{/if}
</Stack>

<style>
	label {
		display: block;
		font-size: var(--font-size-sm);
		font-weight: var(--font-weight-medium);
		color: var(--text-primary);
	}

	.required-indicator {
		color: var(--color-error);
		margin-left: var(--space-xs);
	}

	input {
		display: block;
		width: 100%;
		padding: var(--space-sm) var(--space-md);
		border: 1px solid var(--border-primary);
		border-radius: var(--radius-md);
		background-color: var(--bg-primary);
		color: var(--text-primary);
		font-family: inherit;
		font-size: var(--font-size-base);
		transition:
			border-color var(--transition-fast),
			box-shadow var(--transition-fast);
	}

	input:focus {
		outline: none;
		border-color: var(--border-focus);
		box-shadow: 0 0 0 3px oklch(60% 0.18 250 / 0.1);
	}

	input:disabled {
		background-color: var(--bg-secondary);
		cursor: not-allowed;
		opacity: 0.6;
	}

	input:read-only {
		background-color: var(--bg-secondary);
		cursor: default;
	}

	input.has-error {
		border-color: var(--color-error);
	}

	input.has-error:focus {
		border-color: var(--color-error);
		box-shadow: 0 0 0 3px oklch(60% 0.22 25 / 0.1);
	}

	/* Style the calendar icon */
	input::-webkit-calendar-picker-indicator {
		cursor: pointer;
		opacity: 0.6;
		transition: opacity var(--transition-fast);
	}

	input::-webkit-calendar-picker-indicator:hover {
		opacity: 1;
	}

	.error-message {
		font-size: var(--font-size-sm);
		color: var(--color-error);
		margin: 0;
	}

	.help-text {
		font-size: var(--font-size-xs);
		color: var(--text-tertiary);
		margin: 0;
	}
</style>
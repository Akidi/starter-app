<script lang="ts">
	import type { Snippet } from 'svelte';
	import { Stack } from '$lib/components/layout';

	interface Props {
		legend: string;
		description?: string;
		error?: string;
		helpText?: string;
		required?: boolean;
		disabled?: boolean;
		class?: string;
		children: Snippet;
	}

	let {
		legend,
		description,
		error,
		helpText,
		required = false,
		disabled = false,
		class: className = '',
		children
	}: Props = $props();

	// Generate unique ID for aria-describedby
	const fieldsetId = `fieldset-${Math.random().toString(36).substr(2, 9)}`;
	const hasDescription = description || helpText || error;
</script>

<fieldset 
	class="fieldset {className}"
	{disabled}
	aria-describedby={hasDescription ? `${fieldsetId}-description` : undefined}
>
	<Stack gap="md">
		<div class="fieldset-header">
			<legend class="fieldset-legend">
				{legend}
				{#if required}
					<span class="required-indicator" aria-label="required">*</span>
				{/if}
			</legend>
			
			{#if description}
				<p class="fieldset-description">
					{description}
				</p>
			{/if}
		</div>

		<div class="fieldset-content">
			{@render children()}
		</div>

		{#if error || helpText}
			<div id="{fieldsetId}-description">
				{#if error}
					<p class="fieldset-error" role="alert" aria-live="polite">
						{error}
					</p>
				{:else if helpText}
					<p class="fieldset-help">
						{helpText}
					</p>
				{/if}
			</div>
		{/if}
	</Stack>
</fieldset>

<style>
	.fieldset {
		border: none;
		padding: 0;
		margin: 0;
		min-width: 0;
	}

	.fieldset:disabled {
		opacity: 0.6;
		cursor: not-allowed;
	}

	.fieldset-header {
		display: flex;
		flex-direction: column;
		gap: var(--space-xs);
	}

	.fieldset-legend {
		font-size: var(--font-size-base);
		font-weight: var(--font-weight-semibold);
		color: var(--text-primary);
		line-height: 1.5;
		padding: 0;
	}

	.fieldset:disabled .fieldset-legend {
		color: var(--text-disabled);
	}

	.required-indicator {
		color: var(--color-error);
		margin-left: var(--space-xs);
	}

	.fieldset-description {
		font-size: var(--font-size-sm);
		color: var(--text-secondary);
		margin: 0;
		line-height: 1.5;
	}

	.fieldset:disabled .fieldset-description {
		color: var(--text-disabled);
	}

	.fieldset-content {
		display: flex;
		flex-direction: column;
		gap: var(--space-md);
	}

	.fieldset-error {
		font-size: var(--font-size-sm);
		color: var(--color-error);
		margin: 0;
		line-height: 1.5;
	}

	.fieldset-help {
		font-size: var(--font-size-sm);
		color: var(--text-tertiary);
		margin: 0;
		line-height: 1.5;
	}

	.fieldset:disabled .fieldset-help {
		color: var(--text-disabled);
	}
</style>
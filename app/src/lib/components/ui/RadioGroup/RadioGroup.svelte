<script lang="ts">
	interface Props {
		id: string;
		name: string;
		label: string;
		value?: string;
		checked?: boolean;
		disabled?: boolean;
		required?: boolean;
		onchange?: (e: Event) => void;
		class?: string;
	}

	let {
		id,
		name,
		label,
		value = $bindable(''),
		checked = false,
		disabled = false,
		required = false,
		onchange,
		class: className = ''
	}: Props = $props();

	const handleChange = (e: Event) => {
		if (!(e.currentTarget instanceof HTMLInputElement)) return;
		value = e.currentTarget.value;
		onchange?.(e);
	};
</script>

<div class="radio-wrapper {className}">
	<div class="radio-input-wrapper">
		<input
			{id}
			{name}
			type="radio"
			value={value}
			{checked}
			{disabled}
			{required}
			onchange={handleChange}
		/>
	</div>
	<label
		for={id}
		class:disabled={disabled}
	>
		{label}
	</label>
</div>

<style>
	.radio-wrapper {
		display: flex;
		align-items: flex-start;
		gap: var(--space-md);
	}

	.radio-input-wrapper {
		display: flex;
		align-items: center;
		height: 1.25rem;
	}

	input[type="radio"] {
		width: 1rem;
		height: 1rem;
		border: 1px solid var(--border-secondary);
		cursor: pointer;
		transition: all var(--transition-fast);
		accent-color: var(--color-primary);
	}

	input[type="radio"]:focus {
		outline: none;
		box-shadow: 0 0 0 3px oklch(60% 0.18 250 / 0.1);
	}

	input[type="radio"]:disabled {
		cursor: not-allowed;
		opacity: 0.5;
	}

	label {
		font-size: var(--font-size-sm);
		font-weight: var(--font-weight-medium);
		color: var(--text-primary);
		cursor: pointer;
		user-select: none;
	}

	label.disabled {
		color: var(--text-tertiary);
		cursor: not-allowed;
	}
</style>

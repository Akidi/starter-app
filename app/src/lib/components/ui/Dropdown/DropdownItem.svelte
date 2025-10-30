<script lang="ts">
	interface Props {
		onclick?: () => void;
		disabled?: boolean;
		danger?: boolean;
		class?: string;
		children: any;
	}

	let {
		onclick,
		disabled = false,
		danger = false,
		class: className = '',
		children
	}: Props = $props();

	const handleClick = () => {
		if (!disabled && onclick) {
			onclick();
		}
	};
</script>

<button
	type="button"
	onclick={handleClick}
	disabled={disabled}
	class="dropdown-item {className}"
	class:danger={danger}
	class:disabled={disabled}
	role="menuitem"
	tabindex={disabled ? -1 : 0}
>
	{@render children()}
</button>

<style>
	.dropdown-item {
		display: flex;
		width: 100%;
		align-items: center;
		padding: var(--space-sm) var(--space-lg);
		text-align: left;
		font-size: var(--font-size-sm);
		color: var(--text-primary);
		background: transparent;
		border: none;
		transition: all var(--transition-fast);
		cursor: pointer;
	}

	.dropdown-item:hover:not(.disabled) {
		background-color: var(--bg-secondary);
	}

	.dropdown-item:focus {
		outline: none;
		background-color: var(--bg-secondary);
	}

	.dropdown-item.danger:not(.disabled) {
		color: var(--color-error);
	}

	.dropdown-item.danger:hover:not(.disabled),
	.dropdown-item.danger:focus:not(.disabled) {
		background-color: var(--color-error-light);
	}

	.dropdown-item.disabled {
		color: var(--text-disabled);
		cursor: not-allowed;
	}
</style>

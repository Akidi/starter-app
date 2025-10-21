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
	class="flex w-full items-center px-4 py-2 text-left text-sm transition-colors focus:outline-none {className}"
	class:text-gray-700={!danger && !disabled}
	class:hover:bg-gray-100={!disabled && !danger}
	class:focus:bg-gray-100={!disabled && !danger}
	class:text-red-700={danger && !disabled}
	class:hover:bg-red-50={danger && !disabled}
	class:focus:bg-red-50={danger && !disabled}
	class:text-gray-400={disabled}
	class:cursor-not-allowed={disabled}
	role="menuitem"
	tabindex={disabled ? -1 : 0}
>
	{@render children()}
</button>
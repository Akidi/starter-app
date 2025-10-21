<script lang="ts">
	interface Props {
		id: string;
		label: string;
		checked?: boolean;
		disabled?: boolean;
		size?: 'sm' | 'md' | 'lg';
		onchange?: (checked: boolean) => void;
		class?: string;
	}

	let {
		id,
		label,
		checked = $bindable(false),
		disabled = false,
		size = 'md',
		onchange,
		class: className = ''
	}: Props = $props();

	const toggle = () => {
		if (!disabled) {
			checked = !checked;
			onchange?.(checked);
		}
	};

	const sizeClasses = {
		sm: {
			switch: 'h-5 w-9',
			handle: 'h-4 w-4',
			translate: 'translate-x-4'
		},
		md: {
			switch: 'h-6 w-11',
			handle: 'h-5 w-5',
			translate: 'translate-x-5'
		},
		lg: {
			switch: 'h-7 w-14',
			handle: 'h-6 w-6',
			translate: 'translate-x-7'
		}
	};
</script>

<div class="flex items-center gap-3 {className}">
	<button
		type="button"
		role="switch"
		aria-checked={checked}
		aria-labelledby="{id}-label"
		onclick={toggle}
		disabled={disabled}
		class="relative inline-flex flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 {sizeClasses[size].switch}"
		class:bg-blue-600={checked && !disabled}
		class:bg-gray-200={!checked && !disabled}
		class:opacity-50={disabled}
		class:cursor-not-allowed={disabled}
	>
		<span class="sr-only">{label}</span>
		<span
			aria-hidden="true"
			class="pointer-events-none inline-block rounded-full bg-white shadow transform ring-0 transition duration-200 ease-in-out {sizeClasses[size].handle}"
			class:translate-x-0.5={!checked}
			class:{sizeClasses[size].translate}={checked}
		>
		</span>
	</button>

	<span
		id="{id}-label"
		class="text-sm font-medium select-none"
		class:text-gray-700={!disabled}
		class:text-gray-400={disabled}
	>
		{label}
	</span>
</div>
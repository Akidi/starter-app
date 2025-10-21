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

<div class="flex items-start gap-3 {className}">
	<div class="flex items-center h-5">
		<input
			{id}
			{name}
			type="radio"
			value={value}
			{checked}
			{disabled}
			{required}
			onchange={handleChange}
			class="h-4 w-4 border-gray-300 text-blue-600 transition-colors focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 focus:outline-none disabled:cursor-not-allowed disabled:opacity-50"
		/>
	</div>
	<label
		for={id}
		class="text-sm font-medium cursor-pointer select-none"
		class:text-gray-700={!disabled}
		class:text-gray-400={disabled}
	>
		{label}
	</label>
</div>
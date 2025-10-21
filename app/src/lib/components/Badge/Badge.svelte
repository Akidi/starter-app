<script lang="ts">
	interface Props {
		text: string;
		variant?: 'blue' | 'green' | 'amber' | 'red' | 'gray' | 'purple';
		size?: 'sm' | 'md' | 'lg';
		dot?: boolean;
		removable?: boolean;
		onRemove?: () => void;
		class?: string;
	}

	let { 
		text, 
		variant = 'blue',
		size = 'md',
		dot = false,
		removable = false,
		onRemove,
		class: className = ''
	}: Props = $props();

	const variantStyles = {
		blue: 'bg-blue-100 text-blue-700',
		green: 'bg-green-100 text-green-700',
		amber: 'bg-amber-100 text-amber-700',
		red: 'bg-red-100 text-red-700',
		gray: 'bg-gray-100 text-gray-700',
		purple: 'bg-purple-100 text-purple-700'
	};

	const dotStyles = {
		blue: 'bg-blue-600',
		green: 'bg-green-600',
		amber: 'bg-amber-600',
		red: 'bg-red-600',
		gray: 'bg-gray-600',
		purple: 'bg-purple-600'
	};

	const sizeStyles = {
		sm: 'px-1.5 py-0.5 text-xs',
		md: 'px-2 py-0.5 text-xs',
		lg: 'px-2.5 py-1 text-sm'
	};

	const handleRemove = (e: MouseEvent) => {
		e.stopPropagation();
		onRemove?.();
	};
</script>

<span
	class="inline-flex items-center gap-1 rounded-full font-semibold uppercase tracking-wide {variantStyles[variant]} {sizeStyles[size]} {className}"
	role="status"
	aria-label={text}
>
	{#if dot}
		<span 
			class="h-1.5 w-1.5 rounded-full {dotStyles[variant]}"
			aria-hidden="true"
		></span>
	{/if}
	<span>{text}</span>
	{#if removable && onRemove}
		<button
			type="button"
			onclick={handleRemove}
			class="ml-0.5 inline-flex items-center justify-center rounded-full hover:bg-black/10 focus:outline-none focus:ring-2 focus:ring-offset-1 focus:ring-current transition-colors"
			class:h-3={size === 'sm'}
			class:w-3={size === 'sm'}
			class:h-3.5={size === 'md'}
			class:w-3.5={size === 'md'}
			class:h-4={size === 'lg'}
			class:w-4={size === 'lg'}
			aria-label="Remove {text}"
		>
			<svg 
				class="h-2.5 w-2.5" 
				fill="none" 
				viewBox="0 0 24 24" 
				stroke="currentColor"
				aria-hidden="true"
			>
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M6 18L18 6M6 6l12 12" />
			</svg>
		</button>
	{/if}
</span>
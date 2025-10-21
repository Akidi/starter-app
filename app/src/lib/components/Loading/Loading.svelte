<script lang="ts">
	interface Props {
		size?: 'sm' | 'md' | 'lg' | 'xl';
		variant?: 'primary' | 'secondary' | 'white';
		text?: string;
		centered?: boolean;
		fullscreen?: boolean;
		class?: string;
	}

	let {
		size = 'md',
		variant = 'primary',
		text,
		centered = false,
		fullscreen = false,
		class: className = ''
	}: Props = $props();

	const sizeClasses = {
		sm: 'h-4 w-4',
		md: 'h-8 w-8',
		lg: 'h-12 w-12',
		xl: 'h-16 w-16'
	};

	const variantClasses = {
		primary: 'text-blue-600',
		secondary: 'text-gray-600',
		white: 'text-white'
	};
</script>

{#if fullscreen}
	<div class="fixed inset-0 z-50 flex items-center justify-center bg-white/80 backdrop-blur-sm">
		<div class="flex flex-col items-center gap-3">
			<svg
				class="animate-spin {sizeClasses[size]} {variantClasses[variant]}"
				xmlns="http://www.w3.org/2000/svg"
				fill="none"
				viewBox="0 0 24 24"
				role="status"
				aria-label="Loading"
			>
				<circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
				<path
					class="opacity-75"
					fill="currentColor"
					d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
				></path>
			</svg>
			{#if text}
				<p class="text-sm font-medium text-gray-700">{text}</p>
			{/if}
		</div>
	</div>
{:else}
	<div
		class="flex items-center gap-3 {className}"
		class:justify-center={centered}
		role="status"
		aria-label="Loading"
	>
		<svg
			class="animate-spin {sizeClasses[size]} {variantClasses[variant]}"
			xmlns="http://www.w3.org/2000/svg"
			fill="none"
			viewBox="0 0 24 24"
		>
			<circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
			<path
				class="opacity-75"
				fill="currentColor"
				d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
			></path>
		</svg>
		{#if text}
			<span class="text-sm font-medium text-gray-700">{text}</span>
		{/if}
	</div>
{/if}
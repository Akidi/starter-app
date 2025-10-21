<script lang="ts">
	interface Props {
		href: string;
		external?: boolean;
		active?: boolean;
		children: any;
	}

	let { href, external = false, active = false, children }: Props = $props();
</script>

<a
	{href}
	target={external ? '_blank' : undefined}
	rel={external ? 'noopener noreferrer' : undefined}
	class="inline-flex items-center border-b-2 px-1 pt-1 text-sm font-medium transition-colors {active
		? 'border-blue-500 text-gray-900'
		: 'border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700'}"
>
	{@render children()}
	{#if external}
		<svg class="ml-1 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
			<path
				stroke-linecap="round"
				stroke-linejoin="round"
				stroke-width="2"
				d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"
			/>
		</svg>
	{/if}
</a>

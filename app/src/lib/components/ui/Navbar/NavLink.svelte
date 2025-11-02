<script lang="ts">
	interface Props {
		href: string;
		external?: boolean;
		onclick?: () => void;
		class?: string;
		children: any;
	}

	let { href, external = false, onclick, class: className = '', children }: Props = $props();
</script>
<a
	{href}
	target={external ? '_blank' : undefined}
	rel={external ? 'noopener noreferrer' : undefined}
	onclick={onclick}
	class={className}
>
	{@render children()}
	{#if external}
		<svg class="external-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
			<path
				stroke-linecap="round"
				stroke-linejoin="round"
				stroke-width="2"
				d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"
			/>
		</svg>
	{/if}
</a>

<style>
	.external-icon {
		display: inline;
		width: 1rem;
		height: 1rem;
		margin-left: var(--space-xs);
	}
</style>

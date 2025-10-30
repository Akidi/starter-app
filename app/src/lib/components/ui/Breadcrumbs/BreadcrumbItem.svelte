<script lang="ts">
	interface Props {
		href?: string;
		current?: boolean;
		class?: string;
		children: any;
	}

	let {
		href,
		current = false,
		class: className = '',
		children
	}: Props = $props();
</script>

<li class={className}>
	{#if current || !href}
		<span aria-current={current ? 'page' : undefined}>
			{@render children()}
		</span>
	{:else}
		<a {href}>
			{@render children()}
		</a>
	{/if}
</li>
<script lang="ts">
	interface Props {
		size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl';
	}

	let { 
		size = 'md'
	}: Props = $props();
</script>

<div class="spacer" data-size={size}></div>

<style>
	.spacer[data-size="xs"] { height: var(--space-xs); }
	.spacer[data-size="sm"] { height: var(--space-sm); }
	.spacer[data-size="md"] { height: var(--space-md); }
	.spacer[data-size="lg"] { height: var(--space-lg); }
	.spacer[data-size="xl"] { height: var(--space-xl); }
</style>
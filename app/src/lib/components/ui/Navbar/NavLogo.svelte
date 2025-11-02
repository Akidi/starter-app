<script lang="ts">
	interface Props {
		href?: string;
		text: string;
	}

	let { href = '/', text }: Props = $props();
</script>

<div class="nav-logo">
	<a {href} class="nav-logo-link">{text}</a>
</div>

<style>
	.nav-logo {
		display: flex;
		flex-shrink: 0;
		align-items: center;
	}

	.nav-logo-link {
		font-size: var(--font-size-xl);
		font-weight: var(--font-weight-bold);
		color: var(--text-primary);
		text-decoration: none;
	}
</style>

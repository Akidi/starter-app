<script lang="ts">
	interface Props {
		name?: string;
	}

	let { name = 'World' }: Props = $props();
</script>

<h1>Hello {name}</h1>

<script lang="ts">
	interface Props {
		href?: string;
		text: string;
	}

	let { href = '/', text }: Props = $props();
</script>

<div class="flex flex-shrink-0 items-center">
	<a {href} class="text-xl font-bold text-gray-900">{text}</a>
</div>

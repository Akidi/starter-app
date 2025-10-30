<!-- Form.svelte -->
<script lang="ts">
	import type { Snippet } from 'svelte';
	import type { SubmitFunction } from '@sveltejs/kit';
	import { enhance } from '$app/forms';

	interface Props {
		action?: string;
		method?: 'get' | 'post' | 'dialog';
		enctype?: 'application/x-www-form-urlencoded' | 'multipart/form-data' | 'text/plain';
		enhance?: SubmitFunction;
		novalidate?: boolean;
		target?: string;
		autocomplete?: 'on' | 'off';
		class?: string;
		children: Snippet;
		onsubmit?: (event: SubmitEvent & { currentTarget: HTMLFormElement }) => void;
		onreset?: (event: Event & { currentTarget: HTMLFormElement }) => void;
	}

	let {
		action,
		method = 'post',
		enctype,
		enhance: enhanceFunction,
		novalidate = false,
		target,
		autocomplete,
		class: className = '',
		children,
		onsubmit,
		onreset,
		...restProps
	}: Props = $props();
</script>

<form
	{action}
	{method}
	{enctype}
	{novalidate}
	{target}
	{autocomplete}
	class={className}
	use:enhance={enhanceFunction}
	{onsubmit}
	{onreset}
	{...restProps}
>
	{@render children()}
</form>
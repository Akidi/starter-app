<script lang="ts">
	import { toasts } from '$lib/stores/toasts';
	import Toast from './Toast.svelte';
</script>

<div
	aria-live="polite"
	aria-atomic="false"
	class="pointer-events-none fixed bottom-0 right-0 z-50 flex flex-col items-end gap-3 p-4 sm:p-6"
	role="region"
	aria-label="Notifications"
>
	{#each $toasts.toasts as toast (toast.id)}
		<Toast
			id={toast.id}
			type={toast.type}
			message={toast.message}
			duration={toast.duration}
			onClose={toasts.remove}
		/>
	{/each}
</div>
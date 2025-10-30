<script lang="ts">
	import { toasts } from '$lib/stores/toasts';
	import Toast from './Toast.svelte';
</script>

<div
	aria-live="polite"
	aria-atomic="false"
	class="toast-container"
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

<style>
	.toast-container {
		pointer-events: none;
		position: fixed;
		bottom: 0;
		right: 0;
		z-index: 50;
		display: flex;
		flex-direction: column;
		align-items: flex-end;
		gap: var(--space-md);
		padding: var(--space-lg);
	}

	@media (min-width: 640px) {
		.toast-container {
			padding: var(--space-2xl);
		}
	}
</style>

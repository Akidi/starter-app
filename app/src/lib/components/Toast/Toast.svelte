<script lang="ts">
	import { fly } from 'svelte/transition';
	import { onMount } from 'svelte';
	import type { ToastType } from '$lib/stores/toasts';

	interface Props {
		id: string;
		type: ToastType;
		message: string;
		duration?: number;
		onClose: (id: string) => void;
	}

	let { id, type, message, duration, onClose }: Props = $props();

	let progress = $state(100);
	let isPaused = $state(false);
	let animationFrame: number;
	let startTime = $state(0);
	let totalElapsed = $state(0);

	onMount(() => {
		if (duration) {
			startTime = Date.now();
			
			const animate = () => {
				if (!isPaused) {
					const now = Date.now();
					const elapsed = now - startTime;
					const currentElapsed = totalElapsed + elapsed;
					const remaining = Math.max(0, 100 - (currentElapsed / duration) * 100);
					progress = remaining;
					
					if (remaining > 0) {
						animationFrame = requestAnimationFrame(animate);
					} else {
						onClose(id);
					}
				} else {
					// Keep animating even when paused to maintain smooth updates
					animationFrame = requestAnimationFrame(animate);
				}
			};
			
			animationFrame = requestAnimationFrame(animate);
			
			return () => {
				if (animationFrame) {
					cancelAnimationFrame(animationFrame);
				}
			};
		}
	});

	const handleMouseEnter = () => {
		if (duration && !isPaused) {
			isPaused = true;
			// Accumulate the elapsed time before pausing
			const now = Date.now();
			totalElapsed += (now - startTime);
		}
	};

	const handleMouseLeave = () => {
		if (duration && isPaused) {
			isPaused = false;
			// Reset startTime to now so we start measuring from this point
			startTime = Date.now();
		}
	};

	const icons = {
		success: {
			path: 'M5 13l4 4L19 7',
			label: 'Success'
		},
		error: {
			path: 'M6 18L18 6M6 6l12 12',
			label: 'Error'
		},
		warning: {
			path: 'M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z',
			label: 'Warning'
		},
		info: {
			path: 'M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z',
			label: 'Information'
		}
	};

	const styles = {
		success: 'bg-green-50 border-green-200 text-green-800',
		error: 'bg-red-50 border-red-200 text-red-800',
		warning: 'bg-amber-50 border-amber-200 text-amber-800',
		info: 'bg-blue-50 border-blue-200 text-blue-800'
	};

	const iconStyles = {
		success: 'bg-green-100 text-green-600',
		error: 'bg-red-100 text-red-600',
		warning: 'bg-amber-100 text-amber-600',
		info: 'bg-blue-100 text-blue-600'
	};

	const progressStyles = {
		success: 'bg-green-600',
		error: 'bg-red-600',
		warning: 'bg-amber-600',
		info: 'bg-blue-600'
	};
</script>

<div
	role="status"
	aria-live="polite"
	aria-atomic="true"
	transition:fly={{ x: 300, duration: 300 }}
	onmouseenter={handleMouseEnter}
	onmouseleave={handleMouseLeave}
	class="pointer-events-auto relative flex min-w-0 max-w-sm items-start gap-3 rounded-lg border-2 p-4 shadow-lg transition-transform hover:scale-105 {styles[type]}"
>
	{#if duration}
		<div
			class="absolute bottom-0 left-0 h-1 {progressStyles[type]} ease-linear"
			style="width: {progress}%; transition: width {isPaused ? '0ms' : '100ms'}"
			role="progressbar"
			aria-valuenow={Math.round(progress)}
			aria-valuemin={0}
			aria-valuemax={100}
			aria-label="Time remaining"
		></div>
	{/if}
	
	<div
		class="flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-full {iconStyles[type]}"
		aria-hidden="true"
	>
		<svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
			<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d={icons[type].path} />
		</svg>
	</div>
	
	<div class="flex-1 pt-0.5 min-w-0">
		<p class="text-sm font-medium leading-snug break-words">{message}</p>
	</div>
	
	<button
		type="button"
		onclick={() => onClose(id)}
		class="flex-shrink-0 rounded-md p-1 transition-colors hover:bg-black/5 focus:ring-2 focus:ring-offset-2 focus:outline-none"
		aria-label="Close {icons[type].label.toLowerCase()} notification"
	>
		<svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
			<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
		</svg>
	</button>
</div>
<script lang="ts">
	import type { Snippet } from 'svelte';
	import { onMount } from 'svelte';

	interface Props {
		isOpen: boolean;
		onClose: () => void;
		title: string;
		description?: string;
		maxWidth?: 'sm' | 'md' | 'lg' | 'xl' | '2xl' | 'full';
		closeOnEscape?: boolean;
		closeOnBackdrop?: boolean;
		showCloseButton?: boolean;
		children: Snippet;
		footer?: Snippet;
	}

	let { 
		isOpen, 
		onClose, 
		title, 
		description,
		maxWidth = 'lg', 
		closeOnEscape = true,
		closeOnBackdrop = true,
		showCloseButton = true,
		children,
		footer
	}: Props = $props();

	const maxWidthClasses = {
		sm: 'max-w-sm',
		md: 'max-w-md',
		lg: 'max-w-lg',
		xl: 'max-w-xl',
		'2xl': 'max-w-2xl',
		full: 'max-w-full mx-4'
	};

	let modalElement = $state<HTMLDivElement>();
	let previousActiveElement: HTMLElement | null = null;

	// Generate unique IDs for ARIA
	const titleId = `modal-title-${Math.random().toString(36).substr(2, 9)}`;
	const descriptionId = description ? `modal-description-${Math.random().toString(36).substr(2, 9)}` : undefined;

	// Handle escape key
	const handleKeydown = (e: KeyboardEvent) => {
		if (closeOnEscape && e.key === 'Escape' && isOpen) {
			e.preventDefault();
			onClose();
		}
	};

	// Handle backdrop click
	const handleBackdropClick = (e: MouseEvent) => {
		if (closeOnBackdrop && e.target === e.currentTarget) {
			onClose();
		}
	};

	// Focus management and body scroll lock
	$effect(() => {
		if (isOpen) {
			// Store the element that had focus before opening modal
			previousActiveElement = document.activeElement as HTMLElement;
			
			// Prevent body scroll
			document.body.style.overflow = 'hidden';
			
			// Focus the modal
			setTimeout(() => {
				modalElement?.focus();
			}, 0);

			// Add escape key listener
			document.addEventListener('keydown', handleKeydown);

			return () => {
				// Restore body scroll
				document.body.style.overflow = '';
				
				// Remove escape key listener
				document.removeEventListener('keydown', handleKeydown);
				
				// Restore focus to previous element
				if (previousActiveElement) {
					previousActiveElement.focus();
				}
			};
		}
	});
</script>

{#if isOpen}
	<!-- Portal-like wrapper -->
	<div 
		class="fixed inset-0 z-50 overflow-y-auto"
		role="dialog"
		aria-modal="true"
		aria-labelledby={titleId}
		aria-describedby={descriptionId}
	>
		<div class="flex min-h-screen items-center justify-center p-4">
			<!-- Background overlay -->
			<div
				class="fixed inset-0 bg-gray-900/50 backdrop-blur-sm transition-opacity"
				onclick={handleBackdropClick}
				aria-hidden="true"
			></div>

			<!-- Modal panel -->
			<div
				bind:this={modalElement}
				class="relative z-10 w-full bg-white rounded-lg shadow-2xl transform transition-all {maxWidthClasses[maxWidth]}"
				tabindex="-1"
			>
				<!-- Header -->
				<div class="flex items-start justify-between p-6 border-b border-gray-200">
					<div class="flex-1">
						<h2 id={titleId} class="text-lg font-semibold text-gray-900">
							{title}
						</h2>
						{#if description}
							<p id={descriptionId} class="mt-1 text-sm text-gray-500">
								{description}
							</p>
						{/if}
					</div>
					{#if showCloseButton}
						<button
							type="button"
							onclick={onClose}
							class="ml-4 rounded-md text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-colors"
							aria-label="Close dialog"
						>
							<svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
								<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
							</svg>
						</button>
					{/if}
				</div>

				<!-- Content -->
				<div class="p-6">
					{@render children()}
				</div>

				<!-- Footer -->
				{#if footer}
					<div class="flex items-center justify-end gap-3 p-6 border-t border-gray-200 bg-gray-50">
						{@render footer()}
					</div>
				{/if}
			</div>
		</div>
	</div>
{/if}
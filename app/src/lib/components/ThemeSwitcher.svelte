<script lang="ts">
	import { Toggle } from '$lib/components/ui';
	import { createLocalStorageStore } from '$lib/utils/localStorage.svelte';
	import { onMount } from 'svelte';

	interface Props {
		variant?: 'toggle' | 'icon' | 'button';
		size?: 'sm' | 'md' | 'lg';
		class?: string;
		showLabel?: boolean;
		label?: string;
		transition?: 'fade' | 'slide' | 'scale' | 'none' | 'view-transition';
		duration?: number;
	}

	let {
		variant = 'toggle',
		size = 'md',
		class: className = '',
		showLabel = true,
		label = 'Dark Mode',
		transition = 'view-transition',
		duration = 300
	}: Props = $props();

	const themeStore = createLocalStorageStore<'light' | 'dark'>('theme', 'light', {
		prefix: 'app'
	});

	let isDarkMode = $derived(themeStore.value === 'dark');

	const applyTheme = (theme: 'light' | 'dark') => {
		if (typeof document !== 'undefined') {
			document.documentElement.setAttribute('data-theme', theme);
			
			// Also add class for additional CSS targeting if needed
			if (theme === 'dark') {
				document.documentElement.classList.add('dark');
			} else {
				document.documentElement.classList.remove('dark');
			}
		}
	};

	onMount(() => {
		applyTheme(themeStore.value);
	});

	const handleToggle = (checked: boolean) => {
		themeStore.value = checked ? 'dark' : 'light';
	};

	const handleButtonClick = () => {
		themeStore.value = themeStore.value === 'dark' ? 'light' : 'dark';
	};

	let isInitialRender = $state(true);

// Watch for theme changes and apply them with transition
$effect(() => {
	if (isInitialRender) {
		// Don't transition on initial load
		isInitialRender = false;
		applyTheme(themeStore.value);
	} else {
		// Transition when user changes theme
		applyThemeWithTransition(themeStore.value);
	}
});

	const supportsViewTransitions = $derived(
		typeof document !== 'undefined' && 
		'startViewTransition' in document
	);

	const applyThemeWithTransition = (theme: 'light' | 'dark') => {
		if (typeof document === 'undefined') return;

		if (transition === 'view-transition' && supportsViewTransitions) {
			document.startViewTransition(() => {
				applyTheme(theme);
			});
		} else if (transition !== 'none') {
			// Use CSS transition fallback
			document.documentElement.classList.add('theme-transitioning');
			
			// Apply theme after a brief delay to ensure transition
			requestAnimationFrame(() => {
				applyTheme(theme);
				
				// Remove transition class after animation completes
				setTimeout(() => {
					document.documentElement.classList.remove('theme-transitioning');
				}, duration);
			});
		} else {
			// No transition
			applyTheme(theme);
		}
	};
</script>

<div class="theme-switcher {className}" data-variant={variant}>
	{#if variant === 'toggle'}
		<Toggle
			id="theme-toggle"
			label={showLabel ? label : 'Toggle theme'}
			description={showLabel ? `Switch to ${isDarkMode ? 'light' : 'dark'} mode` : undefined}
			checked={isDarkMode}
			onchange={handleToggle}
			{size}
		/>
	{:else if variant === 'icon'}
		<button
			type="button"
			onclick={handleButtonClick}
			class="icon-button"
			data-size={size}
			aria-label={`Switch to ${isDarkMode ? 'light' : 'dark'} mode`}
			title={`Switch to ${isDarkMode ? 'light' : 'dark'} mode`}
		>
			{#if isDarkMode}
				<!-- Sun icon for light mode -->
				<svg
					xmlns="http://www.w3.org/2000/svg"
					width="24"
					height="24"
					viewBox="0 0 24 24"
					fill="none"
					stroke="currentColor"
					stroke-width="2"
					stroke-linecap="round"
					stroke-linejoin="round"
					class="icon"
				>
					<circle cx="12" cy="12" r="4"></circle>
					<path d="M12 2v2"></path>
					<path d="M12 20v2"></path>
					<path d="m4.93 4.93 1.41 1.41"></path>
					<path d="m17.66 17.66 1.41 1.41"></path>
					<path d="M2 12h2"></path>
					<path d="M20 12h2"></path>
					<path d="m6.34 17.66-1.41 1.41"></path>
					<path d="m19.07 4.93-1.41 1.41"></path>
				</svg>
			{:else}
				<!-- Moon icon for dark mode -->
				<svg
					xmlns="http://www.w3.org/2000/svg"
					width="24"
					height="24"
					viewBox="0 0 24 24"
					fill="none"
					stroke="currentColor"
					stroke-width="2"
					stroke-linecap="round"
					stroke-linejoin="round"
					class="icon"
				>
					<path d="M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z"></path>
				</svg>
			{/if}
		</button>
	{:else if variant === 'button'}
		<button
			type="button"
			onclick={handleButtonClick}
			class="text-button"
			data-size={size}
			aria-label={`Switch to ${isDarkMode ? 'light' : 'dark'} mode`}
		>
			{#if isDarkMode}
				<svg
					xmlns="http://www.w3.org/2000/svg"
					width="20"
					height="20"
					viewBox="0 0 24 24"
					fill="none"
					stroke="currentColor"
					stroke-width="2"
					stroke-linecap="round"
					stroke-linejoin="round"
					class="button-icon"
				>
					<circle cx="12" cy="12" r="4"></circle>
					<path d="M12 2v2"></path>
					<path d="M12 20v2"></path>
					<path d="m4.93 4.93 1.41 1.41"></path>
					<path d="m17.66 17.66 1.41 1.41"></path>
					<path d="M2 12h2"></path>
					<path d="M20 12h2"></path>
					<path d="m6.34 17.66-1.41 1.41"></path>
					<path d="m19.07 4.93-1.41 1.41"></path>
				</svg>
				<span>Light</span>
			{:else}
				<svg
					xmlns="http://www.w3.org/2000/svg"
					width="20"
					height="20"
					viewBox="0 0 24 24"
					fill="none"
					stroke="currentColor"
					stroke-width="2"
					stroke-linecap="round"
					stroke-linejoin="round"
					class="button-icon"
				>
					<path d="M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z"></path>
				</svg>
				<span>Dark</span>
			{/if}
		</button>
	{/if}
</div>

<style>
	.theme-switcher {
		display: inline-block;
	}

	.icon-button {
		display: inline-flex;
		align-items: center;
		justify-content: center;
		border-radius: var(--radius-md);
		background-color: transparent;
		border: none;
		color: var(--text-secondary);
		cursor: pointer;
		transition: all var(--transition-fast);
		padding: var(--space-sm);
	}

	.icon-button:hover {
		background-color: var(--bg-secondary);
		color: var(--text-primary);
	}

	.icon-button:focus-visible {
		outline: 2px solid var(--border-focus);
		outline-offset: 2px;
	}

	.icon-button[data-size='sm'] {
		padding: var(--space-xs);
	}

	.icon-button[data-size='sm'] .icon {
		width: 1rem;
		height: 1rem;
	}

	.icon-button[data-size='md'] {
		padding: var(--space-sm);
	}

	.icon-button[data-size='md'] .icon {
		width: 1.25rem;
		height: 1.25rem;
	}

	.icon-button[data-size='lg'] {
		padding: var(--space-md);
	}

	.icon-button[data-size='lg'] .icon {
		width: 1.5rem;
		height: 1.5rem;
	}

	.text-button {
		display: inline-flex;
		align-items: center;
		gap: var(--space-sm);
		padding: var(--space-sm) var(--space-md);
		border-radius: var(--radius-md);
		background-color: var(--bg-secondary);
		border: 1px solid var(--border-primary);
		color: var(--text-primary);
		font-size: var(--font-size-sm);
		font-weight: var(--font-weight-medium);
		cursor: pointer;
		transition: all var(--transition-fast);
	}

	.text-button:hover {
		background-color: var(--bg-tertiary);
		border-color: var(--border-secondary);
	}

	.text-button:focus-visible {
		outline: 2px solid var(--border-focus);
		outline-offset: 2px;
	}

	.text-button[data-size='sm'] {
		padding: var(--space-xs) var(--space-sm);
		font-size: var(--font-size-xs);
		gap: var(--space-xs);
	}

	.text-button[data-size='sm'] .button-icon {
		width: 0.875rem;
		height: 0.875rem;
	}

	.text-button[data-size='md'] {
		padding: var(--space-sm) var(--space-md);
		font-size: var(--font-size-sm);
		gap: var(--space-sm);
	}

	.text-button[data-size='md'] .button-icon {
		width: 1rem;
		height: 1rem;
	}

	.text-button[data-size='lg'] {
		padding: var(--space-md) var(--space-lg);
		font-size: var(--font-size-base);
		gap: var(--space-sm);
	}

	.text-button[data-size='lg'] .button-icon {
		width: 1.25rem;
		height: 1.25rem;
	}

	.icon,
	.button-icon {
		flex-shrink: 0;
		transition: transform var(--transition-base);
	}

	.icon-button:hover .icon,
	.text-button:hover .button-icon {
		transform: rotate(15deg);
	}
</style>
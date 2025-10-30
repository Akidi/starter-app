<script lang="ts">
	import type { Snippet } from "svelte";

	interface Props {
		side?: 'left' | 'right';
		sidebarWidth?: string;
		gap?: 'xs' | 'sm' | 'md' | 'lg' | 'xl';
		sidebar: Snippet;
		children: Snippet;
	}

	let { 
		side = 'left',
		sidebarWidth = '250px',
		gap = 'md',
		sidebar,
		children 
	}: Props = $props();
</script>

<div class="sidebar-layout" data-side={side} data-gap={gap} style="--sidebar-width: {sidebarWidth}">
	<aside class="sidebar">
		{@render sidebar()}
	</aside>
	<main class="content">
		{@render children()}
	</main>
</div>

<style>
	.sidebar-layout {
		display: grid;
		grid-template-columns: var(--sidebar-width) 1fr;
	}
	
	.sidebar-layout[data-side="right"] {
		grid-template-columns: 1fr var(--sidebar-width);
	}
	
	.sidebar-layout[data-side="right"] .sidebar {
		order: 2;
	}
	
	.sidebar-layout[data-gap="xs"] { gap: var(--space-xs); }
	.sidebar-layout[data-gap="sm"] { gap: var(--space-sm); }
	.sidebar-layout[data-gap="md"] { gap: var(--space-md); }
	.sidebar-layout[data-gap="lg"] { gap: var(--space-lg); }
	.sidebar-layout[data-gap="xl"] { gap: var(--space-xl); }
	
	@media (max-width: 768px) {
		.sidebar-layout {
			grid-template-columns: 1fr;
		}
		
		.sidebar-layout[data-side="right"] .sidebar {
			order: 0;
		}
	}
</style>
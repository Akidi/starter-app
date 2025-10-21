<script lang="ts">
	import type { NavItem } from '$lib/types/navigation';

	interface Props {
		items: NavItem[];
		isCurrentPage: (href: string) => boolean;
		isNavItemActive: (item: NavItem) => boolean;
	}

	let { items, isCurrentPage, isNavItemActive }: Props = $props();
</script>

<div class="sm:hidden" id="mobile-menu">
	<div class="space-y-1 pt-2 pb-3">
		{#each items as item (item.name)}
			{#if item.children?.length}
				<details class="group">
					<summary
						class="flex cursor-pointer items-center justify-between border-l-4 py-2 pr-4 pl-3 text-base font-medium transition-colors focus:outline-none [list-style:none] [&::-webkit-details-marker]:hidden {isNavItemActive(
							item
						)
							? 'border-blue-500 bg-blue-50 text-blue-700'
							: 'border-transparent text-gray-500 hover:border-gray-300 hover:bg-gray-50 hover:text-gray-700'}"
					>
						<span>{item.name}</span>
						<svg class="h-4 w-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path
								stroke-linecap="round"
								stroke-linejoin="round"
								stroke-width="2"
								d="M19 9l-7 7-7-7"
							/>
						</svg>
					</summary>
					<div class="space-y-1 border-l-4 border-blue-100 bg-blue-50/60 py-1 pl-6 pr-4">
						{#each item.children as child (child.name)}
							<a
								href={child.href}
								target={child.external ? '_blank' : undefined}
								rel={child.external ? 'noopener noreferrer' : undefined}
								class="block border-l-4 py-2 pr-3 pl-3 text-sm font-medium {isCurrentPage(child.href)
									? 'border-blue-500 text-blue-700'
									: 'border-transparent text-gray-600 hover:border-blue-200 hover:bg-blue-50 hover:text-gray-900'}"
							>
								{child.name}
							</a>
						{/each}
					</div>
				</details>
			{:else if item.external}
				<a
					href={item.href}
					target="_blank"
					rel="noopener noreferrer"
					class="block border-l-4 border-transparent py-2 pr-4 pl-3 text-base font-medium text-gray-500 hover:border-gray-300 hover:bg-gray-50 hover:text-gray-700"
				>
					{item.name}
				</a>
			{:else if item.href}
				<a
					href={item.href}
					class="block border-l-4 py-2 pr-4 pl-3 text-base font-medium {isCurrentPage(item.href)
						? 'border-blue-500 bg-blue-50 text-blue-700'
						: 'border-transparent text-gray-500 hover:border-gray-300 hover:bg-gray-50 hover:text-gray-700'}"
				>
					{item.name}
				</a>
			{:else}
				<span class="block border-l-4 border-transparent py-2 pr-4 pl-3 text-base font-medium text-gray-500">
					{item.name}
				</span>
			{/if}
		{/each}
	</div>
</div>

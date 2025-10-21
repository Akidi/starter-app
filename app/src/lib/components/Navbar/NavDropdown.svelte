<script lang="ts">
	import type { NavChild } from '$lib/types/navigation';

	interface Props {
		name: string;
		children: NavChild[];
		active?: boolean;
	}

	let { name, children, active = false }: Props = $props();
</script>

<details class="group relative list-none">
	<summary
		class="inline-flex cursor-pointer items-center gap-1 border-b-2 px-1 pt-1 text-sm font-medium transition-colors focus-visible:border-blue-500 focus-visible:text-gray-900 focus:outline-none [list-style:none] [&::-webkit-details-marker]:hidden {active
			? 'border-blue-500 text-gray-900'
			: 'border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700'}"
	>
		{name}
		<svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
			<path
				stroke-linecap="round"
				stroke-linejoin="round"
				stroke-width="2"
				d="M19 9l-7 7-7-7"
			/>
		</svg>
	</summary>
	<div
		class="absolute left-1/2 z-20 mt-3 w-64 -translate-x-1/2 rounded-lg border border-gray-200 bg-white shadow-lg"
	>
		<div class="py-2">
			{#each children as child (child.name)}
				<a
					href={child.href}
					target={child.external ? '_blank' : undefined}
					rel={child.external ? 'noopener noreferrer' : undefined}
					class="block px-4 py-2 text-sm text-gray-700 transition-colors hover:bg-gray-50 hover:text-gray-900"
				>
					<div class="font-medium">{child.name}</div>
					{#if child.description}
						<p class="mt-1 text-xs text-gray-500">{child.description}</p>
					{/if}
				</a>
			{/each}
		</div>
	</div>
</details>

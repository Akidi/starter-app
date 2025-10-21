<script lang="ts">
	import { page } from '$app/stores';
	import type { NavItem } from '$lib/types/navigation';
	import NavLogo from './NavLogo.svelte';
	import NavLink from './NavLink.svelte';
	import NavDropdown from './NavDropdown.svelte';
	import MobileMenu from './MobileMenu.svelte';

	interface Props {
		logo?: string;
		items: NavItem[];
	}

	let { logo = 'Starter App', items }: Props = $props();

	function isCurrentPage(href: string) {
		if (href === '/') {
			return $page.url.pathname === '/';
		}
		return $page.url.pathname.startsWith(href);
	}

	function isNavItemActive(item: NavItem) {
		if (item.href) {
			return isCurrentPage(item.href);
		}

		if (item.children?.length) {
			return item.children.some((child) => isCurrentPage(child.href));
		}

		return false;
	}
</script>

<nav class="border-b border-gray-200 bg-white shadow-sm">
	<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
		<div class="flex h-16 justify-between">
			<div class="flex">
				<!-- Logo/Brand -->
				<NavLogo text={logo} />

				<!-- Desktop Navigation Links -->
				<div class="hidden sm:ml-6 sm:flex sm:items-center sm:space-x-6">
					{#each items as item (item.name)}
						{#if item.children?.length}
							<NavDropdown name={item.name} children={item.children} active={isNavItemActive(item)} />
						{:else if item.href}
							<NavLink href={item.href} external={item.external} active={isCurrentPage(item.href)}>
								{item.name}
							</NavLink>
						{:else}
							<span class="inline-flex items-center border-b-2 border-transparent px-1 pt-1 text-sm font-medium text-gray-500">
								{item.name}
							</span>
						{/if}
					{/each}
				</div>
			</div>

			<!-- Mobile menu button -->
			<div class="flex items-center sm:hidden">
				<button
					type="button"
					class="inline-flex items-center justify-center rounded-md p-2 text-gray-400 hover:bg-gray-100 hover:text-gray-500 focus:ring-2 focus:ring-blue-500 focus:outline-none focus:ring-inset"
					aria-controls="mobile-menu"
					aria-expanded="false"
				>
					<span class="sr-only">Open main menu</span>
					<svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							stroke-width="2"
							d="M4 6h16M4 12h16M4 18h16"
						/>
					</svg>
				</button>
			</div>
		</div>
	</div>

	<!-- Mobile menu -->
	<MobileMenu {items} {isCurrentPage} {isNavItemActive} />
</nav>

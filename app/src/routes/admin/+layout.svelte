<script lang="ts">
	import type { Snippet } from 'svelte';
	import type { LayoutData } from './$types';
	import { page } from '$app/stores';
	import { Container, Stack } from '$lib/components/layout';

	interface Props {
		data: LayoutData;
		children: Snippet;
	}

	let { data, children }: Props = $props();

	const navItems = [
		{ href: '/admin', label: 'Dashboard', icon: '📊' },
		{ href: '/admin/users', label: 'Users', icon: '👥' },
		{ href: '/admin/posts', label: 'Posts', icon: '📝' }
	];

	function isActive(href: string): boolean {
		return $page.url.pathname === href;
	}
</script>

<div style="background: var(--bg-secondary); border-bottom: 1px solid var(--border-primary); padding: 1rem 0;">
	<Container>
		<div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 1rem;">
			<div>
				<h1 style="font-size: 1.5rem; font-weight: 700; margin: 0;">Admin Panel</h1>
				<p style="margin: 0; color: var(--text-secondary); font-size: 0.875rem;">
					Welcome, {data.user.name}
				</p>
			</div>

			<nav style="display: flex; gap: 1rem;">
				{#each navItems as item}
					<a
						href={item.href}
						style="padding: 0.5rem 1rem; border-radius: var(--radius-md); text-decoration: none; display: flex; align-items: center; gap: 0.5rem; {isActive(
							item.href
						)
							? 'background: var(--color-primary); color: white; font-weight: 600;'
							: 'color: var(--text-primary); hover:background: var(--bg-tertiary);'}"
					>
						<span>{item.icon}</span>
						<span>{item.label}</span>
					</a>
				{/each}
			</nav>
		</div>
	</Container>
</div>

<Container>
	<div style="margin-top: 2rem; margin-bottom: 3rem;">
		{@render children()}
	</div>
</Container>

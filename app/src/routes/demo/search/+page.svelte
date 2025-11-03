<script lang="ts">
	import type { PageData } from './$types';
	import Container from '$lib/components/layout/Container.svelte';
	import Stack from '$lib/components/layout/Stack.svelte';
	import Card from '$lib/components/ui/Card/Card.svelte';
	import Badge from '$lib/components/ui/Badge/Badge.svelte';
	import Loading from '$lib/components/ui/Loading/Loading.svelte';

	interface Props {
		data: PageData;
	}

	let { data }: Props = $props();

	let searchQuery = $state('');
	let results = $state<any[]>([]);
	let isLoading = $state(false);
	let isOpen = $state(false);
	let selectedIndex = $state(-1);
	let searchInput: HTMLInputElement;
	let debounceTimer: ReturnType<typeof setTimeout>;

	// Debounced search function
	function handleSearch() {
		const query = searchQuery.trim();

		// Clear previous timer
		clearTimeout(debounceTimer);

		if (query.length < 2) {
			results = [];
			isOpen = false;
			return;
		}

		// Set loading state
		isLoading = true;
		isOpen = true;

		// Debounce API call by 300ms
		debounceTimer = setTimeout(async () => {
			try {
				const response = await fetch(`/api/search?q=${encodeURIComponent(query)}&limit=10`);
				const data = await response.json();

				if (data.data) {
					results = data.data;
					selectedIndex = -1;
				}
			} catch (error) {
				console.error('Search error:', error);
				results = [];
			} finally {
				isLoading = false;
			}
		}, 300);
	}

	// Keyboard navigation
	function handleKeyDown(event: KeyboardEvent) {
		if (!isOpen || results.length === 0) return;

		switch (event.key) {
			case 'ArrowDown':
				event.preventDefault();
				selectedIndex = (selectedIndex + 1) % results.length;
				break;
			case 'ArrowUp':
				event.preventDefault();
				selectedIndex = selectedIndex <= 0 ? results.length - 1 : selectedIndex - 1;
				break;
			case 'Enter':
				event.preventDefault();
				if (selectedIndex >= 0 && selectedIndex < results.length) {
					selectResult(results[selectedIndex]);
				}
				break;
			case 'Escape':
				event.preventDefault();
				isOpen = false;
				selectedIndex = -1;
				break;
		}
	}

	function selectResult(result: any) {
		searchQuery = result.title;
		isOpen = false;
		selectedIndex = -1;
		// In a real app, you might navigate to the post here
		console.log('Selected:', result);
	}

	function highlightMatch(text: string, query: string): string {
		if (!query) return text;
		const regex = new RegExp(`(${query})`, 'gi');
		return text.replace(regex, '<mark style="background: yellow; font-weight: 600;">$1</mark>');
	}

	function formatDate(date: Date | null): string {
		if (!date) return '';
		return new Date(date).toLocaleDateString('en-US', {
			year: 'numeric',
			month: 'short',
			day: 'numeric'
		});
	}

	function getStatusVariant(status: string): 'success' | 'warning' | 'info' {
		switch (status) {
			case 'published':
				return 'success';
			case 'draft':
				return 'warning';
			default:
				return 'info';
		}
	}

	// Close dropdown when clicking outside
	function handleClickOutside(event: MouseEvent) {
		const target = event.target as HTMLElement;
		if (!target.closest('.search-container')) {
			isOpen = false;
		}
	}

	$effect(() => {
		document.addEventListener('click', handleClickOutside);
		return () => {
			document.removeEventListener('click', handleClickOutside);
		};
	});
</script>

<svelte:head>
	<title>Search with Autocomplete</title>
</svelte:head>

<Container>
	<Stack gap="lg" style="margin-top: 2rem; margin-bottom: 3rem;">
		<!-- Header -->
		<div>
			<h1 style="font-size: 2rem; font-weight: 700; margin: 0 0 0.5rem 0;">
				Search with Autocomplete
			</h1>
			<p style="color: var(--text-secondary); margin: 0;">
				Debounced search with keyboard navigation and result highlighting
			</p>
		</div>

		<!-- Search Demo -->
		<Card>
			<Stack gap="md">
				<h2 style="font-size: 1.25rem; font-weight: 600; margin: 0;">Search Posts</h2>

				<!-- Search Input with Dropdown -->
				<div class="search-container" style="position: relative;">
					<div style="position: relative;">
						<input
							bind:this={searchInput}
							bind:value={searchQuery}
							oninput={handleSearch}
							onkeydown={handleKeyDown}
							type="text"
							placeholder="Start typing to search posts..."
							style="width: 100%; padding: 0.75rem 3rem 0.75rem 1rem; border: 2px solid var(--border-primary); border-radius: var(--radius-md); font-size: 1rem; outline: none; transition: border-color 0.2s;"
							onfocus={() => {
								if (searchQuery.length >= 2) isOpen = true;
							}}
						/>

						<!-- Search Icon / Loading Spinner -->
						<div
							style="position: absolute; right: 1rem; top: 50%; transform: translateY(-50%); pointer-events: none;"
						>
							{#if isLoading}
								<Loading size="sm" />
							{:else}
								<span style="font-size: 1.25rem;">🔍</span>
							{/if}
						</div>
					</div>

					<!-- Autocomplete Dropdown -->
					{#if isOpen && (results.length > 0 || isLoading)}
						<div
							style="position: absolute; top: 100%; left: 0; right: 0; margin-top: 0.5rem; background: var(--bg-primary); border: 2px solid var(--border-primary); border-radius: var(--radius-md); box-shadow: var(--shadow-lg); max-height: 400px; overflow-y: auto; z-index: 1000;"
						>
							{#if isLoading}
								<div style="padding: 2rem; text-align: center; color: var(--text-secondary);">
									<Loading />
									<p style="margin-top: 0.5rem;">Searching...</p>
								</div>
							{:else if results.length === 0}
								<div style="padding: 2rem; text-align: center; color: var(--text-secondary);">
									No results found for "{searchQuery}"
								</div>
							{:else}
								{#each results as result, index}
									<button
										type="button"
										onclick={() => selectResult(result)}
										style="width: 100%; padding: 1rem; text-align: left; border: none; background: {selectedIndex ===
										index
											? 'var(--bg-secondary)'
											: 'transparent'}; border-bottom: 1px solid var(--border-primary); cursor: pointer; transition: background 0.1s; display: block;"
										onmouseenter={() => {
											selectedIndex = index;
										}}
									>
										<Stack gap="xs">
											<div
												style="font-weight: 600; display: flex; justify-content: space-between; align-items: center; gap: 0.5rem;"
											>
												<span>{@html highlightMatch(result.title, searchQuery)}</span>
												<Badge variant={getStatusVariant(result.status)} size="sm">
													{result.status}
												</Badge>
											</div>
											{#if result.excerpt}
												<div
													style="font-size: 0.875rem; color: var(--text-secondary); overflow: hidden; text-overflow: ellipsis; white-space: nowrap;"
												>
													{@html highlightMatch(result.excerpt, searchQuery)}
												</div>
											{/if}
											<div style="font-size: 0.75rem; color: var(--text-secondary);">
												by {result.authorName || 'Unknown'} • {formatDate(result.createdAt)}
											</div>
										</Stack>
									</button>
								{/each}
							{/if}
						</div>
					{/if}
				</div>

				<!-- Search Stats -->
				{#if searchQuery.length >= 2 && !isLoading && isOpen}
					<div style="font-size: 0.875rem; color: var(--text-secondary);">
						{results.length} result{results.length !== 1 ? 's' : ''} found for "{searchQuery}"
					</div>
				{/if}
			</Stack>
		</Card>

		<!-- Keyboard Shortcuts -->
		<Card>
			<Stack gap="md">
				<h3 style="font-size: 1.25rem; font-weight: 600; margin: 0;">Keyboard Shortcuts</h3>
				<div style="display: grid; gap: 0.75rem;">
					<div style="display: flex; justify-content: space-between; align-items: center;">
						<span>Navigate results</span>
						<code
							style="padding: 0.25rem 0.5rem; background: var(--bg-secondary); border-radius: var(--radius-sm); font-size: 0.875rem;"
						>
							↑ ↓
						</code>
					</div>
					<div style="display: flex; justify-content: space-between; align-items: center;">
						<span>Select result</span>
						<code
							style="padding: 0.25rem 0.5rem; background: var(--bg-secondary); border-radius: var(--radius-sm); font-size: 0.875rem;"
						>
							Enter
						</code>
					</div>
					<div style="display: flex; justify-content: space-between; align-items: center;">
						<span>Close dropdown</span>
						<code
							style="padding: 0.25rem 0.5rem; background: var(--bg-secondary); border-radius: var(--radius-sm); font-size: 0.875rem;"
						>
							Esc
						</code>
					</div>
				</div>
			</Stack>
		</Card>

		<!-- Features Info -->
		<Card>
			<Stack gap="md">
				<h3 style="font-size: 1.25rem; font-weight: 600; margin: 0;">Features Demonstrated</h3>
				<ul style="margin: 0; padding-left: 1.5rem; color: var(--text-secondary);">
					<li>Debounced API calls (300ms delay) to reduce server load</li>
					<li>Real-time search as you type</li>
					<li>Keyboard navigation (arrow keys, Enter, Escape)</li>
					<li>Highlighted matching text in results</li>
					<li>Loading indicators during search</li>
					<li>Mouse hover highlighting synchronized with keyboard selection</li>
					<li>Click outside to close dropdown</li>
					<li>Minimum 2 characters required to search</li>
					<li>Comprehensive result display with metadata</li>
					<li>Server-side ILIKE search across multiple fields</li>
				</ul>
			</Stack>
		</Card>

		<!-- Implementation Notes -->
		<Card>
			<Stack gap="md">
				<h3 style="font-size: 1.25rem; font-weight: 600; margin: 0;">Implementation Notes</h3>
				<Stack gap="sm">
					<div>
						<strong>Debouncing:</strong>
						<p style="margin: 0.25rem 0 0 0; color: var(--text-secondary); font-size: 0.875rem;">
							API calls are debounced by 300ms to avoid excessive requests. The timer is cleared on
							each keystroke and restarted, so the API is only called when the user stops typing.
						</p>
					</div>
					<div>
						<strong>Keyboard Navigation:</strong>
						<p style="margin: 0.25rem 0 0 0; color: var(--text-secondary); font-size: 0.875rem;">
							Arrow keys cycle through results with wrap-around. Enter selects the highlighted
							result. Escape closes the dropdown. Mouse hover and keyboard selection stay in sync.
						</p>
					</div>
					<div>
						<strong>Text Highlighting:</strong>
						<p style="margin: 0.25rem 0 0 0; color: var(--text-secondary); font-size: 0.875rem;">
							Matching text is highlighted using a regex replace that wraps matches in a &lt;mark&gt;
							tag. This provides visual feedback on why each result matched.
						</p>
					</div>
				</Stack>
			</Stack>
		</Card>
	</Stack>
</Container>

<style>
	mark {
		background: var(--color-warning);
		color: var(--text-primary);
		padding: 0 0.125rem;
		border-radius: 2px;
	}
</style>

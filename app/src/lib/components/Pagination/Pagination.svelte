<script lang="ts">
	interface Props {
		currentPage: number;
		totalPages: number;
		onPageChange: (page: number) => void;
		showFirstLast?: boolean;
		maxVisible?: number;
		class?: string;
	}

	let {
		currentPage,
		totalPages,
		onPageChange,
		showFirstLast = true,
		maxVisible = 7,
		class: className = ''
	}: Props = $props();

	const goToPage = (page: number) => {
		if (page >= 1 && page <= totalPages && page !== currentPage) {
			onPageChange(page);
		}
	};

	const getVisiblePages = $derived(() => {
		if (totalPages <= maxVisible) {
			return Array.from({ length: totalPages }, (_, i) => i + 1);
		}

		const halfVisible = Math.floor(maxVisible / 2);
		let start = Math.max(1, currentPage - halfVisible);
		let end = Math.min(totalPages, start + maxVisible - 1);

		if (end - start + 1 < maxVisible) {
			start = Math.max(1, end - maxVisible + 1);
		}

		const pages: (number | string)[] = [];
		
		if (start > 1) {
			pages.push(1);
			if (start > 2) pages.push('...');
		}

		for (let i = start; i <= end; i++) {
			pages.push(i);
		}

		if (end < totalPages) {
			if (end < totalPages - 1) pages.push('...');
			pages.push(totalPages);
		}

		return pages;
	});

	const canGoPrevious = $derived(currentPage > 1);
	const canGoNext = $derived(currentPage < totalPages);
</script>

<nav 
	class="flex items-center justify-center gap-1 {className}"
	aria-label="Pagination"
>
	{#if showFirstLast}
		<button
			type="button"
			onclick={() => goToPage(1)}
			disabled={!canGoPrevious}
			class="inline-flex items-center justify-center h-9 px-3 rounded-md text-sm font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
			class:text-gray-700={canGoPrevious}
			class:hover:bg-gray-100={canGoPrevious}
			class:text-gray-400={!canGoPrevious}
			class:cursor-not-allowed={!canGoPrevious}
			aria-label="Go to first page"
		>
			<svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 19l-7-7 7-7m8 14l-7-7 7-7" />
			</svg>
		</button>
	{/if}

	<button
		type="button"
		onclick={() => goToPage(currentPage - 1)}
		disabled={!canGoPrevious}
		class="inline-flex items-center justify-center h-9 px-3 rounded-md text-sm font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
		class:text-gray-700={canGoPrevious}
		class:hover:bg-gray-100={canGoPrevious}
		class:text-gray-400={!canGoPrevious}
		class:cursor-not-allowed={!canGoPrevious}
		aria-label="Go to previous page"
	>
		<svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
			<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
		</svg>
	</button>

	{#each getVisiblePages() as page}
		{#if page === '...'}
			<span class="inline-flex items-center justify-center h-9 px-3 text-sm text-gray-400">
				{page}
			</span>
		{:else}
			<button
				type="button"
				onclick={() => goToPage(page as number)}
				class="inline-flex items-center justify-center h-9 min-w-9 px-3 rounded-md text-sm font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
				class:bg-blue-600={currentPage === page}
				class:text-white={currentPage === page}
				class:hover:bg-blue-700={currentPage === page}
				class:text-gray-700={currentPage !== page}
				class:hover:bg-gray-100={currentPage !== page}
				aria-label="Go to page {page}"
				aria-current={currentPage === page ? 'page' : undefined}
			>
				{page}
			</button>
		{/if}
	{/each}

	<button
		type="button"
		onclick={() => goToPage(currentPage + 1)}
		disabled={!canGoNext}
		class="inline-flex items-center justify-center h-9 px-3 rounded-md text-sm font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
		class:text-gray-700={canGoNext}
		class:hover:bg-gray-100={canGoNext}
		class:text-gray-400={!canGoNext}
		class:cursor-not-allowed={!canGoNext}
		aria-label="Go to next page"
	>
		<svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
			<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
		</svg>
	</button>

	{#if showFirstLast}
		<button
			type="button"
			onclick={() => goToPage(totalPages)}
			disabled={!canGoNext}
			class="inline-flex items-center justify-center h-9 px-3 rounded-md text-sm font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
			class:text-gray-700={canGoNext}
			class:hover:bg-gray-100={canGoNext}
			class:text-gray-400={!canGoNext}
			class:cursor-not-allowed={!canGoNext}
			aria-label="Go to last page"
		>
			<svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" aria-hidden="true">
				<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5l7 7-7 7M5 5l7 7-7 7" />
			</svg>
		</button>
	{/if}
</nav>
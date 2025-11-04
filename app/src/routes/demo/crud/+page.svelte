<script lang="ts">
	import { enhance } from '$app/forms';
	import { goto, invalidateAll } from '$app/navigation';
	import { page } from '$app/stores';
	import { Container, Stack } from '$lib/components/layout';
	import {
		Card,
		Button,
		TextInput,
		Select,
		Textarea,
		Badge,
		Modal,
		Table,
		Pagination
	} from '$lib/components/ui';
	import { toasts } from '$lib/stores/toasts';

	interface Post {
		id: string;
		title: string;
		slug: string;
		content: string;
		excerpt?: string;
		status: string;
		createdAt: Date | null;
	}

	interface Author {
		name: string;
	}

	interface PostWithAuthor {
		post: Post;
		author: Author | null;
	}

	interface Props {
		data: {
			posts: PostWithAuthor[];
			filters: {
				search: string;
				status: string;
				sortBy: string;
				sortOrder: string;
			};
			stats: {
				total: number;
				published: number;
				drafts: number;
				archived: number;
			};
			pagination: {
				page: number;
				limit: number;
				total: number;
				totalPages: number;
			};
		};
	}

	let { data }: Props = $props();

	// Modal state
	let isCreateModalOpen = $state(false);
	let isEditModalOpen = $state(false);
	let isDeleteModalOpen = $state(false);
	let selectedPost = $state<PostWithAuthor | null>(null);

	// Form state
	let isSubmitting = $state(false);

	// Filter state (bound to inputs)
	let searchValue = $state(data.filters.search);
	let statusValue = $state(data.filters.status);

	// Handle filter changes
	function updateFilters() {
		const url = new URL($page.url);
		url.searchParams.set('page', '1'); // Reset to page 1 on filter change
		if (searchValue) url.searchParams.set('search', searchValue);
		else url.searchParams.delete('search');
		if (statusValue && statusValue !== 'all') url.searchParams.set('status', statusValue);
		else url.searchParams.delete('status');
		goto(url.toString(), { invalidateAll: true });
	}

	// Handle sort changes
	function updateSort(sortBy: string) {
		const url = new URL($page.url);
		const currentSortBy = data.filters.sortBy;
		const currentSortOrder = data.filters.sortOrder;

		// Toggle sort order if clicking same column
		if (sortBy === currentSortBy) {
			url.searchParams.set('sortOrder', currentSortOrder === 'asc' ? 'desc' : 'asc');
		} else {
			url.searchParams.set('sortBy', sortBy);
			url.searchParams.set('sortOrder', 'desc');
		}

		goto(url.toString(), { invalidateAll: true });
	}

	// Handle pagination
	function goToPage(pageNum: number) {
		const url = new URL($page.url);
		url.searchParams.set('page', pageNum.toString());
		goto(url.toString(), { invalidateAll: true });
	}

	// Get status badge variant
	function getStatusVariant(status: string): 'primary' | 'success' | 'warning' | 'info' {
		switch (status) {
			case 'published':
				return 'success';
			case 'draft':
				return 'warning';
			case 'archived':
				return 'info';
			default:
				return 'primary';
		}
	}

	// Format date
	function formatDate(date: Date | null): string {
		if (!date) return '-';
		return new Date(date).toLocaleDateString('en-US', {
			year: 'numeric',
			month: 'short',
			day: 'numeric'
		});
	}

	// Open edit modal
	function openEditModal(post: PostWithAuthor) {
		selectedPost = post;
		isEditModalOpen = true;
	}

	// Open delete modal
	function openDeleteModal(post: PostWithAuthor) {
		selectedPost = post;
		isDeleteModalOpen = true;
	}

	// Auto-generate slug from title
	function generateSlug(title: string): string {
		return title
			.toLowerCase()
			.replace(/[^a-z0-9]+/g, '-')
			.replace(/^-+|-+$/g, '');
	}
</script>

<svelte:head>
	<title>CRUD Demo - Posts Management</title>
</svelte:head>

<Container>
	<Stack gap="lg" style="margin-top: 2rem; margin-bottom: 3rem;">
		<!-- Header -->
		<div>
			<h1 style="font-size: 2rem; font-weight: 700; margin: 0 0 0.5rem 0;">Posts Management</h1>
			<p style="color: var(--text-secondary); margin: 0;">
				Complete CRUD demo with pagination, sorting, filtering, and form validation using Zod
			</p>
		</div>

		<!-- Stats Cards -->
		<div
			style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem;"
		>
			<Card>
				<Stack gap="xs">
					<div style="color: var(--text-secondary); font-size: 0.875rem;">Total Posts</div>
					<div style="font-size: 2rem; font-weight: 700;">{data.stats.total}</div>
				</Stack>
			</Card>
			<Card>
				<Stack gap="xs">
					<div style="color: var(--text-secondary); font-size: 0.875rem;">Published</div>
					<div style="font-size: 2rem; font-weight: 700; color: var(--color-success);">
						{data.stats.published}
					</div>
				</Stack>
			</Card>
			<Card>
				<Stack gap="xs">
					<div style="color: var(--text-secondary); font-size: 0.875rem;">Drafts</div>
					<div style="font-size: 2rem; font-weight: 700; color: var(--color-warning);">
						{data.stats.drafts}
					</div>
				</Stack>
			</Card>
			<Card>
				<Stack gap="xs">
					<div style="color: var(--text-secondary); font-size: 0.875rem;">Archived</div>
					<div style="font-size: 2rem; font-weight: 700; color: var(--color-info);">
						{data.stats.archived}
					</div>
				</Stack>
			</Card>
		</div>

		<!-- Filters and Actions -->
		<Card>
			<Stack gap="md">
				<div
					style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 1rem;"
				>
					<h2 style="font-size: 1.25rem; font-weight: 600; margin: 0;">All Posts</h2>
					<Button
						variant="primary"
						onclick={() => {
							isCreateModalOpen = true;
						}}
					>
						Create New Post
					</Button>
				</div>

				<div style="display: flex; gap: 1rem; flex-wrap: wrap;">
					<div style="flex: 1; min-width: 200px;">
						<TextInput
							label="Search"
							id="search"
							name="search"
							label="Search"
							type="search"
							placeholder="Search posts..."
							bind:value={searchValue}
							oninput={updateFilters}
						/>
					</div>
					<div style="min-width: 150px;">
						<Select
							id="status"
							name="status"
							label="Status"
							bind:value={statusValue}
							onchange={updateFilters}
						>
							<option value="all">All Status</option>
							<option value="draft">Draft</option>
							<option value="published">Published</option>
							<option value="archived">Archived</option>
						</Select>
					</div>
				</div>
			</Stack>
		</Card>

		<!-- Posts Table -->
		<Card>
			{#if data.posts.length === 0}
				<div style="text-align: center; padding: 3rem 1rem; color: var(--text-secondary);">
					<p style="font-size: 1.125rem; margin: 0 0 0.5rem 0;">No posts found</p>
					<p style="margin: 0;">
						{data.filters.search || data.filters.status !== 'all'
							? 'Try adjusting your filters'
							: 'Create your first post to get started'}
					</p>
				</div>
			{:else}
				<Table>
					<thead>
						<tr>
							<th>
								<button
									onclick={() => updateSort('title')}
									style="background: none; border: none; cursor: pointer; padding: 0; font: inherit; display: flex; align-items: center; gap: 0.25rem;"
								>
									Title
									{#if data.filters.sortBy === 'title'}
										<span>{data.filters.sortOrder === 'asc' ? '↑' : '↓'}</span>
									{/if}
								</button>
							</th>
							<th>Author</th>
							<th>Status</th>
							<th>
								<button
									onclick={() => updateSort('createdAt')}
									style="background: none; border: none; cursor: pointer; padding: 0; font: inherit; display: flex; align-items: center; gap: 0.25rem;"
								>
									Created
									{#if data.filters.sortBy === 'createdAt'}
										<span>{data.filters.sortOrder === 'asc' ? '↑' : '↓'}</span>
									{/if}
								</button>
							</th>
							<th>Actions</th>
						</tr>
					</thead>
					<tbody>
						{#each data.posts as { post, author } (post.id)}
							<tr>
								<td>
									<Stack gap="xs">
										<div style="font-weight: 600;">{post.title}</div>
										{#if post.excerpt}
											<div
												style="font-size: 0.875rem; color: var(--text-secondary); overflow: hidden; text-overflow: ellipsis; white-space: nowrap;"
											>
												{post.excerpt}
											</div>
										{/if}
									</Stack>
								</td>
								<td>{author?.name || 'Unknown'}</td>
								<td>
									<Badge variant={getStatusVariant(post.status)} text={post.status} />
								</td>
								<td>{formatDate(post.createdAt)}</td>
								<td>
									<div style="display: flex; gap: 0.5rem;">
										<Button
											variant="ghost"
											size="sm"
											onclick={() => openEditModal({ post, author })}
										>
											Edit
										</Button>
										<Button
											variant="ghost"
											size="sm"
											onclick={() => openDeleteModal({ post, author })}
										>
											Delete
										</Button>
									</div>
								</td>
							</tr>
						{/each}
					</tbody>
				</Table>

				<!-- Pagination -->
				{#if data.pagination.totalPages > 1}
					<div style="margin-top: 1rem; display: flex; justify-content: center;">
						<Pagination
							currentPage={data.pagination.page}
							totalPages={data.pagination.totalPages}
							onPageChange={goToPage}
						/>
					</div>
				{/if}
			{/if}
		</Card>
	</Stack>
</Container>

<!-- Create Post Modal -->
<Modal
	isOpen={isCreateModalOpen}
	onClose={() => (isCreateModalOpen = false)}
	title="Create New Post"
	maxWidth="lg"
>
	<form
		method="post"
		action="?/create"
		use:enhance={() => {
			isSubmitting = true;
			return async ({ result, update }) => {
				isSubmitting = false;
				if (result.type === 'success') {
					isCreateModalOpen = false;
					toasts.add({ type: 'success', message: 'Post created successfully!' });
					await update();
				} else if (result.type === 'failure') {
					toasts.add({
						type: 'error',
						message: (result.data?.message as string) || 'Failed to create post'
					});
				}
			};
		}}
	>
		<Stack gap="md">
			<TextInput
				id="create-title"
				name="title"
				label="Title"
				required
				placeholder="Enter post title"
				onblur={(e) => {
					if (!(e.currentTarget instanceof HTMLInputElement)) return;
					const slugInput = document.getElementById('create-slug') as HTMLInputElement;
					if (e.currentTarget instanceof HTMLInputElement && slugInput && !slugInput.value) {
						slugInput.value = generateSlug(e.currentTarget.value);
					}
				}}
			/>

			<TextInput
				id="create-slug"
				name="slug"
				label="Slug"
				required
				placeholder="auto-generated-from-title"
				helpText="URL-friendly version of the title"
				pattern="^[a-z0-9-]+$"
			/>

			<Textarea
				id="create-content"
				name="content"
				label="Content"
				required
				rows={6}
				placeholder="Write your post content here..."
			/>

			<Textarea
				id="create-excerpt"
				name="excerpt"
				label="Excerpt (optional)"
				rows={2}
				placeholder="Short summary of the post"
			/>

			<Select id="create-status" name="status" label="Status">
				<option value="draft">Draft</option>
				<option value="published">Published</option>
				<option value="archived">Archived</option>
			</Select>

			<div style="display: flex; gap: 1rem; justify-content: flex-end; margin-top: 1rem;">
				<Button
					type="button"
					variant="ghost"
					onclick={() => {
						isCreateModalOpen = false;
					}}
					disabled={isSubmitting}
				>
					Cancel
				</Button>
				<Button type="submit" variant="primary" loading={isSubmitting}>Create Post</Button>
			</div>
		</Stack>
	</form>
</Modal>

<!-- Edit Post Modal -->
<Modal
	isOpen={isEditModalOpen}
	onClose={() => (isEditModalOpen = false)}
	title="Edit Post"
	maxWidth="lg"
>
	{#if selectedPost}
		<form
			method="post"
			action="?/update"
			use:enhance={() => {
				isSubmitting = true;
				return async ({ result, update }) => {
					isSubmitting = false;
					if (result.type === 'success') {
						isEditModalOpen = false;
						selectedPost = null;
						toasts.add({ type: 'success', message: 'Post updated successfully!' });
						await update();
					} else if (result.type === 'failure') {
						toasts.add({
							type: 'error',
							message: (result.data?.message as string) || 'Failed to update post'
						});
					}
				};
			}}
		>
			<input type="hidden" name="id" value={selectedPost.post.id} />

			<Stack gap="md">
				<TextInput
					id="edit-title"
					name="title"
					label="Title"
					required
					value={selectedPost.post.title}
				/>

				<TextInput
					id="edit-slug"
					name="slug"
					label="Slug"
					required
					value={selectedPost.post.slug}
					pattern="^[a-z0-9-]+$"
				/>

				<Textarea
					id="edit-content"
					name="content"
					label="Content"
					required
					rows={6}
					value={selectedPost.post.content}
				/>

				<Textarea
					id="edit-excerpt"
					name="excerpt"
					label="Excerpt (optional)"
					rows={2}
					value={selectedPost.post.excerpt || ''}
				/>

				<Select id="edit-status" name="status" label="Status" value={selectedPost.post.status}>
					<option value="draft">Draft</option>
					<option value="published">Published</option>
					<option value="archived">Archived</option>
				</Select>

				<div style="display: flex; gap: 1rem; justify-content: flex-end; margin-top: 1rem;">
					<Button
						type="button"
						variant="ghost"
						onclick={() => {
							isEditModalOpen = false;
							selectedPost = null;
						}}
						disabled={isSubmitting}
					>
						Cancel
					</Button>
					<Button type="submit" variant="primary" loading={isSubmitting}>Save Changes</Button>
				</div>
			</Stack>
		</form>
	{/if}
</Modal>

<!-- Delete Confirmation Modal -->
<Modal
	isOpen={isDeleteModalOpen}
	onClose={() => (isDeleteModalOpen = false)}
	title="Delete Post"
	maxWidth="sm"
>
	{#if selectedPost}
		<form
			method="post"
			action="?/delete"
			use:enhance={() => {
				isSubmitting = true;
				return async ({ result, update }) => {
					isSubmitting = false;
					if (result.type === 'success') {
						isDeleteModalOpen = false;
						selectedPost = null;
						toasts.add({ type: 'success', message: 'Post deleted successfully!' });
						await update();
					} else if (result.type === 'failure') {
						toasts.add({
							type: 'error',
							message: (result.data?.message as string) || 'Failed to delete post'
						});
					}
				};
			}}
		>
			<input type="hidden" name="id" value={selectedPost.post.id} />

			<Stack gap="md">
				<p style="margin: 0; color: var(--text-secondary);">
					Are you sure you want to delete <strong>{selectedPost.post.title}</strong>? This action
					cannot be undone.
				</p>

				<div style="display: flex; gap: 1rem; justify-content: flex-end;">
					<Button
						type="button"
						variant="ghost"
						onclick={() => {
							isDeleteModalOpen = false;
							selectedPost = null;
						}}
						disabled={isSubmitting}
					>
						Cancel
					</Button>
					<Button type="submit" variant="danger" loading={isSubmitting}>Delete Post</Button>
				</div>
			</Stack>
		</form>
	{/if}
</Modal>

<script lang="ts">
	import { enhance } from '$app/forms';
	import { goto } from '$app/navigation';
	import { page } from '$app/stores';
	import { Stack } from '$lib/components/layout';
	import {
		Card,
		Button,
		TextInput,
		Select,
		Badge,
		Modal,
		Table,
		Pagination
	} from '$lib/components/ui';
	import { toasts } from '$lib/stores/toasts';

	interface User {
		id: string;
		name: string;
		email: string;
		role: string;
		createdAt: Date | null;
		updatedAt: Date | null;
	}

	interface Props {
		data: {
			users: User[];
			filters: {
				search: string;
				role: string;
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
	let isEditRoleModalOpen = $state(false);
	let isDeleteModalOpen = $state(false);
	let selectedUser = $state<User | null>(null);
	let isSubmitting = $state(false);

	// Filter state
	let searchValue = $state(data.filters.search);
	let roleValue = $state(data.filters.role);

	// Handle filter changes
	function updateFilters() {
		const url = new URL($page.url);
		url.searchParams.set('page', '1');
		if (searchValue) url.searchParams.set('search', searchValue);
		else url.searchParams.delete('search');
		if (roleValue && roleValue !== 'all') url.searchParams.set('role', roleValue);
		else url.searchParams.delete('role');
		goto(url.toString(), { invalidateAll: true });
	}

	// Handle pagination
	function goToPage(pageNum: number) {
		const url = new URL($page.url);
		url.searchParams.set('page', pageNum.toString());
		goto(url.toString(), { invalidateAll: true });
	}

	// Get role badge variant
	function getRoleBadgeVariant(role: string): 'danger' | 'primary' | 'info' {
		switch (role) {
			case 'admin':
				return 'danger';
			case 'moderator':
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

	// Open edit role modal
	function openEditRoleModal(user: User) {
		selectedUser = user;
		isEditRoleModalOpen = true;
	}

	// Open delete modal
	function openDeleteModal(user: User) {
		selectedUser = user;
		isDeleteModalOpen = true;
	}
</script>

<svelte:head>
	<title>User Management - Admin</title>
</svelte:head>

<Stack gap="lg">
	<div>
		<h2 style="font-size: 1.75rem; font-weight: 700; margin: 0 0 0.5rem 0;">User Management</h2>
		<p style="color: var(--text-secondary); margin: 0;">Manage user accounts and permissions</p>
	</div>

	<!-- Filters -->
	<Card>
		<Stack gap="md">
			<h3 style="font-size: 1.25rem; font-weight: 600; margin: 0;">All Users</h3>

			<div style="display: flex; gap: 1rem; flex-wrap: wrap;">
				<div style="flex: 1; min-width: 200px;">
					<TextInput
						id="search"
						name="search"
						label="Search"
						type="search"
						placeholder="Search by name or email..."
						bind:value={searchValue}
						oninput={updateFilters}
					/>
				</div>
				<div style="min-width: 150px;">
					<Select
						id="role"
						name="role"
						label="Role"
						bind:value={roleValue}
						onchange={updateFilters}
					>
						<option value="all">All Roles</option>
						<option value="admin">Admin</option>
						<option value="moderator">Moderator</option>
						<option value="user">User</option>
					</Select>
				</div>
			</div>
		</Stack>
	</Card>

	<!-- Users Table -->
	<Card>
		{#if data.users.length === 0}
			<div style="text-align: center; padding: 3rem 1rem; color: var(--text-secondary);">
				<p style="font-size: 1.125rem; margin: 0 0 0.5rem 0;">No users found</p>
				<p style="margin: 0;">
					{data.filters.search || data.filters.role !== 'all'
						? 'Try adjusting your filters'
						: 'No users in the system'}
				</p>
			</div>
		{:else}
			<Table>
				<thead>
					<tr>
						<th>User</th>
						<th>Role</th>
						<th>Joined</th>
						<th>Last Updated</th>
						<th>Actions</th>
					</tr>
				</thead>
				<tbody>
					{#each data.users as user}
						<tr>
							<td>
								<Stack gap="xs">
									<div style="font-weight: 600;">{user.name}</div>
									<div style="font-size: 0.875rem; color: var(--text-secondary);">
										{user.email}
									</div>
								</Stack>
							</td>
							<td>
								<Badge variant={getRoleBadgeVariant(user.role)} text={user.role} />
							</td>
							<td>{formatDate(user.createdAt)}</td>
							<td>{formatDate(user.updatedAt)}</td>
							<td>
								<div style="display: flex; gap: 0.5rem;">
									<Button variant="ghost" size="sm" onclick={() => openEditRoleModal(user)}>
										Edit Role
									</Button>
									<Button variant="ghost" size="sm" onclick={() => openDeleteModal(user)}>
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

			<div
				style="margin-top: 1rem; font-size: 0.875rem; color: var(--text-secondary); text-align: center;"
			>
				Showing {(data.pagination.page - 1) * data.pagination.limit + 1}-{Math.min(
					data.pagination.page * data.pagination.limit,
					data.pagination.total
				)} of {data.pagination.total} user{data.pagination.total !== 1 ? 's' : ''}
			</div>
		{/if}
	</Card>
</Stack>

<!-- Edit Role Modal -->
<Modal
	isOpen={isEditRoleModalOpen}
	onClose={() => (isEditRoleModalOpen = false)}
	title="Edit User Role"
	maxWidth="sm"
>
	{#if selectedUser}
		<form
			method="post"
			action="?/updateRole"
			use:enhance={() => {
				isSubmitting = true;
				return async ({ result, update }) => {
					isSubmitting = false;
					if (result.type === 'success') {
						isEditRoleModalOpen = false;
						selectedUser = null;
						toasts.add({ type: 'success', message: 'User role updated successfully!' });
						await update();
					} else if (result.type === 'failure') {
						toasts.add({
							type: 'error',
							message: (result.data?.message as string) || 'Failed to update role'
						});
					}
				};
			}}
		>
			<input type="hidden" name="userId" value={selectedUser.id} />

			<Stack gap="md">
				<div>
					<p style="margin: 0 0 0.5rem 0; font-weight: 600;">{selectedUser.name}</p>
					<p style="margin: 0; font-size: 0.875rem; color: var(--text-secondary);">
						{selectedUser.email}
					</p>
				</div>

				<Select id="edit-role" name="role" label="Role" value={selectedUser.role}>
					<option value="user">User</option>
					<option value="moderator">Moderator</option>
					<option value="admin">Admin</option>
				</Select>

				<div
					style="padding: 0.75rem; background: var(--bg-secondary); border-radius: var(--radius-md); font-size: 0.875rem;"
				>
					<strong>⚠️ Warning:</strong> Changing a user's role will affect their permissions throughout
					the application.
				</div>

				<div style="display: flex; gap: 1rem; justify-content: flex-end;">
					<Button
						type="button"
						variant="ghost"
						onclick={() => {
							isEditRoleModalOpen = false;
							selectedUser = null;
						}}
						disabled={isSubmitting}
					>
						Cancel
					</Button>
					<Button type="submit" variant="primary" loading={isSubmitting}>Update Role</Button>
				</div>
			</Stack>
		</form>
	{/if}
</Modal>

<!-- Delete User Modal -->
<Modal
	isOpen={isDeleteModalOpen}
	onClose={() => (isDeleteModalOpen = false)}
	title="Delete User"
	maxWidth="sm"
>
	{#if selectedUser}
		<form
			method="post"
			action="?/deleteUser"
			use:enhance={() => {
				isSubmitting = true;
				return async ({ result, update }) => {
					isSubmitting = false;
					if (result.type === 'success') {
						isDeleteModalOpen = false;
						selectedUser = null;
						toasts.add({ type: 'success', message: 'User deleted successfully!' });
						await update();
					} else if (result.type === 'failure') {
						toasts.add({
							type: 'error',
							message: (result.data?.message as string) || 'Failed to delete user'
						});
					}
				};
			}}
		>
			<input type="hidden" name="userId" value={selectedUser.id} />

			<Stack gap="md">
				<div>
					<p style="margin: 0 0 0.5rem 0;">
						Are you sure you want to delete <strong>{selectedUser.name}</strong>?
					</p>
					<p style="margin: 0; font-size: 0.875rem; color: var(--text-secondary);">
						{selectedUser.email}
					</p>
				</div>

				<div
					style="padding: 0.75rem; background: var(--color-error); color: white; border-radius: var(--radius-md); font-size: 0.875rem;"
				>
					<strong>⚠️ This action cannot be undone!</strong><br />
					All user data, including their posts and sessions, will be permanently deleted.
				</div>

				<div style="display: flex; gap: 1rem; justify-content: flex-end;">
					<Button
						type="button"
						variant="ghost"
						onclick={() => {
							isDeleteModalOpen = false;
							selectedUser = null;
						}}
						disabled={isSubmitting}
					>
						Cancel
					</Button>
					<Button type="submit" variant="danger" loading={isSubmitting}>Delete User</Button>
				</div>
			</Stack>
		</form>
	{/if}
</Modal>

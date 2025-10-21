<script module lang="ts">
	import { defineMeta } from '@storybook/addon-svelte-csf';
	import { fn } from 'storybook/test';
	import EmptyState from './EmptyState.svelte';

	const onActionFn = fn().mockName('onAction');
	const onSecondaryActionFn = fn().mockName('onSecondaryAction');

	/**
	 * EmptyState component for displaying empty or no-data states.
	 * Provides visual feedback and actions when content is unavailable.
	 */
	const { Story } = defineMeta({
		component: EmptyState,
		title: 'UI/EmptyState',
		tags: ['autodocs'],
		args: {
			title: 'No items found',
			icon: 'box'
		},
		argTypes: {
			icon: {
				control: 'select',
				options: ['box', 'folder', 'search', 'document', 'users']
			}
		}
	});
</script>

<Story name="Basic" args={{ 
	title: 'No products found'
}} />

<Story name="With Description" args={{ 
	title: 'No products found',
	description: 'Get started by adding your first product to the inventory.'
}} />

<Story name="With Action" args={{ 
	title: 'No products found',
	description: 'Get started by adding your first product to the inventory.',
	actionLabel: 'Add Product',
	onAction: onActionFn
}} />

<Story name="With Two Actions" args={{ 
	title: 'No products found',
	description: 'Get started by adding your first product or import from a file.',
	actionLabel: 'Add Product',
	onAction: onActionFn,
	secondaryActionLabel: 'Import Products',
	onSecondaryAction: onSecondaryActionFn
}} />

<Story name="Search Results" args={{ 
	icon: 'search',
	title: 'No results found',
	description: 'Try adjusting your search or filter to find what you\'re looking for.',
	actionLabel: 'Clear Filters',
	onAction: onActionFn
}} />

<Story name="Empty Folder" args={{ 
	icon: 'folder',
	title: 'This folder is empty',
	description: 'Add files to this folder to get started.',
	actionLabel: 'Upload Files',
	onAction: onActionFn
}} />

<Story name="No Documents" args={{ 
	icon: 'document',
	title: 'No documents',
	description: 'Create your first document to get started.',
	actionLabel: 'Create Document',
	onAction: onActionFn
}} />

<Story name="No Users" args={{ 
	icon: 'users',
	title: 'No team members',
	description: 'Invite your team members to collaborate.',
	actionLabel: 'Invite Team',
	onAction: onActionFn
}} />

<Story name="Different Icons">
	{#snippet template()}
		<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 2rem;">
			<div style="border: 1px solid #e5e7eb; border-radius: 0.5rem; padding: 1rem;">
				<EmptyState icon="box" title="Box Icon" />
			</div>
			<div style="border: 1px solid #e5e7eb; border-radius: 0.5rem; padding: 1rem;">
				<EmptyState icon="folder" title="Folder Icon" />
			</div>
			<div style="border: 1px solid #e5e7eb; border-radius: 0.5rem; padding: 1rem;">
				<EmptyState icon="search" title="Search Icon" />
			</div>
			<div style="border: 1px solid #e5e7eb; border-radius: 0.5rem; padding: 1rem;">
				<EmptyState icon="document" title="Document Icon" />
			</div>
			<div style="border: 1px solid #e5e7eb; border-radius: 0.5rem; padding: 1rem;">
				<EmptyState icon="users" title="Users Icon" />
			</div>
		</div>
	{/snippet}
</Story>

<Story name="Use Cases">
	{#snippet template()}
		<div style="display: flex; flex-direction: column; gap: 2rem;">
			<div>
				<h3 style="font-size: 0.875rem; font-weight: 600; margin-bottom: 0.75rem;">Empty Product List</h3>
				<div style="border: 1px solid #e5e7eb; border-radius: 0.5rem; min-height: 300px;">
					<EmptyState
						icon="box"
						title="No products yet"
						description="Start building your inventory by adding your first product."
						actionLabel="Add Product"
						onAction={onActionFn}
					/>
				</div>
			</div>

			<div>
				<h3 style="font-size: 0.875rem; font-weight: 600; margin-bottom: 0.75rem;">Empty Search Results</h3>
				<div style="border: 1px solid #e5e7eb; border-radius: 0.5rem; min-height: 300px;">
					<EmptyState
						icon="search"
						title="No results for 'wireless mouse'"
						description="We couldn't find any products matching your search. Try different keywords."
						actionLabel="Clear Search"
						onAction={onActionFn}
						secondaryActionLabel="Browse All"
						onSecondaryAction={onSecondaryActionFn}
					/>
				</div>
			</div>

			<div>
				<h3 style="font-size: 0.875rem; font-weight: 600; margin-bottom: 0.75rem;">Empty Category</h3>
				<div style="border: 1px solid #e5e7eb; border-radius: 0.5rem; min-height: 300px;">
					<EmptyState
						icon="folder"
						title="No items in this category"
						description="This category doesn't have any products yet. Add products to get started."
						actionLabel="Add to Category"
						onAction={onActionFn}
					/>
				</div>
			</div>
		</div>
	{/snippet}
</Story>
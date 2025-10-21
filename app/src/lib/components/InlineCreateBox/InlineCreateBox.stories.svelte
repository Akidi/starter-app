<script module lang="ts">
	import { defineMeta } from '@storybook/addon-svelte-csf';
	import { fn } from 'storybook/test';
	import InlineCreateBox from './InlineCreateBox.svelte';
	import TextInput from '../TextInput/TextInput.svelte';
	import Button from '../Button/Button.svelte';
	import Select from '../Select/Select.svelte';

	const onSubmitFn = fn().mockName('onSubmit');
	const onCancelFn = fn().mockName('onCancel');

	/**
	 * InlineCreateBox component for quick creation forms within the page.
	 * Useful for adding new items without navigating to a separate page.
	 */
	const { Story } = defineMeta({
		component: InlineCreateBox,
		title: 'UI/InlineCreateBox',
		tags: ['autodocs'],
		args: {
			title: 'Create New Item',
			variant: 'blue',
			showBadge: true,
			badge: 'New',
			badgeVariant: 'blue'
		},
		argTypes: {
			variant: {
				control: 'select',
				options: ['blue', 'green', 'amber', 'purple', 'gray']
			},
			badgeVariant: {
				control: 'select',
				options: ['blue', 'green', 'amber', 'red', 'gray', 'purple']
			},
			showBadge: { control: 'boolean' }
		}
	});
</script>

<Story name="Basic" args={{ title: 'Quick Add Product' }}>
	<TextInput
		id="product-name"
		name="productName"
		label="Product Name"
		placeholder="Enter product name"
	/>
	<div style="margin-top: 1rem; display: flex; gap: 0.5rem;">
		<Button size="sm" variant="primary">Create</Button>
		<Button size="sm" variant="secondary">Cancel</Button>
	</div>
</Story>

<Story name="With Description" args={{ 
	title: 'Add New Category',
	description: 'Create a new category for organizing your products'
}}>
	<TextInput
		id="category-name"
		name="categoryName"
		label="Category Name"
		placeholder="Enter category name"
	/>
	<div style="margin-top: 1rem; display: flex; gap: 0.5rem;">
		<Button size="sm" variant="primary">Create</Button>
		<Button size="sm" variant="secondary">Cancel</Button>
	</div>
</Story>

<Story name="Blue Variant" args={{ variant: 'blue', title: 'Quick Add' }}>
	<TextInput
		id="item"
		name="item"
		label="Item Name"
		placeholder="Enter name"
	/>
	<Button size="sm" variant="primary" class="mt-3">Add</Button>
</Story>

<Story name="Green Variant" args={{ variant: 'green', badgeVariant: 'green', title: 'Quick Add' }}>
	<TextInput
		id="item"
		name="item"
		label="Item Name"
		placeholder="Enter name"
	/>
	<Button size="sm" variant="primary" class="mt-3">Add</Button>
</Story>

<Story name="Amber Variant" args={{ variant: 'amber', badgeVariant: 'amber', title: 'Quick Add' }}>
	<TextInput
		id="item"
		name="item"
		label="Item Name"
		placeholder="Enter name"
	/>
	<Button size="sm" variant="primary" class="mt-3">Add</Button>
</Story>

<Story name="Purple Variant" args={{ variant: 'purple', badgeVariant: 'purple', title: 'Quick Add' }}>
	<TextInput
		id="item"
		name="item"
		label="Item Name"
		placeholder="Enter name"
	/>
	<Button size="sm" variant="primary" class="mt-3">Add</Button>
</Story>

<Story name="Without Badge" args={{ 
	title: 'Quick Create',
	showBadge: false
}}>
	<TextInput
		id="name"
		name="name"
		label="Name"
		placeholder="Enter name"
	/>
	<Button size="sm" variant="primary" class="mt-3">Create</Button>
</Story>

<Story name="Custom Badge" args={{ 
	title: 'Beta Feature',
	badge: 'Beta',
	badgeVariant: 'purple'
}}>
	<TextInput
		id="feature"
		name="feature"
		label="Feature Name"
		placeholder="Enter feature name"
	/>
	<Button size="sm" variant="primary" class="mt-3">Enable</Button>
</Story>

<Story name="Simple Form">
	{#snippet template()}
		<InlineCreateBox
			title="Add New Tag"
			description="Tags help organize and categorize your items"
		>
			<TextInput
				id="tag-name"
				name="tagName"
				label="Tag Name"
				placeholder="e.g., Electronics"
				required
			/>
			<div style="margin-top: 1rem; display: flex; gap: 0.5rem;">
				<Button size="sm" variant="primary" onclick={onSubmitFn}>
					Add Tag
				</Button>
				<Button size="sm" variant="ghost" onclick={onCancelFn}>
					Cancel
				</Button>
			</div>
		</InlineCreateBox>
	{/snippet}
</Story>

<Story name="Multi-Field Form">
	{#snippet template()}
		<InlineCreateBox
			title="Quick Add Product"
			description="Add a new product to your inventory"
			variant="blue"
		>
			<div style="display: flex; flex-direction: column; gap: 1rem;">
				<TextInput
					id="product-name"
					name="productName"
					label="Product Name"
					placeholder="Enter product name"
					required
				/>
				<TextInput
					id="sku"
					name="sku"
					label="SKU"
					placeholder="ABC-12345"
				/>
				<Select
					id="category"
					name="category"
					label="Category"
				>
					<option value="">Select category...</option>
					<option value="electronics">Electronics</option>
					<option value="clothing">Clothing</option>
					<option value="food">Food</option>
				</Select>
				<div style="display: flex; gap: 0.5rem; padding-top: 0.5rem;">
					<Button size="sm" variant="primary" onclick={onSubmitFn}>
						Add Product
					</Button>
					<Button size="sm" variant="secondary" onclick={onCancelFn}>
						Cancel
					</Button>
				</div>
			</div>
		</InlineCreateBox>
	{/snippet}
</Story>

<Story name="Use Cases">
	{#snippet template()}
		<div style="display: flex; flex-direction: column; gap: 1.5rem;">
			<div>
				<h3 style="font-size: 0.875rem; font-weight: 600; margin-bottom: 0.75rem;">Quick Add Tag</h3>
				<InlineCreateBox
					title="Add Tag"
					variant="blue"
				>
					<TextInput
						id="tag"
						name="tag"
						label="Tag Name"
						placeholder="New tag"
					/>
					<Button size="sm" variant="primary" class="mt-3">Add</Button>
				</InlineCreateBox>
			</div>

			<div>
				<h3 style="font-size: 0.875rem; font-weight: 600; margin-bottom: 0.75rem;">Quick Add Category</h3>
				<InlineCreateBox
					title="Add Category"
					description="Organize your products with categories"
					variant="green"
					badgeVariant="green"
				>
					<TextInput
						id="category"
						name="category"
						label="Category Name"
						placeholder="Electronics"
					/>
					<Button size="sm" variant="primary" class="mt-3">Create</Button>
				</InlineCreateBox>
			</div>

			<div>
				<h3 style="font-size: 0.875rem; font-weight: 600; margin-bottom: 0.75rem;">Quick Add Note</h3>
				<InlineCreateBox
					title="Add Note"
					variant="amber"
					badge="Quick"
					badgeVariant="amber"
				>
					<TextInput
						id="note"
						name="note"
						label="Note"
						placeholder="Enter your note"
					/>
					<Button size="sm" variant="primary" class="mt-3">Save</Button>
				</InlineCreateBox>
			</div>
		</div>
	{/snippet}
</Story>

<Story name="In Context">
	{#snippet template()}
		<div style="max-width: 600px;">
			<h2 style="font-size: 1.25rem; font-weight: 700; margin-bottom: 1rem;">Product Categories</h2>
			
			<div style="display: flex; flex-direction: column; gap: 0.75rem; margin-bottom: 1.5rem;">
				<div style="padding: 0.75rem; border: 1px solid #e5e7eb; border-radius: 0.5rem;">
					<div style="font-weight: 600;">Electronics</div>
					<div style="font-size: 0.875rem; color: #6b7280;">15 products</div>
				</div>
				<div style="padding: 0.75rem; border: 1px solid #e5e7eb; border-radius: 0.5rem;">
					<div style="font-weight: 600;">Clothing</div>
					<div style="font-size: 0.875rem; color: #6b7280;">23 products</div>
				</div>
			</div>

			<InlineCreateBox
				title="Add New Category"
				description="Create a category to organize your products"
			>
				<TextInput
					id="new-category"
					name="newCategory"
					label="Category Name"
					placeholder="e.g., Home & Garden"
					required
				/>
				<div style="margin-top: 1rem; display: flex; gap: 0.5rem;">
					<Button size="sm" variant="primary">Create Category</Button>
					<Button size="sm" variant="ghost">Cancel</Button>
				</div>
			</InlineCreateBox>
		</div>
	{/snippet}
</Story>
<script module lang="ts">
	import { defineMeta } from '@storybook/addon-svelte-csf';
	import FormSection from './FormSection.svelte';
	import TextInput from '../TextInput.svelte';
	import Select from '../Select/Select.svelte';
	import Button from '../Button/Button.svelte';

	const { Story } = defineMeta({
		component: FormSection,
		title: 'UI/FormSection',
		tags: ['autodocs'],
		argTypes: {
			required: { control: 'boolean' },
			collapsible: { control: 'boolean' },
			defaultOpen: { control: 'boolean' },
			spacing: {
				control: 'select',
				options: ['tight', 'normal', 'relaxed']
			}
		},
		args: {
			title: 'Section Title',
			required: false,
			collapsible: false,
			defaultOpen: true,
			spacing: 'normal'
		}
	});
</script>

<script lang="ts">
    let withActionsInput = $state('');
</script>

<Story name="Basic" args={{ title: 'Personal Information' }}>
	<TextInput
		id="name"
		name="name"
		label="Full Name"
	/>
	<TextInput
		id="email"
		name="email"
		label="Email"
		type="email"
	/>
</Story>

<Story name="With Description" args={{ 
	title: 'Product Details',
	description: 'Enter the basic information about your product'
}}>
	<TextInput
		id="product-name"
		name="productName"
		label="Product Name"
	/>
	<Select
		id="category"
		name="category"
		label="Category"
	>
		<option value="electronics">Electronics</option>
		<option value="clothing">Clothing</option>
	</Select>
</Story>

<Story name="Required" args={{ 
	title: 'Required Information',
	required: true
}}>
	<TextInput
		id="required-name"
		name="name"
		label="Name"
		required
	/>
</Story>

<Story name="With Error" args={{ 
	title: 'Billing Information',
	error: 'Please correct the errors below'
}}>
	<TextInput
		id="card"
		name="card"
		label="Card Number"
		error="Invalid card number"
	/>
</Story>

<Story name="With Badge" args={{ 
	title: 'Advanced Options',
	badge: 'Optional'
}}>
	<TextInput
		id="notes"
		name="notes"
		label="Additional Notes"
	/>
</Story>

<Story name="Collapsible" args={{ 
	title: 'Additional Information',
	description: 'Click to expand',
	collapsible: true,
	defaultOpen: false
}}>
	<TextInput
		id="extra"
		name="extra"
		label="Extra Field"
	/>
</Story>

<Story name="With Actions" args={{ title: 'Inventory Settings', description: 'Manage your inventory preferences' }}>
		<Button size="sm" onclick={() => withActionsInput = ""} variant="ghost">
			Reset
		</Button>
		<Button size="sm" onclick={() => console.log('Data saved')} variant="primary">
			Save
		</Button>
	
	<TextInput
		id="stock"
		name="stock"
		label="Stock Quantity"
		type="number"
        bind:value={withActionsInput}
	/>
</Story>

<Story name="Tight Spacing" args={{ 
	title: 'Compact Form',
	spacing: 'tight'
}}>
	<TextInput id="field1" name="field1" label="Field 1" />
	<TextInput id="field2" name="field2" label="Field 2" />
	<TextInput id="field3" name="field3" label="Field 3" />
</Story>

<Story name="Relaxed Spacing" args={{ 
	title: 'Spacious Form',
	spacing: 'relaxed'
}}>
	<TextInput id="field1" name="field1" label="Field 1" />
	<TextInput id="field2" name="field2" label="Field 2" />
	<TextInput id="field3" name="field3" label="Field 3" />
</Story>

<Story name="Multiple Sections">
	{#snippet template()}
		<div style="display: flex; flex-direction: column; gap: 1.5rem;">
			<FormSection title="Section 1">
				<TextInput id="s1-field" name="field" label="Field" />
			</FormSection>
			<FormSection title="Section 2">
				<TextInput id="s2-field" name="field" label="Field" />
			</FormSection>
			<FormSection title="Section 3" collapsible defaultOpen={false}>
				<TextInput id="s3-field" name="field" label="Field" />
			</FormSection>
		</div>
	{/snippet}
</Story>
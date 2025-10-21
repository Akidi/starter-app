<script module lang="ts">
	import { defineMeta } from '@storybook/addon-svelte-csf';
	import Button from './Button.svelte';

	const { Story } = defineMeta({
		component: Button,
		title: 'UI/Button',
		tags: ['autodocs'],
		argTypes: {
			variant: {
				control: 'select',
				options: ['primary', 'secondary', 'danger', 'ghost']
			},
			size: {
				control: 'select',
				options: ['sm', 'md', 'lg']
			},
			type: {
				control: 'select',
				options: ['button', 'submit', 'reset']
			},
			disabled: { control: 'boolean' },
			loading: { control: 'boolean' },
			fullWidth: { control: 'boolean' }
		},
		args: {
			variant: 'primary',
			size: 'md',
			type: 'button',
			disabled: false,
			loading: false,
			fullWidth: false
		}
	});
</script>

<Story name="Primary" args={{ variant: 'primary' }}>
	Primary Button
</Story>

<Story name="Secondary" args={{ variant: 'secondary' }}>
	Secondary Button
</Story>

<Story name="Danger" args={{ variant: 'danger' }}>
	Danger Button
</Story>

<Story name="Ghost" args={{ variant: 'ghost' }}>
	Ghost Button
</Story>

<Story name="Small" args={{ size: 'sm' }}>
	Small Button
</Story>

<Story name="Medium" args={{ size: 'md' }}>
	Medium Button
</Story>

<Story name="Large" args={{ size: 'lg' }}>
	Large Button
</Story>

<Story name="Loading" args={{ loading: true }}>
	Loading...
</Story>

<Story name="Disabled" args={{ disabled: true }}>
	Disabled Button
</Story>

<Story name="Full Width" args={{ fullWidth: true }}>
	Full Width Button
</Story>

<Story name="With Click Handler">
	{#snippet template()}
		<Button onclick={() => alert('Button clicked!')}>
			Click Me
		</Button>
	{/snippet}
</Story>

<Story name="All Variants">
	{#snippet template()}
		<div style="display: flex; flex-direction: column; gap: 1rem;">
			<Button variant="primary">Primary</Button>
			<Button variant="secondary">Secondary</Button>
			<Button variant="danger">Danger</Button>
			<Button variant="ghost">Ghost</Button>
		</div>
	{/snippet}
</Story>

<Story name="All Sizes">
	{#snippet template()}
		<div style="display: flex; align-items: center; gap: 1rem;">
			<Button size="sm">Small</Button>
			<Button size="md">Medium</Button>
			<Button size="lg">Large</Button>
		</div>
	{/snippet}
</Story>
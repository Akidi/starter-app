import { render, screen, fireEvent } from '@testing-library/svelte';
import { describe, it, expect, vi } from 'vitest';
import TextInput from './TextInput.svelte';

describe('TextInput.svelte', () => {
	it('renders input with label', () => {
		render(TextInput, {
			props: { id: 'test', name: 'test', label: 'Test Input' }
		});

		const label = screen.getByText('Test Input');
		const input = screen.getByLabelText('Test Input');

		expect(label).toBeInTheDocument();
		expect(input).toBeInTheDocument();
	});

	it('renders with placeholder', () => {
		render(TextInput, {
			props: { id: 'test', name: 'test', placeholder: 'Enter text...' }
		});

		const input = screen.getByPlaceholderText('Enter text...');
		expect(input).toBeInTheDocument();
	});

	it('renders as required when required prop is true', () => {
		render(TextInput, {
			props: { id: 'test', name: 'test', required: true, label: 'Required Field' }
		});

		const input = screen.getByLabelText(/required field/i);
		expect(input).toBeRequired();
	});

	it('renders as disabled when disabled prop is true', () => {
		render(TextInput, {
			props: { id: 'test', name: 'test', disabled: true }
		});

		const input = screen.getByRole('textbox');
		expect(input).toBeDisabled();
	});

	it('displays help text when provided', () => {
		render(TextInput, {
			props: { id: 'test', name: 'test', helpText: 'This is help text' }
		});

		const helpText = screen.getByText('This is help text');
		expect(helpText).toBeInTheDocument();
	});

	it('displays error message when provided', () => {
		render(TextInput, {
			props: { id: 'test', name: 'test', error: 'This field is required' }
		});

		const errorMsg = screen.getByText('This field is required');
		expect(errorMsg).toBeInTheDocument();
	});

	it('handles value binding', async () => {
		let value = 'initial';
		const { component } = render(TextInput, {
			props: { id: 'test', name: 'test', value }
		});

		const input = screen.getByRole('textbox') as HTMLInputElement;
		expect(input.value).toBe('initial');

		// Update value
		await fireEvent.input(input, { target: { value: 'updated' } });
		expect(input.value).toBe('updated');
	});

	it('calls onchange handler when value changes', async () => {
		const handleChange = vi.fn();
		render(TextInput, {
			props: { id: 'test', name: 'test', onchange: handleChange }
		});

		const input = screen.getByRole('textbox');
		await fireEvent.change(input, { target: { value: 'new value' } });

		expect(handleChange).toHaveBeenCalled();
	});

	it('supports different input types', () => {
		render(TextInput, {
			props: { id: 'test', name: 'test', type: 'email' }
		});

		const input = screen.getByRole('textbox');
		expect(input).toHaveAttribute('type', 'email');
	});

	it('applies pattern attribute when provided', () => {
		render(TextInput, {
			props: { id: 'test', name: 'test', pattern: '[0-9]+' }
		});

		const input = screen.getByRole('textbox');
		expect(input).toHaveAttribute('pattern', '[0-9]+');
	});

	it('applies min and max length', () => {
		render(TextInput, {
			props: { id: 'test', name: 'test', minlength: 3, maxlength: 10 }
		});

		const input = screen.getByRole('textbox');
		expect(input).toHaveAttribute('minlength', '3');
		expect(input).toHaveAttribute('maxlength', '10');
	});

	it('renders with autocomplete attribute', () => {
		render(TextInput, {
			props: { id: 'email', name: 'email', autocomplete: 'email' }
		});

		const input = screen.getByRole('textbox');
		expect(input).toHaveAttribute('autocomplete', 'email');
	});
});

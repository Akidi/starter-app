import { render, screen, fireEvent } from '@testing-library/svelte';
import { describe, it, expect, vi } from 'vitest';
import Button from './Button.svelte';

describe('Button.svelte', () => {
	it('renders default button with text', () => {
		render(Button, {
			props: { children: 'Click me' }
		});

		const button = screen.getByRole('button', { name: /click me/i });
		expect(button).toBeInTheDocument();
	});

	it('applies variant classes correctly', () => {
		const { container } = render(Button, {
			props: { variant: 'primary', children: 'Primary Button' }
		});

		const button = container.querySelector('button');
		expect(button).toHaveAttribute('data-variant', 'primary');
	});

	it('applies size classes correctly', () => {
		const { container } = render(Button, {
			props: { size: 'lg', children: 'Large Button' }
		});

		const button = container.querySelector('button');
		expect(button).toHaveAttribute('data-size', 'lg');
	});

	it('disables button when disabled prop is true', () => {
		render(Button, {
			props: { disabled: true, children: 'Disabled Button' }
		});

		const button = screen.getByRole('button');
		expect(button).toBeDisabled();
	});

	it('shows loading state', () => {
		render(Button, {
			props: { loading: true, children: 'Submit' }
		});

		const button = screen.getByRole('button');
		expect(button).toBeDisabled();
		// Loading spinner should be present
		expect(button.querySelector('.spinner')).toBeInTheDocument();
	});

	it('calls onclick handler when clicked', async () => {
		const handleClick = vi.fn();
		render(Button, {
			props: { onclick: handleClick, children: 'Click me' }
		});

		const button = screen.getByRole('button');
		await fireEvent.click(button);

		expect(handleClick).toHaveBeenCalledTimes(1);
	});

	it('does not call onclick when disabled', async () => {
		const handleClick = vi.fn();
		render(Button, {
			props: { onclick: handleClick, disabled: true, children: 'Click me' }
		});

		const button = screen.getByRole('button');
		await fireEvent.click(button);

		expect(handleClick).not.toHaveBeenCalled();
	});

	it('renders as link when href is provided', () => {
		render(Button, {
			props: { href: '/test', children: 'Link Button' }
		});

		const link = screen.getByRole('link', { name: /link button/i });
		expect(link).toHaveAttribute('href', '/test');
	});

	it('applies fullWidth style', () => {
		const { container } = render(Button, {
			props: { fullWidth: true, children: 'Full Width' }
		});

		const button = container.querySelector('button');
		expect(button).toHaveStyle({ width: '100%' });
	});

	it('renders different button types', () => {
		render(Button, {
			props: { type: 'submit', children: 'Submit' }
		});

		const button = screen.getByRole('button');
		expect(button).toHaveAttribute('type', 'submit');
	});
});

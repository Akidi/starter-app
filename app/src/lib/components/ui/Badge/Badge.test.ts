import { render, screen } from '@testing-library/svelte';
import { describe, it, expect } from 'vitest';
import Badge from './Badge.svelte';

describe('Badge.svelte', () => {
	it('renders badge with text', () => {
		render(Badge, {
			props: {
				children: 'New'
			}
		});

		expect(screen.getByText('New')).toBeInTheDocument();
	});

	it('applies variant attribute correctly', () => {
		const { container } = render(Badge, {
			props: {
				variant: 'success',
				children: 'Success'
			}
		});

		const badge = container.querySelector('[data-badge]');
		expect(badge).toHaveAttribute('data-variant', 'success');
	});

	it('applies size attribute correctly', () => {
		const { container } = render(Badge, {
			props: {
				size: 'lg',
				children: 'Large'
			}
		});

		const badge = container.querySelector('[data-badge]');
		expect(badge).toHaveAttribute('data-size', 'lg');
	});

	it('renders different variants', () => {
		const variants = ['primary', 'success', 'warning', 'danger', 'info'] as const;

		variants.forEach((variant) => {
			const { container } = render(Badge, {
				props: {
					variant,
					children: variant
				}
			});

			const badge = container.querySelector('[data-badge]');
			expect(badge).toHaveAttribute('data-variant', variant);
		});
	});

	it('renders different sizes', () => {
		const sizes = ['sm', 'md', 'lg'] as const;

		sizes.forEach((size) => {
			const { container } = render(Badge, {
				props: {
					size,
					children: 'Badge'
				}
			});

			const badge = container.querySelector('[data-badge]');
			expect(badge).toHaveAttribute('data-size', size);
		});
	});

	it('renders with custom styles', () => {
		const { container } = render(Badge, {
			props: {
				style: 'margin: 10px;',
				children: 'Styled'
			}
		});

		const badge = container.querySelector('[data-badge]');
		expect(badge).toHaveAttribute('style', expect.stringContaining('margin: 10px'));
	});
});

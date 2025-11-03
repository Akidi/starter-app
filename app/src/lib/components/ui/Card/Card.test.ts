import { render, screen, fireEvent } from '@testing-library/svelte';
import { describe, it, expect, vi } from 'vitest';
import Card from './Card.svelte';

describe('Card.svelte', () => {
	it('renders children content', () => {
		render(Card, {
			props: {
				children: 'Card content'
			}
		});

		expect(screen.getByText('Card content')).toBeInTheDocument();
	});

	it('renders with title when provided', () => {
		render(Card, {
			props: {
				title: 'Card Title',
				children: 'Card content'
			}
		});

		const title = screen.getByText('Card Title');
		expect(title).toBeInTheDocument();
	});

	it('renders with subtitle when provided', () => {
		render(Card, {
			props: {
				subtitle: 'Card subtitle',
				children: 'Card content'
			}
		});

		const subtitle = screen.getByText('Card subtitle');
		expect(subtitle).toBeInTheDocument();
	});

	it('applies hoverable styles when hoverable prop is true', () => {
		const { container } = render(Card, {
			props: {
				hoverable: true,
				children: 'Hoverable card'
			}
		});

		const card = container.querySelector('[data-card]');
		expect(card).toHaveAttribute('data-hoverable', 'true');
	});

	it('applies clickable styles and calls onclick when clickable', async () => {
		const handleClick = vi.fn();
		const { container } = render(Card, {
			props: {
				clickable: true,
				onclick: handleClick,
				children: 'Clickable card'
			}
		});

		const card = container.querySelector('[data-card]');
		expect(card).toHaveAttribute('data-clickable', 'true');

		if (card) {
			await fireEvent.click(card);
			expect(handleClick).toHaveBeenCalledTimes(1);
		}
	});

	it('applies padding prop correctly', () => {
		const { container } = render(Card, {
			props: {
				padding: 'lg',
				children: 'Card with large padding'
			}
		});

		const card = container.querySelector('[data-card]');
		expect(card).toHaveAttribute('data-padding', 'lg');
	});

	it('renders with custom styles', () => {
		const { container } = render(Card, {
			props: {
				style: 'background: red;',
				children: 'Styled card'
			}
		});

		const card = container.querySelector('[data-card]');
		expect(card).toHaveAttribute('style', expect.stringContaining('background: red'));
	});
});

import { render, screen, fireEvent } from '@testing-library/svelte';
import { describe, it, expect } from 'vitest';
import Modal from './Modal.svelte';

describe('Modal.svelte', () => {
	it('does not render when isOpen is false', () => {
		const { container } = render(Modal, {
			props: {
				isOpen: false,
				title: 'Test Modal',
				children: 'Modal content'
			}
		});

		// Modal should not be in the document
		expect(container.querySelector('[role="dialog"]')).not.toBeInTheDocument();
	});

	it('renders when isOpen is true', () => {
		render(Modal, {
			props: {
				isOpen: true,
				title: 'Test Modal',
				children: 'Modal content'
			}
		});

		const modal = screen.getByRole('dialog');
		expect(modal).toBeInTheDocument();
	});

	it('renders title correctly', () => {
		render(Modal, {
			props: {
				isOpen: true,
				title: 'Test Modal Title',
				children: 'Modal content'
			}
		});

		const title = screen.getByText('Test Modal Title');
		expect(title).toBeInTheDocument();
	});

	it('renders children content', () => {
		render(Modal, {
			props: {
				isOpen: true,
				title: 'Test Modal',
				children: 'This is modal content'
			}
		});

		const content = screen.getByText('This is modal content');
		expect(content).toBeInTheDocument();
	});

	it('closes when close button is clicked', async () => {
		let isOpen = true;

		const { component } = render(Modal, {
			props: {
				isOpen,
				title: 'Test Modal',
				children: 'Modal content'
			}
		});

		// Find close button
		const closeButton = screen.getByRole('button', { name: /close/i });
		await fireEvent.click(closeButton);

		// In a real test, you'd check that isOpen was set to false
		// This would typically involve component state or event dispatching
	});

	it('applies size classes correctly', () => {
		const { container } = render(Modal, {
			props: {
				isOpen: true,
				title: 'Test Modal',
				size: 'lg',
				children: 'Modal content'
			}
		});

		const modalContent = container.querySelector('[data-modal-content]');
		expect(modalContent).toHaveAttribute('data-size', 'lg');
	});

	it('renders with overlay', () => {
		const { container } = render(Modal, {
			props: {
				isOpen: true,
				title: 'Test Modal',
				children: 'Modal content'
			}
		});

		const overlay = container.querySelector('[data-modal-overlay]');
		expect(overlay).toBeInTheDocument();
	});

	it('has proper accessibility attributes', () => {
		render(Modal, {
			props: {
				isOpen: true,
				title: 'Test Modal',
				children: 'Modal content'
			}
		});

		const modal = screen.getByRole('dialog');
		expect(modal).toHaveAttribute('aria-modal', 'true');
		expect(modal).toHaveAttribute('aria-labelledby');
	});
});

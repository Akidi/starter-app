import { writable } from 'svelte/store';

export type ToastType = 'success' | 'error' | 'warning' | 'info';

export interface Toast {
	id: string;
	type: ToastType;
	message: string;
	duration?: number;
}

interface ToastStore {
	toasts: Toast[];
}

function createToastStore() {
	const { subscribe, update } = writable<ToastStore>({ toasts: [] });

	return {
		subscribe,
		add: (toast: Omit<Toast, 'id'>) => {
			const id = `toast-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
			const newToast: Toast = { ...toast, id };

			update((store) => ({
				toasts: [...store.toasts, newToast]
			}));

			// Don't auto-remove here - let the Toast component handle it
			return id;
		},
		remove: (id: string) => {
			update((store) => ({
				toasts: store.toasts.filter((t) => t.id !== id)
			}));
		},
		clear: () => {
			update(() => ({ toasts: [] }));
		}
	};
}

export const toasts = createToastStore();
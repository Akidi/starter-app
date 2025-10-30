// src/lib/utils/localStorage.svelte.ts
/**
 * Type-safe localStorage utility with automatic JSON parsing/stringification
 * and optional expiration support
 */

interface StorageOptions {
	/** Time in milliseconds until the item expires. If not set, item never expires */
	expiresIn?: number;
	/** Whether to log errors to console. Default: true */
	silent?: boolean;
}

interface StorageItem<T> {
	value: T;
	expiresAt?: number;
}

class LocalStorageManager {
	private prefix: string;
	private isAvailable: boolean;

	constructor(prefix: string = 'app') {
		this.prefix = prefix;
		this.isAvailable = this.checkAvailability();
	}

	/**
	 * Check if localStorage is available in the current environment
	 */
	private checkAvailability(): boolean {
		if (typeof window === 'undefined' || typeof localStorage === 'undefined') {
			return false;
		}

		try {
			const testKey = '__storage_test__';
			localStorage.setItem(testKey, 'test');
			localStorage.removeItem(testKey);
			return true;
		} catch (e) {
			return false;
		}
	}

	/**
	 * Get the full key with prefix
	 */
	private getKey(key: string): string {
		return `${this.prefix}:${key}`;
	}

	/**
	 * Set an item in localStorage with optional expiration
	 */
	set<T>(key: string, value: T, options: StorageOptions = {}): boolean {
		if (!this.isAvailable) {
			if (!options.silent) {
				console.warn('localStorage is not available');
			}
			return false;
		}

		try {
			const item: StorageItem<T> = {
				value,
				expiresAt: options.expiresIn ? Date.now() + options.expiresIn : undefined
			};

			localStorage.setItem(this.getKey(key), JSON.stringify(item));
			return true;
		} catch (error) {
			if (!options.silent) {
				console.error(`Failed to set localStorage item "${key}":`, error);
			}
			return false;
		}
	}

	/**
	 * Get an item from localStorage with automatic type inference
	 */
	get<T>(key: string, defaultValue?: T, options: StorageOptions = {}): T | null {
		if (!this.isAvailable) {
			return defaultValue ?? null;
		}

		try {
			const itemStr = localStorage.getItem(this.getKey(key));
			if (!itemStr) {
				return defaultValue ?? null;
			}

			const item: StorageItem<T> = JSON.parse(itemStr);

			// Check if item has expired
			if (item.expiresAt && Date.now() > item.expiresAt) {
				this.remove(key);
				return defaultValue ?? null;
			}

			return item.value;
		} catch (error) {
			if (!options.silent) {
				console.error(`Failed to get localStorage item "${key}":`, error);
			}
			return defaultValue ?? null;
		}
	}

	/**
	 * Remove an item from localStorage
	 */
	remove(key: string): boolean {
		if (!this.isAvailable) {
			return false;
		}

		try {
			localStorage.removeItem(this.getKey(key));
			return true;
		} catch (error) {
			console.error(`Failed to remove localStorage item "${key}":`, error);
			return false;
		}
	}

	/**
	 * Check if an item exists and is not expired
	 */
	has(key: string): boolean {
		if (!this.isAvailable) {
			return false;
		}

		const value = this.get(key, undefined, { silent: true });
		return value !== null;
	}

	/**
	 * Clear all items with the current prefix
	 */
	clear(): boolean {
		if (!this.isAvailable) {
			return false;
		}

		try {
			const keys = Object.keys(localStorage);
			const prefixedKeys = keys.filter((key) => key.startsWith(`${this.prefix}:`));

			prefixedKeys.forEach((key) => {
				localStorage.removeItem(key);
			});

			return true;
		} catch (error) {
			console.error('Failed to clear localStorage:', error);
			return false;
		}
	}

	/**
	 * Clear all items in localStorage (including other prefixes)
	 */
	clearAll(): boolean {
		if (!this.isAvailable) {
			return false;
		}

		try {
			localStorage.clear();
			return true;
		} catch (error) {
			console.error('Failed to clear all localStorage:', error);
			return false;
		}
	}

	/**
	 * Get all keys with the current prefix
	 */
	keys(): string[] {
		if (!this.isAvailable) {
			return [];
		}

		try {
			const keys = Object.keys(localStorage);
			const prefixLength = this.prefix.length + 1; // +1 for the colon

			return keys
				.filter((key) => key.startsWith(`${this.prefix}:`))
				.map((key) => key.slice(prefixLength));
		} catch (error) {
			console.error('Failed to get localStorage keys:', error);
			return [];
		}
	}

	/**
	 * Get the size of localStorage in bytes (approximate)
	 */
	getSize(): number {
		if (!this.isAvailable) {
			return 0;
		}

		try {
			let size = 0;
			for (const key in localStorage) {
				if (localStorage.hasOwnProperty(key)) {
					size += key.length + (localStorage.getItem(key)?.length || 0);
				}
			}
			return size;
		} catch (error) {
			console.error('Failed to calculate localStorage size:', error);
			return 0;
		}
	}

	/**
	 * Remove all expired items
	 */
	cleanExpired(): number {
		if (!this.isAvailable) {
			return 0;
		}

		let removedCount = 0;
		const keys = this.keys();

		keys.forEach((key) => {
			// get() will automatically remove expired items
			const value = this.get(key, undefined, { silent: true });
			if (value === null) {
				removedCount++;
			}
		});

		return removedCount;
	}
}

/**
 * Create a reactive localStorage store using Svelte 5 runes
 */
export function createLocalStorageStore<T>(
	key: string,
	initialValue: T,
	options: StorageOptions & { prefix?: string } = {}
) {
	const storage = new LocalStorageManager(options.prefix);
	const storedValue = storage.get<T>(key, initialValue, options);

	let value = $state<T>(storedValue ?? initialValue);

	// Watch for changes and update localStorage
	$effect(() => {
		storage.set(key, value, options);
	});

	// Listen for storage events from other tabs/windows
	if (typeof window !== 'undefined') {
		const handleStorageChange = (event: StorageEvent) => {
			if (event.key === storage['getKey'](key) && event.newValue) {
				try {
					const item: StorageItem<T> = JSON.parse(event.newValue);
					value = item.value;
				} catch (error) {
					console.error('Failed to parse storage event:', error);
				}
			}
		};

		window.addEventListener('storage', handleStorageChange);
	}

	return {
		get value() {
			return value;
		},
		set value(newValue: T) {
			value = newValue;
		},
		reset() {
			value = initialValue;
		},
		clear() {
			storage.remove(key);
			value = initialValue;
		}
	};
}

// Export a default instance with app prefix
export const storage = new LocalStorageManager('app');

// Export the class for custom instances
export { LocalStorageManager };
/**
 * Paraglide i18n runtime stub
 * This is a placeholder until paraglide is properly initialized with message files
 */

/**
 * Removes locale prefix from URL pathname
 * Stub implementation - just returns the URL as-is
 */
export function deLocalizeUrl(url: string | URL): URL {
	const urlObj = typeof url === 'string' ? new URL(url) : url;
	return urlObj;
}

/**
 * Sets the current locale
 * Stub implementation - does nothing
 */
export function setLocale(locale: string): void {
	// Stub - locale setting would be implemented when paraglide is fully configured
	console.log(`[Paraglide stub] Locale set to: ${locale}`);
}

/**
 * Gets the current locale
 * Stub implementation - always returns 'en'
 */
export function getLocale(): string {
	return 'en';
}

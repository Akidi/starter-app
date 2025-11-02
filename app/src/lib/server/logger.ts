/**
 * Structured Logger for Server-Side Code
 *
 * Usage:
 *   import { logger } from '$lib/server/logger';
 *
 *   logger.info('User logged in', { userId, email });
 *   logger.error('Database error', error, { query });
 *   logger.debug('Processing request', { path, method });
 */

type LogLevel = 'debug' | 'info' | 'warn' | 'error';
type LogContext = Record<string, unknown>;

interface LogEntry {
	timestamp: string;
	level: LogLevel;
	message: string;
	context?: LogContext;
	error?: {
		message: string;
		stack?: string;
		name: string;
	};
}

class Logger {
	private readonly isProduction: boolean;
	private readonly logLevel: LogLevel;
	private readonly enableDebug: boolean;

	constructor() {
		this.isProduction = process.env.NODE_ENV === 'production';
		this.enableDebug = process.env.DEBUG === 'true' || process.env.NODE_ENV === 'development';

		// Determine log level from environment
		const envLogLevel = (process.env.LOG_LEVEL?.toLowerCase() as LogLevel) || 'info';
		this.logLevel = envLogLevel;
	}

	/**
	 * Check if a log level should be logged based on current configuration
	 */
	private shouldLog(level: LogLevel): boolean {
		const levels: LogLevel[] = ['debug', 'info', 'warn', 'error'];
		const currentLevelIndex = levels.indexOf(this.logLevel);
		const requestedLevelIndex = levels.indexOf(level);

		return requestedLevelIndex >= currentLevelIndex;
	}

	/**
	 * Format a log entry as JSON (production) or human-readable (development)
	 */
	private format(entry: LogEntry): string {
		if (this.isProduction) {
			// Production: JSON format for log aggregation
			return JSON.stringify(entry);
		}

		// Development: Human-readable format with colors
		const timestamp = entry.timestamp.split('T')[1]?.slice(0, 8) || '';
		const level = entry.level.toUpperCase().padEnd(5);

		let color = '\x1b[0m'; // Reset
		switch (entry.level) {
			case 'debug':
				color = '\x1b[36m'; // Cyan
				break;
			case 'info':
				color = '\x1b[32m'; // Green
				break;
			case 'warn':
				color = '\x1b[33m'; // Yellow
				break;
			case 'error':
				color = '\x1b[31m'; // Red
				break;
		}

		let output = `${color}[${timestamp}] ${level}\x1b[0m ${entry.message}`;

		if (entry.context && Object.keys(entry.context).length > 0) {
			output += `\n  ${JSON.stringify(entry.context, null, 2)}`;
		}

		if (entry.error) {
			output += `\n  Error: ${entry.error.message}`;
			if (entry.error.stack && !this.isProduction) {
				output += `\n${entry.error.stack}`;
			}
		}

		return output;
	}

	/**
	 * Write log entry
	 */
	private write(level: LogLevel, message: string, context?: LogContext, error?: Error): void {
		if (!this.shouldLog(level)) {
			return;
		}

		const entry: LogEntry = {
			timestamp: new Date().toISOString(),
			level,
			message,
			...(context && { context }),
			...(error && {
				error: {
					message: error.message,
					stack: error.stack,
					name: error.name
				}
			})
		};

		const formatted = this.format(entry);

		switch (level) {
			case 'debug':
			case 'info':
				console.log(formatted);
				break;
			case 'warn':
				console.warn(formatted);
				break;
			case 'error':
				console.error(formatted);
				break;
		}
	}

	/**
	 * Debug log - only shown when DEBUG=true or in development
	 */
	debug(message: string, context?: LogContext): void {
		if (this.enableDebug) {
			this.write('debug', message, context);
		}
	}

	/**
	 * Info log - general informational messages
	 */
	info(message: string, context?: LogContext): void {
		this.write('info', message, context);
	}

	/**
	 * Warning log - something unexpected but not an error
	 */
	warn(message: string, context?: LogContext): void {
		this.write('warn', message, context);
	}

	/**
	 * Error log - errors that need attention
	 */
	error(message: string, error?: Error | unknown, context?: LogContext): void {
		const errorObj = error instanceof Error ? error : new Error(String(error));
		this.write('error', message, context, errorObj);
	}
}

// Export singleton instance
export const logger = new Logger();

// Export type for testing
export type { LogLevel, LogContext };

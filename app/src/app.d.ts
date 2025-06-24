// for information about these interfaces
declare global {
	namespace App {
		interface Locals {
			user: auth.CachedUser | null;
			session: auth.SessionValidationResult['session'];
		}
	}
}

export {};

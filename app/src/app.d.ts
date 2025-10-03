// for information about these interfaces
declare global {
	namespace App {
		interface Locals {
			user: {
				id: string;
				name: string;
				email: string;
				role: string;
			} | null;
			session: auth.SessionValidationResult['session'];
		}
	}
}

export {};

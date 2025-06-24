<script lang="ts">
	import { enhance } from '$app/forms';
	import type { ActionData } from './$types';

	let { form }: { form: ActionData } = $props();
</script>

<div class="flex min-h-screen flex-col justify-center bg-gray-50 py-12 sm:px-6 lg:px-8">
	<div class="sm:mx-auto sm:w-full sm:max-w-md">
		<h2 class="mt-6 text-center text-3xl font-extrabold text-gray-900">Sign in to your account</h2>
		<p class="mt-2 text-center text-sm text-gray-600">Or create a new account</p>
	</div>

	<div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
		<div class="bg-white px-4 py-8 shadow sm:rounded-lg sm:px-10">
			<!-- Login Form -->
			<form method="post" action="?/login" use:enhance class="space-y-6">
				<div>
					<label for="login-email" class="block text-sm font-medium text-gray-700">
						Email address
					</label>
					<div class="mt-1">
						<input
							id="login-email"
							name="email"
							type="email"
							autocomplete="email"
							required
							class="block w-full appearance-none rounded-md border border-gray-300 px-3 py-2 placeholder-gray-400 focus:border-blue-500 focus:ring-blue-500 focus:outline-none"
							placeholder="your@email.com"
						/>
					</div>
				</div>

				<div>
					<label for="login-password" class="block text-sm font-medium text-gray-700">
						Password
					</label>
					<div class="mt-1">
						<input
							id="login-password"
							name="password"
							type="password"
							autocomplete="current-password"
							required
							class="block w-full appearance-none rounded-md border border-gray-300 px-3 py-2 placeholder-gray-400 focus:border-blue-500 focus:ring-blue-500 focus:outline-none"
						/>
					</div>
				</div>

				<div>
					<button
						type="submit"
						class="flex w-full justify-center rounded-md border border-transparent bg-blue-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-blue-700 focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 focus:outline-none"
					>
						Sign in
					</button>
				</div>
			</form>

			<div class="mt-6">
				<div class="relative">
					<div class="absolute inset-0 flex items-center">
						<div class="w-full border-t border-gray-300"></div>
					</div>
					<div class="relative flex justify-center text-sm">
						<span class="bg-white px-2 text-gray-500">Or register</span>
					</div>
				</div>
			</div>

			<!-- Register Form -->
			<form method="post" action="?/register" use:enhance class="mt-6 space-y-6">
				<div>
					<label for="register-name" class="block text-sm font-medium text-gray-700">
						Full name
					</label>
					<div class="mt-1">
						<input
							id="register-name"
							name="name"
							type="text"
							autocomplete="name"
							required
							class="block w-full appearance-none rounded-md border border-gray-300 px-3 py-2 placeholder-gray-400 focus:border-green-500 focus:ring-green-500 focus:outline-none"
							placeholder="John Doe"
						/>
					</div>
				</div>

				<div>
					<label for="register-email" class="block text-sm font-medium text-gray-700">
						Email address
					</label>
					<div class="mt-1">
						<input
							id="register-email"
							name="email"
							type="email"
							autocomplete="email"
							required
							class="block w-full appearance-none rounded-md border border-gray-300 px-3 py-2 placeholder-gray-400 focus:border-green-500 focus:ring-green-500 focus:outline-none"
							placeholder="your@email.com"
						/>
					</div>
				</div>

				<div>
					<label for="register-password" class="block text-sm font-medium text-gray-700">
						Password
					</label>
					<div class="mt-1">
						<input
							id="register-password"
							name="password"
							type="password"
							autocomplete="new-password"
							required
							class="block w-full appearance-none rounded-md border border-gray-300 px-3 py-2 placeholder-gray-400 focus:border-green-500 focus:ring-green-500 focus:outline-none"
						/>
					</div>
					<p class="mt-1 text-xs text-gray-500">Minimum 6 characters</p>
				</div>

				<div>
					<button
						type="submit"
						class="flex w-full justify-center rounded-md border border-transparent bg-green-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-green-700 focus:ring-2 focus:ring-green-500 focus:ring-offset-2 focus:outline-none"
					>
						Create account
					</button>
				</div>
			</form>

			{#if form?.message}
				<div class="mt-4 rounded-md border border-red-200 bg-red-50 p-3">
					<p class="text-sm text-red-600">{form.message}</p>
				</div>
			{/if}
		</div>
	</div>
</div>

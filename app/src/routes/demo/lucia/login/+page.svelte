<script lang="ts">
	import { enhance } from '$app/forms';
	import type { ActionData } from './$types';
	import { Center, Stack, Container, Divider } from '$lib/components/layout';
	import { Button, Alert, TextInput } from '$lib/components/ui';

	let { form }: { form: ActionData } = $props();

	// Form state for login
	let loginEmail = $state('');
	let loginPassword = $state('');

	// Form state for register
	let registerName = $state('');
	let registerEmail = $state('');
	let registerPassword = $state('');
</script>

<Center>
	<div class="auth-page">
		<Container size="sm">
			<Stack gap="xl">
				<!-- Header -->
				<Stack gap="xs" align="center">
					<h2 class="page-title">Sign in to your account</h2>
					<p class="page-subtitle">Or create a new account</p>
				</Stack>

				<!-- Forms Card -->
				<div class="forms-card">
					<Stack gap="xl">
						<!-- Login Form -->
						<form method="post" action="?/login" use:enhance>
							<Stack gap="lg">
								<h3 class="form-title">Sign In</h3>

								<TextInput
									id="login-email"
									name="email"
									label="Email address"
									type="email"
									autocomplete="email"
									required
									placeholder="your@email.com"
									bind:value={loginEmail}
								/>

								<TextInput
									id="login-password"
									name="password"
									label="Password"
									type="password"
									autocomplete="current-password"
									required
									bind:value={loginPassword}
								/>

								<Button type="submit" variant="primary" fullWidth size="lg">Sign in</Button>
							</Stack>
						</form>

						<!-- Divider -->
						<Divider label="Or register" spacing="lg" />

						<!-- Register Form -->
						<form method="post" action="?/register" use:enhance>
							<Stack gap="lg">
								<h3 class="form-title">Create Account</h3>

								<TextInput
									id="register-name"
									name="name"
									label="Full name"
									type="text"
									autocomplete="name"
									required
									placeholder="John Doe"
									bind:value={registerName}
								/>

								<TextInput
									id="register-email"
									name="email"
									label="Email address"
									type="email"
									autocomplete="email"
									required
									placeholder="your@email.com"
									bind:value={registerEmail}
								/>

								<TextInput
									id="register-password"
									name="password"
									label="Password"
									type="password"
									autocomplete="new-password"
									required
									helpText="Minimum 6 characters"
									bind:value={registerPassword}
								/>

								<Button type="submit" variant="success" fullWidth size="lg">Create account</Button>
							</Stack>
						</form>

						<!-- Error Message -->
						{#if form?.message}
							<Alert type="error">
								{form.message}
							</Alert>
						{/if}
					</Stack>
				</div>
			</Stack>
		</Container>
	</div>
</Center>

<style>
	.auth-page {
		min-height: 100vh;
		display: flex;
		flex-direction: column;
		justify-content: center;
		padding: var(--space-3xl) 0;
		width: 100%;
	}

	.page-title {
		font-size: var(--font-size-3xl);
		font-weight: var(--font-weight-extrabold);
		color: var(--text-primary);
		text-align: center;
		margin: 0;
	}

	.page-subtitle {
		font-size: var(--font-size-sm);
		color: var(--text-secondary);
		text-align: center;
		margin: 0;
	}

	.forms-card {
		background-color: var(--bg-primary);
		padding: var(--space-2xl);
		border-radius: var(--radius-lg);
		box-shadow: var(--shadow-lg);
		border: 1px solid var(--border-primary);
	}

	.form-title {
		font-size: var(--font-size-lg);
		font-weight: var(--font-weight-semibold);
		color: var(--text-primary);
		margin: 0;
	}

	@media (min-width: 640px) {
		.forms-card {
			padding: var(--space-3xl);
		}
	}
</style>

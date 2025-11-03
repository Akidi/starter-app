<script lang="ts">
	import type { PageData, ActionData } from './$types';
	import { enhance } from '$app/forms';
	import { Container, Stack } from '$lib/components/layout';
	import { Card, Button, TextInput, Select, Checkbox } from '$lib/components/ui';
	import { toasts } from '$lib/stores/toasts';

	interface Props {
		data: PageData;
		form: ActionData;
	}

	let { data, form }: Props = $props();

	// Form state
	let currentStep = $state(1);
	const totalSteps = 3;
	let isSubmitting = $state(false);
	let isComplete = $state(false);

	// Step 1 data
	let company = $state('');
	let website = $state('');
	let industry = $state('technology');

	// Step 2 data
	let firstName = $state('');
	let lastName = $state('');
	let email = $state('');
	let phone = $state('');

	// Step 3 data
	let plan = $state('free');
	let billingCycle = $state('monthly');
	let agreeToTerms = $state(false);

	// Step validation
	function validateStep(step: number): boolean {
		switch (step) {
			case 1:
				if (!company || company.length < 2) {
					toasts.add({ type: 'error', message: 'Please enter a valid company name' });
					return false;
				}
				if (website && !isValidUrl(website)) {
					toasts.add({ type: 'error', message: 'Please enter a valid URL' });
					return false;
				}
				if (!industry) {
					toasts.add({ type: 'error', message: 'Please select an industry' });
					return false;
				}
				return true;

			case 2:
				if (!firstName || firstName.length < 2) {
					toasts.add({ type: 'error', message: 'Please enter a valid first name' });
					return false;
				}
				if (!lastName || lastName.length < 2) {
					toasts.add({ type: 'error', message: 'Please enter a valid last name' });
					return false;
				}
				if (!email || !isValidEmail(email)) {
					toasts.add({ type: 'error', message: 'Please enter a valid email' });
					return false;
				}
				if (!phone || !isValidPhone(phone)) {
					toasts.add({ type: 'error', message: 'Please enter a valid phone number' });
					return false;
				}
				return true;

			case 3:
				if (!plan) {
					toasts.add({ type: 'error', message: 'Please select a plan' });
					return false;
				}
				if (!billingCycle) {
					toasts.add({ type: 'error', message: 'Please select a billing cycle' });
					return false;
				}
				if (!agreeToTerms) {
					toasts.add({ type: 'error', message: 'You must agree to the terms and conditions' });
					return false;
				}
				return true;

			default:
				return false;
		}
	}

	function isValidUrl(url: string): boolean {
		try {
			new URL(url);
			return true;
		} catch {
			return false;
		}
	}

	function isValidEmail(email: string): boolean {
		return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
	}

	function isValidPhone(phone: string): boolean {
		return /^\+?[1-9]\d{1,14}$/.test(phone);
	}

	function nextStep() {
		if (validateStep(currentStep)) {
			if (currentStep < totalSteps) {
				currentStep++;
			}
		}
	}

	function previousStep() {
		if (currentStep > 1) {
			currentStep--;
		}
	}

	function getStepTitle(step: number): string {
		switch (step) {
			case 1:
				return 'Company Information';
			case 2:
				return 'Contact Details';
			case 3:
				return 'Select Plan';
			default:
				return '';
		}
	}

	function getPlanPrice(planName: string, cycle: string): string {
		const prices: Record<string, { monthly: string; annual: string }> = {
			free: { monthly: '$0', annual: '$0' },
			starter: { monthly: '$29', annual: '$290' },
			professional: { monthly: '$99', annual: '$990' },
			enterprise: { monthly: '$299', annual: '$2,990' }
		};
		return cycle === 'annual'
			? `${prices[planName].annual}/year`
			: `${prices[planName].monthly}/month`;
	}
</script>

<svelte:head>
	<title>Multi-Step Form Wizard</title>
</svelte:head>

<Container>
	<Stack gap="lg" style="margin-top: 2rem; margin-bottom: 3rem;">
		<!-- Header -->
		<div>
			<h1 style="font-size: 2rem; font-weight: 700; margin: 0 0 0.5rem 0;">
				Multi-Step Form Wizard
			</h1>
			<p style="color: var(--text-secondary); margin: 0;">
				Complete onboarding form with step-by-step validation and progress tracking
			</p>
		</div>

		{#if !isComplete}
			<!-- Progress Bar -->
			<Card>
				<Stack gap="md">
					<div style="display: flex; justify-content: space-between; align-items: center;">
						<div style="font-weight: 600;">
							Step {currentStep} of {totalSteps}: {getStepTitle(currentStep)}
						</div>
						<div style="font-size: 0.875rem; color: var(--text-secondary);">
							{Math.round((currentStep / totalSteps) * 100)}% Complete
						</div>
					</div>

					<!-- Progress Bar -->
					<div
						style="height: 8px; background: var(--bg-secondary); border-radius: 999px; overflow: hidden;"
					>
						<div
							style="height: 100%; background: var(--color-primary); border-radius: 999px; transition: width 0.3s; width: {(currentStep /
								totalSteps) *
								100}%;"
						/>
					</div>

					<!-- Step Indicators -->
					<div style="display: flex; justify-content: space-between;">
						{#each [1, 2, 3] as step}
							<div style="display: flex; flex-direction: column; align-items: center; gap: 0.5rem;">
								<div
									style="width: 40px; height: 40px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 600; {currentStep ===
									step
										? 'background: var(--color-primary); color: white;'
										: currentStep > step
											? 'background: var(--color-success); color: white;'
											: 'background: var(--bg-secondary); color: var(--text-secondary);'}"
								>
									{currentStep > step ? '✓' : step}
								</div>
								<div
									style="font-size: 0.75rem; text-align: center; {currentStep === step
										? 'color: var(--color-primary); font-weight: 600;'
										: 'color: var(--text-secondary);'}"
								>
									{getStepTitle(step)}
								</div>
							</div>
						{/each}
					</div>
				</Stack>
			</Card>

			<!-- Form -->
			<Card>
				<form
					method="post"
					action="?/submit"
					use:enhance={() => {
						if (!validateStep(currentStep)) {
							return () => {};
						}

						isSubmitting = true;
						return async ({ result, update }) => {
							isSubmitting = false;
							if (result.type === 'success' && result.data?.success) {
								isComplete = true;
								toasts.add({ type: 'success', message: 'Form submitted successfully!' });
								await update();
							} else if (result.type === 'failure') {
								toasts.add({
									type: 'error',
									message: result.data?.message || 'Failed to submit form'
								});
							}
						};
					}}
				>
					<!-- Step 1: Company Information -->
					{#if currentStep === 1}
						<Stack gap="md">
							<h3 style="font-size: 1.25rem; font-weight: 600; margin: 0;">
								Company Information
							</h3>

							<TextInput
								id="company"
								name="company"
								label="Company Name"
								required
								bind:value={company}
								placeholder="Acme Corporation"
							/>

							<TextInput
								id="website"
								name="website"
								label="Website (optional)"
								type="url"
								bind:value={website}
								placeholder="https://example.com"
								helpText="Enter your company website"
							/>

							<Select id="industry" name="industry" label="Industry" bind:value={industry}>
								<option value="technology">Technology</option>
								<option value="healthcare">Healthcare</option>
								<option value="finance">Finance</option>
								<option value="education">Education</option>
								<option value="retail">Retail</option>
								<option value="manufacturing">Manufacturing</option>
								<option value="other">Other</option>
							</Select>
						</Stack>
					{/if}

					<!-- Step 2: Contact Details -->
					{#if currentStep === 2}
						<Stack gap="md">
							<h3 style="font-size: 1.25rem; font-weight: 600; margin: 0;">Contact Details</h3>

							<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem;">
								<TextInput
									id="firstName"
									name="firstName"
									label="First Name"
									required
									bind:value={firstName}
									placeholder="John"
								/>

								<TextInput
									id="lastName"
									name="lastName"
									label="Last Name"
									required
									bind:value={lastName}
									placeholder="Doe"
								/>
							</div>

							<TextInput
								id="email"
								name="email"
								label="Email Address"
								type="email"
								required
								bind:value={email}
								placeholder="john@example.com"
							/>

							<TextInput
								id="phone"
								name="phone"
								label="Phone Number"
								type="tel"
								required
								bind:value={phone}
								placeholder="+1234567890"
								helpText="Include country code (e.g., +1 for US)"
							/>
						</Stack>
					{/if}

					<!-- Step 3: Select Plan -->
					{#if currentStep === 3}
						<Stack gap="md">
							<h3 style="font-size: 1.25rem; font-weight: 600; margin: 0;">Select Your Plan</h3>

							<!-- Billing Cycle Toggle -->
							<div style="display: flex; gap: 1rem; justify-content: center; margin-bottom: 1rem;">
								<label style="display: flex; align-items: center; cursor: pointer;">
									<input
										type="radio"
										name="billingCycle"
										value="monthly"
										bind:group={billingCycle}
										style="margin-right: 0.5rem;"
									/>
									Monthly
								</label>
								<label style="display: flex; align-items: center; cursor: pointer;">
									<input
										type="radio"
										name="billingCycle"
										value="annual"
										bind:group={billingCycle}
										style="margin-right: 0.5rem;"
									/>
									Annual <span style="color: var(--color-success); margin-left: 0.5rem;"
										>(Save 20%)</span
									>
								</label>
							</div>

							<!-- Plans Grid -->
							<div
								style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem;"
							>
								{#each ['free', 'starter', 'professional', 'enterprise'] as planOption}
									<label
										style="border: 2px solid {plan === planOption
											? 'var(--color-primary)'
											: 'var(--border-primary)'}; border-radius: var(--radius-md); padding: 1.5rem; cursor: pointer; transition: all 0.2s; background: {plan ===
										planOption
											? 'var(--bg-secondary)'
											: 'transparent'};"
									>
										<input
											type="radio"
											name="plan"
											value={planOption}
											bind:group={plan}
											style="margin-bottom: 1rem;"
										/>
										<Stack gap="xs">
											<div style="font-weight: 700; text-transform: capitalize; font-size: 1.125rem;">
												{planOption}
											</div>
											<div style="font-size: 1.5rem; font-weight: 700; color: var(--color-primary);">
												{getPlanPrice(planOption, billingCycle)}
											</div>
										</Stack>
									</label>
								{/each}
							</div>

							<Checkbox
								id="agreeToTerms"
								name="agreeToTerms"
								bind:checked={agreeToTerms}
								label="I agree to the terms and conditions"
								description="By checking this box, you agree to our Terms of Service and Privacy Policy"
							/>
						</Stack>
					{/if}

					<!-- Navigation Buttons -->
					<div
						style="display: flex; justify-content: space-between; margin-top: 2rem; padding-top: 1.5rem; border-top: 1px solid var(--border-primary);"
					>
						<Button
							type="button"
							variant="ghost"
							onclick={previousStep}
							disabled={currentStep === 1 || isSubmitting}
						>
							← Previous
						</Button>

						{#if currentStep < totalSteps}
							<Button type="button" variant="primary" onclick={nextStep} disabled={isSubmitting}>
								Next →
							</Button>
						{:else}
							<Button type="submit" variant="primary" loading={isSubmitting}>
								Complete Setup
							</Button>
						{/if}
					</div>
				</form>
			</Card>
		{:else}
			<!-- Success State -->
			<Card>
				<Stack gap="md" style="text-align: center; padding: 3rem 2rem;">
					<div style="font-size: 4rem;">🎉</div>
					<h2 style="font-size: 2rem; font-weight: 700; margin: 0;">Setup Complete!</h2>
					<p style="color: var(--text-secondary); margin: 0; max-width: 500px; margin-left: auto; margin-right: auto;">
						Thank you for completing the onboarding wizard. Your account has been configured
						successfully.
					</p>

					{#if form?.data}
						<div
							style="background: var(--bg-secondary); border-radius: var(--radius-md); padding: 1.5rem; text-align: left; max-width: 500px; margin: 1.5rem auto 0 auto;"
						>
							<Stack gap="xs">
								<div style="font-weight: 600; margin-bottom: 0.5rem;">Your Details:</div>
								<div style="font-size: 0.875rem;">
									<strong>Company:</strong>
									{form.data.company}
								</div>
								<div style="font-size: 0.875rem;">
									<strong>Contact:</strong>
									{form.data.firstName}
									{form.data.lastName}
								</div>
								<div style="font-size: 0.875rem;">
									<strong>Email:</strong>
									{form.data.email}
								</div>
								<div style="font-size: 0.875rem;">
									<strong>Plan:</strong>
									{form.data.plan} ({form.data.billingCycle})
								</div>
							</Stack>
						</div>
					{/if}

					<div style="margin-top: 1.5rem;">
						<Button
							variant="primary"
							onclick={() => {
								isComplete = false;
								currentStep = 1;
							}}
						>
							Start Over
						</Button>
					</div>
				</Stack>
			</Card>
		{/if}

		<!-- Features Info -->
		<Card>
			<Stack gap="md">
				<h3 style="font-size: 1.25rem; font-weight: 600; margin: 0;">Features Demonstrated</h3>
				<ul style="margin: 0; padding-left: 1.5rem; color: var(--text-secondary);">
					<li>Multi-step form with progress tracking</li>
					<li>Visual progress bar and step indicators</li>
					<li>Per-step client-side validation</li>
					<li>Form state persistence across steps</li>
					<li>Back/forward navigation</li>
					<li>Server-side validation with Zod</li>
					<li>Responsive design with grid layouts</li>
					<li>Success state with submitted data display</li>
					<li>Conditional rendering based on current step</li>
					<li>Loading states during submission</li>
				</ul>
			</Stack>
		</Card>
	</Stack>
</Container>

<script lang="ts">
	import { enhance } from '$app/forms';
	import { Container, Stack } from '$lib/components/layout';
	import { Card, Button, TextInput, Select, Checkbox, Textarea } from '$lib/components/ui';
	import { toasts } from '$lib/stores/toasts';
	import {
		adminRoleOptions,
		billingCycles,
		planOptions,
		regionOptions,
		teamSizeOptions,
		type AdminRoleOption,
		type BillingCycle,
		type PlanId,
		type RegionOption,
		type TeamSizeOption,
		type WizardSubmission
	} from './config';

	const stepDetails = [
		{ order: 1, title: 'Workspace', description: 'Share basic company details.' },
		{ order: 2, title: 'Team', description: 'Tell us who we should invite.' },
		{ order: 3, title: 'Plan', description: 'Confirm plan, billing, and terms.' }
	] satisfies { order: number; title: string; description: string }[];

	const featuresShown = [
		'Stateful multi-step wizard built with the new runes API',
		'Inline validation with friendly toast feedback per step',
		'Server action powered by `enhance` for optimistic UX',
		'Submission summary that shows the sanitized payload'
	];

	const seatsLimit = { min: 1, max: 5000 };
	const maxGoalLength = 240;

	let currentStep = $state(1);
	const totalSteps = stepDetails.length;
	let isSubmitting = $state(false);
	let isComplete = $state(false);
	let submitted = $state<WizardSubmission | null>(null);

	let companyName = $state('');
	let teamSize = $state<TeamSizeOption>(teamSizeOptions[0]);
	let region = $state<RegionOption>(regionOptions[0].value);
	let adminName = $state('');
	let adminEmail = $state('');
	let adminRole = $state<AdminRoleOption>(adminRoleOptions[0].value);
	let inviteSeats = $state('5');
	let goals = $state('');
	let plan = $state<PlanId>(planOptions[1].id);
	let billing = $state<BillingCycle>(billingCycles[0]);
	let acceptTerms = $state(false);

	type WizardActionSuccess = { success: true; submitted: WizardSubmission };
	type WizardActionFailure = { success: false; errors?: Record<string, string> };

	const progressPercent = $derived(Math.round((currentStep / totalSteps) * 100));

	const billingCopy: Record<BillingCycle, { label: string; helper: string }> = {
		monthly: { label: 'Monthly', helper: 'Pause or cancel anytime' },
		annual: { label: 'Annual', helper: 'Get two months free' }
	};

	function goToNextStep() {
		if (validateStep(currentStep)) {
			currentStep = Math.min(totalSteps, currentStep + 1);
		}
	}

	function goToPreviousStep() {
		currentStep = Math.max(1, currentStep - 1);
	}

	function validateStep(step: number): boolean {
		switch (step) {
			case 1:
				return validateWorkspace();
			case 2:
				return validateTeam();
			case 3:
				return validatePlan();
			default:
				return false;
		}
	}

	function validateWorkspace(): boolean {
		if (companyName.trim().length < 2) {
			notify('Company name must be at least two characters.');
			return false;
		}

		if (!teamSizeOptions.includes(teamSize)) {
			notify('Choose a team size to help us shape onboarding.');
			return false;
		}

		if (!regionOptions.some((option) => option.value === region)) {
			notify('Pick the region that best represents your team.');
			return false;
		}

		return true;
	}

	function validateTeam(): boolean {
		if (adminName.trim().length < 2) {
			notify('Admin name should be at least two characters.');
			return false;
		}

		if (!isValidEmail(adminEmail)) {
			notify('Please enter a valid email address.');
			return false;
		}

		if (!adminRoleOptions.some((role) => role.value === adminRole)) {
			notify('Select the role that best describes you.');
			return false;
		}

		const seats = Number(inviteSeats);
		if (!Number.isFinite(seats)) {
			notify('Provide the number of teammates you plan to invite.');
			return false;
		}

		if (seats < seatsLimit.min) {
			notify(`Invite at least ${seatsLimit.min} teammate to continue.`);
			return false;
		}

		if (seats > seatsLimit.max) {
			notify(`Contact sales for more than ${seatsLimit.max} seats.`);
			return false;
		}

		return true;
	}

	function validatePlan(): boolean {
		if (!planOptions.some((option) => option.id === plan)) {
			notify('Choose a plan tier to finish setup.');
			return false;
		}

		if (!billingCycles.includes(billing)) {
			notify('Select a billing cadence.');
			return false;
		}

		if (goals.length > maxGoalLength) {
			notify(`Keep your goals under ${maxGoalLength} characters.`);
			return false;
		}

		if (!acceptTerms) {
			notify('You must accept the terms to continue.');
			return false;
		}

		return true;
	}

	function notify(message: string) {
		toasts.add({ type: 'error', message });
	}

	function resetWizard() {
		currentStep = 1;
		isComplete = false;
		submitted = null;
		companyName = '';
		teamSize = teamSizeOptions[0];
		region = regionOptions[0].value;
		adminName = '';
		adminEmail = '';
		adminRole = adminRoleOptions[0].value;
		inviteSeats = '5';
		goals = '';
		plan = planOptions[1].id;
		billing = billingCycles[0];
		acceptTerms = false;
	}

	function isValidEmail(value: string): boolean {
		return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
	}

	function planPriceLabel(planId: PlanId, cycle: BillingCycle): string {
		const selectedPlan = planOptions.find((planOption) => planOption.id === planId);
		if (!selectedPlan) return '';
		const amount = selectedPlan.price[cycle];
		if (amount === 0) {
			return cycle === 'monthly' ? '$0 per month' : '$0 per year';
		}
		const formatted = `$${amount.toLocaleString()}`;
		return cycle === 'monthly' ? `${formatted} per month` : `${formatted} per year`;
	}

	function regionLabel(option: RegionOption): string {
		return regionOptions.find((item) => item.value === option)?.label ?? option;
	}

	function roleLabel(option: AdminRoleOption): string {
		return adminRoleOptions.find((item) => item.value === option)?.label ?? option;
	}

	function isActionSuccess(data: unknown): data is WizardActionSuccess {
		return (
			typeof data === 'object' &&
			data !== null &&
			'success' in data &&
			(data as { success: unknown }).success === true &&
			'submitted' in data
		);
	}

	function isActionFailure(data: unknown): data is WizardActionFailure {
		return (
			typeof data === 'object' &&
			data !== null &&
			'success' in data &&
			(data as { success: unknown }).success === false
		);
	}
</script>

<svelte:head>
	<title>Workspace Wizard Demo</title>
</svelte:head>

<Container>
	<Stack gap="lg" style="margin-top: 2rem; margin-bottom: 3rem;">
		<Stack gap="xs">
			<h1 style="font-size: 2rem; font-weight: 700; margin: 0;">Workspace Wizard</h1>
			<p style="color: var(--text-secondary); margin: 0;">
				Give the wizard a try to see how form state, progress, and server actions work together.
			</p>
		</Stack>

		<Card>
			<Stack gap="md">
				<div style="display: flex; justify-content: space-between; align-items: center;">
					<div style="font-weight: 600;">
						Step {currentStep} of {totalSteps}: {stepDetails[currentStep - 1].title}
					</div>
					<div style="font-size: 0.875rem; color: var(--text-secondary);">
						{progressPercent}% ready
					</div>
				</div>

				<div class="progress-track">
					<div class="progress-indicator" style:width={`${progressPercent}%`}></div>
				</div>

				<div class="step-grid">
					{#each stepDetails as step, index (index)}
						<div class="step-detail">
							<div
								class="step-circle"
								class:step-circle__active={currentStep === step.order}
								class:step-circle__done={currentStep > step.order}
							>
								{currentStep > step.order ? 'OK' : step.order}
							</div>
							<div>
								<div style="font-weight: 600;">{step.title}</div>
								<div style="font-size: 0.75rem; color: var(--text-secondary);">
									{step.description}
								</div>
							</div>
						</div>
					{/each}
				</div>
			</Stack>
		</Card>

		{#if !isComplete}
			<Card>
				<form
					method="post"
					action="?/submit"
					use:enhance={() => {
						if (!validatePlan()) {
							return () => {};
						}

						isSubmitting = true;
						return async ({ result, update }) => {
							isSubmitting = false;

							if (result.type === 'success' && isActionSuccess(result.data)) {
								submitted = result.data.submitted;
								isComplete = true;
								toasts.add({ type: 'success', message: 'Workspace created successfully.' });
							} else if (result.type === 'failure' && isActionFailure(result.data)) {
								const [firstError] = Object.values(result.data.errors ?? {});
								if (firstError) {
									notify(firstError);
								}
							}

							await update();
						};
					}}
				>
					{#if currentStep === 1}
						<Stack gap="md">
							<h3 style="margin: 0; font-size: 1.25rem; font-weight: 600;">Company details</h3>
							<TextInput
								id="companyName"
								name="companyName"
								label="Company name"
								placeholder="Acme Analytics"
								required
								bind:value={companyName}
							/>

							<div
								style="display: grid; gap: 1rem; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));"
							>
								<Select id="teamSize" name="teamSize" label="Team size" bind:value={teamSize}>
									{#each teamSizeOptions as option, index (index)}
										<option value={option}>{option} people</option>
									{/each}
								</Select>

								<Select id="region" name="region" label="Primary region" bind:value={region}>
									{#each regionOptions as option, index (index)}
										<option value={option.value}>{option.label}</option>
									{/each}
								</Select>
							</div>
						</Stack>
					{:else if currentStep === 2}
						<Stack gap="md">
							<h3 style="margin: 0; font-size: 1.25rem; font-weight: 600;">Team contact</h3>
							<TextInput
								id="adminName"
								name="adminName"
								label="Primary admin name"
								placeholder="Jane Doe"
								required
								bind:value={adminName}
							/>

							<TextInput
								id="adminEmail"
								name="adminEmail"
								label="Primary admin email"
								type="email"
								autocomplete="email"
								placeholder="jane@example.com"
								required
								bind:value={adminEmail}
							/>

							<div
								style="display: grid; gap: 1rem; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));"
							>
								<Select id="adminRole" name="adminRole" label="Role" bind:value={adminRole}>
									{#each adminRoleOptions as option, index (index)}
										<option value={option.value}>{option.label}</option>
									{/each}
								</Select>

								<TextInput
									id="inviteSeats"
									name="inviteSeats"
									label="Seats to provision"
									type="number"
									min={seatsLimit.min}
									max={seatsLimit.max}
									step="1"
									inputmode="numeric"
									bind:value={inviteSeats}
									helpText={`Between ${seatsLimit.min} and ${seatsLimit.max} teammates`}
								/>
							</div>
						</Stack>
					{:else}
						<Stack gap="lg">
							<div>
								<h3 style="margin: 0; font-size: 1.25rem; font-weight: 600;">Plan selection</h3>
								<p style="margin: 0; color: var(--text-secondary); font-size: 0.9rem;">
									Pick a plan and billing cadence. Annual billing grants a discount.
								</p>
							</div>

							<div class="plan-grid">
								{#each planOptions as planOption, index (index)}
									<label
										for={`plan-${planOption.id}`}
										class={`plan-card ${plan === planOption.id ? 'plan-card__active' : ''}`}
									>
										<input
											id={`plan-${planOption.id}`}
											type="radio"
											name="plan"
											value={planOption.id}
											checked={plan === planOption.id}
											onchange={() => (plan = planOption.id)}
										/>
										<div style="display: flex; flex-direction: column; gap: 0.5rem;">
											<div
												style="display: flex; justify-content: space-between; align-items: center;"
											>
												<div style="font-weight: 600; font-size: 1.05rem;">{planOption.label}</div>
												<span class="plan-badge">{planOption.badge}</span>
											</div>
											<div style="color: var(--text-secondary); font-size: 0.9rem;">
												{planOption.description}
											</div>
											<div style="font-size: 1.5rem; font-weight: 700; color: var(--text-primary);">
												{planPriceLabel(planOption.id, billing)}
											</div>
											<ul class="plan-perks">
												{#each planOption.perks as perk, index (index)}
													<li>{perk}</li>
												{/each}
											</ul>
										</div>
									</label>
								{/each}
							</div>

							<div class="billing-picker">
								{#each billingCycles as cycle, index (index)}
									<label
										class={`billing-card ${billing === cycle ? 'billing-card__active' : ''}`}
										for={`billing-${cycle}`}
									>
										<input
											id={`billing-${cycle}`}
											type="radio"
											name="billing"
											value={cycle}
											checked={billing === cycle}
											onchange={() => (billing = cycle)}
										/>
										<div style="font-weight: 600;">{billingCopy[cycle].label}</div>
										<div style="font-size: 0.85rem; color: var(--text-secondary);">
											{billingCopy[cycle].helper}
										</div>
									</label>
								{/each}
							</div>

							<Textarea
								id="goals"
								name="goals"
								label="What do you hope to accomplish?"
								placeholder="Share automation, collect research, onboard a department..."
								rows={4}
								maxlength={maxGoalLength}
								bind:value={goals}
								helpText={`${maxGoalLength - goals.length} characters remaining`}
							/>

							<Checkbox
								id="acceptTerms"
								name="acceptTerms"
								label="I agree to the Terms of Service and Privacy Policy"
								required
								bind:checked={acceptTerms}
								helpText="We use this to enable messaging and provisioning on your behalf."
							/>
						</Stack>
					{/if}

					<div class="wizard-nav">
						<Button
							type="button"
							variant="ghost"
							onclick={goToPreviousStep}
							disabled={currentStep === 1 || isSubmitting}
						>
							Back
						</Button>

						{#if currentStep < totalSteps}
							<Button
								type="button"
								variant="primary"
								onclick={goToNextStep}
								disabled={isSubmitting}
							>
								Next step
							</Button>
						{:else}
							<Button type="submit" variant="primary" disabled={isSubmitting}>
								{isSubmitting ? 'Submitting...' : 'Complete setup'}
							</Button>
						{/if}
					</div>
				</form>
			</Card>
		{:else}
			<Card>
				<Stack gap="md" style="text-align: center;">
					<div style="font-size: 3rem;">:)</div>
					<h2 style="margin: 0; font-size: 1.75rem;">Workspace ready</h2>
					<p style="margin: 0; color: var(--text-secondary);">
						Thanks for running through the wizard demo. Below is the sanitized payload returned from
						the server action.
					</p>

					{#if submitted}
						<div class="summary-grid">
							<div>
								<strong>Company</strong>
								<div>{submitted.companyName}</div>
								<div style="color: var(--text-secondary); font-size: 0.85rem;">
									{regionLabel(submitted.region)} - Team size {submitted.teamSize}
								</div>
							</div>
							<div>
								<strong>Contact</strong>
								<div>{submitted.adminName}</div>
								<div style="color: var(--text-secondary); font-size: 0.85rem;">
									{submitted.adminEmail} ({roleLabel(submitted.adminRole)})
								</div>
							</div>
							<div>
								<strong>Plan</strong>
								<div style="text-transform: capitalize;">{submitted.plan}</div>
								<div style="color: var(--text-secondary); font-size: 0.85rem;">
									Billed {submitted.billing}
								</div>
							</div>
							<div>
								<strong>Seats</strong>
								<div>{submitted.inviteSeats} teammates</div>
							</div>
							<div style="grid-column: 1 / -1;">
								<strong>Goals</strong>
								<div>{submitted.goals || 'No goals provided'}</div>
							</div>
						</div>
					{/if}

					<Button
						variant="primary"
						onclick={resetWizard}
						style="width: fit-content; margin: 0 auto;"
					>
						Run it again
					</Button>
				</Stack>
			</Card>
		{/if}

		<Card>
			<Stack gap="md">
				<h3 style="margin: 0; font-size: 1.25rem; font-weight: 600;">What this demonstrates</h3>
				<ul style="margin: 0; padding-left: 1.5rem; color: var(--text-secondary);">
					{#each featuresShown as feature, index (index)}
						<li>{feature}</li>
					{/each}
				</ul>
			</Stack>
		</Card>
	</Stack>
</Container>

<style>
	.progress-track {
		height: 8px;
		background: var(--bg-secondary);
		border-radius: 999px;
		overflow: hidden;
	}

	.progress-indicator {
		height: 100%;
		background: var(--color-primary);
		border-radius: 999px;
		transition: width 200ms ease;
	}

	.step-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
		gap: 1rem;
	}

	.step-detail {
		display: flex;
		gap: 0.75rem;
		align-items: center;
	}

	.step-circle {
		width: 40px;
		height: 40px;
		border-radius: 999px;
		display: flex;
		align-items: center;
		justify-content: center;
		font-weight: 600;
		background: var(--bg-secondary);
		color: var(--text-secondary);
	}

	.step-circle__active {
		background: var(--color-primary);
		color: white;
	}

	.step-circle__done {
		background: var(--color-success);
		color: white;
	}

	.plan-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
		gap: 1rem;
	}

	.plan-card {
		border: 1px solid var(--border-primary);
		border-radius: var(--radius-lg);
		padding: 1.25rem;
		display: block;
		cursor: pointer;
		transition:
			border-color 150ms ease,
			box-shadow 150ms ease;
	}

	.plan-card input[type='radio'] {
		position: absolute;
		opacity: 0;
		pointer-events: none;
	}

	.plan-card__active {
		border-color: var(--color-primary);
		box-shadow: 0 8px 20px rgb(0 0 0 / 0.1);
	}

	.plan-badge {
		font-size: 0.75rem;
		padding: 0.1rem 0.5rem;
		background: var(--bg-secondary);
		border-radius: 999px;
		text-transform: uppercase;
		letter-spacing: 0.05em;
	}

	.plan-perks {
		margin: 0;
		padding-left: 1.25rem;
		color: var(--text-secondary);
		font-size: 0.85rem;
	}

	.billing-picker {
		display: flex;
		flex-wrap: wrap;
		gap: 1rem;
	}

	.billing-card {
		border: 1px solid var(--border-primary);
		border-radius: var(--radius-md);
		padding: 0.75rem 1rem;
		cursor: pointer;
		min-width: 160px;
	}

	.billing-card input[type='radio'] {
		position: absolute;
		opacity: 0;
		pointer-events: none;
	}

	.billing-card__active {
		border-color: var(--color-primary);
		background: var(--bg-secondary);
	}

	.wizard-nav {
		display: flex;
		justify-content: space-between;
		margin-top: 2rem;
		padding-top: 1.5rem;
		border-top: 1px solid var(--border-primary);
	}

	.summary-grid {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
		gap: 1rem;
		text-align: left;
		border: 1px solid var(--border-primary);
		border-radius: var(--radius-lg);
		padding: 1.5rem;
		background: var(--bg-secondary);
	}
</style>

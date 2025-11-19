import { fail, type Actions } from '@sveltejs/kit';
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

const includesOption = <Option extends string>(
	options: readonly Option[],
	value: string
): value is Option => options.includes(value as Option);

const regionValues: RegionOption[] = regionOptions.map((option) => option.value);
const roleValues: AdminRoleOption[] = adminRoleOptions.map((option) => option.value);
const planIds: PlanId[] = planOptions.map((plan) => plan.id);
const seatsLimit = { min: 1, max: 5000 };
const maxGoalLength = 240;
const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export const actions: Actions = {
	submit: async ({ request }) => {
		const formData = await request.formData();
		const errors: Record<string, string> = {};

		const companyName = (formData.get('companyName') ?? '').toString().trim();
		if (companyName.length < 2) {
			errors.companyName = 'Company name must be at least two characters long.';
		}

		const teamSizeRaw = (formData.get('teamSize') ?? '').toString();
		const teamSize = includesOption(teamSizeOptions, teamSizeRaw) ? teamSizeRaw : null;
		if (!teamSize) {
			errors.teamSize = 'Select the team size you are planning for.';
		}

		const regionRaw = (formData.get('region') ?? '').toString();
		const region = includesOption(regionValues, regionRaw) ? regionRaw : null;
		if (!region) {
			errors.region = 'Choose a primary operating region.';
		}

		const adminName = (formData.get('adminName') ?? '').toString().trim();
		if (adminName.length < 2) {
			errors.adminName = 'Admin name must be at least two characters long.';
		}

		const adminEmail = (formData.get('adminEmail') ?? '').toString().trim();
		if (!emailRegex.test(adminEmail)) {
			errors.adminEmail = 'Enter a valid email so we can send the invite.';
		}

		const adminRoleRaw = (formData.get('adminRole') ?? '').toString();
		const adminRole = includesOption(roleValues, adminRoleRaw) ? adminRoleRaw : null;
		if (!adminRole) {
			errors.adminRole = 'Select the role that best describes you.';
		}

		const inviteSeatsRaw = (formData.get('inviteSeats') ?? '').toString();
		const inviteSeatsNumber = Number(inviteSeatsRaw);
		const inviteSeats = Number.isFinite(inviteSeatsNumber) ? Math.round(inviteSeatsNumber) : NaN;
		if (!Number.isFinite(inviteSeats)) {
			errors.inviteSeats = 'Enter the number of teammates you plan to invite.';
		} else if (inviteSeats < seatsLimit.min) {
			errors.inviteSeats = `Invite at least ${seatsLimit.min} teammate.`;
		} else if (inviteSeats > seatsLimit.max) {
			errors.inviteSeats = `Please contact sales for more than ${seatsLimit.max} seats.`;
		}

		const planRaw = (formData.get('plan') ?? '').toString();
		const plan = includesOption(planIds, planRaw) ? planRaw : null;
		if (!plan) {
			errors.plan = 'Pick a plan tier to continue.';
		}

		const billingRaw = (formData.get('billing') ?? '').toString();
		const billing = includesOption(billingCycles, billingRaw) ? billingRaw : null;
		if (!billing) {
			errors.billing = 'Select a billing cycle.';
		}

		const goals = (formData.get('goals') ?? '').toString().trim();
		if (goals.length > maxGoalLength) {
			errors.goals = `Keep your goals under ${maxGoalLength} characters.`;
		}

		const acceptTerms = formData.get('acceptTerms') === 'on';
		if (!acceptTerms) {
			errors.acceptTerms = 'You must agree to continue.';
		}

		if (
			Object.keys(errors).length > 0 ||
			!teamSize ||
			!region ||
			!adminRole ||
			!plan ||
			!billing ||
			!Number.isFinite(inviteSeats)
		) {
			return fail(400, { success: false, errors });
		}

		const submission: WizardSubmission = {
			companyName,
			teamSize,
			region,
			adminName,
			adminEmail,
			adminRole,
			inviteSeats,
			plan,
			billing,
			goals
		};

		return {
			success: true,
			submitted: submission
		};
	}
};

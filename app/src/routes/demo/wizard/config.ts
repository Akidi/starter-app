export const teamSizeOptions = ['1-10', '11-50', '51-250', '251+'] as const;
export type TeamSizeOption = (typeof teamSizeOptions)[number];

export const regionOptions = [
	{ value: 'americas', label: 'Americas' },
	{ value: 'emea', label: 'Europe, Middle East & Africa' },
	{ value: 'apac', label: 'Asia-Pacific' }
] as const;
export type RegionOption = (typeof regionOptions)[number]['value'];

export const adminRoleOptions = [
	{ value: 'owner', label: 'Founder / Owner' },
	{ value: 'operator', label: 'Operations / BizOps' },
	{ value: 'finance', label: 'Finance' },
	{ value: 'it', label: 'IT / Security' },
	{ value: 'other', label: 'Other' }
] as const;
export type AdminRoleOption = (typeof adminRoleOptions)[number]['value'];

export const planOptions = [
	{
		id: 'starter',
		label: 'Starter',
		description: 'Capture ideas and share lightweight reports with a single workspace.',
		price: { monthly: 0, annual: 0 },
		badge: 'Free',
		perks: ['Unlimited viewers', 'Two automations', 'Community templates']
	},
	{
		id: 'growth',
		label: 'Growth',
		description: 'Invite a growing team with permissions and shared automations.',
		price: { monthly: 39, annual: 390 },
		badge: 'Popular',
		perks: ['Role-based access', 'Connections to Slack/Teams', 'Dashboard scheduling']
	},
	{
		id: 'scale',
		label: 'Scale',
		description: 'Advanced controls, audit logs, and guaranteed response times.',
		price: { monthly: 129, annual: 1290 },
		badge: 'New',
		perks: ['SSO & SCIM', 'Field-level locking', 'Dedicated support']
	}
] as const;
export type PlanId = (typeof planOptions)[number]['id'];

export const billingCycles = ['monthly', 'annual'] as const;
export type BillingCycle = (typeof billingCycles)[number];

export interface WizardSubmission {
	companyName: string;
	teamSize: TeamSizeOption;
	region: RegionOption;
	adminName: string;
	adminEmail: string;
	adminRole: AdminRoleOption;
	inviteSeats: number;
	plan: PlanId;
	billing: BillingCycle;
	goals: string;
}

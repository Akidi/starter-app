import type { Actions, PageServerLoad } from './$types';
import { fail, redirect } from '@sveltejs/kit';
import { logger } from '$lib/server/logger';
import { z } from 'zod';

// Wizard form schemas
const step1Schema = z.object({
	company: z.string().min(2, 'Company name must be at least 2 characters'),
	website: z.string().url('Must be a valid URL').optional().or(z.literal('')),
	industry: z.enum([
		'technology',
		'healthcare',
		'finance',
		'education',
		'retail',
		'manufacturing',
		'other'
	])
});

const step2Schema = z.object({
	firstName: z.string().min(2, 'First name must be at least 2 characters'),
	lastName: z.string().min(2, 'Last name must be at least 2 characters'),
	email: z.string().email('Must be a valid email'),
	phone: z.string().regex(/^\+?[1-9]\d{1,14}$/, 'Must be a valid phone number')
});

const step3Schema = z.object({
	plan: z.enum(['free', 'starter', 'professional', 'enterprise']),
	billingCycle: z.enum(['monthly', 'annual']),
	agreeToTerms: z.literal('true', {
		errorMap: () => ({ message: 'You must agree to the terms and conditions' })
	})
});

export const load: PageServerLoad = async ({ locals }) => {
	// Require authentication
	if (!locals.user) {
		return redirect(302, '/demo/lucia/login');
	}

	return {
		user: locals.user
	};
};

export const actions: Actions = {
	submit: async ({ request, locals }) => {
		if (!locals.user) {
			return fail(401, { message: 'Authentication required' });
		}

		try {
			const formData = await request.formData();

			// Parse and validate all steps
			const step1Data = step1Schema.parse({
				company: formData.get('company'),
				website: formData.get('website'),
				industry: formData.get('industry')
			});

			const step2Data = step2Schema.parse({
				firstName: formData.get('firstName'),
				lastName: formData.get('lastName'),
				email: formData.get('email'),
				phone: formData.get('phone')
			});

			const step3Data = step3Schema.parse({
				plan: formData.get('plan'),
				billingCycle: formData.get('billingCycle'),
				agreeToTerms: formData.get('agreeToTerms')
			});

			const allData = {
				...step1Data,
				...step2Data,
				...step3Data,
				userId: locals.user.id,
				submittedAt: new Date()
			};

			logger.info('Wizard form submitted successfully', {
				userId: locals.user.id,
				company: step1Data.company,
				plan: step3Data.plan
			});

			// In a real app, you would save this data to the database here
			// For the demo, we just return success

			return {
				success: true,
				data: allData
			};
		} catch (error) {
			logger.error('Error submitting wizard form', error);
			if (error instanceof z.ZodError) {
				return fail(400, {
					message: 'Validation failed',
					errors: error.errors
				});
			}
			if (error instanceof Error) {
				return fail(400, { message: error.message });
			}
			return fail(500, { message: 'Failed to submit form' });
		}
	}
};

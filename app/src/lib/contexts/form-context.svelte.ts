import { getContext, setContext } from 'svelte';

const FORM_CONTEXT_KEY = Symbol('form-context');

export class FormContext {
	isSubmitting = $state(false);
	
	setSubmitting(value: boolean) {
		this.isSubmitting = value;
	}
}

export function createFormContext() {
	const context = new FormContext();
	setContext(FORM_CONTEXT_KEY, context);
	return context;
}

export function getFormContext(): FormContext | undefined {
	return getContext(FORM_CONTEXT_KEY);
}
<script lang="ts">
	interface Props {
		id: string;
		name: string;
		label: string;
		type?: 'text' | 'email' | 'password' | 'number' | 'tel' | 'url';
		value?: string | null;
		placeholder?: string;
		required?: boolean;
		disabled?: boolean;
		readonly?: boolean;
		autocomplete?: AutoFill | undefined | null;
		maxlength?: number;
		error?: string;
		helpText?: string;
		inputmode?: 'text' | 'decimal' | 'numeric' | 'tel' | 'search' | 'email' | 'url';
		min?: string | number;
		max?: string | number;
		pattern?: string;
		patternError?: string;
		step?: string;
		validateOn?: 'input' | 'blur' | 'submit';
		oninput?: (e: Event) => void;
		onblur?: (e: FocusEvent) => void;
		onfocus?: (e: FocusEvent) => void;
	}

	let {
		id,
		name,
		label,
		type = 'text',
		value = $bindable(''),
		placeholder = '',
		required = false,
		disabled = false,
		readonly = false,
		autocomplete,
		maxlength,
		error,
		helpText,
		inputmode,
		pattern,
		patternError = 'Please match the requested format',
		min,
		max,
		step,
		validateOn = 'blur',
		oninput,
		onblur,
		onfocus
	}: Props = $props();

	let inputValue = $derived(value ?? '');
	let validationError = $state<string | undefined>(undefined);
	let touched = $state(false);
	
	let displayError = $derived(touched ? (error || validationError) : error);

	const validatePattern = (inputValue: string): boolean => {
		if (!pattern || !inputValue) {
			validationError = undefined;
			return true;
		}
		
		const regex = new RegExp(`^${pattern}$`);
		if (!regex.test(inputValue)) {
			validationError = patternError;
			return false;
		}
		
		validationError = undefined;
		return true;
	};

	const handleInput = (e: Event) => {
		if (!(e.currentTarget instanceof HTMLInputElement)) return;
		const target = e.currentTarget;
		value = target.value || null;
		
		if (validateOn === 'input' && touched) {
			validatePattern(target.value);
		}
		
		oninput?.(e);
	};

	const handleBlur = (e: FocusEvent) => {
		if (!(e.currentTarget instanceof HTMLInputElement)) return;
		const target = e.currentTarget;
		touched = true;
		
		if (validateOn === 'blur') {
			validatePattern(target.value);
		}
		
		onblur?.(e);
	};

	const handleFocus = (e: FocusEvent) => {
		onfocus?.(e);
	};
</script>

<div class="w-full">
	<div class="flex items-center justify-between">
		<label for={id} class="block text-sm font-medium text-gray-700">
			{label}
			{#if required}
				<span class="text-red-500" aria-label="required">*</span>
			{/if}
		</label>
		{#if maxlength}
			<span class="text-xs text-gray-500" aria-live="polite" aria-atomic="true">
				{inputValue.length}/{maxlength}
			</span>
		{/if}
	</div>
	
	<input
		{id}
		{name}
		{type}
		{required}
		{disabled}
		{readonly}
		{autocomplete}
		{maxlength}
		value={inputValue}
		{placeholder}
		{inputmode}
		{min}
		{max}
		{step}
		{pattern}
		oninput={handleInput}
		onblur={handleBlur}
		onfocus={handleFocus}
		class="mt-1 block w-full rounded-md border px-3 py-2 text-gray-900 focus:outline-none transition-colors"
		class:border-gray-300={!displayError && !disabled}
		class:border-red-500={displayError}
		class:bg-gray-50={disabled}
		class:cursor-not-allowed={disabled}
		class:focus:border-blue-500={!displayError}
		class:focus:ring-1={!displayError}
		class:focus:ring-blue-500={!displayError}
		class:focus:border-red-500={displayError}
		class:focus:ring-red-500={displayError}
		aria-describedby={helpText || displayError ? `${id}-description` : undefined}
		aria-invalid={displayError ? true : undefined}
		aria-required={required ? true : undefined}
	/>
	
	{#if displayError}
		<p id="{id}-description" class="mt-1 text-sm text-red-600" role="alert" aria-live="polite">
			{displayError}
		</p>
	{:else if helpText}
		<p id="{id}-description" class="mt-1 text-xs text-gray-500">
			{helpText}
		</p>
	{/if}
</div>
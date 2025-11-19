<script lang="ts">
	import { FormSection, Button, TextInput, Select } from '$lib/components/ui';
	import { toasts, type ToastType } from '$lib/stores/toasts';

	let customMessage = $state('This is a custom toast message!');
	let customType = $state<ToastType>('info');
	let customDuration = $state('5000');

	function showSuccess() {
		toasts.add({
			type: 'success',
			message: 'Operation completed successfully!',
			duration: 5000
		});
	}

	function showError() {
		toasts.add({
			type: 'error',
			message: 'An error occurred while processing your request.',
			duration: 7000
		});
	}

	function showWarning() {
		toasts.add({
			type: 'warning',
			message: 'Please review your changes before continuing.',
			duration: 6000
		});
	}

	function showInfo() {
		toasts.add({
			type: 'info',
			message: 'Did you know? You can customize toast notifications!',
			duration: 5000
		});
	}

	function showPersistent() {
		toasts.add({
			type: 'info',
			message: 'This toast will stay until you manually close it.'
		});
	}

	function showLongMessage() {
		toasts.add({
			type: 'success',
			message:
				'This is a much longer toast message to demonstrate how the component handles multi-line text. It should wrap nicely and remain readable.',
			duration: 8000
		});
	}

	function showMultiple() {
		toasts.add({
			type: 'info',
			message: 'First notification',
			duration: 5000
		});

		setTimeout(() => {
			toasts.add({
				type: 'success',
				message: 'Second notification',
				duration: 5000
			});
		}, 500);

		setTimeout(() => {
			toasts.add({
				type: 'warning',
				message: 'Third notification',
				duration: 5000
			});
		}, 1000);
	}

	function showCustom() {
		const duration = customDuration ? parseInt(customDuration) : undefined;

		toasts.add({
			type: customType,
			message: customMessage,
			duration
		});
	}

	function clearAll() {
		toasts.clear();
	}

	const toastTypeExamples = [
		{
			type: 'success' as ToastType,
			title: 'Success Toast',
			description: 'Used for successful operations like saving data, completing tasks, etc.',
			example: 'Product saved successfully!'
		},
		{
			type: 'error' as ToastType,
			title: 'Error Toast',
			description: 'Used for error messages when something goes wrong.',
			example: 'Failed to connect to server. Please try again.'
		},
		{
			type: 'warning' as ToastType,
			title: 'Warning Toast',
			description: 'Used for cautionary messages that need attention.',
			example: 'Changes have not been saved. Continue anyway?'
		},
		{
			type: 'info' as ToastType,
			title: 'Info Toast',
			description: 'Used for informational messages and tips.',
			example: 'New features are available in the settings panel.'
		}
	];
</script>

<svelte:head>
	<title>Toast Notifications Demo</title>
</svelte:head>

<div class="container mx-auto max-w-6xl space-y-8 p-6">
	<!-- Header -->
	<div class="space-y-2">
		<h1 class="text-3xl font-bold text-gray-900">Toast Notifications</h1>
		<p class="text-gray-600">
			A comprehensive demonstration of the toast notification system with various types, durations,
			and options.
		</p>
	</div>

	<!-- Quick Actions -->
	<FormSection title="Quick Examples" description="Click any button to see different toast types">
		<div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
			<Button onclick={showSuccess} variant="primary" fullWidth>Show Success</Button>
			<Button onclick={showError} variant="danger" fullWidth>Show Error</Button>
			<Button onclick={showWarning} variant="secondary" fullWidth>Show Warning</Button>
			<Button onclick={showInfo} variant="ghost" fullWidth>Show Info</Button>
		</div>
	</FormSection>

	<!-- Special Cases -->
	<FormSection title="Special Cases" description="Test edge cases and special behaviors">
		<div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
			<Button onclick={showPersistent} variant="secondary" fullWidth>Persistent Toast</Button>
			<Button onclick={showLongMessage} variant="secondary" fullWidth>Long Message</Button>
			<Button onclick={showMultiple} variant="secondary" fullWidth>Multiple Toasts</Button>
		</div>
		<div class="mt-4">
			<Button onclick={clearAll} variant="danger" size="sm">Clear All Toasts</Button>
		</div>
	</FormSection>

	<!-- Custom Toast Builder -->
	<FormSection
		title="Custom Toast Builder"
		description="Create your own toast notification with custom settings"
	>
		<div class="space-y-4">
			<TextInput
				id="custom-message"
				name="customMessage"
				label="Message"
				bind:value={customMessage}
				placeholder="Enter your toast message..."
				required
			/>

			<div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
				<Select id="custom-type" name="customType" label="Type" bind:value={customType}>
					<option value="success">Success</option>
					<option value="error">Error</option>
					<option value="warning">Warning</option>
					<option value="info">Info</option>
				</Select>

				<TextInput
					id="custom-duration"
					name="customDuration"
					label="Duration (ms)"
					type="number"
					bind:value={customDuration}
					helpText="Leave empty for persistent toast"
					placeholder="5000"
					min="1000"
					step="1000"
				/>
			</div>

			<Button onclick={showCustom} variant="primary">Show Custom Toast</Button>
		</div>
	</FormSection>

	<!-- Toast Types Reference -->
	<FormSection
		title="Toast Types Reference"
		description="Overview of all available toast types and their use cases"
	>
		<div class="space-y-6">
			{#each toastTypeExamples as toast}
				<div class="space-y-2 rounded-lg border border-gray-200 p-4">
					<div class="flex items-center justify-between">
						<h3 class="text-lg font-semibold text-gray-900">{toast.title}</h3>
						<Button
							size="sm"
							variant="ghost"
							onclick={() =>
								toasts.add({ type: toast.type, message: toast.example, duration: 5000 })}
						>
							Try it
						</Button>
					</div>
					<p class="text-sm text-gray-600">{toast.description}</p>
					<div class="rounded border border-gray-200 bg-gray-50 p-3">
						<p class="font-mono text-sm text-gray-700">{toast.example}</p>
					</div>
				</div>
			{/each}
		</div>
	</FormSection>

	<!-- Features -->
	<FormSection title="Features" description="Key features of the toast notification system">
		<div class="grid grid-cols-1 gap-4 md:grid-cols-2">
			<div class="space-y-2">
				<h4 class="font-semibold text-gray-900">✓ Auto-dismiss</h4>
				<p class="text-sm text-gray-600">Toasts automatically close after a specified duration</p>
			</div>
			<div class="space-y-2">
				<h4 class="font-semibold text-gray-900">✓ Pause on hover</h4>
				<p class="text-sm text-gray-600">Hover over a toast to pause the auto-dismiss timer</p>
			</div>
			<div class="space-y-2">
				<h4 class="font-semibold text-gray-900">✓ Manual dismiss</h4>
				<p class="text-sm text-gray-600">Click the X button to close any toast manually</p>
			</div>
			<div class="space-y-2">
				<h4 class="font-semibold text-gray-900">✓ Persistent toasts</h4>
				<p class="text-sm text-gray-600">
					Omit duration to create toasts that stay until dismissed
				</p>
			</div>
			<div class="space-y-2">
				<h4 class="font-semibold text-gray-900">✓ Progress indicator</h4>
				<p class="text-sm text-gray-600">Visual progress bar shows remaining time</p>
			</div>
			<div class="space-y-2">
				<h4 class="font-semibold text-gray-900">✓ ARIA compliant</h4>
				<p class="text-sm text-gray-600">Full screen reader support with proper announcements</p>
			</div>
			<div class="space-y-2">
				<h4 class="font-semibold text-gray-900">✓ Responsive</h4>
				<p class="text-sm text-gray-600">Works great on mobile and desktop devices</p>
			</div>
			<div class="space-y-2">
				<h4 class="font-semibold text-gray-900">✓ Stackable</h4>
				<p class="text-sm text-gray-600">Multiple toasts stack nicely in the corner</p>
			</div>
		</div>
	</FormSection>

	<!-- Code Examples -->
	<FormSection title="Usage Examples" description="How to use toasts in your application">
		<div class="space-y-4">
			<div>
				<h4 class="mb-2 text-sm font-semibold text-gray-900">Basic Usage</h4>
				<pre class="overflow-x-auto rounded-lg bg-gray-900 p-4 text-sm text-gray-100"><code
						>{`import { toasts } from '$lib/stores/toasts';

// Show a success toast
toasts.add({
  type: 'success',
  message: 'Operation completed successfully!',
  duration: 5000 // milliseconds
});

// Show an error toast
toasts.add({
  type: 'error',
  message: 'Something went wrong!',
  duration: 7000
});

// Persistent toast (no auto-dismiss)
toasts.add({
  type: 'info',
  message: 'This will stay until closed'
  // No duration property
});`}</code
					></pre>
			</div>

			<div>
				<h4 class="mb-2 text-sm font-semibold text-gray-900">In a Form Submit Handler</h4>
				<pre class="overflow-x-auto rounded-lg bg-gray-900 p-4 text-sm text-gray-100"><code
						>{`async function handleSubmit() {
  try {
    await saveProduct(product);
    toasts.add({
      type: 'success',
      message: 'Product saved successfully!',
      duration: 5000
    });
  } catch (error) {
    toasts.add({
      type: 'error',
      message: 'Failed to save product. Please try again.',
      duration: 7000
    });
  }
}`}</code
					></pre>
			</div>

			<div>
				<h4 class="mb-2 text-sm font-semibold text-gray-900">Clear All Toasts</h4>
				<pre class="overflow-x-auto rounded-lg bg-gray-900 p-4 text-sm text-gray-100"><code
						>{`// Clear all active toasts
toasts.clear();

// Or remove a specific toast by ID
toasts.remove('toast-id');`}</code
					></pre>
			</div>
		</div>
	</FormSection>
</div>

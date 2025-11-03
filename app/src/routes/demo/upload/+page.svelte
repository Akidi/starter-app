<script lang="ts">
	import type { PageData, ActionData } from './$types';
	import { enhance } from '$app/forms';
	import Container from '$lib/components/layout/Container/Container.svelte';
	import Stack from '$lib/components/layout/Stack/Stack.svelte';
	import Card from '$lib/components/ui/Card/Card.svelte';
	import Button from '$lib/components/ui/Button/Button.svelte';
	import { addToast } from '$lib/stores/toasts';

	export let data: PageData;
	export let form: ActionData;

	let fileInput: HTMLInputElement;
	let isDragOver = $state(false);
	let selectedFile = $state<File | null>(null);
	let previewUrl = $state<string | null>(null);
	let isUploading = $state(false);
	let uploadedFile = $state<any>(null);

	const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB
	const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];

	function handleDragOver(event: DragEvent) {
		event.preventDefault();
		isDragOver = true;
	}

	function handleDragLeave(event: DragEvent) {
		event.preventDefault();
		isDragOver = false;
	}

	function handleDrop(event: DragEvent) {
		event.preventDefault();
		isDragOver = false;

		const files = event.dataTransfer?.files;
		if (files && files.length > 0) {
			handleFileSelect(files[0]);
		}
	}

	function handleFileInputChange(event: Event) {
		const target = event.target as HTMLInputElement;
		const files = target.files;
		if (files && files.length > 0) {
			handleFileSelect(files[0]);
		}
	}

	function handleFileSelect(file: File) {
		// Validate file type
		if (!ALLOWED_TYPES.includes(file.type)) {
			addToast({
				type: 'error',
				message: `Invalid file type. Please select an image file (JPEG, PNG, GIF, or WebP).`
			});
			return;
		}

		// Validate file size
		if (file.size > MAX_FILE_SIZE) {
			addToast({
				type: 'error',
				message: `File too large. Maximum size is ${MAX_FILE_SIZE / 1024 / 1024}MB.`
			});
			return;
		}

		selectedFile = file;

		// Create preview
		const reader = new FileReader();
		reader.onload = (e) => {
			previewUrl = e.target?.result as string;
		};
		reader.readAsDataURL(file);
	}

	function clearSelection() {
		selectedFile = null;
		previewUrl = null;
		uploadedFile = null;
		if (fileInput) {
			fileInput.value = '';
		}
	}

	function formatFileSize(bytes: number): string {
		if (bytes === 0) return '0 Bytes';
		const k = 1024;
		const sizes = ['Bytes', 'KB', 'MB', 'GB'];
		const i = Math.floor(Math.log(bytes) / Math.log(k));
		return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
	}
</script>

<svelte:head>
	<title>File Upload Demo</title>
</svelte:head>

<Container>
	<Stack gap="lg" style="margin-top: 2rem; margin-bottom: 3rem;">
		<!-- Header -->
		<div>
			<h1 style="font-size: 2rem; font-weight: 700; margin: 0 0 0.5rem 0;">File Upload Demo</h1>
			<p style="color: var(--text-secondary); margin: 0;">
				Drag and drop file upload with validation, preview, and server-side handling
			</p>
		</div>

		<!-- Upload Card -->
		<Card>
			<Stack gap="md">
				<h2 style="font-size: 1.25rem; font-weight: 600; margin: 0;">Upload Image</h2>

				<form
					method="post"
					action="?/upload"
					enctype="multipart/form-data"
					use:enhance={() => {
						isUploading = true;
						return async ({ result, update }) => {
							isUploading = false;
							if (result.type === 'success' && result.data?.success) {
								uploadedFile = result.data.file;
								addToast({ type: 'success', message: 'File uploaded successfully!' });
								clearSelection();
							} else if (result.type === 'failure') {
								addToast({
									type: 'error',
									message: result.data?.message || 'Failed to upload file'
								});
							}
							await update();
						};
					}}
				>
					{#if !selectedFile && !uploadedFile}
						<!-- Drop Zone -->
						<div
							role="button"
							tabindex="0"
							ondragover={handleDragOver}
							ondragleave={handleDragLeave}
							ondrop={handleDrop}
							onclick={() => fileInput.click()}
							onkeydown={(e) => {
								if (e.key === 'Enter' || e.key === ' ') {
									fileInput.click();
								}
							}}
							style="border: 2px dashed {isDragOver
								? 'var(--color-primary)'
								: 'var(--border-primary)'};
                     border-radius: var(--radius-lg);
                     padding: 3rem 2rem;
                     text-align: center;
                     cursor: pointer;
                     background: {isDragOver ? 'var(--bg-secondary)' : 'transparent'};
                     transition: all 0.2s;"
						>
							<Stack gap="md" style="align-items: center;">
								<div style="font-size: 4rem;">{isDragOver ? '📥' : '📤'}</div>
								<div>
									<p style="font-size: 1.125rem; font-weight: 600; margin: 0 0 0.5rem 0;">
										{isDragOver ? 'Drop your image here' : 'Drag and drop your image here'}
									</p>
									<p style="color: var(--text-secondary); margin: 0;">or click to browse</p>
								</div>
								<div
									style="font-size: 0.875rem; color: var(--text-secondary); max-width: 400px;"
								>
									<p style="margin: 0;">Supported formats: JPEG, PNG, GIF, WebP</p>
									<p style="margin: 0.25rem 0 0 0;">Maximum size: 5MB</p>
								</div>
							</Stack>
						</div>

						<input
							bind:this={fileInput}
							type="file"
							name="file"
							accept="image/jpeg,image/png,image/gif,image/webp"
							onchange={handleFileInputChange}
							style="display: none;"
						/>
					{/if}

					{#if selectedFile && previewUrl}
						<!-- Preview -->
						<Stack gap="md">
							<div
								style="border: 2px solid var(--border-primary); border-radius: var(--radius-lg); padding: 1rem; background: var(--bg-secondary);"
							>
								<Stack gap="md">
									<div style="text-align: center;">
										<img
											src={previewUrl}
											alt="Preview"
											style="max-width: 100%; max-height: 400px; border-radius: var(--radius-md);"
										/>
									</div>
									<div style="display: flex; justify-content: space-between; align-items: center;">
										<Stack gap="xs">
											<div style="font-weight: 600;">{selectedFile.name}</div>
											<div style="font-size: 0.875rem; color: var(--text-secondary);">
												{formatFileSize(selectedFile.size)} • {selectedFile.type}
											</div>
										</Stack>
										<div style="display: flex; gap: 0.5rem;">
											<Button
												type="button"
												variant="ghost"
												onclick={clearSelection}
												disabled={isUploading}
											>
												Remove
											</Button>
											<Button type="submit" variant="primary" loading={isUploading}>
												Upload
											</Button>
										</div>
									</div>
								</Stack>
							</div>
						</Stack>
					{/if}

					{#if uploadedFile}
						<!-- Success Message -->
						<div
							style="border: 2px solid var(--color-success); border-radius: var(--radius-lg); padding: 1.5rem; background: var(--bg-success, #f0fdf4);"
						>
							<Stack gap="md">
								<div style="display: flex; align-items: center; gap: 0.5rem;">
									<div style="font-size: 1.5rem;">✅</div>
									<div style="font-weight: 600; font-size: 1.125rem;">
										File Uploaded Successfully!
									</div>
								</div>
								<Stack gap="xs">
									<div style="font-size: 0.875rem; color: var(--text-secondary);">
										<strong>Original name:</strong>
										{uploadedFile.name}
									</div>
									<div style="font-size: 0.875rem; color: var(--text-secondary);">
										<strong>Size:</strong>
										{formatFileSize(uploadedFile.size)}
									</div>
									<div style="font-size: 0.875rem; color: var(--text-secondary);">
										<strong>Type:</strong>
										{uploadedFile.type}
									</div>
									<div style="font-size: 0.875rem; color: var(--text-secondary);">
										<strong>Saved as:</strong>
										{uploadedFile.savedAs}
									</div>
								</Stack>
								<div>
									<Button type="button" variant="primary" onclick={clearSelection}>
										Upload Another File
									</Button>
								</div>
							</Stack>
						</div>
					{/if}
				</form>
			</Stack>
		</Card>

		<!-- Features Info -->
		<Card>
			<Stack gap="md">
				<h3 style="font-size: 1.25rem; font-weight: 600; margin: 0;">Features Demonstrated</h3>
				<ul style="margin: 0; padding-left: 1.5rem; color: var(--text-secondary);">
					<li>Drag and drop file upload interface</li>
					<li>Click to browse file selection</li>
					<li>Client-side file type validation (JPEG, PNG, GIF, WebP)</li>
					<li>Client-side file size validation (5MB max)</li>
					<li>Image preview before upload</li>
					<li>Server-side validation and error handling</li>
					<li>Unique filename generation to prevent conflicts</li>
					<li>Progress indication during upload</li>
					<li>Success feedback with file details</li>
					<li>Proper file system handling with fs/promises</li>
				</ul>
			</Stack>
		</Card>

		<!-- Implementation Notes -->
		<Card>
			<Stack gap="md">
				<h3 style="font-size: 1.25rem; font-weight: 600; margin: 0;">Implementation Notes</h3>
				<Stack gap="sm">
					<div>
						<strong>Server-side:</strong>
						<p style="margin: 0.25rem 0 0 0; color: var(--text-secondary); font-size: 0.875rem;">
							Files are saved to <code>/uploads</code> directory with unique timestamped names. The
							server validates file type and size, then converts the file to a buffer before writing
							to disk using Node.js fs/promises API.
						</p>
					</div>
					<div>
						<strong>Client-side:</strong>
						<p style="margin: 0.25rem 0 0 0; color: var(--text-secondary); font-size: 0.875rem;">
							Drag and drop is handled with native drag events. FileReader API is used to create
							image previews. Form submission uses SvelteKit's progressive enhancement with
							use:enhance for a smooth user experience.
						</p>
					</div>
					<div>
						<strong>Production considerations:</strong>
						<p style="margin: 0.25rem 0 0 0; color: var(--text-secondary); font-size: 0.875rem;">
							For production, consider using cloud storage (S3, Google Cloud Storage) instead of
							local filesystem, implementing virus scanning, adding user-specific subdirectories,
							and setting up proper file cleanup policies.
						</p>
					</div>
				</Stack>
			</Stack>
		</Card>
	</Stack>
</Container>

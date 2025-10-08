import { render, screen } from '@testing-library/svelte';
import { describe, it, expect } from 'vitest';
import Hello from './Hello.svelte';

describe('Hello.svelte', () => {
  it('renders default name', () => {
    render(Hello);
    expect(screen.getByRole('heading', { name: /hello world/i })).toBeInTheDocument();
  });

  it('renders provided name', () => {
    render(Hello, { props: { name: 'Akidi' } });
    expect(screen.getByRole('heading', { name: /hello akidi/i })).toBeInTheDocument();
  });
});


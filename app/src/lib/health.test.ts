import { describe, it, expect } from 'vitest';

describe('vitest: smoke', () => {
  it('performs basic math', () => {
    expect(2 + 2).toBe(4);
  });

  it('asserts truthiness', () => {
    expect(true).toBeTruthy();
  });
});


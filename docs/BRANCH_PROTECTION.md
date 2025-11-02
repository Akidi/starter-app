# Branch Protection Recommendations

This repo uses an upstream mirror model with `upstream-main` (local mirror), `develop` (integration), and `main` (stable releases).

Configure GitHub Settings → Branches → Add rule with the patterns below.

## Rule: main (stable)

- Require a pull request before merging
  - Require approvals: 1–2 (recommend 1 to start)
  - Dismiss stale pull request approvals when new commits are pushed
  - Require review from Code Owners (optional if CODEOWNERS is added)
  - Require conversation resolution before merging
- Require status checks to pass before merging
  - Require branches to be up to date before merging
  - Checks to require (adjust to your CI names):
    - build
    - typecheck
    - lint
    - test
- Branch restrictions
  - Restrict who can push to matching branches (recommended)
  - Do not allow force pushes
  - Do not allow deletions
- Merge strategy
  - Allow squash merges (recommended)
  - Optionally allow rebase merges; avoid merge commits for a cleaner history
- Additional
  - Enable “Automatically delete head branches” after merge (Repository Settings → General)

## Rule: develop (integration)

- Require a pull request before merging (same options as `main`)
- Require status checks to pass before merging
  - build, typecheck, lint, test
  - Not strictly required to be up to date, but recommended for consistency
- Disallow force pushes; allow squash merges

## Tags and Releases

- Protect release tags (e.g., pattern `v*`)
  - Disallow tag deletion
  - Consider requiring signed tags if you use signed releases

## Optional Extras

- CODEOWNERS to enforce reviews from specific owners
- Require signed commits (if your team uses signing)
- Auto-merge for green PRs (if you prefer automation)

## Operational Notes

- Upstream updates: merge `upstream-main` → `develop`, test, then merge `develop` → `main` for release.
- Hotfixes: branch from `main`, PR back to `main` and `develop`.


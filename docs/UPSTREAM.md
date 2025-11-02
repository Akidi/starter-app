# Upstream Mirror Workflow

This repository tracks a starter app as an upstream source while keeping your own `main` stable and development flowing on `develop`.

## Branches

- `upstream-main`: Local mirror of `upstream/main` (do not edit; typically not pushed).
- `develop`: Integration branch for feature work and upstream merges.
- `main`: Stable, release-only branch. Tag releases from here.

## Remotes

- `upstream`: Points to the starter-app repository (read-only for you).
- `origin`: Points to your repository (this project).

## Regular Tasks

1) Pull updates from upstream

```bash
git fetch upstream
git branch -f upstream-main upstream/main
```

2) Integrate upstream into develop

```bash
git checkout develop
git merge upstream-main
# resolve conflicts if any, run tests, commit
```

3) Release a stable version

```bash
git checkout main
git merge --no-ff develop
git tag vX.Y.Z
git push origin main --tags
```

4) Feature workflow

```bash
git checkout -b feature/short-name develop
# work, commit
git push -u origin feature/short-name
# open PR to develop
```

5) Hotfix workflow

```bash
git checkout -b hotfix/short-name main
# fix, test
git checkout main && git merge --no-ff hotfix/short-name
git checkout develop && git merge --no-ff hotfix/short-name
```

## CI Suggestions

- On PRs to `develop` and `main`: run lint, typecheck, tests, and build.
- On tags (releases): build Docker images, run migrations, deploy.

## Notes

- Keep `.env.example` committed; keep real secrets out of Git.
- Prefer squash merges for `feature/*` → `develop` to keep history clean.
- Consider protecting `main` in GitHub settings (require PR, CI, reviews).


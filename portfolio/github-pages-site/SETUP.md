# GitHub Pages setup

This package adds a portfolio site under `portfolio/` and a GitHub Actions workflow under `.github/workflows/deploy-pages.yml`.

## 1. Copy into the repository

Copy these two paths into the repository root:

- `portfolio/`
- `.github/workflows/deploy-pages.yml`

Do not replace the existing `ci.yaml` workflow.

## 2. Enable GitHub Pages

On GitHub:

`Repository → Settings → Pages → Build and deployment → Source: GitHub Actions`

You only need to select GitHub Actions as the source. The workflow handles deployment.

## 3. Commit and push

```powershell
git add portfolio .github/workflows/deploy-pages.yml
git commit -m "feat: add project portfolio page"
git push
```

The Pages workflow will run automatically on `main`.

## 4. Result

The site will be published at:

`https://keval099.github.io/cloud-native-test-platform/`

If GitHub shows a different Pages URL in Settings → Pages, use the URL shown there.

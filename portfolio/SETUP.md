# Futuristic GitHub Pages portfolio update

## What changed
- Removed the light/dark theme control; the page stays in the futuristic dark theme.
- Changed the header `GH` button to `Github`.
- Added real technology icons using Devicon CDN assets.
- Kept screenshot references relative to the Pages site root: `assets/<filename>.png`.
- Added lazy loading/async decoding to screenshot images.

## IMPORTANT: screenshots
The HTML expects the screenshots to physically exist in the repository at:

```text
portfolio/
├── index.html
└── assets/
    ├── vpc.png
    ├── ecr.png
    ├── eks-pods.png
    ├── cicd-success.png
    ├── rollback.png
    ├── cloudwatch-dashboard.png
    ├── cloudwatch-logs.png
    ├── container-insights.png
    ├── cloudwatch-alarms.png
    └── application.png
```

Run `git ls-files portfolio/assets` before pushing. If it returns nothing, the screenshots are not tracked by Git and must be copied into `portfolio/assets/` and added with `git add portfolio/assets`.

## LinkedIn
Replace every `YOUR_LINKEDIN_ID` in `index.html` with your public LinkedIn profile path.

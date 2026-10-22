# Vercel deployment

The project is a Flutter Web application. Vercel runs
`scripts/vercel_build.sh`, which downloads the pinned Flutter SDK, runs
`flutter pub get`, and publishes `build/web`.

## Production branch

In Vercel, open **Project Settings → Environments → Production → Branch
Tracking** and set the production branch to `newercap`. Every push to that
branch will then publish to `https://shelbyweb.vercel.app`.

## First recovery deployment

If a Git deployment is not ready yet, deploy the already-built static site:

```bash
cd /Users/yco/Codes/cap1
flutter build web --release
cd build/web
npx vercel@latest --prod
```

`build/web/.vercel/project.json` links that command to the existing
`shelbyweb` Vercel project.

## Firebase and API origins

Add `shelbyweb.vercel.app` (and any custom production domain) to Firebase
Authentication's Authorized domains. The FakeMaya API must separately allow
the exact Vercel `https://` origin through CORS.

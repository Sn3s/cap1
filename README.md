# cap1

Shellby Flutter prototype.

## AI with Gemini or llamadart

The app uses Gemini through a Firebase HTTPS proxy on a normal
internet-connected `flutter run`. The Gemini API key is stored in Firebase
Secret Manager, not in the Flutter app. If Gemini is unavailable because the
network is offline or the proxy is temporarily unavailable, Shellby falls back
to the bundled Qwen GGUF model.

```powershell
flutter run -d emulator-5554
```

Configure the backend secret before deploying Functions:

```bash
firebase functions:secrets:set GEMINI_API_KEY
firebase deploy --only functions
```

Firebase requires the project to be on the Blaze plan before it can enable
Secret Manager and deploy the HTTPS function. Until the function is deployed,
the app will use the bundled Qwen fallback.

Do not commit Gemini API keys or hardcode them in the Flutter app.

To override the Gemini proxy URL or model, pass dart defines:

```powershell
flutter run -d emulator-5554 --dart-define=GEMINI_PROXY_URL=<https-function-url> --dart-define=GEMINI_MODEL=gemini-flash-latest
```

To force fully on-device AI, switch to the local provider with `llamadart`.

Add a small GGUF model to `assets/models/` and keep the default asset path in
sync with the bundled file:

```text
assets/models/qwen3-1.7b-instruct-q4_k_m.gguf
```

On first launch, the app copies that asset into the app support directory and
loads it from there. For iPhone, keep the model small and quantized so it fits
device memory comfortably.

Run it on your phone with:

```powershell
flutter run -d <iphone-device-id> --dart-define=AI_PROVIDER=local
```

To use a different bundled model, override the asset path:

```powershell
flutter run -d <iphone-device-id> --dart-define=AI_PROVIDER=local --dart-define=LOCAL_MODEL_ASSET=assets/models/qwen3-1.7b-instruct-q4_k_m.gguf
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

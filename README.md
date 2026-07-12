# cap1

Shellby Flutter prototype.

## AI with Gemini or llamadart

The app uses Gemini by default on a normal internet-connected `flutter run`.
If Gemini is unavailable because the network is offline, Shellby falls back to
the bundled Qwen GGUF model.

```powershell
flutter run -d emulator-5554
```

To override the Gemini key or model without editing code, pass dart defines:

```powershell
flutter run -d emulator-5554 --dart-define=GEMINI_API_KEY=<your-key> --dart-define=GEMINI_MODEL=gemini-flash-latest
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

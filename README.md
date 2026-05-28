# cap1

Shellby Flutter prototype.

## Local AI with Ollama

The app defaults to Ollama for its AI coach.

On an Android emulator, the app reaches Ollama on your PC through
`http://10.0.2.2:11434`.

Start Ollama, then run:

```powershell
ollama serve
flutter run -d emulator-5554 --dart-define=AI_PROVIDER=ollama --dart-define=OLLAMA_MODEL=qwen3.6:latest
```

If you run on a physical Android device, replace `OLLAMA_URL` with your PC's LAN
address:

```powershell
flutter run -d <device-id> --dart-define=AI_PROVIDER=ollama --dart-define=OLLAMA_URL=http://<your-pc-ip>:11434 --dart-define=OLLAMA_MODEL=qwen3.6:latest
```

The app can still use Gemini:

```powershell
flutter run -d emulator-5554 --dart-define=AI_PROVIDER=gemini --dart-define=GEMINI_API_KEY=<your-key>
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

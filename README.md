<div align="center">

# ✨ deepar_kit

### Real-time AR filters for your live streams — DeepAR meets Agora, in one line.

[![pub package](https://img.shields.io/badge/pub-v0.1.0-blue.svg?style=for-the-badge&logo=dart)](https://pub.dev/packages/deepar_kit)
[![license](https://img.shields.io/badge/license-MIT-green.svg?style=for-the-badge)](LICENSE)
[![platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-lightgrey.svg?style=for-the-badge&logo=flutter)](https://flutter.dev)

*Pipe [DeepAR](https://www.deepar.ai/) AR-processed frames straight into [Agora RTC](https://www.agora.io/) as an external video source — or use DeepAR standalone as a pure camera filter.*

</div>

---

## 🚀 Why deepar_kit?

Integrating augmented-reality beauty and face filters into a real-time video call usually means wiring raw camera buffers, format conversions, and low-level frame pushes by hand. **deepar_kit** collapses all of that into a single, resilient bridge — and works just as well as a standalone camera filter with no streaming at all.

- 🔗 **Automatic frame forwarding** — DeepAR output flows into Agora with zero manual plumbing
- 🎭 **First-class effects** — load `.deepar` filters and switch cameras through convenience methods
- 🧩 **Works with *or* without Agora** — drop the bridge and DeepAR runs as a standalone camera filter
- 🛡️ **Error-resilient** — dropped frames never crash your stream
- 📊 **Observable** — built-in frame-count tracking for diagnostics
- 🧹 **Clean lifecycle** — deterministic start / stop / dispose

---

## 📦 Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  deepar_kit: ^0.1.0
  # Automatically pulls in flutter_deepar and agora_rtc_engine
```

Then run:

```bash
flutter pub get
```

---

## 🎯 Two ways to use it

One package, two entry points — import only what you need:

| Use case | Import | What you get |
|----------|--------|--------------|
| 🎥 **Camera filter only** (no Agora) | `package:deepar_kit/deepar_filter.dart` | `DeepARController` + effects. No bridge, no Agora setup. |
| 📡 **Filters + live streaming** | `package:deepar_kit/deepar_kit.dart` | Everything above **plus** `DeepARAgoraBridge`. |

> ℹ️ Both live in the same package, so `agora_rtc_engine` is present in the dependency tree either way — but with the filter-only import you never touch a single Agora type or API.

## 🔐 Separation of concerns

**Your app stays the sole owner of Agora.** This package never asks for, reads, or stores your Agora **App ID**, **token**, or **channel** — you create and initialize the `RtcEngine` yourself and simply hand it to the bridge. DeepAR and Agora remain fully decoupled:

- Want AR filters **in a live stream?** → attach the bridge.
- Want AR filters as **a plain camera filter?** → use `DeepARController` alone, no Agora involved.

## ⚡ Quick Start

```dart
import 'package:deepar_kit/deepar_kit.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

// 1️⃣  Initialize DeepAR
final deepar = DeepARController();
await deepar.initialize(licenseKey: 'YOUR_DEEPAR_KEY');
await deepar.startCapture();

// 2️⃣  Your app owns Agora — App ID/token never enter this package
final agoraEngine = createAgoraRtcEngine();
await agoraEngine.initialize(RtcEngineContext(appId: 'YOUR_AGORA_APP_ID'));

// 3️⃣  Bridge them and go live — one call does all the Agora wiring
final bridge = DeepARAgoraBridge(deepAR: deepar, agoraEngine: agoraEngine);
await bridge.enable();
// 🎉 AR-processed frames now stream into Agora automatically!

// 4️⃣  Load an effect at any time
await bridge.loadEffect('effects/my_filter.deepar');

// 5️⃣  Tear down cleanly
await bridge.disable();
await deepar.stopCapture();
bridge.dispose();
```

---

## 🎥 Standalone Mode (no Agora)

Don't need streaming? Import the filter-only entry point — no bridge, no Agora API, ever.

```dart
import 'package:deepar_kit/deepar_filter.dart';

final deepar = DeepARController();
await deepar.initialize(licenseKey: 'YOUR_DEEPAR_KEY');
await deepar.startCapture();
await deepar.loadEffect('effects/my_filter.deepar');
// Render deepar's preview widget directly in your UI.
```

---

## 🔬 How It Works

The bridge subscribes to `DeepARController.frameStream` and pushes each processed frame to Agora via `MediaEngine.pushVideoFrame()`. Under the hood it handles:

| Concern | Handled |
|--------|---------|
| Pixel format | 🟢 RGBA (Android) & BGRA (iOS) auto-detection |
| Timing | 🟢 Per-frame timestamping |
| Resilience | 🟢 Frame-push failures are non-fatal |
| Lifecycle | 🟢 Deterministic start / stop / dispose |

---

## 📋 Requirements

- Flutter `>= 3.10.0`
- Dart SDK `>= 3.0.0`
- A [DeepAR](https://developer.deepar.ai/) license key
- An [Agora](https://console.agora.io/) App ID

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to open an issue or submit a pull request.

---

## 👤 Author

**Zaman Sheikh**

- GitHub: [@zamansheikh](https://github.com/zamansheikh)

---

## 📄 License

Released under the [MIT License](LICENSE) © Zaman Sheikh.

<div align="center">

**If this package helped you, consider giving it a ⭐ on [GitHub](https://github.com/zamansheikh)!**

</div>

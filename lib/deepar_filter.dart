/// Camera-filter–only entry point for `deepar_kit`.
///
/// Import this when you want DeepAR AR/beauty filters as a standalone camera
/// filter, with **no Agora involved** — no bridge, no streaming, no Agora
/// setup:
///
/// ```dart
/// import 'package:deepar_kit/deepar_filter.dart';
///
/// final deepar = DeepARController();
/// await deepar.initialize(licenseKey: 'YOUR_DEEPAR_KEY');
/// await deepar.startCapture();
/// await deepar.loadEffect('effects/my_filter.deepar');
/// // Render DeepAR's preview widget in your UI.
/// ```
///
/// Need to stream those filtered frames over Agora? Import
/// `package:deepar_kit/deepar_kit.dart` instead — it adds the
/// [DeepARAgoraBridge] on top of everything exported here.
library deepar_filter;

// Re-export the DeepAR camera-filter surface only. This file intentionally
// does NOT reference Agora, so filter-only code never touches the bridge.
export 'package:flutter_deepar/flutter_deepar.dart';

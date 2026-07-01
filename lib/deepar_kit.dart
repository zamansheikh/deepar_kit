/// DeepAR toolkit for Flutter — AR/beauty camera filters that work standalone
/// or stream live over Agora RTC.
///
/// This is the full entry point (filters **plus** the Agora bridge):
/// ```dart
/// import 'package:deepar_kit/deepar_kit.dart';
///
/// final bridge = DeepARAgoraBridge(deepAR: deepar, agoraEngine: engine);
/// await bridge.enable();
/// ```
///
/// Only need the camera filter with no Agora? Import
/// `package:deepar_kit/deepar_filter.dart` instead.
library deepar_kit;

export 'src/deepar_agora_bridge.dart';
// Re-export core types so users don't need both imports
export 'package:flutter_deepar/flutter_deepar.dart';

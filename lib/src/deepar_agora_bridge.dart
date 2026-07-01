import 'dart:async';
import 'dart:developer';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_deepar/flutter_deepar.dart';

/// Bridge that pipes DeepAR AR-processed frames directly into Agora RTC
/// as an external video source.
///
/// ### Separation of concerns
/// This bridge NEVER touches your Agora credentials. Your app stays the sole
/// owner of Agora — you create the [RtcEngine], initialize it with your own
/// App ID/token, and join channels yourself. The bridge only receives the
/// already-initialized engine and forwards processed frames into it. DeepAR
/// can also be used entirely on its own (as a camera filter) without ever
/// constructing this bridge.
///
/// ### Plug & play
/// ```dart
/// // Your app owns Agora — App ID/token never enter this package.
/// final agoraEngine = createAgoraRtcEngine();
/// await agoraEngine.initialize(RtcEngineContext(appId: MY_APP_ID));
///
/// final deepar = DeepARController();
/// await deepar.initialize(licenseKey: MY_DEEPAR_KEY);
/// await deepar.startCapture();
///
/// // One call wires DeepAR → Agora. That's it.
/// final bridge = DeepARAgoraBridge(deepAR: deepar, agoraEngine: agoraEngine);
/// await bridge.enable();
///
/// await bridge.loadEffect('effects/filter.deepar');
/// ```
class DeepARAgoraBridge {
  /// The DeepAR controller providing AR-processed frames.
  final DeepARController deepAR;

  /// The Agora RTC engine to push frames to.
  ///
  /// Owned and initialized by your app — the bridge never reads or stores your
  /// Agora App ID, token, or channel.
  final RtcEngine agoraEngine;

  /// The Agora custom video track id frames are pushed to. Defaults to `0`.
  final int videoTrackId;

  StreamSubscription? _frameSub;
  int _frameCount = 0;
  bool _isForwarding = false;

  /// Creates a bridge between DeepAR and Agora.
  ///
  /// Both [deepAR] and [agoraEngine] must already be initialized. Call
  /// [enable] to wire everything up in one step.
  DeepARAgoraBridge({
    required this.deepAR,
    required this.agoraEngine,
    this.videoTrackId = 0,
  });

  /// Whether frames are currently being forwarded.
  bool get isForwarding => _isForwarding;

  /// Number of frames forwarded in the current session.
  int get frameCount => _frameCount;

  /// Plug-and-play setup: enables Agora's external video source and starts
  /// forwarding DeepAR frames in a single call.
  ///
  /// This is the only Agora configuration the bridge performs. Everything else
  /// (initialize, join channel, publish) stays in your app.
  Future<void> enable() async {
    await agoraEngine.getMediaEngine().setExternalVideoSource(
          enabled: true,
          useTexture: false,
        );
    await startForwarding();
  }

  /// Reverses [enable]: stops forwarding and disables the external video source.
  Future<void> disable() async {
    stopForwarding();
    await agoraEngine.getMediaEngine().setExternalVideoSource(
          enabled: false,
          useTexture: false,
        );
  }

  /// Start forwarding DeepAR frames to Agora.
  ///
  /// Prefer [enable], which also configures Agora's external video source.
  /// Use this directly only if you have already enabled the external source
  /// yourself.
  Future<void> startForwarding() async {
    _frameCount = 0;
    _isForwarding = true;
    _frameSub?.cancel();
    _frameSub = deepAR.frameStream.listen((frame) {
      if (!_isForwarding) return;
      _frameCount++;

      try {
        final mediaEngine = agoraEngine.getMediaEngine();
        mediaEngine.pushVideoFrame(
          frame: ExternalVideoFrame(
            type: VideoBufferType.videoBufferRawData,
            format: frame.format == 'bgra'
                ? VideoPixelFormat.videoPixelBgra
                : VideoPixelFormat.videoPixelRgba,
            buffer: frame.data,
            stride: frame.width,
            height: frame.height,
            timestamp: frame.timestamp,
          ),
          videoTrackId: videoTrackId,
        );
      } catch (e) {
        // Frame push failures are non-fatal; log sparingly
        if (_frameCount <= 3 || _frameCount % 500 == 0) {
          log('⚠️ [DeepARAgoraBridge] Frame push error #$_frameCount: $e');
        }
      }
    });
    log('🔗 [DeepARAgoraBridge] Started forwarding frames');
  }

  /// Stop forwarding frames to Agora.
  void stopForwarding() {
    _isForwarding = false;
    _frameSub?.cancel();
    _frameSub = null;
    log('🔗 [DeepARAgoraBridge] Stopped forwarding (sent $_frameCount frames)');
  }

  /// Load a DeepAR effect (convenience passthrough to [DeepARController]).
  Future<void> loadEffect(String? effectPath) => deepAR.loadEffect(effectPath);

  /// Clear the current effect (convenience passthrough).
  Future<void> clearEffect() => deepAR.clearEffect();

  /// Switch camera (convenience passthrough).
  Future<void> switchCamera() => deepAR.switchCamera();

  /// Full cleanup — stops forwarding.
  void dispose() {
    stopForwarding();
  }
}

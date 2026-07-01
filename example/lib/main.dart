import 'dart:io';
import 'package:flutter/material.dart';
import 'package:deepar_kit/deepar_kit.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeepAR + Agora Example',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const DeepARAgoraExamplePage(),
    );
  }
}

class DeepARAgoraExamplePage extends StatefulWidget {
  const DeepARAgoraExamplePage({super.key});

  @override
  State<DeepARAgoraExamplePage> createState() => _DeepARAgoraExamplePageState();
}

class _DeepARAgoraExamplePageState extends State<DeepARAgoraExamplePage> {
  final DeepARController _deepar = DeepARController();
  late final RtcEngine _agoraEngine;
  DeepARAgoraBridge? _bridge;

  bool _isInitialized = false;
  bool _isStreaming = false;
  String _status = 'Not initialized';

  // Replace with your keys
  static const String _deeparAndroidKey = 'YOUR_ANDROID_DEEPAR_KEY';
  static const String _deeparIosKey = 'YOUR_IOS_DEEPAR_KEY';
  static const String _agoraAppId = 'YOUR_AGORA_APP_ID';
  static const String _channelName = 'test_channel';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => _status = 'Initializing DeepAR...');

    // 1. Initialize DeepAR
    final deeparKey = Platform.isIOS ? _deeparIosKey : _deeparAndroidKey;
    await _deepar.initialize(licenseKey: deeparKey);

    // 2. Initialize Agora
    setState(() => _status = 'Initializing Agora...');
    _agoraEngine = createAgoraRtcEngine();
    await _agoraEngine.initialize(RtcEngineContext(appId: _agoraAppId));
    await _agoraEngine.setChannelProfile(
        ChannelProfileType.channelProfileLiveBroadcasting);
    await _agoraEngine.setClientRole(
        role: ClientRoleType.clientRoleBroadcaster);

    // 3. Create the bridge — Agora's external video source is wired up
    //    automatically by bridge.enable() below. No manual setup needed.
    _bridge = DeepARAgoraBridge(
      deepAR: _deepar,
      agoraEngine: _agoraEngine,
    );

    setState(() {
      _isInitialized = true;
      _status = 'Ready — tap Start to begin streaming';
    });
  }

  Future<void> _toggleStream() async {
    if (_isStreaming) {
      // Stop
      await _bridge?.disable();
      await _deepar.stopCapture();
      await _agoraEngine.leaveChannel();
      setState(() {
        _isStreaming = false;
        _status = 'Stopped';
      });
    } else {
      // Start — one call wires DeepAR → Agora.
      setState(() => _status = 'Starting capture...');
      await _deepar.startCapture();
      await _bridge?.enable();
      await _agoraEngine.joinChannel(
        token: '',
        channelId: _channelName,
        uid: 0,
        options: const ChannelMediaOptions(
          publishCustomVideoTrack: true,
          publishCameraTrack: false,
          autoSubscribeVideo: true,
          autoSubscribeAudio: true,
        ),
      );
      setState(() {
        _isStreaming = true;
        _status = 'Streaming on channel: $_channelName';
      });
    }
  }

  @override
  void dispose() {
    _bridge?.dispose();
    _deepar.dispose();
    _agoraEngine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DeepAR + Agora')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(_status),
                    if (_bridge != null) ...[
                      const SizedBox(height: 4),
                      Text('Frames sent: ${_bridge!.frameCount}',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isInitialized ? _toggleStream : null,
              icon: Icon(_isStreaming ? Icons.stop : Icons.live_tv),
              label: Text(_isStreaming ? 'Stop Stream' : 'Start Stream'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isStreaming ? () => _bridge?.switchCamera() : null,
              icon: const Icon(Icons.cameraswitch),
              label: const Text('Switch Camera'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isStreaming
                  ? () => _bridge?.loadEffect('effects/beauty.deepar')
                  : null,
              icon: const Icon(Icons.auto_fix_high),
              label: const Text('Load Effect'),
            ),
            OutlinedButton.icon(
              onPressed: _isStreaming ? () => _bridge?.clearEffect() : null,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Effect'),
            ),
          ],
        ),
      ),
    );
  }
}

## 0.1.0

* Initial release of **deepar_kit**.
* `DeepARController` camera-filter API usable standalone (import `deepar_filter.dart`) — no Agora required.
* `DeepARAgoraBridge` for plug-and-play live streaming: `enable()` / `disable()` wire DeepAR frames into Agora RTC in a single call.
* Your app stays the sole owner of Agora — the bridge never touches your App ID, token, or channel.
* Automatic RGBA (Android) / BGRA (iOS) pixel-format handling and per-frame timestamping.
* Error-resilient frame forwarding with frame-count tracking.

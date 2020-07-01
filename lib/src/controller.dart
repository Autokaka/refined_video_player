import 'package:flutter/services.dart';

class RVController {
  static final pluginBase = "refined_video_player";
  MethodChannel _methodChannel;

  String url = "";
  List<String> vlcOptions;

  void Function() _onInit;
  void Function() _onPlay;
  void Function() _onPause;
  void Function() _onStop;
  void Function() _onTimeChange;

  RVController(
    this.url, {
    this.vlcOptions,
    void Function() onInit,
    void Function() onPlay,
    void Function() onPause,
    void Function() onStop,
    void Function() onTimeChange,
  }) {
    _onInit = onInit ?? () {};
    _onPlay = onPlay ?? () {};
    _onPause = onPause ?? () {};
    _onStop = onStop ?? () {};
    _onTimeChange = onTimeChange ?? () {};
  }

  /// This method can only be executed onPlatformViewCreated.
  /// After that, though accessible, this method has no use.
  Future<void> initPlayer(int id) async {
    if (_methodChannel != null) return;
    _methodChannel = MethodChannel("$pluginBase/method_$id");
    await _methodChannel.invokeMethod("initialize", {
      "url": url,
      "VLCOptions": vlcOptions ??
          <String>[
            "--no-drop-late-frames",
            "--no-skip-frames",
            "--rtsp-tcp",
            "--quiet",
          ],
    });
    _onInit();
  }

  Future<void> play() async {
    await _methodChannel.invokeMethod("play");
    _onPlay();
  }

  Future<void> pause() async {
    await _methodChannel.invokeMethod("pause");
    _onPause();
  }

  Future<void> stop() async {
    await _methodChannel.invokeMethod("stop");
    _onStop();
  }
}

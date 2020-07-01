import 'dart:io';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RVController {
  static final pluginBase = "refined_video_player";
  MethodChannel _methodChannel;

  String url = "";
  bool _isFullScreen = false;
  bool get isFullScreen => _isFullScreen;
  BuildContext _context;

  void Function() _onInit;
  void Function() _onPlay;
  void Function() _onPause;
  void Function() _onStop;
  void Function() _onTimeChange;

  RVController(
    this.url, {
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

  /// This method can only be executed once RefinedVideoPlayer
  /// view is created.
  set registerContext(BuildContext context) {
    _context = context;
  }

  /// This method can only be executed onPlatformViewCreated.
  /// After that, though accessible, this method has no use.
  Future<void> initPlayer(int id) async {
    if (_methodChannel != null) return;
    _methodChannel = MethodChannel("$pluginBase/method_$id");
    await _methodChannel.invokeMethod("initialize", {"url": url});
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

  void setFullScreen(bool wantFullScreen) {
    if (wantFullScreen == _isFullScreen) return;
    _isFullScreen = wantFullScreen;
    if (_isFullScreen) {
      AutoOrientation.landscapeAutoMode();
      Navigator.of(_context).push(
        MaterialPageRoute(
          builder: (_) => RefinedVideoPlayer(controller: this),
        ),
      );
    }
  }

  void toggleFullScreen() => setFullScreen(!_isFullScreen);
}

class _VideoPlayer extends StatefulWidget {
  final RVController controller;

  _VideoPlayer({
    Key key,
    @required this.controller,
  }) : super(key: key);

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<_VideoPlayer> {
  MethodChannel methodChannel;
  RVController controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    controller.registerContext = context;
    if (Platform.isAndroid) {
      return AndroidView(
        viewType: "${RVController.pluginBase}/view",
        onPlatformViewCreated: controller.initPlayer,
        creationParamsCodec: StandardMessageCodec(),
      );
    }
    if (Platform.isIOS) {
      return UiKitView(
        viewType: "${RVController.pluginBase}/view",
        onPlatformViewCreated: controller.initPlayer,
        creationParamsCodec: StandardMessageCodec(),
      );
    }
    return Center(
      child: Text("Platform not supported"),
    );
  }
}

class RefinedVideoPlayer extends StatefulWidget {
  final RVController controller;

  RefinedVideoPlayer({
    Key key,
    @required this.controller,
  }) : super(key: key);

  @override
  _RefinedVideoPlayerState createState() => _RefinedVideoPlayerState();
}

class _RefinedVideoPlayerState extends State<RefinedVideoPlayer> {
  RVController controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: Hero(
          tag: RVController.pluginBase,
          child: _VideoPlayer(
            controller: controller,
          ),
        ),
      ),
      onWillPop: () async {
        if (controller.isFullScreen) {
          controller.toggleFullScreen();
          AutoOrientation.portraitUpMode();
        }
        return true;
      },
    );
  }
}

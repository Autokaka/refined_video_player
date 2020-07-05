part of refined_video_player;

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
  Future<void> _initPlayer(int id) async {
    if (_methodChannel != null) return;
    _methodChannel = MethodChannel("$pluginBase/method");
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

part of refined_video_player;

enum RVPState {
  PLAYING,
  PAUSED,
  STOPPED,
}

class RVPController {
  static final pluginBase = "refined_video_player";
  MethodChannel _methodChannel;
  EventChannel _eventChannel;
  BuildContext _context;

  String url = "";
  ValueNotifier<bool> _isFullScreen = ValueNotifier(false);
  ValueNotifier<bool> get isFullScreen => _isFullScreen;
  ValueNotifier<Size> _size = ValueNotifier(Size(16, 9));
  ValueNotifier<Size> get size => _size;
  ValueNotifier<Duration> _duration = ValueNotifier(Duration.zero);
  ValueNotifier<Duration> get duration => _duration;
  ValueNotifier<Duration> _position = ValueNotifier(Duration.zero);
  ValueNotifier<Duration> get position => _position;
  ValueNotifier<RVPState> _state = ValueNotifier(RVPState.STOPPED);
  ValueNotifier<RVPState> get state => _state;
  ValueNotifier<double> _speed = ValueNotifier(1);
  ValueNotifier<double> get speed => _speed;

  void Function() _onInited;
  void Function() _onPlaying;
  void Function() _onPaused;
  void Function() _onStopped;
  void Function() _onTimeChanged;

  RVPController(
    this.url, {
    void Function() onInited,
    void Function() onPlaying,
    void Function() onPaused,
    void Function() onStopped,
    void Function() onTimeChanged,
  }) {
    _onInited = onInited ?? () {};
    _onPlaying = onPlaying ?? () {};
    _onPaused = onPaused ?? () {};
    _onStopped = onStopped ?? () {};
    _onTimeChanged = onTimeChanged ?? () {};
  }

  /// This method can only be executed onPlatformViewCreated.
  /// After that, this method has no use.
  Future<void> _initPlayer(int id) async {
    if (_isFullScreen.value) {
      AutoOrientation.landscapeAutoMode();
    } else {
      AutoOrientation.portraitUpMode();
    }
    if (_methodChannel != null) return;
    _methodChannel = MethodChannel("$pluginBase/method");
    _eventChannel = EventChannel("$pluginBase/event");
    await _methodChannel.invokeMethod("initialize", {"url": url});
    _eventChannel.receiveBroadcastStream().listen((event) {
      switch (event["name"]) {
        case "info":
          Size newSize = Size(
            double.parse(event["width"] as String),
            double.parse(event["height"] as String),
          );
          _size.value = newSize;
          _duration.value = Duration(
            milliseconds: double.parse(
              event["duration"] as String,
            ).toInt(),
          );
          _onInited();
          break;
        case "playing":
          _state.value = RVPState.PLAYING;
          _onPlaying();
          break;
        case "paused":
          _state.value = RVPState.PAUSED;
          _onPaused();
          break;
        case "stopped":
          _state.value = RVPState.STOPPED;
          _onStopped();
          break;
        case "timeChanged":
          _position.value = Duration(
            milliseconds: double.parse(
              event["value"] as String,
            ).toInt(),
          );
          _speed.value = double.parse(
            event["speed"] as String,
          );
          _onTimeChanged();
          break;
        default:
      }
    });
  }

  Future<void> play() async {
    await _methodChannel.invokeMethod("play");
  }

  Future<void> pause() async {
    await _methodChannel.invokeMethod("pause");
  }

  Future<void> stop() async {
    await _methodChannel.invokeMethod("stop");
  }

  void setFullScreen(bool wantFullScreen) {
    if (wantFullScreen == _isFullScreen.value) return;
    _isFullScreen.value = wantFullScreen;
    if (_isFullScreen.value) {
      Navigator.of(_context).push(
        MaterialPageRoute(
          builder: (_) => RefinedVideoPlayer(controller: this),
        ),
      );
    } else {
      Navigator.of(_context).pop();
    }
  }

  void toggleFullScreen() => setFullScreen(!_isFullScreen.value);
}

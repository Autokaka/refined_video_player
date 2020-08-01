part of refined_video_player;

enum RVPState {
  PLAYING,
  PAUSED,
  STOPPED,
  ERROR,
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
  ValueNotifier<Duration> _initialPosition = ValueNotifier(Duration.zero);
  ValueNotifier<Duration> get initialPosition => _initialPosition;
  ValueNotifier<RVPState> _state = ValueNotifier(RVPState.STOPPED);
  ValueNotifier<RVPState> get state => _state;
  ValueNotifier<double> _speed = ValueNotifier(1);
  ValueNotifier<double> get speed => _speed;
  ValueNotifier<double> _volume = ValueNotifier(0);
  ValueNotifier<double> get volume => _volume;
  ValueNotifier<double> _initialVolume = ValueNotifier(0);
  ValueNotifier<double> get initialVolume => _initialVolume;
  ValueNotifier<double> _brightness = ValueNotifier(0);
  ValueNotifier<double> get brightness => _brightness;
  ValueNotifier<double> _initialBrightness = ValueNotifier(0);
  ValueNotifier<double> get initialBrightness => _initialBrightness;

  void Function() _onInited;
  void Function() _onPlaying;
  void Function() _onPaused;
  void Function() _onStopped;
  void Function() _onTimeChanged;
  void Function(String detail) _onError;

  RVPController(
    this.url, {
    void Function() onInited,
    void Function() onPlaying,
    void Function() onPaused,
    void Function() onStopped,
    void Function() onTimeChanged,
    void Function(String detail) onError,
  }) {
    _onInited = onInited ?? () {};
    _onPlaying = onPlaying ?? () {};
    _onPaused = onPaused ?? () {};
    _onStopped = onStopped ?? () {};
    _onTimeChanged = onTimeChanged ?? () {};
    _onError = onError ?? (detail) {};
  }

  /// This method can only be executed onPlatformViewCreated.
  /// After that, this method has no use.
  Future<void> _initPlayer(int id) async {
    if (_isFullScreen.value) {
      AutoOrientation.landscapeAutoMode();
      SystemChrome.setEnabledSystemUIOverlays([]);
    } else {
      AutoOrientation.portraitUpMode();
      SystemChrome.setEnabledSystemUIOverlays([
        SystemUiOverlay.top,
        SystemUiOverlay.bottom,
      ]);
    }
    if (_methodChannel != null) return;
    _methodChannel = MethodChannel("$pluginBase/method");
    _eventChannel = EventChannel("$pluginBase/event");
    await setMediaSource(url);
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
        case "error":
          _state.value = RVPState.ERROR;
          _onError(event["detail"]);
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
          if (_state.value != RVPState.PLAYING) break;
          _position.value = Duration(
            milliseconds: double.parse(
              event["value"] as String,
            ).toInt(),
          );
          _initialPosition.value = _position.value;
          _speed.value = double.parse(
            event["speed"] as String,
          );
          if (_position.value.inMilliseconds >=
              _duration.value.inMilliseconds - 1000) {
            pause().then((_) => _state.value = RVPState.STOPPED);
          }
          _onTimeChanged();
          break;
        default:
      }
    });
    VolumeWatcher.getCurrentVolume.then(
      (currentVolume) {
        _volume.value = currentVolume;
        _initialVolume.value = currentVolume;
      },
    );
    Screen.brightness.then(
      (currentBrightness) {
        _brightness.value = currentBrightness;
        _initialBrightness.value = currentBrightness;
      },
    );
  }

  Future<void> setMediaSource(String url) async {
    this.url = url;
    await _methodChannel.invokeMethod("setMediaSource", {"url": url});
  }

  Future<void> play() async {
    await _methodChannel.invokeMethod("play");
  }

  Future<void> pause() async {
    await _methodChannel.invokeMethod("pause");
  }

  Future<void> togglePlay() async {
    if (_state.value == RVPState.STOPPED) return;
    if (_state.value == RVPState.PLAYING) {
      await pause();
      _state.value = RVPState.PAUSED;
    } else {
      await play();
      _state.value = RVPState.PLAYING;
    }
  }

  Future<void> stop() async {
    await _methodChannel.invokeMethod("stop");
  }

  Future<void> seekTo(
    Duration position, [
    bool syncInitial = false,
  ]) async {
    await _methodChannel.invokeMethod("seekTo", {
      "time": position.inMilliseconds.toString(),
    });
    if (syncInitial) {
      _initialPosition.value = position;
    }
  }

  Future<void> dispose() async {
    await _methodChannel.invokeMethod("dispose");
  }

  Future<void> setSpeed(double speed) async {
    _methodChannel.invokeMethod("setSpeed", {
      "speed": speed.toString(),
    });
  }

  Future<void> setVolume(
    double volume, [
    bool syncInitial = false,
  ]) async {
    if (volume < 0) volume = 0;
    if (volume > 1) volume = 1;
    await VolumeWatcher.setVolume(volume);
    _volume.value = volume;
    if (syncInitial) {
      _initialVolume.value = volume;
    }
  }

  Future<void> setBrightness(
    double brightness, [
    bool syncInitial = false,
  ]) async {
    if (brightness < 0) brightness = 0;
    if (brightness > 1) brightness = 1;
    await Screen.setBrightness(brightness);
    _brightness.value = brightness;
    if (syncInitial) {
      _initialBrightness.value = brightness;
    }
  }

  Future<void> keepScreenOn(bool onOrNot) async {
    if (await Screen.isKeptOn) return;
    await Screen.keepOn(onOrNot);
  }

  void setFullScreen(bool wantFullScreen, RefinedVideoPlayer playerInstance) {
    if (wantFullScreen == _isFullScreen.value) return;
    _isFullScreen.value = wantFullScreen;
    if (_isFullScreen.value) {
      Navigator.of(_context).push(
        MaterialPageRoute(
          builder: (_) => playerInstance,
        ),
      );
    } else {
      Navigator.of(_context).pop();
    }
  }

  void toggleFullScreen(RefinedVideoPlayer playerInstance) {
    setFullScreen(
      !_isFullScreen.value,
      playerInstance,
    );
  }
}

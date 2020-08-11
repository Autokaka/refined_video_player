part of refined_video_player;

enum RVPState {
  PLAYING,
  PAUSED,
  STOPPED,
  ERROR,
}

class RVPController with ChangeNotifier {
  static final pluginBase = "refined_video_player";
  MethodChannel _methodChannel;
  EventChannel _eventChannel;
  BuildContext _context;

  String url = "";
  final ValueNotifier<bool> isFullScreen = ValueNotifier(false);
  final ValueNotifier<Size> size = ValueNotifier(Size(16, 9));
  final ValueNotifier<Duration> duration = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> position = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> initialPosition = ValueNotifier(Duration.zero);
  final ValueNotifier<RVPState> state = ValueNotifier(RVPState.STOPPED);
  final ValueNotifier<double> speed = ValueNotifier(1);
  final ValueNotifier<double> volume = ValueNotifier(0);
  final ValueNotifier<double> initialVolume = ValueNotifier(0);
  final ValueNotifier<double> brightness = ValueNotifier(0);
  final ValueNotifier<double> initialBrightness = ValueNotifier(0);

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
          size.value = newSize;
          duration.value = Duration(
            milliseconds: double.parse(
              event["duration"] as String,
            ).toInt(),
          );
          _onInited();
          break;
        case "error":
          state.value = RVPState.ERROR;
          _onError(event["detail"]);
          break;
        case "playing":
          state.value = RVPState.PLAYING;
          _onPlaying();
          break;
        case "paused":
          state.value = RVPState.PAUSED;
          _onPaused();
          break;
        case "stopped":
          state.value = RVPState.STOPPED;
          _onStopped();
          break;
        case "timeChanged":
          if (state.value != RVPState.PLAYING) break;
          position.value = Duration(
            milliseconds: double.parse(
              event["value"] as String,
            ).toInt(),
          );
          initialPosition.value = position.value;
          speed.value = double.parse(
            event["speed"] as String,
          );
          if (position.value.inMilliseconds >=
              duration.value.inMilliseconds - 1000) {
            pause().then((_) => state.value = RVPState.STOPPED);
          }
          _onTimeChanged();
          break;
        default:
      }
    });
    VolumeWatcher.getCurrentVolume.then(
      (currentVolume) {
        volume.value = currentVolume;
        initialVolume.value = currentVolume;
      },
    );
    Screen.brightness.then(
      (currentBrightness) {
        brightness.value = currentBrightness;
        initialBrightness.value = currentBrightness;
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
    if (state.value == RVPState.STOPPED) return;
    if (state.value == RVPState.PLAYING) {
      await pause();
      state.value = RVPState.PAUSED;
    } else {
      await play();
      state.value = RVPState.PLAYING;
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
      initialPosition.value = position;
    }
  }

  @override
  Future<void> dispose() async {
    isFullScreen.dispose();
    size.dispose();
    duration.dispose();
    position.dispose();
    initialPosition.dispose();
    state.dispose();
    speed.dispose();
    volume.dispose();
    initialVolume.dispose();
    brightness.dispose();
    initialBrightness.dispose();
    super.dispose();
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
    this.volume.value = volume;
    if (syncInitial) {
      initialVolume.value = volume;
    }
  }

  Future<void> setBrightness(
    double brightness, [
    bool syncInitial = false,
  ]) async {
    if (brightness < 0) brightness = 0;
    if (brightness > 1) brightness = 1;
    await Screen.setBrightness(brightness);
    this.brightness.value = brightness;
    if (syncInitial) {
      initialBrightness.value = brightness;
    }
  }

  Future<void> keepScreenOn(bool onOrNot) async {
    if (await Screen.isKeptOn) return;
    await Screen.keepOn(onOrNot);
  }

  void setFullScreen(
    bool wantFullScreen,
    RefinedVideoPlayer playerInstance,
  ) {
    if (wantFullScreen == isFullScreen.value) return;
    isFullScreen.value = wantFullScreen;
    if (isFullScreen.value) {
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
      !isFullScreen.value,
      playerInstance,
    );
  }
}

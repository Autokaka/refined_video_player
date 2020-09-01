part of refined_video_player;

class _Position {
  double x = 0;
  double y = 0;

  _Position(this.x, this.y);

  static _Position zero = _Position(0, 0);
}

class RefinedVideoPlayer extends StatefulWidget {
  final RVPController controller;
  final Widget Function() leftAreaBuilder;
  final Widget Function() topAreaBuilder;
  final Widget Function() rightAreaBuilder;
  final Widget Function() bottomAreaBuilder;
  final Widget Function() centerAreaBuilder;

  final void Function(double newVolume) onGestureChangingVolume;
  final void Function(double newBrightness) onGestureChangingBrightness;
  final void Function(Duration newPosition) onGestureChangingPosition;
  final void Function() onGestureDoubleTap;
  final void Function() onGestureTap;

  RefinedVideoPlayer({
    Key key,
    @required this.controller,
    this.leftAreaBuilder,
    this.topAreaBuilder,
    this.rightAreaBuilder,
    this.bottomAreaBuilder,
    this.centerAreaBuilder,
    this.onGestureChangingVolume,
    this.onGestureChangingBrightness,
    this.onGestureChangingPosition,
    this.onGestureTap,
    this.onGestureDoubleTap,
  }) : super(key: key);

  @override
  _RefinedVideoPlayerState createState() => _RefinedVideoPlayerState();
}

class _RefinedVideoPlayerState extends State<RefinedVideoPlayer>
    with WidgetsBindingObserver {
  bool showBottomArea = true;
  bool showRightArea = false;
  String showCenterArea = "loading";

  _Position startPosition = _Position.zero;
  _Position endPosition = _Position.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.keepScreenOn(true);
    widget.controller.addListener(() {
      switch (widget.controller.state.value) {
        case RVPState.BUFFERING:
          if (mounted && showCenterArea != "loading") {
            setState(() {
              showCenterArea = "loading";
            });
          }
          break;
        case RVPState.PLAYING:
          if (mounted && showCenterArea != null) {
            setState(() {
              showCenterArea = null;
            });
          }
          break;
        default:
      }
    });
  }

  @override
  void dispose() {
    widget.controller.keepScreenOn(false);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!widget.controller.autoManageAppLifecycle) return;
    switch (state) {
      case AppLifecycleState.resumed:
        widget.controller.play();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        widget.controller.pause();
        break;
      case AppLifecycleState.detached:
        widget.controller.stop();
        break;
      default:
    }
  }

  bool gestureInvalid(_Position centerPosition) {
    return (startPosition.x < 40 ||
        startPosition.x > centerPosition.x * 2 - 40 ||
        startPosition.y < 40 ||
        startPosition.y > centerPosition.y * 2 - 40);
  }

  String dur2Str(Duration duration) {
    duration = Duration(
      milliseconds: max(
        Duration.zero.inMilliseconds,
        duration.inMilliseconds,
      ),
    );
    duration = Duration(
      milliseconds: min(
        widget.controller.duration.value.inMilliseconds - 1,
        duration.inMilliseconds,
      ),
    );
    String durStrRaw = duration.toString();
    int dotPos = durStrRaw.indexOf(".");
    if (dotPos == -1) dotPos = durStrRaw.length;
    durStrRaw = durStrRaw.substring(0, dotPos);
    return durStrRaw;
  }

  void manageVerticalGesture(
    _Position startPosition,
    _Position endPosition, [
    bool syncInitial = false,
  ]) {
    _Position centerPosition = _Position(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height / 2,
    );
    if (gestureInvalid(centerPosition)) return;
    String newShowCenterArea;
    if (startPosition.x < centerPosition.x) {
      // brightness
      newShowCenterArea = "brightness";
      double currentBrightness = widget.controller.initialBrightness.value;
      double brightnessChange = (startPosition.y - endPosition.y) /
          MediaQuery.of(context).size.height;
      if (widget.onGestureChangingBrightness != null) {
        widget
            .onGestureChangingBrightness(currentBrightness + brightnessChange);
      } else {
        widget.controller.setBrightness(
          currentBrightness + brightnessChange,
          syncInitial,
        );
      }
    } else {
      // volume
      newShowCenterArea = "volume";
      double currentVolume = widget.controller.initialVolume.value;
      double volumeChange = (startPosition.y - endPosition.y) /
          MediaQuery.of(context).size.height;
      if (widget.onGestureChangingVolume != null) {
        widget.onGestureChangingVolume(currentVolume + volumeChange);
      } else {
        widget.controller.setVolume(
          currentVolume + volumeChange,
          syncInitial,
        );
      }
    }

    if (syncInitial) {
      setState(() => showCenterArea = null);
      return;
    }
    if (newShowCenterArea != showCenterArea) {
      setState(() => showCenterArea = newShowCenterArea);
    }
  }

  void manageHorizontalGesture(
    _Position startPosition,
    _Position endPosition, [
    bool syncInitial = false,
  ]) {
    _Position centerPosition = _Position(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height / 2,
    );
    if (gestureInvalid(centerPosition)) return;
    if (showCenterArea != "progress") {
      setState(() => showCenterArea = "progress");
    }

    int currentMilliSec =
        widget.controller.initialPosition.value.inMilliseconds;
    double positionMilliSecChange = (endPosition.x - startPosition.x) /
        MediaQuery.of(context).size.width *
        widget.controller.duration.value.inMilliseconds;
    int newMilliSec = (currentMilliSec + positionMilliSecChange).toInt();
    newMilliSec = max(0, newMilliSec);
    newMilliSec = min(
      widget.controller.duration.value.inMilliseconds - 1500,
      newMilliSec,
    );
    Duration newPosition = Duration(
      milliseconds: newMilliSec,
    );

    if (widget.onGestureChangingPosition != null) {
      widget.onGestureChangingPosition(newPosition);
    } else if (syncInitial) {
      Future.wait([
        widget.controller.seekTo(newPosition, syncInitial),
        widget.controller.play(),
      ]);
    } else {
      widget.controller.position.value = newPosition;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: GestureDetector(
          child: Stack(
            children: [
              Hero(
                tag: RVPController.pluginBase,
                child: _VideoView(controller: widget.controller),
              ),
              Positioned(
                left: 0,
                child: buildLeftArea(),
              ),
              Positioned(
                top: 0,
                child: buildTopArea(),
              ),
              Positioned(
                right: 0,
                child: buildRightArea(),
              ),
              Positioned(
                bottom: 0,
                child: buildBottomArea(),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: buildCenterArea(),
                ),
              ),
            ],
          ),
          onTap: () {
            manageAreas();
            if (widget.onGestureTap != null) {
              return widget.onGestureTap();
            }
          },
          onDoubleTap: () {
            if (widget.onGestureDoubleTap != null) {
              return widget.onGestureDoubleTap();
            }
            widget.controller.togglePlay();
          },
          onVerticalDragStart: (details) {
            startPosition = _Position(
              details.localPosition.dx,
              details.localPosition.dy,
            );
          },
          onVerticalDragUpdate: (details) {
            endPosition = _Position(
              details.localPosition.dx,
              details.localPosition.dy,
            );
            manageVerticalGesture(startPosition, endPosition);
          },
          onVerticalDragEnd: (_) {
            manageVerticalGesture(
              startPosition,
              endPosition,
              true,
            );
          },
          onHorizontalDragStart: (details) {
            widget.controller.pause();
            startPosition = _Position(
              details.localPosition.dx,
              details.localPosition.dy,
            );
          },
          onHorizontalDragUpdate: (details) {
            endPosition = _Position(
              details.localPosition.dx,
              details.localPosition.dy,
            );
            manageHorizontalGesture(startPosition, endPosition);
          },
          onHorizontalDragEnd: (_) {
            manageHorizontalGesture(
              startPosition,
              endPosition,
              true,
            );
          },
        ),
      ),
      onWillPop: () async {
        if (widget.controller.isFullScreen.value) {
          widget.controller.toggleFullScreen(widget);
        }
        return true;
      },
    );
  }

  void manageAreas() {
    if (showRightArea) {
      setState(() => showRightArea = !showRightArea);
      return;
    }
    setState(() => showBottomArea = !showBottomArea);
  }

  Widget buildLeftArea() {
    if (widget.leftAreaBuilder != null) {
      return widget.rightAreaBuilder();
    }
    return Container();
  }

  Widget buildTopArea() {
    if (widget.topAreaBuilder != null) {
      return widget.topAreaBuilder();
    }
    return Container();
  }

  Widget buildRightArea() {
    if (widget.rightAreaBuilder != null) {
      return widget.rightAreaBuilder();
    }
    if (!showRightArea) return Container();

    return Container(
      width: 150,
      height: MediaQuery.of(context).size.height,
      color: Colors.black.withOpacity(0.7),
      padding: EdgeInsets.fromLTRB(45, 45, 0, 85),
      child: ValueListenableBuilder<double>(
        valueListenable: widget.controller.speed,
        builder: (context, speed, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                child: Text(
                  "X2.0",
                  style: TextStyle(
                    color: speed == 2.0 ? Colors.blue : Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => widget.controller.setSpeed(2.0),
              ),
              GestureDetector(
                child: Text(
                  "X1.75",
                  style: TextStyle(
                    color: speed == 1.75 ? Colors.blue : Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => widget.controller.setSpeed(1.75),
              ),
              GestureDetector(
                child: Text(
                  "X1.5",
                  style: TextStyle(
                    color: speed == 1.5 ? Colors.blue : Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => widget.controller.setSpeed(1.5),
              ),
              GestureDetector(
                child: Text(
                  "X1.25",
                  style: TextStyle(
                    color: speed == 1.25 ? Colors.blue : Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => widget.controller.setSpeed(1.25),
              ),
              GestureDetector(
                child: Text(
                  "原速",
                  style: TextStyle(
                    color: speed == 1.0 ? Colors.blue : Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => widget.controller.setSpeed(1.0),
              ),
              GestureDetector(
                child: Text(
                  "X0.5",
                  style: TextStyle(
                    color: speed == 0.5 ? Colors.blue : Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => widget.controller.setSpeed(0.5),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildBottomArea() {
    if (widget.bottomAreaBuilder != null) {
      return widget.bottomAreaBuilder();
    }
    if (!showBottomArea) return Container();

    Widget buildPlayPauseButton() {
      return ValueListenableBuilder<RVPState>(
        valueListenable: widget.controller.state,
        builder: (context, state, child) {
          IconData iconData;
          Future<void> Function() onPressed;
          switch (state) {
            case RVPState.PLAYING:
              iconData = Icons.pause;
              onPressed = widget.controller.pause;
              break;
            case RVPState.PAUSED:
            case RVPState.STOPPED:
              iconData = Icons.play_arrow;
              onPressed = widget.controller.play;
              break;
            case RVPState.BUFFERING:
              iconData = Icons.arrow_circle_down_outlined;
              onPressed = () async {};
              break;
            default:
          }
          return IconButton(
            icon: Icon(
              iconData,
              color: Colors.white,
            ),
            onPressed: onPressed,
          );
        },
      );
    }

    Widget buildProgressBar(bool isFullScreen) {
      Widget childWidget = ValueListenableBuilder<RVPState>(
        valueListenable: widget.controller.state,
        builder: (context, state, child) {
          return ValueListenableBuilder<Duration>(
            valueListenable: widget.controller.position,
            builder: (context, position, child) {
              if (state == RVPState.BUFFERING ||
                  widget.controller.duration.value == Duration.zero) {
                return Offstage(
                  offstage: isFullScreen,
                  child: Center(
                    child: Text(
                      "Loading... =ω=",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }
              return SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white24,
                  thumbColor: Colors.white,
                  // thumbShape: RoundSliderThumbShape(
                  //   enabledThumbRadius: 6,
                  //   pressedElevation: 10,
                  // ),
                  valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                  trackHeight: isFullScreen ? 2 : 8,
                ),
                child: Slider(
                  max: widget.controller.duration.value.inMilliseconds
                      .toDouble(),
                  value: position.inMilliseconds.toDouble(),
                  label: dur2Str(position),
                  divisions: widget.controller.duration.value.inMilliseconds,
                  onChangeStart: (startValue) {
                    widget.controller.pause();
                  },
                  onChanged: (newValue) {
                    widget.controller.position.value = Duration(
                      milliseconds: newValue.toInt(),
                    );
                  },
                  onChangeEnd: (newValue) {
                    setState(() {
                      widget.controller.position.value = Duration(
                        milliseconds: newValue.toInt(),
                      );
                    });

                    Future.wait([
                      widget.controller.seekTo(
                        Duration(milliseconds: newValue.toInt()),
                      ),
                      widget.controller.play(),
                    ]);
                  },
                ),
              );
            },
          );
        },
      );
      if (isFullScreen) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 10,
          child: childWidget,
        );
      }
      return Expanded(child: childWidget);
    }

    Widget buildProgressLabel(bool isFullScreen) {
      return ValueListenableBuilder<Duration>(
        valueListenable: widget.controller.position,
        builder: (context, position, child) {
          return ValueListenableBuilder<RVPState>(
            valueListenable: widget.controller.state,
            builder: (context, state, child) {
              return FlatButton(
                child: Text(
                  isFullScreen && state == RVPState.BUFFERING
                      ? "Loading... =ω="
                      : "${dur2Str(position)}/"
                          "${dur2Str(widget.controller.duration.value)}",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onPressed: () {},
              );
            },
          );
        },
      );
    }

    Widget buildSpeedButton(bool isFullScreen) {
      if (!isFullScreen) return Container();
      return FlatButton(
        padding: EdgeInsets.zero,
        child: Text(
          "倍速",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        onPressed: () => setState(() => showRightArea = !showRightArea),
      );
    }

    Widget buildDivider(bool isFullScreen) {
      if (isFullScreen) {
        return Expanded(
          child: Container(),
        );
      }
      return Container();
    }

    Widget buildScreenButton() {
      return ValueListenableBuilder<bool>(
        valueListenable: widget.controller.isFullScreen,
        builder: (context, isFullScreen, child) {
          return IconButton(
            icon: Icon(
              isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
              color: Colors.white,
            ),
            onPressed: () => widget.controller.toggleFullScreen(widget),
          );
        },
      );
    }

    return ValueListenableBuilder<bool>(
      valueListenable: widget.controller.isFullScreen,
      builder: (context, isFullScreen, child) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: isFullScreen ? 80 : 70,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              isFullScreen ? buildProgressBar(isFullScreen) : Container(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildPlayPauseButton(),
                  isFullScreen ? Container() : buildProgressBar(isFullScreen),
                  buildProgressLabel(isFullScreen),
                  buildDivider(isFullScreen),
                  buildSpeedButton(isFullScreen),
                  buildScreenButton(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildCenterArea() {
    if (widget.centerAreaBuilder != null) {
      return widget.centerAreaBuilder();
    }
    Widget buildLoadingPanel() {
      return Container(
        height: 80,
        width: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SizedBox(
          height: 40,
          width: 40,
          child: CircularProgressIndicator(
            strokeWidth: 5,
            valueColor: AlwaysStoppedAnimation(
              Colors.white,
            ),
          ),
        ),
      );
    }

    Widget buildIndicator(String title, double value) {
      int percent = (double.tryParse(value.toStringAsFixed(2)) * 100).toInt();
      return Container(
        height: 80,
        width: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  child: Text(
                    "$percent%",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                  width: 40,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 5,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation(
                      Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 5),
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget buildBrightnessIndicator() {
      return ValueListenableBuilder<double>(
        valueListenable: widget.controller.brightness,
        builder: (context, brightness, child) {
          return buildIndicator("亮度", brightness);
        },
      );
    }

    Widget buildVolumeIndicator() {
      return ValueListenableBuilder<double>(
        valueListenable: widget.controller.volume,
        builder: (context, volume, child) {
          return buildIndicator("音量", volume);
        },
      );
    }

    Widget buildProgressIndicator() {
      return Container(
        height: 60,
        width: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ValueListenableBuilder<Duration>(
          valueListenable: widget.controller.position,
          builder: (context, position, child) {
            return Text(
              "${dur2Str(position)}/${dur2Str(widget.controller.duration.value)}",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
      );
    }

    switch (showCenterArea) {
      case "loading":
        return buildLoadingPanel();
        break;
      case "brightness":
        return buildBrightnessIndicator();
        break;
      case "volume":
        return buildVolumeIndicator();
        break;
      case "progress":
        return buildProgressIndicator();
        break;
      default:
        return Container();
    }
  }
}

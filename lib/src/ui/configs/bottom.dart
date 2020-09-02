part of refined_video_player;

class BottomAreaConfigs {
  final double height;
  final Decoration decoration;

  final Icon playIcon;
  final Icon pauseIcon;
  final Icon loadingIcon;

  final String loadingText;
  final Widget loadingWidget;

  final SliderThemeData sliderThemeData;
  final Slider sliderWidget;

  final String speedText;
  final TextStyle speedTextStyle;

  final Icon fullScreenIcon;
  final Icon exitFullScreenIcon;

  const BottomAreaConfigs({
    this.height,
    this.decoration = const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          RVPDefaultModifierConfigs.backgroundColor,
        ],
      ),
    ),
    this.playIcon = const Icon(
      Icons.play_arrow,
      color: Colors.white,
    ),
    this.pauseIcon = const Icon(
      Icons.pause,
      color: Colors.white,
    ),
    this.loadingIcon = const Icon(
      Icons.arrow_circle_down_outlined,
      color: Colors.white,
    ),
    this.loadingText = "Loading... =ω=",
    this.loadingWidget,
    this.sliderThemeData,
    this.sliderWidget,
    this.speedText = "倍速",
    this.speedTextStyle = RVPDefaultModifierConfigs.unSelectedTextStyle,
    this.fullScreenIcon = const Icon(
      Icons.fullscreen,
      color: Colors.white,
    ),
    this.exitFullScreenIcon = const Icon(
      Icons.fullscreen_exit,
      color: Colors.white,
    ),
  });
}

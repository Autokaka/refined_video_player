part of refined_video_player;

class CenterAreaConfigs {
  final Decoration loadingDecoration;
  final Widget loadingIndicatorWidget;

  final Decoration indicatorDecoration;
  final Widget Function(double progress) indicatorBuilder;

  final TextStyle percentTextStyle;
  final TextStyle titleTextStyle;

  final Decoration videoProgressDecoration;
  final TextStyle videoProgressTextStyle;

  const CenterAreaConfigs({
    this.loadingDecoration,
    this.loadingIndicatorWidget,
    this.indicatorDecoration,
    this.indicatorBuilder,
    this.percentTextStyle = RVPDefaultModifierConfigs.unSelectedTextStyle,
    this.titleTextStyle = RVPDefaultModifierConfigs.unSelectedTextStyle,
    this.videoProgressDecoration,
    this.videoProgressTextStyle = RVPDefaultModifierConfigs.unSelectedTextStyle,
  });
}

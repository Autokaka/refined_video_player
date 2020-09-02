part of refined_video_player;

class RightAreaConfigs {
  final double width;
  final double height;

  final Color primaryColor;
  final Color backgroundColor;
  final TextStyle selectedTextStyle;
  final TextStyle unSelectedTextStyle;
  final List<double> speedList;

  const RightAreaConfigs({
    this.width = 150,
    this.height,
    this.primaryColor = RVPDefaultModifierConfigs.primaryColor,
    this.backgroundColor,
    this.selectedTextStyle = RVPDefaultModifierConfigs.selectedTextStyle,
    this.unSelectedTextStyle = RVPDefaultModifierConfigs.unSelectedTextStyle,
    this.speedList = const [2.0, 1.75, 1.5, 1.25, 1, 0.5],
  });
}

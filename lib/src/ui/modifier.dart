part of refined_video_player;

class RVPUIModifier {
  final BottomAreaConfigs bottom;
  final CenterAreaConfigs center;
  final LeftAreaConfigs left;
  final RightAreaConfigs right;
  final TopAreaConfigs top;

  const RVPUIModifier({
    this.bottom = const BottomAreaConfigs(),
    this.center = const CenterAreaConfigs(),
    this.left = const LeftAreaConfigs(),
    this.right = const RightAreaConfigs(),
    this.top = const TopAreaConfigs(),
  });
}

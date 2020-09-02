part of refined_video_player;

class RVPUIBuilder {
  final Widget Function() leftAreaBuilder;
  final Widget Function() topAreaBuilder;
  final Widget Function() rightAreaBuilder;
  final Widget Function() bottomAreaBuilder;
  final Widget Function() centerAreaBuilder;

  const RVPUIBuilder({
    this.leftAreaBuilder,
    this.topAreaBuilder,
    this.rightAreaBuilder,
    this.bottomAreaBuilder,
    this.centerAreaBuilder,
  });
}

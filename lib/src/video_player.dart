part of refined_video_player;

class RefinedVideoPlayer extends StatefulWidget {
  final RVController controller;

  RefinedVideoPlayer({
    Key key,
    @required this.controller,
  }) : super(key: key);

  @override
  _RefinedVideoPlayerState createState() => _RefinedVideoPlayerState();
}

class _RefinedVideoPlayerState extends State<RefinedVideoPlayer> {
  RVController controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body: Hero(
          tag: RVController.pluginBase,
          child: _VideoView(controller: controller),
        ),
      ),
      onWillPop: () async {
        if (controller.isFullScreen) {
          controller.toggleFullScreen();
          AutoOrientation.portraitUpMode();
        }
        return true;
      },
    );
  }
}

part of refined_video_player;

class _VideoView extends StatefulWidget {
  final RVPController controller;

  _VideoView({
    Key key,
    @required this.controller,
  }) : super(key: key);

  @override
  _VideoViewState createState() => _VideoViewState();
}

class _VideoViewState extends State<_VideoView> {
  MethodChannel methodChannel;
  RVPController controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    controller._context = context;
    return ValueListenableBuilder<Size>(
      valueListenable: controller.size,
      builder: (context, size, child) {
        return Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: AspectRatio(
            aspectRatio: size.aspectRatio,
            child: buildPlatformView(),
          ),
        );
      },
    );
  }

  Widget buildPlatformView() {
    if (Platform.isAndroid) {
      return AndroidView(
        viewType: "${RVPController.pluginBase}/view",
        onPlatformViewCreated: controller._initPlayer,
      );
    }
    if (Platform.isIOS) {
      return UiKitView(
        viewType: "${RVPController.pluginBase}/view",
        onPlatformViewCreated: controller._initPlayer,
      );
    }
    return Center(
      child: Text("Platform not supported"),
    );
  }
}

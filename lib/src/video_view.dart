part of refined_video_player;

class _VideoView extends StatefulWidget {
  final RVController controller;

  _VideoView({
    Key key,
    @required this.controller,
  }) : super(key: key);

  @override
  _VideoViewState createState() => _VideoViewState();
}

class _VideoViewState extends State<_VideoView> {
  MethodChannel methodChannel;
  RVController controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    controller.registerContext = context;
    if (Platform.isAndroid) {
      return AndroidView(
        viewType: "${RVController.pluginBase}/view",
        onPlatformViewCreated: controller._initPlayer,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    if (Platform.isIOS) {
      return UiKitView(
        viewType: "${RVController.pluginBase}/view",
        onPlatformViewCreated: controller._initPlayer,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return Center(
      child: Text("Platform not supported"),
    );
  }
}

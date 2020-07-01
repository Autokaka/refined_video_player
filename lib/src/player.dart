import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:refined_video_player/refined_video_player.dart';

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
  MethodChannel methodChannel;
  RVController controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return AndroidView(
        viewType: "${RVController.pluginBase}/view",
        onPlatformViewCreated: controller.initPlayer,
      );
    }
    if (Platform.isIOS) {
      return UiKitView(
        viewType: "${RVController.pluginBase}/view",
        onPlatformViewCreated: controller.initPlayer,
      );
    }
    return Center(
      child: Text("Platform not supported"),
    );
  }
}

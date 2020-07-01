import 'package:flutter/material.dart';
import 'package:refined_video_player/refined_video_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  RVController playerCtrl;

  @override
  void initState() {
    super.initState();
    playerCtrl = RVController(
      "https://www.runoob.com/try/demo_source/movie.mp4",
      onInit: () {
        playerCtrl.play();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("VideoPlayerTest"),
        ),
        body: RefinedVideoPlayer(
          controller: playerCtrl,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            playerCtrl.toggleFullScreen();
          },
        ),
      ),
    );
  }
}

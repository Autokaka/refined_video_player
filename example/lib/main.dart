import 'package:flutter/material.dart';
import 'package:refined_video_player/refined_video_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FirstPage(),
    );
  }
}

class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("VideoPlayerTest"),
      ),
      body: Center(
        child: FlatButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPage(),
            ),
          ),
          child: Text("Launch VideoPage"),
        ),
      ),
    );
  }
}

class VideoPage extends StatefulWidget {
  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  RVPController controller;

  @override
  void initState() {
    super.initState();
    controller = RVPController(
      "https://res.exexm.com/cw_145225549855002",
      onInited: () {
        controller.play();
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("VideoPage"),
      ),
      body: RefinedVideoPlayer(
        controller: controller,
      ),
    );
  }
}

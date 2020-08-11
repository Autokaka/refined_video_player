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
  String url =
      "https://cdn.jsdelivr.net/gh/myxuwei123/lucky/movie/jingjuegucheng_01.m3u8";

  @override
  void initState() {
    super.initState();
    controller = RVPController(url, onInited: () {
      controller.play();
    });
    Future.delayed(Duration(seconds: 10), () {
      setState(() {
        url = "https://yun.zxziyuan-yun.com/20180221/4C6ivf8O/index.m3u8";
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (url != controller.url) {
      controller.setMediaSource(url);
    }
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

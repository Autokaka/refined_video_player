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
              builder: (context) => SecondPage(),
            ),
          ),
          child: Text("Launch SecondPage"),
        ),
      ),
    );
  }
}

class SecondPage extends StatefulWidget {
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  RVPController playerCtrl;

  @override
  void initState() {
    super.initState();
    playerCtrl = RVPController(
      "https://res.exexm.com/cw_145225549855002",
      onInited: () {
        playerCtrl.play();
      },
    );
  }

  @override
  void dispose() {
    playerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SecondPage"),
      ),
      body: RefinedVideoPlayer(
        controller: playerCtrl,
      ),
    );
  }
}

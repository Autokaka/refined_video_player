# refined_video_player

A better, highly customizable, user-friendly video player using PlatformView + SurfaceView on Android to fix https://github.com/flutter/flutter/issues/44793. IOS not implemented yet.

## Documentation

[中文文档](README_zh-CN.md)

## Why create this package?

If you don’t care about the picture quality of a video, you may never want to use refined_video_player. I believe some developers have just found that:

When playing videos, there exists sharp sawtooth that can be recognized just using our eyes. I tried about 6 kinds of video player packages using native TextureView (from external texture method), including video_player, fijkplayer, flutter_ijk_player, ijk_player, awsome_video_player(based on video_player) and chewie(based on video_player) to support video rendering and finally found that the problems are the same.

In order to offer the best experience of an application for its users, we need to solve this severe problem. Texture and PlatformView are the same in some degrees, but both of them have their own issues. Since I'm not an expert in Flutter developing, I chose a PlatformView way without considering other performance drawbacks. I just want to fix this annoying problem.

## How to use it?

For simple use, just code like this:

```dart
class _MyAppState extends State<MyApp> {
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
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("VideoPlayerTest"),
        ),
        body: RefinedVideoPlayer(
          controller: playerCtrl,
        ),
      ),
    );
  }
}
```

For more detailed usage, please refer to the source code. You will see all detailed explanation of the parameters. Talk is too cheap. :P

## What’s more

1. This package is still under development, most of its functions are not well tested, and Most of its methods are not implemented. I’m still working on my way.
2. I haven't learnt Swift for iOS development, so it might be a long time before I manage to support iOS platform by myself.
3. Please help me and give me a PR if you have any improvement of this package, thank you very much! :)

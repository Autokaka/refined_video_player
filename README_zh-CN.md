# refined_video_player

一个高度自定义的, 用户友好型视频播放器. 安卓那边用的是exoplayer, 使用PlatformView返回SurfaceView来解决外接纹理锯齿问题. https://github.com/flutter/flutter/issues/44793

## 文档

[English Doc](README.md)

## 这个插件有意义吗?

如果你的业务不涉及到播放高画质视频的话, 你也许永远也不想用refined_video_player, 毕竟它的作者看起来就很菜, 代码写得跟屎一样, iOS的版本都还没实现, 就敢把源码给它开了, 丢人现眼... 嘛嘛, 言归正传, 不知道诸位开发者们做视频播放的时候有无遇到如下情况呢?

放高品质视频的时候, 使用现有仓库的里的插件, 不管用哪个(refined_video_player和flutter_vlc_player除外 :P), 你都可以顺利的在图像上用眼感受到"什么叫做锯齿啊.jpg"的真实, 不信? 您赶紧去瞅瞅, 特别是iOS那边, 好好的一2K视频, 字幕完全就是虚的, 看电影跟玩Minecraft一样. 别测试了, 我测试过了, 当初开了六个分支写了六遍: video_player, fijkplayer, flutter_ijk_player, ijk_player, awsome_video_player, chewie... 

请原作者们不要喷我, 这个不是大伙的问题, 是因为Flutter那边的外接纹理方案很有可能没有开抗锯齿造成的. 从现象看本质, 根据issue44793和网上众多咸鱼技术科普贴, Android docs的TextureView和SurfaceView的注意事项里, 以及Flutter docs中, 我逐渐了解到Texture和PlatformView密不可分却又显著区别的地方, 在此还是不献丑哔哔赖赖的了, 直接给上结论, 请各位高手根据我上述提供的参考思路自己印证印证... 方法很简单, 但我只会安卓这边的. 使用PlatformView, 将返回的View由原本Flutter那边SurfaceTextureEntry构建的TextureView换成在这个问题场景下效果更好的SurfaceView, 问题解决, 洗洗睡吧~

## 效果怎样呢?

<video src="./doc/simple_player_demo.mp4" height="400" width="800"></video>

## 给爷"有手就行”的用法

简单的用法在下面:
```dart
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
```

更复杂的用法呢? 看源码吧... 其实你自己用一下RVPController立马就会玩了, 有手就行.

## 更高级的用法

RefinedVideoPlayer的属性请参考:

![AFA95D4CF28E3B41A82C55979BDDE003](doc/AFA95D4CF28E3B41A82C55979BDDE003.png)

RefinedVideoPlayer自带一套默认的UI, 就是视频里面展示的那套. 如果你需要重写任何一个布局, 你只需要重写对应位置的AreaBuilder即可. 下面的代码是一个实现了顶部标题栏的视频播放器案例, 在这套代码里:

1. 我设置了topAreaBuilder, 为播放器添加了一个标题栏
2. 我在didUpdateWidget内实现了自定义的hot reload方法, 使视频播放源改变时, 播放器能通过setState自动重新设置视频播放器的播放内容以及开始时间

实现效果如下:

<video src="./doc/diy_player_demo.mp4" height="400" width="800"></video>

核心实现代码:

```dart
import 'package:flutter/material.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:online_mobile/solos/video.dart';
import 'package:refined_video_player/refined_video_player.dart';

class VideoPlayer extends StatefulWidget {
  final Record record;

  VideoPlayer({
    Key key,
    @required this.record,
  }) : super(key: key);

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  final videoAPI = VideoAPI.instance;
  RVPController controller;
  RefinedVideoPlayer playerInstance;
  bool showTopArea = true;

  @override
  void initState() {
    super.initState();
    controller = RVPController(
      widget.record.link.url,
      onInited: () {
        Future.wait([
          controller.seekTo(
            Duration(
              milliseconds: double.parse(widget.record.time).toInt(),
            ),
            true,
          ),
        ]);
      },
      onPaused: () => videoAPI.modifyRecord(
        widget.record,
      ),
      onTimeChanged: () => widget.record.time =
          controller.position.value.inMilliseconds.toString(),
    );
  }

  @override
  void didUpdateWidget(VideoPlayer oldWidget) {
    if (widget.record.link.url == controller.url) {
      super.didUpdateWidget(oldWidget);
    } else {
      Future.wait([
        controller.setMediaSource(widget.record.link.url),
        controller.seekTo(
          Duration(
            milliseconds: double.parse(widget.record.time).toInt(),
          ),
          true,
        ),
      ]).then(
        (value) => super.didUpdateWidget(oldWidget),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    playerInstance = RefinedVideoPlayer(
      controller: controller,
      topAreaBuilder: buildTopArea,
      onGestureTap: () => setState(
        () => showTopArea = !showTopArea,
      ),
    );
    return playerInstance;
  }

  Widget buildTopArea() {
    String videoName = widget.record.video.name.trim();
    String linkName = widget.record.link.name.trim();
    if (videoName != linkName) {
      videoName += "\t$linkName";
    }
    return Visibility(
      visible: showTopArea,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onPressed: () {
                if (controller.isFullScreen.value) {
                  controller.toggleFullScreen(playerInstance);
                  return;
                }
                Navigator.of(context).pop();
              },
            ),
            Marquee(
              child: Text(
                videoName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    videoAPI.modifyRecord(widget.record);
    super.dispose();
  }
}
```

## 我还想说啥?

1. 这个插件仍处于并将长期处于初级阶段, 大伙所说的breaking change每天都在发生. 我只是个初学者, 太菜了, 还在慢慢爬.
2. 没学过objc和swift, 在学了, 进度0%, 等我学完了就把iOS的版本给搞上. 但是如果有人能帮我搞, 那必然是绝好的. 有大哥能帮帮我嘛? TwT
3. 有任何问题咱们Issue里面见. 如果有开Q群的必要, 请跟我说. 有任何改进性方案请直接来个PR, 秋梨膏.

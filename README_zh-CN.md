# refined_video_player

一个高度自定义的, 用户友好型视频播放器. 安卓那边用的是exoplayer, 使用PlatformView返回SurfaceView来解决外接纹理锯齿问题. https://github.com/flutter/flutter/issues/44793

## 文档

[English Doc](README.md)

## 这个插件有意义吗?

如果你的业务不涉及到播放高画质视频的话, 你也许永远也不想用refined_video_player, 毕竟它的作者看起来就很菜, 代码写得跟屎一样, iOS的版本都还没实现, 就敢把源码给它开了, 丢人现眼... 嘛嘛, 言归正传, 不知道诸位开发者们做视频播放的时候有无遇到如下情况呢?

放高品质视频的时候, 使用现有仓库的里的插件, 不管用哪个(refined_video_player和flutter_vlc_player除外 :P), 你都可以顺利的在图像上用眼感受到"什么叫做锯齿啊.jpg"的真实, 不信? 您赶紧去瞅瞅, 特别是iOS那边, 好好的一2K视频, 字幕完全就是虚的, 看电影跟玩Minecraft一样. 别测试了, 我测试过了, 当初开了六个分支写了六遍: video_player, fijkplayer, flutter_ijk_player, ijk_player, awsome_video_player, chewie... 

请原作者们不要喷我, 这个不是大伙的问题, 是因为Flutter那边的外接纹理方案很有可能没有开抗锯齿造成的. 从现象看本质, 根据issue44793和网上众多咸鱼技术科普贴, Android docs的TextureView和SurfaceView的注意事项里, 以及Flutter docs中, 我逐渐了解到Texture和PlatformView密不可分却又显著区别的地方, 在此还是不献丑哔哔赖赖的了, 直接给上结论, 请各位高手根据我上述提供的参考思路自己印证印证... 方法很简单, 但我只会安卓这边的. 使用PlatformView, 将返回的View由原本Flutter那边SurfaceTextureEntry构建的TextureView换成在这个问题场景下效果更好的SurfaceView, 问题解决, 洗洗睡吧~

## 你这东西怎么用啊?

简单的用法在下面:
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

更复杂的用法呢? 看源码吧... 其实你自己用一下RVPController立马就会玩了, 有手就行.

## 我还想说啥?

1. 这个插件仍处于并将长期处于初级阶段, 大伙所说的breaking change每天都在发生. 我只是个初学者, 太菜了, 还在慢慢爬.
2. 没学过objc和swift, 在学了, 进度0%, 等我学完了就把iOS的版本给搞上. 但是如果有人能帮我搞, 那必然是绝好的. 有大哥能帮帮我嘛? TwT
3. 有任何问题咱们Issue里面见. 如果有开Q群的必要, 请跟我说. 有任何改进性方案请直接来个PR, 秋梨膏.

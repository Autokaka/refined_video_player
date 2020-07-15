package cn.dshitpie.refined_video_player;

import androidx.annotation.NonNull;

import java.util.HashMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class RefinedVideoPlayerPlugin implements FlutterPlugin, MethodChannel.MethodCallHandler {
    private MethodChannel methodChannel;
    private PlayerViewFactory playerViewFactory;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        methodChannel = new MethodChannel(binding.getBinaryMessenger(), "refined_video_player/method");
        methodChannel.setMethodCallHandler(this);
        playerViewFactory = new PlayerViewFactory(binding);
        binding
                .getPlatformViewRegistry()
                .registerViewFactory(
                        "refined_video_player/view",
                        playerViewFactory
                );
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        methodChannel.setMethodCallHandler(null);
        methodChannel = null;
        playerViewFactory.disposeChannels();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        HashMap<String, Object> eventObject = new HashMap<>();
        switch (call.method) {
            case "setMediaSource":
                String url = (String) call.argument("url");
                playerViewFactory.setMediaSource(url);
                result.success(null);
                break;
            case "play":
                playerViewFactory.playVideo();
                result.success(null);
                break;
            case "pause":
                playerViewFactory.pauseVideo();
                result.success(null);
                break;
            case "stop":
                playerViewFactory.stopVideo();
                result.success(null);
                break;
            case "seekTo":
                long time = Long.parseLong((String) call.argument("time"));
                playerViewFactory.videoSeekTo(time);
                result.success(null);
                break;
            case "setSpeed":
                float speed = Float.parseFloat((String) call.argument("speed"));
                playerViewFactory.setVideoSpeed(speed);
                result.success(null);
                break;
            case "dispose":
                playerViewFactory.disposePlayer();
                result.success(null);
                break;
        }
    }
}

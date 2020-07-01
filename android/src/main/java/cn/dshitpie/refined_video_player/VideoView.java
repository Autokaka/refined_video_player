package cn.dshitpie.refined_video_player;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;

import com.google.android.exoplayer2.ExoPlayer;
import com.google.android.exoplayer2.ExoPlayerFactory;
import com.google.android.exoplayer2.SimpleExoPlayer;
import com.google.android.exoplayer2.ui.PlayerView;
import com.google.android.exoplayer2.ui.SimpleExoPlayerView;
import com.shuyu.gsyvideoplayer.GSYVideoManager;
import com.shuyu.gsyvideoplayer.builder.GSYVideoOptionBuilder;
import com.shuyu.gsyvideoplayer.listener.GSYSampleCallBack;
import com.shuyu.gsyvideoplayer.utils.OrientationUtils;
import com.shuyu.gsyvideoplayer.video.StandardGSYVideoPlayer;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.platform.PlatformView;

import static io.flutter.plugin.common.MethodChannel.MethodCallHandler;

public class VideoView implements PlatformView, MethodCallHandler {
    private final MethodChannel methodChannel;
    private final QueuingEventSink eventSink;
    private final EventChannel eventChannel;
    private final Registrar registrar;

    private final PlayerView videoView;

    VideoView(Context context, int id, Object args, Registrar registrar) {
        /**
         * Init channels
         * */
        eventSink = new QueuingEventSink();
        this.registrar = registrar;
        eventChannel = new EventChannel(registrar.messenger(), "refined_video_player/event_" + id);
        eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object o, EventChannel.EventSink sink) {
                eventSink.setDelegate(sink);
            }

            @Override
            public void onCancel(Object o) {
                eventSink.setDelegate(null);
            }
        });
        methodChannel = new MethodChannel(registrar.messenger(), "refined_video_player/method_" + id);
        methodChannel.setMethodCallHandler(this);
        /**
         * Init view
         */
        videoView = (PlayerView) LayoutInflater.from(registrar.activity()).inflate(R.layout.video_view, null);
    }

    @Override
    public View getView() {
        return videoView;
    }

    @Override
    public void dispose() {
    }

    /**
     * Init GSYPlayer
     */
    private void initPlayer(String url) {
        player = ExoPlayer.Builder();
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        switch (methodCall.method) {
            case "initialize":
                String url = methodCall.argument("url");
                initPlayer(url);
                result.success(null);
                break;
            case "play":
                result.success(null);
                break;
            case "pause":
                result.success(null);
                break;
            case "stop":
                result.success(null);
                break;
        }
    }


}
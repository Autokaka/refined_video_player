package cn.dshitpie.refined_video_player;

import android.content.Context;
import android.net.Uri;
import android.view.LayoutInflater;
import android.view.View;
import com.google.android.exoplayer2.ExoPlayer;
import com.google.android.exoplayer2.SimpleExoPlayer;
import com.google.android.exoplayer2.source.MediaSource;
import com.google.android.exoplayer2.source.ProgressiveMediaSource;
import com.google.android.exoplayer2.ui.PlayerView;
import com.google.android.exoplayer2.upstream.DataSource;
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory;
import com.google.android.exoplayer2.util.Util;


import io.flutter.Log;
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

    private final PlayerView videoView;
    private ExoPlayer videoPlayer;
    private Context context;

    VideoView(Context context, int id, Object args, Registrar registrar) {
        /**
         * Init channels
         * */
        eventSink = new QueuingEventSink();
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
        this.context = context;
        videoView = (PlayerView) LayoutInflater.from(registrar.activity()).inflate(R.layout.video_view, null);
    }

    @Override
    public View getView() {
        return videoView;
    }

    @Override
    public void dispose() {
        Log.i("FUCKKKKKKKKKKK", "RRRRRREEEEEEEELLLLLEEEEEAAAASSSSSEEEEEE");
//        videoPlayer.release();
    }

    /**
     * Init ExoPlayer
     */
    private void initPlayer(String url) {
        videoPlayer = new SimpleExoPlayer.Builder(context).build();
        DataSource.Factory dataSourceFactory = new DefaultDataSourceFactory(
                context,
                Util.getUserAgent(context, "RefinedVideoPlayer")
        );
        MediaSource videoSource = new ProgressiveMediaSource
                .Factory(dataSourceFactory)
                .createMediaSource(Uri.parse(url));
        videoPlayer.prepare(videoSource);
        videoView.setPlayer(videoPlayer);
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
                videoPlayer.setPlayWhenReady(true);
                result.success(null);
                break;
            case "pause":
                videoPlayer.setPlayWhenReady(false);
                result.success(null);
                break;
            case "stop":
                videoPlayer.stop();
                result.success(null);
                break;
        }
    }


}
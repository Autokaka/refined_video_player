package cn.dshitpie.refined_video_player;

import android.content.Context;
import android.graphics.SurfaceTexture;
import android.net.Uri;
import android.view.TextureView;
import android.view.ViewGroup;

import androidx.annotation.NonNull;

import com.google.android.exoplayer2.Player;
import com.google.android.exoplayer2.SimpleExoPlayer;
import com.google.android.exoplayer2.extractor.DefaultExtractorsFactory;
import com.google.android.exoplayer2.source.MediaSource;
import com.google.android.exoplayer2.source.ProgressiveMediaSource;
import com.google.android.exoplayer2.trackselection.DefaultTrackSelector;
import com.google.android.exoplayer2.trackselection.TrackSelector;
import com.google.android.exoplayer2.upstream.DataSource;
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory;
import com.google.android.exoplayer2.upstream.DefaultHttpDataSource;
import com.google.android.exoplayer2.upstream.DefaultHttpDataSourceFactory;

import java.util.HashMap;
import java.util.concurrent.atomic.AtomicInteger;

import io.flutter.Log;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import io.flutter.view.TextureRegistry;

public class VideoViewFactory extends PlatformViewFactory implements Player.EventListener, MethodChannel.MethodCallHandler {
    private final Registrar registrar;
    private final MethodChannel methodChannel;
    private final QueuingEventSink eventSink;
    private final EventChannel eventChannel;

    private TextureView textureView;
    private final SimpleExoPlayer exoPlayer;

    public VideoViewFactory(Registrar registrar) {
        /**
         * Init Channel
         */
        super(StandardMessageCodec.INSTANCE);
        this.registrar = registrar;
        eventSink = new QueuingEventSink();
        eventChannel = new EventChannel(registrar.messenger(), "refined_video_player/event");
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
        methodChannel = new MethodChannel(registrar.messenger(), "refined_video_player/method");
        methodChannel.setMethodCallHandler(this);

        /**
         * Init Player
         */
        final TrackSelector trackSelector = new DefaultTrackSelector(registrar.activity());
        exoPlayer = new SimpleExoPlayer.Builder(registrar.activity())
                .setTrackSelector(trackSelector)
                .build();
    }

    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        Log.i("RefinedVideoPlayer", "create: " + context.toString());
        final TextureRegistry.SurfaceTextureEntry textureEntry = registrar.textures().createSurfaceTexture();
        textureView = new TextureView(context);
        textureView.setSurfaceTexture(textureEntry.surfaceTexture());
        exoPlayer.setVideoTextureView(textureView);
        return new VideoView(textureView);
    }

    public void dispose() {
        Log.i("RefinedVideoPlayer", "disposeFactory");
        methodChannel.setMethodCallHandler(null);
        eventChannel.setStreamHandler(null);
        eventSink.endOfStream();

        exoPlayer.stop(true);
        exoPlayer.removeListener(this);
        exoPlayer.release();
    }

    private DataSource.Factory getDataSourceFactory(Uri uri) {
        String scheme = uri.getScheme();
        if (scheme != null &&
                (scheme.equals("http") ||
                        scheme.equals("https"))) {
            return new DefaultHttpDataSourceFactory(
                    "ExoPlayer",
                    null,
                    DefaultHttpDataSource.DEFAULT_CONNECT_TIMEOUT_MILLIS,
                    DefaultHttpDataSource.DEFAULT_READ_TIMEOUT_MILLIS,
                    true
            );
        }
        return new DefaultDataSourceFactory(
                registrar.activity(),
                "ExoPlayer"
        );
    }

    /**
     * Init ExoPlayer
     */
    private void initPlayer(String url) {
        Log.i("RefinedVideoPlayer", "initPlayer");
        try {
            exoPlayer.addListener(this);
            exoPlayer.setVideoTextureView(textureView);
        } catch (Exception e) {
            e.printStackTrace();
        }
        Uri uri = Uri.parse(url);
        DataSource.Factory dataSourceFactory = getDataSourceFactory(uri);
        MediaSource mediaSource = new ProgressiveMediaSource.Factory(
                dataSourceFactory,
                new DefaultExtractorsFactory()
        ).createMediaSource(uri);
        exoPlayer.prepare(mediaSource);
        exoPlayer.setPlayWhenReady(false);
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        HashMap<String, Object> eventObject = new HashMap<>();
        switch (methodCall.method) {
            case "initialize":
                String url = methodCall.argument("url");
                initPlayer(url);
//                Format videoFormat = exoPlayer.getVideoFormat();
//                eventObject.put("height", videoFormat.height);
//                eventObject.put("width", videoFormat.width);
//                eventObject.put("duration", exoPlayer.getDuration());
//                result.success(eventObject);
//                eventObject.clear();
                result.success(null);
                break;
            case "play":
                exoPlayer.setPlayWhenReady(true);
                result.success(null);
                break;
            case "pause":
                exoPlayer.setPlayWhenReady(false);
                result.success(null);
                break;
            case "stop":
                exoPlayer.stop(true);
                result.success(null);
                break;
        }
    }
}
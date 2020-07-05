package cn.dshitpie.refined_video_player;

import android.content.Context;
import android.net.Uri;
import android.view.TextureView;

import com.google.android.exoplayer2.Player;
import com.google.android.exoplayer2.SimpleExoPlayer;
import com.google.android.exoplayer2.analytics.AnalyticsListener;
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
import java.util.concurrent.TimeUnit;

import io.flutter.Log;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import io.flutter.view.TextureRegistry;
import io.reactivex.rxjava3.core.Observable;
import io.reactivex.rxjava3.functions.Consumer;
import io.reactivex.rxjava3.functions.Function;

public class VideoViewFactory extends PlatformViewFactory implements AnalyticsListener, MethodChannel.MethodCallHandler {
    private static final String TAG = "RefinedVideoPlayer -> VideoViewFactory";

    private final Registrar registrar;
    private final MethodChannel methodChannel;
    private final QueuingEventSink eventSink;
    private final EventChannel eventChannel;

    private TextureView textureView;
    private final SimpleExoPlayer exoPlayer;
    Observable<Long> position;

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
        exoPlayer.addAnalyticsListener(this);
    }

    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        final TextureRegistry.SurfaceTextureEntry textureEntry = registrar.textures().createSurfaceTexture();
        textureView = new TextureView(context);
        textureView.setSurfaceTexture(textureEntry.surfaceTexture());
        exoPlayer.setVideoTextureView(textureView);
        return new VideoView(textureView);
    }

    public void dispose() {
        methodChannel.setMethodCallHandler(null);
        eventChannel.setStreamHandler(null);
        eventSink.endOfStream();

        exoPlayer.stop(true);
        exoPlayer.removeAnalyticsListener(this);
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
        Uri uri = Uri.parse(url);
        DataSource.Factory dataSourceFactory = getDataSourceFactory(uri);
        MediaSource mediaSource = new ProgressiveMediaSource.Factory(
                dataSourceFactory,
                new DefaultExtractorsFactory()
        ).createMediaSource(uri);
        exoPlayer.prepare(mediaSource);
        exoPlayer.setPlayWhenReady(true);
        onPlayerTimeProcessing();
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        Log.i(TAG, "onMethodCall: " + methodCall.method);
        HashMap<String, Object> eventObject = new HashMap<>();
        switch (methodCall.method) {
            case "initialize":
                String url = methodCall.argument("url");
                initPlayer(url);
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

    public void onPlayerTimeProcessing() {
        final HashMap<String, Object> eventObject = new HashMap<>();
        position = Observable
                .interval(1, TimeUnit.SECONDS)
                .map(new Function<Long, Long>() {
                    @Override
                    public Long apply(Long aLong) {
                        return exoPlayer.getCurrentPosition();
                    }
                });
        position.subscribe(new Consumer<Long>() {
            @Override
            public void accept(Long aLong) {
                Log.i(TAG, "timeChanged: " + aLong);
                eventObject.put("name", "timeChanged");
                eventObject.put("value", exoPlayer.getCurrentPosition());
                eventObject.put("speed", exoPlayer.getPlaybackParameters().speed);
                eventSink.success(eventObject);
            }
        });
    }

    @Override
    public void onPlayerStateChanged(EventTime eventTime, boolean playWhenReady, int playbackState) {
        Log.i(TAG, "onPlayerStateChanged: " + playbackState);
        HashMap<String, Object> eventObject = new HashMap<>();
        if (playbackState == Player.STATE_ENDED) {
            eventObject.put("name", "ended");
        }
        if (eventObject.isEmpty()) return;
        eventSink.success(eventObject);
    }

    @Override
    public void onIsPlayingChanged(EventTime eventTime, boolean isPlaying) {
        Log.i(TAG, "onIsPlayingChanged: " + isPlaying);
        HashMap<String, Object> eventObject = new HashMap<>();
        if (isPlaying) {
            eventObject.put("name", "playing");
        } else {
            eventObject.put("name", "paused");
        }
    }

    @Override
    public void onVideoSizeChanged(EventTime eventTime, int width, int height, int unappliedRotationDegrees, float pixelWidthHeightRatio) {
        Log.i(TAG, "onVideoSizeChanged: " + width + "/" + height);
        HashMap<String, Object> eventObject = new HashMap<>();
        eventObject.put("name", "size");
        eventObject.put("height", height);
        eventObject.put("width", width);
        eventObject.put("duration", exoPlayer.getDuration());
        eventSink.success(eventObject);
    }
}
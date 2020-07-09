package cn.dshitpie.refined_video_player;

import android.content.Context;
import android.net.Uri;
import android.view.SurfaceView;

import androidx.annotation.NonNull;

import com.google.android.exoplayer2.PlaybackParameters;
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
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers;
import io.reactivex.rxjava3.core.Observable;
import io.reactivex.rxjava3.disposables.Disposable;
import io.reactivex.rxjava3.functions.Consumer;
import io.reactivex.rxjava3.functions.Function;

public class PlayerViewFactory
        extends PlatformViewFactory
        implements AnalyticsListener {
    private static final String TAG = "RVP -> VideoViewFactory";

    private FlutterPlugin.FlutterPluginBinding binding;
    private QueuingEventSink eventSink;
    private EventChannel eventChannel;

    private SurfaceView surfaceView;

    private SimpleExoPlayer exoPlayer;
    private Observable<Long> position;
    private Disposable positionDisposable;

    public PlayerViewFactory(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
        super(StandardMessageCodec.INSTANCE);
        this.binding = binding;
        eventSink = new QueuingEventSink();
        eventChannel = new EventChannel(binding.getBinaryMessenger(), "refined_video_player/event");
        eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                eventSink.setDelegate(events);
            }

            @Override
            public void onCancel(Object arguments) {
                eventSink.setDelegate(null);
            }
        });

        final TrackSelector trackSelector = new DefaultTrackSelector(binding.getApplicationContext());
        exoPlayer = new SimpleExoPlayer
                .Builder(binding.getApplicationContext())
                .setTrackSelector(trackSelector)
                .build();
        exoPlayer.addAnalyticsListener(this);
    }

    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        surfaceView = new SurfaceView(context);
        exoPlayer.setVideoSurfaceView(surfaceView);
        return new VideoView(surfaceView);
    }

    public void disposeChannels() {
        eventChannel.setStreamHandler(null);
        eventSink.endOfStream();
        eventSink = null;
        eventChannel = null;
    }

    public void disposePlayer() {
        positionDisposable.dispose();
        exoPlayer.removeAnalyticsListener(this);
        exoPlayer.stop(true);
        exoPlayer.clearVideoSurfaceView(surfaceView);
        exoPlayer.release();
        surfaceView = null;
        exoPlayer = null;
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
                binding.getApplicationContext(),
                "ExoPlayer"
        );
    }

    public void onPlayerTimeProcessing() {
        final HashMap<String, Object> eventObject = new HashMap<>();
        position = Observable
                .interval(1, TimeUnit.SECONDS)
                .observeOn(AndroidSchedulers.mainThread())
                .map(new Function<Long, Long>() {
                    @Override
                    public Long apply(Long aLong) {
                        return exoPlayer.getCurrentPosition();
                    }
                });
        positionDisposable = position.subscribe(new Consumer<Long>() {
            @Override
            public void accept(Long aLong) {
                eventObject.put("name", "timeChanged");
                eventObject.put("value", "" + exoPlayer.getCurrentPosition());
                eventObject.put("speed", "" + exoPlayer.getPlaybackParameters().speed);
                eventSink.success(eventObject);
            }
        });
    }

    @Override
    public void onPlayerStateChanged(EventTime eventTime, boolean playWhenReady, int playbackState) {
        HashMap<String, Object> eventObject = new HashMap<>();
        if (playbackState == Player.STATE_ENDED) {
            eventObject.put("name", "ended");
        }
        if (eventObject.isEmpty()) return;
        eventSink.success(eventObject);
    }

    @Override
    public void onIsPlayingChanged(EventTime eventTime, boolean isPlaying) {
        HashMap<String, Object> eventObject = new HashMap<>();
        if (isPlaying) {
            eventObject.put("name", "playing");
        } else {
            eventObject.put("name", "paused");
        }
        eventSink.success(eventObject);
    }

    @Override
    public void onVideoSizeChanged(EventTime eventTime, int width, int height, int unappliedRotationDegrees, float pixelWidthHeightRatio) {
        HashMap<String, Object> eventObject = new HashMap<>();
        eventObject.put("name", "info");
        eventObject.put("height", "" + height);
        eventObject.put("width", "" + width);
        eventObject.put("duration", "" + exoPlayer.getDuration());
        eventSink.success(eventObject);
    }

    /**
     * Video Player API
     */
    protected void setUpPlayer(String url) {
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

    protected void playVideo() {
        exoPlayer.setPlayWhenReady(true);
    }

    protected void pauseVideo() {
        exoPlayer.setPlayWhenReady(false);
    }

    protected void stopVideo() {
        exoPlayer.stop(true);
    }

    protected void videoSeekTo(long milliSec) {
        exoPlayer.seekTo(milliSec);
    }

    protected void setVideoSpeed(float speed) {
        PlaybackParameters playbackParameters = new PlaybackParameters(speed, 1.0F);
        exoPlayer.setPlaybackParameters(playbackParameters);
    }
}
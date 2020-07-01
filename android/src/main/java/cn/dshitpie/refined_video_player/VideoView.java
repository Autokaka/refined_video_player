package cn.dshitpie.refined_video_player;

import android.content.Context;
import android.graphics.SurfaceTexture;
import android.net.Uri;
import android.os.Build;
import android.view.Surface;
import android.view.TextureView;
import android.view.View;

import androidx.annotation.RequiresApi;

import org.videolan.libvlc.AWindow;
import org.videolan.libvlc.LibVLC;
import org.videolan.libvlc.Media;
import org.videolan.libvlc.MediaPlayer;

import java.util.ArrayList;

import io.flutter.Log;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.view.TextureRegistry.*;

import static io.flutter.plugin.common.MethodChannel.MethodCallHandler;

public class VideoView implements PlatformView, MethodCallHandler {
    final private MethodChannel methodChannel;
    final private QueuingEventSink eventSink;
    final private EventChannel eventChannel;

    final private TextureView textureView;
    final private Context context;
    private LibVLC libVLC;
    private MediaPlayer mediaPlayer;

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
         * Init textures
         * */
        this.context = context;
        final SurfaceTextureEntry textureEntry = registrar.textures().createSurfaceTexture();
        textureView = new TextureView(context);
        textureView.setSurfaceTexture(textureEntry.surfaceTexture());
        textureView.setSurfaceTextureListener(new TextureView.SurfaceTextureListener() {
            @Override
            public void onSurfaceTextureAvailable(SurfaceTexture surface, int width, int height) {
                Log.wtf("FUCKKKKKKKKKKKKKKKKKKKK", "onSurfaceTextureAvailable");
            }

            @Override
            public void onSurfaceTextureSizeChanged(SurfaceTexture surface, int width, int height) {
                Log.wtf("FUCKKKKKKKKKKKKKKKKKKKK", "onSurfaceTextureSizeChanged");
            }

            @Override
            public boolean onSurfaceTextureDestroyed(SurfaceTexture surface) {
                Log.wtf("FUCKKKKKKKKKKKKKKKKKKKK", "onSurfaceTextureDestroyed");
                return mediaPlayer.isReleased();
            }

            @Override
            public void onSurfaceTextureUpdated(SurfaceTexture surface) {
                Log.wtf("FUCKKKKKKKKKKKKKKKKKKKK", "onSurfaceTextureUpdated");
            }
        });
    }

    @Override
    public View getView() {
        return textureView;
    }

    @Override
    public void dispose() {
        if (!mediaPlayer.isReleased()) {
            mediaPlayer.release();
        }
    }

    /**
     * Init VLCPlayer
     * ArrayList<String> options = new ArrayList<>();
     * options.add("--no-drop-late-frames");
     * options.add("--no-skip-frames");
     * options.add("--rtsp-tcp");
     * options.add("--quiet");
     */
    private void initPlayer(String url, ArrayList<String> vlcOptions) {
        libVLC = new LibVLC(context, vlcOptions);
        mediaPlayer = new MediaPlayer(libVLC);
        mediaPlayer.getVLCVout().setVideoSurface(textureView.getSurfaceTexture());
        mediaPlayer.getVLCVout().attachViews();
        mediaPlayer.setMedia(new Media(libVLC, Uri.parse(url)));
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        switch (methodCall.method) {
            case "initialize":
                String url = methodCall.argument("url");
                ArrayList<String> vlcOptions = methodCall.argument("VLCOptions");
                initPlayer(url, vlcOptions);
                result.success(null);
                break;
            case "play":
                mediaPlayer.play();
                result.success(null);
                break;
            case "pause":
                mediaPlayer.pause();
                result.success(null);
                break;
            case "stop":
                mediaPlayer.stop();
                result.success(null);
                break;
        }
    }


}
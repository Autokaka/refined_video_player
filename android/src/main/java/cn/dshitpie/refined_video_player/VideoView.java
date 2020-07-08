package cn.dshitpie.refined_video_player;

import android.view.SurfaceView;
import android.view.View;
import androidx.annotation.NonNull;
import io.flutter.plugin.platform.PlatformView;

public class VideoView implements PlatformView {
    private static final String TAG = "RVP -> VideoView";

    private SurfaceView surfaceView;

    VideoView(@NonNull SurfaceView surfaceView) {
        this.surfaceView = surfaceView;
    }

    @Override
    public View getView() {
        return surfaceView;
    }

    @Override
    public void dispose() {
        surfaceView = null;
    }
}
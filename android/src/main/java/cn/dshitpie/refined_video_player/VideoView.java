package cn.dshitpie.refined_video_player;

import android.view.TextureView;
import android.view.View;
import io.flutter.plugin.platform.PlatformView;

public class VideoView implements PlatformView {
    private final TextureView textureView;

    VideoView(TextureView textureView) {
        this.textureView = textureView;
    }

    @Override
    public View getView() {
        return textureView;
    }

    @Override
    public void dispose() {
    }
}
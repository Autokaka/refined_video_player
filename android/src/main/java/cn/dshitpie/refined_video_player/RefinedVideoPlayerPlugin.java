package cn.dshitpie.refined_video_player;

import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * RefinedVideoPlayerPlugin
 */
public class RefinedVideoPlayerPlugin {
    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        registrar.platformViewRegistry()
                .registerViewFactory("refined_video_player/view", new VideoViewFactory(registrar));
    }
}

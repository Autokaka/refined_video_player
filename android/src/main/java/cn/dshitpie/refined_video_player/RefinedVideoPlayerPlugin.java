package cn.dshitpie.refined_video_player;

import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.FlutterNativeView;

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
        registrar.addViewDestroyListener(new PluginRegistry.ViewDestroyListener() {
            @Override
            public boolean onViewDestroy(FlutterNativeView view) {
                return false;
            }
        });
    }
}

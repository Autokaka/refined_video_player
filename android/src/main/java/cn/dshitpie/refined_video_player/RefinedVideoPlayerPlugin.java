package cn.dshitpie.refined_video_player;

import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.FlutterNativeView;

public class RefinedVideoPlayerPlugin {
    public static void registerWith(Registrar registrar) {
        if (registrar.activity() == null) return;
        final VideoViewFactory videoViewFactory = new VideoViewFactory(registrar);

        registrar
                .platformViewRegistry()
                .registerViewFactory(
                        "refined_video_player/view",
                        videoViewFactory
                );
        registrar.addViewDestroyListener(
                new PluginRegistry.ViewDestroyListener() {
                    @Override
                    public boolean onViewDestroy(FlutterNativeView view) {
                        videoViewFactory.dispose();
                        return true;
                    }
                }
        );
    }
}

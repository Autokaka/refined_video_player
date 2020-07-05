package cn.dshitpie.refined_video_player;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;

import java.util.concurrent.atomic.AtomicInteger;

import io.flutter.Log;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.FlutterNativeView;

public class RefinedVideoPlayerPlugin {
    private final Registrar registrar;

    RefinedVideoPlayerPlugin(Registrar registrar) {
        this.registrar = registrar;
    }

    public static void registerWith(Registrar registrar) {
        Log.i("RefinedVideoPlayerPlugin", "registerWith: " + registrar.toString());
        if (registrar.activity() == null) return;
        RefinedVideoPlayerPlugin plugin = new RefinedVideoPlayerPlugin(registrar);
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

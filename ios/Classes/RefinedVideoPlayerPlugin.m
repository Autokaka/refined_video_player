#import "RefinedVideoPlayerPlugin.h"

@implementation RefinedVideoPlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"refined_video_player"
            binaryMessenger:[registrar messenger]];
  RefinedVideoPlayerPlugin* instance = [[RefinedVideoPlayerPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}
@end

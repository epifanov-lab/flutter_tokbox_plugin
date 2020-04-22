#import "FlutterOpentokPlugin.h"
#import <flutter_tokbox_plugin/flutter_tokbox_plugin-Swift.h>
#import "UserAgent.h"

@implementation FlutterOpentokPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterOpentokPlugin registerWithRegistrar:registrar];
}
@end

import 'dart:async';

import 'package:flutter/services.dart';

const String PLUGIN_CHANNEL_KEY = "flutter_tokbox_plugin";
const String PLUGIN_VIEW_CHANNEL_KEY = "$PLUGIN_CHANNEL_KEY.view";

class FlutterTokboxPlugin {
  static const MethodChannel _channel
    = const MethodChannel(PLUGIN_CHANNEL_KEY);

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

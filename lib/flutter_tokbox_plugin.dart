import 'dart:async';

import 'package:flutter/services.dart';

class FlutterTokboxPlugin {
  static const MethodChannel _channel =
      const MethodChannel('flutter_tokbox_plugin');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

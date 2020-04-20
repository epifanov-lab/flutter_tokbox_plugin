import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tokbox_plugin/flutter_tokbox_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_tokbox_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FlutterTokboxPlugin.platformVersion, '42');
  });
}

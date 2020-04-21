import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tokbox_plugin/flutter_tokbox_plugin.dart';

class TokboxConfiguration {
  final String token, apiKey, sessionId;
  TokboxConfiguration(this.token, this.apiKey, this.sessionId);
}

class TokboxWidget extends StatefulWidget {
  final TokboxConfiguration config;
  final Function onVideoCallFinished;

  TokboxWidget(this.config, this.onVideoCallFinished);

  @override
  State<StatefulWidget> createState() => _TokboxState();
}

class _TokboxState extends State<TokboxWidget> {
  @override
  Widget build(BuildContext context) {
    Map<String, String> params = <String, String>{
      'token': widget.config.token,
      'api_key': widget.config.apiKey,
      'session_id': widget.config.sessionId
    };

    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: PLUGIN_VIEW_CHANNEL_KEY,
        creationParams: params,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return SafeArea(
        top: true,
        child: UiKitView(
          viewType: PLUGIN_VIEW_CHANNEL_KEY,
          creationParams: params,
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: _onPlatformViewCreated,
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
            new Factory<OneSequenceGestureRecognizer>(
              () => new EagerGestureRecognizer(),
            ),
          ].toSet(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Call"),
      ),
      body: SafeArea(
        child: Center(
          child: Text(
              '$defaultTargetPlatform is not yet supported by the Tokbox Widget plugin'),
        ),
      ),
    );
  }

  void _onPlatformViewCreated(int id) {
    new TokboxController._(id).onWidgetDispose().then((_) {
      widget.onVideoCallFinished();
    });
  }
}

class TokboxController {
  TokboxController._(int id)
      : _channel = new MethodChannel('plugins.flutter.io/tokbox_$id');

  final MethodChannel _channel;

  Future<void> onWidgetDispose() async {
    return _channel.invokeMethod('onCallDispose');
  }
}

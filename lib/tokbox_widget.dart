import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tokbox_plugin/flutter_tokbox_plugin.dart';

import 'flutter_opentok.dart';

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
  bool publishVideo = true;
  OTFlutter controller;
  OpenTokConfiguration openTokConfiguration;

  @override
  Widget build(BuildContext context) {
    Map<String, String> params = <String, String>{
      'token': widget.config.token,
      'api_key': widget.config.apiKey,
      'session_id': widget.config.sessionId
    };
    openTokConfiguration = OpenTokConfiguration(
        token: widget.config.token, apiKey: widget.config.apiKey, sessionId: widget.config.sessionId);
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
        child: _addRenderView(0, (viewId) => null),
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
  Widget _addRenderView(int uid, Function(int viewId) finished) {
    OTFlutter.onSessionConnect = () {
      print("onSessionConnect");
    };

    OTFlutter.onSessionDisconnect = () {
      print("onSessionDisconnect");
    };

    var publisherSettings = OTPublisherKitSettings(
      name: "Mr. John Doe",
      audioTrack: true,
      videoTrack: publishVideo,
    );

    Widget view = OTFlutter.createNativeView(uid,
        publisherSettings: publisherSettings, created: (viewId) async {
          controller = await OTFlutter.init(viewId);
          //await controller.enableVideo();
          await controller.create(openTokConfiguration);
        });
    return view;
  }
  void _onPlatformViewCreated(int id) {
    new TokboxController._(id).onWidgetDispose().then((_) {
      widget.onVideoCallFinished();
    });
  }
}

class TokboxController {
  TokboxController._(int id)
      : _channel = new MethodChannel('$PLUGIN_VIEW_CHANNEL_KEY#$id');

  final MethodChannel _channel;

  Future<void> onWidgetDispose() async {
    return _channel.invokeMethod('onCallDispose');
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tokbox_plugin/flutter_tokbox_plugin.dart';
import 'package:flutter_tokbox_plugin/tokbox_widget.dart';

import 'theme.dart';

void main() => runApp(FlutterTokboxApp());

class FlutterTokboxApp extends StatefulWidget {
  @override
  _FlutterTokboxAppState createState() => _FlutterTokboxAppState();
}

class _FlutterTokboxAppState extends State<FlutterTokboxApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterTokboxPlugin.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() => _platformVersion = platformVersion);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter tokbox plugin example'),
        ),
        body: Stack(
          children: <Widget>[
            TokboxWidget(
                TokboxConfiguration(
                  /* token */ '',
                  /* apiKey */ '',
                  /* sessionId */ ''
                ),
                (){}
            ),
            Positioned(
              top: 8, right: 16,
              child: Text('Running on: $_platformVersion',
                style: appTheme.textTheme.subtitle1),
            )
          ],
        ),
      ),
    );
  }
}

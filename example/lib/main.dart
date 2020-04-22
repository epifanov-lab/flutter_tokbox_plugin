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
                  /* token */ 'T1==cGFydG5lcl9pZD00NjY0NDk1MiZzaWc9Y2MwZDdjYTNlOGViZjQwYjlmMTdiZDZhNjljMWZiOGVjODNiZGJhMDpzZXNzaW9uX2lkPTFfTVg0ME5qWTBORGsxTW41LU1UVTROelV4TXpZeU16YzJNbjVzYjFjeVVsRTFUM2syTlZvemFYUm1Za2h6VlhCdlQycC1mZyZjcmVhdGVfdGltZT0xNTg3NTEzNjIzJnJvbGU9bW9kZXJhdG9yJm5vbmNlPTE1ODc1MTM2MjMuNzcyODE4Mzc3NTY2OTg=',
                  /* apiKey */ '46644952',
                  /* sessionId */ '1_MX40NjY0NDk1Mn5-MTU4NzUxMzYyMzc2Mn5sb1cyUlE1T3k2NVozaXRmYkhzVXBvT2p-fg'
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

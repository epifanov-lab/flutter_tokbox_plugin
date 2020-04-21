import 'dart:ui';

import 'package:flutter/material.dart';

const Color colorBcgMain = const Color(0xFF333333);
const Color colorBcgAccept = const Color(0xFF009688);
const Color colorBcgCancel = const Color(0xFFF44336);
const Color colorText = const Color(0xFFFFFFFF);
Color colorAccent = Colors.blueAccent;

final int appColorsLength = appColors.length;
const List<int> appColors =
[ 0xFFF44336, 0xFFe91e63, 0xFF9C27B0, 0xFF673AB7,
  0xFF3F51B5, 0xFF2196F3, 0xFF03A9F4, 0xFF00BCD4, 0xFF009688,
  0xFF4CAF50, 0xFF8BC34A, 0xFFFF9800, 0xFFFF5722, 0xFF607D8B ];

final List<int> bcgAppColors = appColors
    .map((color) => Color.alphaBlend(Colors.white70, Color(color)))
    .map((color) => color.value)
    .toList();

final ThemeData appTheme = ThemeData(
    appBarTheme: AppBarTheme(color: Colors.black),
    scaffoldBackgroundColor: colorBcgMain,
    accentColor: colorAccent,

    textTheme: TextTheme(
      headline1: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
      headline2: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
      subtitle1: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      subtitle2: TextStyle(fontSize: 14.0),
      caption: TextStyle(fontSize: 12.0),
    ).apply(
        bodyColor: colorText,
        displayColor: colorText
    )
);
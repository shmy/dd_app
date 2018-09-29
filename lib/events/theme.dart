import 'package:flutter/material.dart';

final List<ThemeConf> themes = [
  new ThemeConf(
    primaryColor: Colors.black,
  ),
  new ThemeConf(
    primaryColor: Colors.teal,
  ),
  new ThemeConf(
    primaryColor: Colors.red,
  ),
  new ThemeConf(
    primaryColor: Colors.pink,
  ),
  new ThemeConf(
    primaryColor: Colors.amber,
  ),
  new ThemeConf(
    primaryColor: Colors.orange,
  ),
  new ThemeConf(
    primaryColor: Colors.green,
  ),
  new ThemeConf(
    primaryColor: Colors.blue,
  ),
  new ThemeConf(
    primaryColor: Colors.lightBlue,
  ),
  new ThemeConf(
    primaryColor: Colors.purple,
  ),
  new ThemeConf(
    primaryColor: Colors.deepPurple,
  ),
  new ThemeConf(
    primaryColor: Colors.indigo,
  ),
  new ThemeConf(
    primaryColor: Colors.cyan,
  ),
  new ThemeConf(
    primaryColor: Colors.brown,
  ),
  new ThemeConf(
    primaryColor: Colors.grey,
  ),
  new ThemeConf(
    primaryColor: Colors.blueGrey,
  )
];

class ThemeConf {
  final Color primaryColor;
  ThemeConf({this.primaryColor});
}

class ThemeChangedEvent {
  ThemeConf theme;
  ThemeChangedEvent(this.theme);
}

import 'dart:async';
// import 'package:dd_app/utils/db/future.dart';
import 'package:flutter/material.dart';
import 'package:dd_app/app.dart';
import 'package:dd_app/events/event_bus.dart';
import 'package:dd_app/events/theme.dart';
import 'package:dd_app/utils/db/setting.dart';

// 主题索引
final int themeIndex = 0;

// Future<void> onSelectNotification(String payload) {
//   print(payload);
// }

void main() async {
  // 准备好数据库
  Setting settingModel = await Setting.instance;
  Map sets = await settingModel.findById(1);
  if (sets == null) {
    sets = await initSetting(settingModel);
  }
  // 修改表结构
  // TODO 想个更好的升级策略
  // await FutureUpdateDB.future();
  runApp(new App(setting: sets));
}

// 初始化设置表
Future<Map> initSetting(Setting s) async {
  await s.upsert(1, {
    "id": 1,
    "theme_index": themeIndex, // 主题索引
  }, "id");
  Map r = await s.findById(1);
  return Future.value(r);
}

class App extends StatefulWidget {
  final Map setting;
  App({this.setting});
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  Color primaryColor = Colors.black;
  ThemeConf theme;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // 应用主题
    int themeIndex = widget.setting["theme_index"];
    theme = themes[themeIndex];
    EventBus.instance.on<ThemeChangedEvent>().listen((event) {
      setState(() {
        theme = event.theme;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    EventBus.instance.destroy();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: '黑人视频',
      theme: new ThemeData(
        platform: TargetPlatform.iOS,
        primaryColor: theme.primaryColor,
      ),
      home: new AppPage(),
    );
  }
}

import 'package:dd_app/widget/empty-widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:dd_app/events/event_bus.dart';
import 'package:dd_app/events/theme.dart';
import 'package:dd_app/utils/db/setting.dart';

class ThemePage extends StatefulWidget {
  @override
  _ThemePageState createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  Setting settingModel;
  int themeIndex = -1;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  void init() async {
    settingModel = await Setting.instance;
    Map s = await settingModel.findById(1);
    setState(() {
      this.themeIndex = s["theme_index"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("更换主题"),
        elevation: 0.0,
      ),
      body: StaggeredGridView.countBuilder(
        crossAxisCount: 2, // 4列
        itemCount: themes.length,
        itemBuilder: (BuildContext context, int index) => _buildLiveItem(index),
        staggeredTileBuilder: (int index) {
          return StaggeredTile.count(1, 0.5);
        }, // 列宽 和 高
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.all(10.0),
      ),
    );
  }

  Widget _buildLiveItem(int index) {
    ThemeConf theme = themes[index];
    return MaterialButton(
      color: theme.primaryColor,
      elevation: 0.0,
      onPressed: () async {
        if (index == this.themeIndex) {
          return;
        }
        // 存储主题索引
        await settingModel.update(1, {
          "theme_index": index,
        });
        // 发事件
        EventBus.instance.fire(ThemeChangedEvent(theme));
        // 设置当前
        setState(() {
          this.themeIndex = index;
        });
      },
      child: Stack(
        children: <Widget>[
          index == this.themeIndex
              ? Positioned(
                  top: 0.0,
                  right: 0.0,
                  left: 0.0,
                  bottom: 0.0,
                  child: Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 40.0,
                    ),
                  ),
                )
              : EmptyWidget()
        ],
      ),
    );
  }
}

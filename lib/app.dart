import 'package:dd_app/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dd_app/pages/index.dart';
import 'dart:async';
import 'package:dd_app/pages/classify.dart';
import 'package:dd_app/pages/user.dart';
import 'package:toasty/toasty.dart';
import 'package:clipboard/clipboard.dart';
import 'package:tx_xg/tx_xg.dart';
import 'package:dd_app/utils/action.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:dd_app/mixins/pageState.dart';
import 'package:dd_app/utils/db/record.dart';

final String AlipayKEY = "Nl7FJ976sg";

final List<Map> menus = [
  {"icon": Icons.home, "name": "首页"},
  {"icon": Icons.loyalty, "name": "分类"},
  {"icon": Icons.person, "name": "我的"},
];

class AppPage extends StatefulWidget {
  @override
  _AppPageState createState() => new _AppPageState();
}

class _AppPageState extends State<AppPage> {
  final GlobalKey<IndexPageState> _indexPageKey =
      new GlobalKey<IndexPageState>();
  final GlobalKey<ClassifyPageState> _classifyPageKey =
      new GlobalKey<ClassifyPageState>();
  final GlobalKey<UserPageState> _userPageKey = new GlobalKey<UserPageState>();

  static int lastExitTime = 0;
  List<GlobalKey> keys = [];
  List<Widget> pages = [];
  dynamic subscription;
  int currentIndex = 0;
  @override
  initState() {
    super.initState();
    pages = [
      IndexPage(
        key: _indexPageKey,
      ),
      ClassifyPage(
        key: _classifyPageKey,
      ),
      UserPage(
        key: _userPageKey,
      ),
    ];
    keys = [
      _indexPageKey,
      _classifyPageKey,
      _userPageKey,
    ];
    // 信鸽通知 监听
    if (Platform.isAndroid) {
      TxXg.init((data) async {
        print("-------来自通知栏的数据--------");
        print(data["customContent"]);
        Action.handleAction(context, data["customContent"]);
      }, (e) {
        print("信鸽出错：" + e);
      });
    }
    Util.setLocale();
    _handleNetworkChanged();
    _copyZCode();
    _listenVideoSeekChanged();
  }

  @override
  dispose() {
    super.dispose();
    subscription.cancel();
  }
  void _listenVideoSeekChanged() async {
    Record instance = await Record.instance;
    VideoPlayer.init((data) async {
      await instance.updateObjectId(data["id"], {
        "tag_name": data["tag_name"],
        "tag_time": data["tag_time"],
        "time": DateTime.now().millisecondsSinceEpoch,
      });
      
    });
  }
  // 复制吱口令到剪贴板
  void _copyZCode() async {
    await ClipboardManager.copy(AlipayKEY);
  }

  // 监听网络变化
  void _handleNetworkChanged() {
    subscription = new Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      switch (result) {
        case ConnectivityResult.mobile:
          Toasty.warning("当前处于移动网络");
          break;
        case ConnectivityResult.wifi:
          Toasty.success("当前处于wifi网络");
          break;
        case ConnectivityResult.none:
          Toasty.error("当前没有网络连接！");
          break;
        default:
          break;
      }
    });
  }

  // 再按一次退出程序
  Future<bool> _handleWillPop() {
    int now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastExitTime > 2000) {
      Toasty.info("再按一次退出程序");
      lastExitTime = now;
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleWillPop, // 再按一次退出程序
      child: Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: handleBottomNavigationBarTap,
          type: BottomNavigationBarType.fixed,
          items: menus.map<BottomNavigationBarItem>((item) {
            return BottomNavigationBarItem(
              title: Text(
                item["name"],
              ),
              icon: Icon(
                item["icon"],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void handleBottomNavigationBarTap(index) {
    if (currentIndex == index) return;
    setState(() {
      currentIndex = index;
    });

    // 手动触发onShow
    PageState s = keys[index].currentState as PageState;
    s.onShow();

  }
}

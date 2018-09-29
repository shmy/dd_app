import 'dart:io';

import 'package:dd_app/pages/series.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:toasty/toasty.dart';
import 'package:webview/webview.dart';
import 'package:dd_app/utils/modal.dart';
import 'package:dd_app/utils/util.dart';
import 'package:android_intent/android_intent.dart';
import 'package:clipboard/clipboard.dart';
import 'package:dd_app/pages/video.dart';
import 'dart:convert';

// 根据指令操作本地
class Action {
  // 可能是字符串 需要转成map
  static dynamic _stringToMap(dynamic jsonEq) {
    if (jsonEq.runtimeType == String) {
      return json.decode(jsonEq);
    }
    return jsonEq;
  }

  static void handleAction(BuildContext context, dynamic action) async {
    switch (action["type"]) {
      case "video": // 进入视频详情
        {
          // 需要map类型
          action["data"] = _stringToMap(action["data"]);
          Navigator.of(context).push(
                new CupertinoPageRoute(
                    builder: (context) => new VideoPage(item: action["data"])),
              );
          break;
        }
      case "series": // 进入播单
        {
          // 需要map类型
          action["data"] = _stringToMap(action["data"]);
          Navigator.of(context).push(
                new CupertinoPageRoute(
                    builder: (context) => new SeriesPage(item: action["data"])),
              );
          break;
        }
      case "webview": // 进入自带的webview
        Webview.load(
          action["data"],
          primaryColor: Theme.of(context).primaryColor,
          titleColor: Colors.white,
        );
        break;
      case "browser": // 进入自带的浏览器
        Util.openUrlLink(action["data"]);
        break;
      case "alert": // 提示框
        ShmyDialog.alert(context, content: action["data"]);
        break;
      case "alipay_readpack": // 支付宝红包 单独封装
        {
          ClipboardManager.copy(action["data"]); // 拷贝吱口令
          // 设置支付宝的 IOS ANDROID 包名
          String packageName =
              Platform.isIOS ? "alipay://" : "com.eg.android.AlipayGphone";
          // 设置支付宝 IOS appStore的ID
          String itemId = Platform.isIOS ? "333206289" : "";
          await AndroidIntent.launchApp(
            packageName,
            itemId: itemId,
          ); // 打开支付宝
          break;
        }
      default:
        Toasty.warning("暂不支持的事件，也许你需要升级app");
        break;
    }
  }
}

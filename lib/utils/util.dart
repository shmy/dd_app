import 'dart:async';
import 'package:dd_app/utils/zh_message.dart';
import 'package:flutter/material.dart';
import 'package:dd_app/pages/signin.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:dd_app/utils/dio.dart';
import 'package:package_info/package_info.dart';

class Util {
  static setLocale() {
    timeago.setLocaleMessages("zh-cn", new ZhCnMessages());
  }
  // 显示登录页面
  static showLoginPage(BuildContext context) async {
    final result = await Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) => new SignInPage(),
        fullscreenDialog: true,
      ),
    );
    return result;
  }

  // 打开URL连接
  static Future<bool> openUrlLink(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
      return Future.value(true);
    }
    return Future.value(false);
  }

  // timeago
  static String getTimeago(DateTime date) {
    return timeago.format(
      date,
      locale: 'zh-cn'
    );
  }

  static Future<Map> checkUpdateOfAndroid() async {
    dynamic payload = await Fetch.instance.get("/check_for_update");
    if (payload == null) {
      // throw NullThrownError();
      return {"canUpdate": false, "payload": {}};
    }
    return {
      "canUpdate": await Util._toCompareVersion(payload["version"]),
      "payload": payload
    };
  }

  // 比较版本号码
  static Future<bool> _toCompareVersion(String version) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;
    List<String> versions = version.split(".");
    List<String> currentVersions = currentVersion.split(".");
    for (int i = 0, j = currentVersions.length; i < j; i++) {
      if (int.parse(versions[i]) > int.parse(currentVersions[i])) {
        return Future.value(true);
      }
    }
    return Future.value(false);
  }

  // 获取来源图标
  static String getTypeIcon(String source) {
    final String zuidazy = "images/type_icons/zuidazy.webp";
    if (source == "kuyunzy") return "images/type_icons/kuyunzy.webp";
    return zuidazy;
  }

  static String parserTime(int time) {
    time = time ~/ 1000;
    String timeStr = "";
    int hour = 0;
    int minute = 0;
    int second = 0;
    if (time <= 0)
      return "00:00";
    else {
      minute = time ~/ 60;
      if (minute < 60) {
        second = time % 60;
        timeStr = _unitFormat(minute) + ":" + _unitFormat(second);
      } else {
        hour = minute ~/ 60;
        if (hour > 99) return "99:59:59";
        minute = minute % 60;
        second = time - hour * 3600 - minute * 60;
        timeStr = _unitFormat(hour) +
            ":" +
            _unitFormat(minute) +
            ":" +
            _unitFormat(second);
      }
    }
    return timeStr;
  }

  static String _unitFormat(int i) {
    String retStr = "";
    if (i >= 0 && i < 10)
      retStr = "0" + i.toString();
    else
      retStr = i.toString();
    return retStr;
  }
}

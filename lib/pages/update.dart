import 'package:dd_app/widget/empty-widget.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:dd_app/utils/modal.dart';
import 'package:package_info/package_info.dart';
import 'package:toasty/toasty.dart';
import 'package:dd_app/utils/util.dart';

class UpdatePage extends StatefulWidget {
  String url;
  UpdatePage({
    Key key,
    this.url: "",
  }) : super(key: key);
   @override
  _UpdatePageState createState() => new _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  @override
  initState () {
    super.initState();
    this._init();
    // this._handleDownloadUpdate();
  }
  @override
  dispose () {
    super.dispose();
  }

  PackageInfo packageInfo;
  bool isCheckUpdataing = false;
  CancelToken token = new CancelToken();
  String url = "";
  String saveUrl = "";
  Widget build (BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("检查版本更新"),
        elevation: 0.0,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildContent()
        ),
      )
    );
  }
  List<Widget> _buildContent () {
    String appName = "检测中";
    String version = "检测中";
    if (this.packageInfo != null) {
      appName = this.packageInfo.appName;
      version = this.packageInfo.version;
    }
    return [
      Image(
        height: 95.0,
        width: 100.0,
        image: AssetImage("images/logo.webp"),
      ),
      this.isCheckUpdataing ? Container(
        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
        child: Text("正在检查更新中", style: TextStyle(
          color: Colors.red,
          fontSize: 12.0,
        ),),
      ) : EmptyWidget(),
      InkWell(
        onTap: () {},
        child: Container(
          height: 45.0,
          width: 200.0,
          child: Center(
            child: Text(appName, style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600
            ),),
          ),
        ),
      ),
      InkWell(
        onTap: () {},
        child: Container(
          height: 45.0,
          width: 200.0,
          child: Center(
            child: Text("v " + version, style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600
            ),),
          ),
        ),
      ),
    ];
  }
  
  // 获取pkg信息
  Future<Null> _getPkgInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      this.packageInfo = packageInfo;
    });
    return null;
  }

  void fetch() async {
    setState(() {
      this.isCheckUpdataing = true;
    });
    try {
      Map info = await Util.checkUpdateOfAndroid();
      // setState() called after dispose()
      if (!mounted) {
        return;
      }
      if (info["canUpdate"]) {
        var payload = info["payload"];
        ShmyDialog.confirm(context, 
          content: "发布日期：" + payload["date"] + "\n更新内容：\n\t\t\t\t" + payload["content"].join("\n\t\t\t\t"),
          title: "发现新版本： v " + payload["version"],
          okLabel: "立即更新",
          cancelLabel: "稍后再说",
          okFn: () {
            Util.openUrlLink(payload["website"]);
          }
        );
      } else {
        Toasty.success("你的版本已是最新！");
      }
    } on NullThrownError {
      Toasty.error("检查更新时发生错误！请检查网络设置！");
    } finally {
      // setState() called after dispose()
      if (mounted) {
        setState(() {
          this.isCheckUpdataing = false;
        });
      }
    }
  }
  void _init () async {
    await this._getPkgInfo();
    // 安卓方式
    if (Platform.isAndroid) {
      this.fetch();
    } else {
      Toasty.info("IOS更新正在建设中，请耐心等待。");
    }
  }
 }
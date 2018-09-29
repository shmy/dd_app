import 'dart:io';
import 'package:dd_app/widget/empty-widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dd_app/utils/db/user.dart';
import 'package:dd_app/utils/modal.dart';
import 'package:dd_app/utils/util.dart';
import 'package:dd_app/pages/record.dart';
import 'package:dd_app/pages/more.dart';
import 'package:dd_app/pages/favorite.dart';
import 'package:toasty/toasty.dart';
import 'package:dd_app/pages/secret.dart';

import 'package:dd_app/mixins/pageState.dart';

class UserPage extends StatefulWidget {
  UserPage({Key key}) : super(key: key);
  @override
  UserPageState createState() => UserPageState();
}

class UserPageState extends State<UserPage> implements PageState {

  void onShow() {
    print('UserPageState 啦啦啦1');
  }

  bool isLogined = false;
  Map user = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("我的"),
        elevation: 0.0,
      ),
      body: ListView(
        children: <Widget>[
          Container(
              height: 140.0,
              color: Colors.black,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 0.0,
                    left: 0.0,
                    bottom: 0.0,
                    right: 0.0,
                    child: Image(
                      image: AssetImage("images/users/user-bg.webp"),
                      repeat: ImageRepeat.repeat,
                    ),
                  ),
                  Positioned(
                    top: 0.0,
                    left: 0.0,
                    bottom: 0.0,
                    right: 0.0,
                    child: Container(
                      child: isLogined
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Container(
                                  decoration: new BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: new BorderRadius.all(
                                      const Radius.circular(50.0),
                                    ),
                                  ),
                                  padding: EdgeInsets.all(5.0),
                                  child: Image(
                                    height: 60.0,
                                    width: 60.0,
                                    image: AssetImage("images/logo.webp"),
                                  ),
                                ),
                                GestureDetector(
                                  onLongPress: _handleSecretPage,
                                  child: Text(
                                    user["username"] != null
                                        ? user["username"].toUpperCase()
                                        : "",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                              // ),
                            )
                          : Center(
                              child: MaterialButton(
                                color: Theme.of(context).primaryColor,
                                height: 48.0,
                                onPressed: () async {
                                  if (await Util.showLoginPage(context) ==
                                      "SUCCESS") {
                                    _handleRefreshUserState();
                                  }
                                },
                                child: Text(
                                  "登录/注册，发现秘密花园",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  )
                ],
              )),
          Container(
            height: 20.0,
          ),
          ListTile(
            title: Text("我的收藏"),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Navigator.of(context).push(
                    new CupertinoPageRoute(
                        builder: (context) => new FavoritePage()),
                  );
            },
          ),
          Divider(),
          ListTile(
            title: Text("播放记录"),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: _handleRecordTap,
          ),
          Divider(),
          ListTile(
            title: Text("更多选项"),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Navigator.of(context).push(
                    new CupertinoPageRoute(
                        builder: (context) => new MorePage()),
                  );
            },
          ),
          isLogined
              ? Container(
                  margin: EdgeInsets.only(top: 20.0),
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: MaterialButton(
                    elevation: 0.0,
                    height: 50.0,
                    minWidth: MediaQuery.of(context).size.width - 20.0,
                    color: Colors.red,
                    onPressed: () {
                      ShmyDialog.confirm(context, content: "确实要退出登录吗？",
                          okFn: () async {
                        User userModel = await User.instance;
                        await userModel.truncateTable();
                        _handleRefreshUserState();
                        Toasty.success("退出成功");
                      });
                    },
                    child: Text(
                      "退出登录",
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                  ),
                )
              : EmptyWidget(),

          // ListTile(
          //   title: Text("播单"),
          //   trailing: Icon(Icons.keyboard_arrow_right),
          //   onTap: () {
          //     Navigator.of(context).push(
          //           new CupertinoPageRoute(
          //               builder: (context) => new TPage()),
          //         );
          //   },
          // ),

        ],
      ),
    );
  }

  @override
  initState() {
    super.initState();
    _handleRefreshUserState();
    _handleCheckUpdate();
  }

  void _handleRecordTap() {
    Navigator.of(context).push(
          new CupertinoPageRoute(builder: (context) => new RecordPage()),
        );
  }

  void _handleCheckUpdate() async {
    if (Platform.isAndroid) {
      try {
        Map info = await Util.checkUpdateOfAndroid();
        if (info["canUpdate"]) {
          var payload = info["payload"];
          ShmyDialog.confirm(
            context,
            content: payload["content"].join("\n"),
            title: "发现新版本： v " + payload["version"],
            okLabel: "立即更新",
            cancelLabel: "稍后再说",
            okFn: () {
              Util.openUrlLink(payload["website"]);
            },
          );
        }
      } on NullThrownError {}
    }
  }

  void _handleRefreshUserState() async {
    User userModel = await User.instance;
    Map u = await userModel.findID1();
    if (u == null) {
      setState(() {
        isLogined = false;
        user = {};
      });
      return;
    }
    int now = DateTime.now().millisecondsSinceEpoch;
    print("------------");
    print(now);
    print(u["overdue"]);
    print(now < u["overdue"]);
    print("------------");
    if (now < u["overdue"]) {
      setState(() {
        isLogined = true;
        user = u;
      });
    } else {
      setState(() {
        isLogined = false;
        user = {};
      });
    }

    // TODO 自动刷新token
  }

  void _handleSecretPage () {
    Navigator.of(context).push(
          new CupertinoPageRoute(
            builder: (context) => new SecretPage(),
          ),
        );
  }
}

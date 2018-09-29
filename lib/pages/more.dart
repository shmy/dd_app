import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dd_app/pages/update.dart';
import 'package:dd_app/pages/feedback.dart';
import 'package:dd_app/pages/theme.dart';

class MorePage extends StatefulWidget {
  @override
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("更多选项"),
          elevation: 0.0,
        ),
        body: ListView(
          children: <Widget>[
            ListTile(
              title: Text("检查版本更新"),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.of(context).push(
                      new CupertinoPageRoute(
                          builder: (context) => new UpdatePage()),
                    );
              },
            ),
            Divider(),
            ListTile(
              title: Text("更换主题颜色"),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.of(context).push(
                      new CupertinoPageRoute(
                          builder: (context) => new ThemePage()),
                    );
              },
            ),
            Divider(),
            ListTile(
              title: Text("体验网页版本"),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () async {
                String url = "https://dd.shmy.tech";
                if (await canLaunch(url)) {
                  await launch(url);
                }
              },
            ),
            Divider(),
            ListTile(
              title: Text("功能与意见反馈"),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.of(context).push(
                      new CupertinoPageRoute(
                          builder: (context) => new FeedbackPage()),
                    );
              },
            ),
            Divider(),
            ListTile(
              title: Text("版权声明与投诉"),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () async {
                String year = DateTime.now().year.toString();
                Navigator.of(context).push(new CupertinoPageRoute(
                      builder: (context) => new Scaffold(
                            appBar: AppBar(
                              title: Text("版权声明与投诉"),
                              elevation: 0.0,
                            ),
                            body: Container(
                              padding: EdgeInsets.all(10.0),
                              child: ListView(
                                children: <Widget>[
                                  Text(
                                      "    本软件所有内容均来自互联网，由【人工智能深度机器学习的AI】自动采集，如果本软件部分内容侵犯您的版权请告知，在必要证明文件下我们第一时间撤除。"),
                                  Center(
                                    child: Text(
                                        "\n\n\nCopyright © $year SHMY. All rights reserved."),
                                  ),
                                  Container(
                                    height: 40.0,
                                  ),
                                  MaterialButton(
                                    elevation: 0.0,
                                    height: 50.0,
                                    minWidth:
                                        MediaQuery.of(context).size.width -
                                            20.0,
                                    color: Theme.of(context).primaryColor,
                                    onPressed: () {
                                      Navigator.of(context).pushReplacement(
                                            new CupertinoPageRoute(
                                              builder: (context) =>
                                                  new FeedbackPage(
                                                    appBarTitle: "版权投诉",
                                                    titleHintText: "请输入投诉标题",
                                                    titleHelperText:
                                                        "包含投诉的视频名称",
                                                    titleDefaultText: "",
                                                    contentHintText: "请输入投诉证据",
                                                    contentHelperText:
                                                        "务必提供有力证明",
                                                    // contentDefaultText: "",
                                                  ),
                                            ),
                                          );
                                    },
                                    child: Text(
                                      "提交版权投诉",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                    ));
              },
            ),
            Divider(),
            ListTile(
              title: Text("LICENSE"),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.of(context).push(
                      new CupertinoPageRoute(
                          builder: (context) => new LicensePage()),
                    );
              },
            ),
            // Divider(),
            // ListTile(
            //   title: Text("测试"),
            //   trailing: Icon(Icons.keyboard_arrow_right),
            //   onTap: () {
            //     Navigator.of(context).push(
            //           new CupertinoPageRoute(
            //               builder: (context) => new IndexPage()),
            //         );
            //   },
            // ),
          ],
        ));
  }
}

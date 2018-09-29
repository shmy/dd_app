import 'package:flutter/material.dart';
import 'package:toasty/toasty.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io';

class FeedbackPage extends StatefulWidget {
  final String appBarTitle;
  final String titleHintText;
  final String titleHelperText;
  final String titleDefaultText;
  final String contentHintText;
  final String contentHelperText;
  final String contentDefaultText;
  // TODO 附加数据
  FeedbackPage({
    Key key,
    this.appBarTitle = "意见反馈",
    this.titleHintText = "请输入你的联系方式",
    this.titleHelperText = "你的联系方式不会被泄露",
    this.titleDefaultText = "",
    this.contentHintText = "请输入需要反馈的内容",
    this.contentHelperText = "输入你的反馈内容",
    this.contentDefaultText = "",
  }) : super(key: key);
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final String SCKEY = "SCU29489T427d03a73594b376a9471a70fc9c23555b4b2b37d718d";
  String contact;
  String content;
  TextEditingController _contactController;
  TextEditingController _contentController;
  bool isSendIng = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    contact = widget.titleDefaultText;
    content = widget.contentDefaultText;
    _contactController = new TextEditingController(text: contact);
    _contentController = new TextEditingController(text: content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.appBarTitle),
          elevation: 0.0,
        ),
        body: ListView(
          children: <Widget>[
            Container(
              height: 30.0,
            ),
            TextField(
              controller: _contactController,
              onChanged: (String value) {
                setState(() {
                  this.contact = value;
                });
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.white,
                hintText: widget.titleHintText,
                helperText: widget.titleHelperText,
                // contentPadding: EdgeInsets.only(left: 10.0, right: 10.0)
              ),
              style: TextStyle(color: Colors.black, fontSize: 16.0),
              autofocus: true,
            ),
            TextField(
              controller: _contentController,
              onChanged: (String value) {
                setState(() {
                  this.content = value;
                });
              },
              maxLines: 8,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.white,
                hintText: widget.contentHintText,
                helperText: widget.contentHelperText,
              ),
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                // height: 300.0
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20.0),
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              // height: 55.0,
              child: MaterialButton(
                elevation: 0.0,
                height: 50.0,
                minWidth: MediaQuery.of(context).size.width - 20.0,
                onPressed: _handleSubmit,
                child: Text(
                  this.isSendIng ? "正在提交..." : "提交",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
                color: Theme.of(context).primaryColor,
              ),
            )
          ],
        ));
  }

  void _handleSubmit() async {
    String contact = this.contact.trim();
    String content = this.content.trim();
    if (contact == "") {
      Toasty.warning(widget.titleHintText);
      return;
    }
    if (content == "") {
      Toasty.warning(widget.contentHintText);
      return;
    }
    DateTime now = DateTime.now();
    Map<String, String> data = {
      "text": contact + " ${now.hour}时${now.minute}分",
      "desp": content + " 来自: ${Platform.operatingSystem.toUpperCase()}"
    };
    setState(() {
      this.isSendIng = true;
    });
    Dio dio = new Dio();
    try {
      Response response = await dio.get(
          "https://sc.ftqq.com/" + SCKEY + ".send",
          data: data,
          options: Options(responseType: ResponseType.JSON));
      String jsonString = response.data;
      Map<String, dynamic> d = json.decode(jsonString);
      if (d["errno"] == 0) {
        Toasty.success("提交成功！");
        Navigator.of(context).pop();
      } else {
        print(d);
        Toasty.error("提交失败，请稍后再试！");
      }
    } catch (e) {
      Toasty.error("提交失败，请稍后再试！");
    } finally {
      setState(() {
        this.isSendIng = false;
      });
    }
  }
}

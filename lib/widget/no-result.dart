import 'package:flutter/material.dart';

class NoResult extends StatefulWidget {
  String text;
  NoResult({this.text = "暂无历史记录。"});
  @override
  _NoResultState createState() => _NoResultState();
}

class _NoResultState extends State<NoResult> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Container(
            height: 80.0,
          ),
          Image(
            height: 180.0,
            width: 240.0,
            image: AssetImage("images/null-page-draw.webp"),
            fit: BoxFit.fill,
          ),
          Container(
            height: 30.0,
            width: 200.0,
            alignment: Alignment.center,
            child: Text(widget.text),
          ),
        ],
      ),
    );
  }
}

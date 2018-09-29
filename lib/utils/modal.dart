import 'package:flutter/material.dart';
import 'dart:async';

// Dialog
class ShmyDialog {
// alert
  static void alert(BuildContext context,
      {@required String content,
      String title: "提示",
      bool barrierDismissible: true,
      String okLabel: "确定"}) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(barrierDismissible);
          },
          child: AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Text(content),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(okLabel),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

// confirm
  static void confirm(BuildContext context,
      {@required String content,
      String title: "提示",
      String okLabel: "确定",
      String cancelLabel: "取消",
      bool barrierDismissible: true,
      Function okFn,
      Function cancelFn}) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(barrierDismissible);
          },
          child: AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Text(content),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(okLabel),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (okFn != null) {
                    okFn();
                  }
                },
              ),
              FlatButton(
                child: Text(cancelLabel),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (cancelFn != null) {
                    cancelFn();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 对话框

  // static void prompt(BuildContext context,
  //     {String title: "提示",
  //     String okLabel: "确定",
  //     String cancelLabel: "取消",
  //     bool barrierDismissible: true,
  //     Function okFn,
  //     Function cancelFn}) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: barrierDismissible,
  //     builder: (BuildContext context) {
  //       return WillPopScope(
  //         onWillPop: () {
  //           return Future.value(barrierDismissible);
  //         },
  //         child: SimpleDialog(
  //           title: Text(title),
  //           children: [
  //             Container(
  //               padding: EdgeInsets.only(left: 20.0, right: 20.0),
  //               child: TextField(
  //                 decoration: InputDecoration(hintText: "请输入收藏夹名称"),
  //                 autofocus: true,
  //               ),
  //             ),
  //             Container(
  //               margin: EdgeInsets.only(top: 20.0),
  //               padding: EdgeInsets.only(left: 20.0, right: 20.0),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.end,
  //                 children: <Widget>[
  //                   MaterialButton(
  //                     height: 35.0,
  //                     color: Theme.of(context).primaryColor,
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                     },
  //                     child: Text(
  //                       "确定",
  //                       style: TextStyle(
  //                         color: Colors.white,
  //                       ),
  //                     ),
  //                   ),
  //                   Container(
  //                     width: 20.0,
  //                   ),
  //                   MaterialButton(
  //                     height: 35.0,
  //                     color: Colors.grey[500],
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                     },
  //                     child: Text(
  //                       "取消",
  //                       style: TextStyle(
  //                         color: Colors.white,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // 单选框
  static void chooseFavorite(BuildContext context,
      {@required List<dynamic> selection,
      String title: "提示",
      String okLabel: "确定",
      String cancelLabel: "取消",
      bool barrierDismissible: true,
      Function selectedFn}) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(barrierDismissible);
          },
          child: SimpleDialog(
              title: Text(title),
              children: selection.map(
                (v) {
                  return ListTile(
                    onTap: () {
                      Navigator.of(context).pop();
                      if (selectedFn != null) {
                        selectedFn(v);
                      }
                    },
                    title: Text(
                      v["name"],
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    leading: Icon(
                      Icons.folder,
                      size: 45.0,
                    ),
                    subtitle: Text(
                      "已有" + v["count"].toString() + "个视频",
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                    ),
                  );
                },
              ).toList()),
        );
      },
    );
  }

  static void customDialog(BuildContext context,
      {@required Widget child, bool barrierDismissible: true}) {
    showDialog(
      context: context,
      builder: (context) => new FullScreenDialog(
            child: Center(
              child: child,
            ),
          ),
    );
  }

  static void customDialog2(BuildContext context,
      {@required Widget child, bool barrierDismissible: true}) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(barrierDismissible);
          },
          child: SimpleDialog(
            titlePadding: EdgeInsets.all(0.0),
            contentPadding: EdgeInsets.all(0.0),
            children: <Widget>[
              Container(
                height: 300.0,
                width: 300.0,
              ),
            ],
          ),
        );
      },
    );
  }
}

// 全屏dialog
class FullScreenDialog extends StatefulWidget {
  final Widget child;

  final Function onTapOutside;

  const FullScreenDialog({Key key, this.child, this.onTapOutside})
      : super(key: key);

  @override
  _FullScreenDialogState createState() => new _FullScreenDialogState();
}

class _FullScreenDialogState extends State<FullScreenDialog> {
  @override
  Widget build(BuildContext context) {
    var onDismiss = widget.onTapOutside ?? dismiss;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: GestureDetector(
              onTap: onDismiss,
            ),
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: widget.child,
          ),
        ],
      ),
    );
  }

  dismiss() {
    Navigator.of(context).pop();
  }
}

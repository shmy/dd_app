import 'package:dd_app/utils/db/future.dart';
import 'package:dd_app/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dd_app/utils/db/record.dart';
import 'package:dd_app/pages/video.dart';
import 'package:dd_app/widget/no-result.dart';
import 'package:dd_app/utils/modal.dart';
import 'package:toasty/toasty.dart';
import 'dart:async';

class RecordPage extends StatefulWidget {
  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  List<Map<String, dynamic>> items = [];
  Record recordModel;
  bool noResult = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("播放记录"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.clear_all),
              onPressed: _handleClearAll,
            )
          ],
          elevation: 0.0,
        ),
        body: this.noResult
            ? NoResult()
            : ListView.builder(
                itemCount: this.items.length,
                padding: const EdgeInsets.all(10.0),
                itemBuilder: _buildListItem,
              ));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.fetch();
  }

  Future<Null> fetch() async {
    recordModel = await Record.instance;
    var list = await recordModel.paging(1, 100, "time DESC");
    setState(() {
      this.items = list.toList();
      // print(this.items);
      if (this.items.length == 0) {
        this.noResult = true;
      }
    });
  }

  Widget _buildListItem(BuildContext context, int i) {
    final item = this.items[i];
    return Dismissible(
      key: Key(item["_id"]),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) async {
        await recordModel.delete(item["id"]);
        this.items.removeAt(i);
        if (this.items.length == 0) {
          setState(() {
            this.noResult = true;
          });
        }
        // Scaffold.of(context).showSnackBar(
        //     new SnackBar(content: new Text(item["name"] + "已移除")));
      },
      background: Container(
        color: Colors.red,
        padding: EdgeInsets.only(right: 15.0),
        alignment: Alignment.centerRight,
        child: Text("继续左滑删除",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w400)),
      ),
      child: ListTile(
        title: Text((i + 1).toString() + ". " + item["name"]),
        subtitle: Text(
          item["tag_name"] + "  (" + Util.parserTime(item["tag_time"]) + ")",
        ),
        // isThreeLine: true,
        trailing: Icon(
          Icons.keyboard_arrow_right,
          size: 32.0,
        ),
        onTap: () {
          Navigator.of(context).push(
            new CupertinoPageRoute(
                builder: (context) => new VideoPage(item: {
                      "_id": item["_id"],
                      "name": item["name"],
                      "thumbnail": item["pic"],
                    })),
          );
        },
      ),
    );
  }
  
  void _handleClearAll() {
    if (this.items.length == 0) {
      Toasty.warning("还没有播放记录哦，先去逛逛吧。");
      return;
    }
    ShmyDialog.confirm(context, content: "是否清空全部播放记录？", okFn: () async {
      await recordModel.truncateTable();
      this.fetch();
    });
  }
}

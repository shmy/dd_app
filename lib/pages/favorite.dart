import 'package:dd_app/widget/empty-widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dd_app/utils/dio.dart';
import 'package:loading/loading.dart';
import 'package:toasty/toasty.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:dd_app/widget/no-result.dart';
import 'package:dd_app/pages/favorite-list.dart';
import 'package:dd_app/utils/modal.dart';

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  Map favorite = {
    "name": "",
  };
  List<dynamic> items = [];
  bool isLoading = false;
  bool loadError = false;
  bool noResult = false;
  @override
  void initState() {
    super.initState();
    this.fetch();
    // TODO: implement initState
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("我的收藏"),
        actions: <Widget>[
          IconButton(
            onPressed: _handleAdd,
            tooltip: '新增收藏夹',
            icon: Icon(
              Icons.add,
              size: 28.0,
            ),
          )
        ],
        elevation: 0.0,
      ),
      body: ListView.builder(
        itemCount: this.items.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return _buildProgressIndicator();
          }
          index--;
          Map item = this.items[index];
          return Container(
            height: 70.0,
            // margin: EdgeInsets.only(top: 20.0),
            child: Center(
              child: ListTile(
                onTap: () => _handleItemTaped(item),
                leading: Icon(
                  Icons.folder,
                  size: 50.0,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(
                  item["name"],
                  style: TextStyle(
                      color: Theme.of(context).primaryColor, fontSize: 16.0),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(item["count"].toString() + "个视频"),
                trailing: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  tooltip: "操作",
                  onSelected: (String v) => _handleSelection(index, v),
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuItem<String>>[
                        PopupMenuItem<String>(
                          value: "EDITOR",
                          child: Text('编辑'),
                        ),
                        PopupMenuItem<String>(
                          value: "REMOVE",
                          child: Text('删除'),
                        ),
                      ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleAdd() {
    this._handleOpenPrompt(submitFn: _handleCrate);
  }

  void _handleOpenPrompt(
      {String title: "新增收藏夹",
      String defaultName = "",
      @required Function submitFn}) {
    this.favorite["name"] = defaultName;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(false);
          },
          child: SimpleDialog(
            title: Text(title),
            children: [
              Container(
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: TextField(
                  controller: new TextEditingController(text: defaultName),
                  decoration: InputDecoration(
                    hintText: "请输入收藏夹名称",
                  ),
                  autofocus: true,
                  onChanged: (String val) {
                    this.favorite["name"] = val;
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20.0),
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    MaterialButton(
                      height: 35.0,
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        // Navigator.of(context).pop();
                        submitFn();
                      },
                      child: Text(
                        "确定",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: 20.0,
                    ),
                    MaterialButton(
                      height: 35.0,
                      color: Colors.grey[500],
                      onPressed: () {
                        Navigator.of(context).pop();
                        this.favorite["name"] = "";
                      },
                      child: Text(
                        "取消",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleCrate() async {
    if (this.favorite["name"] == "") {
      Toasty.warning("请输入收藏夹名称");
      return;
    }
    Loading.show();
    dynamic payload =
        await Fetch.instance.post("/favorite", data: this.favorite);
    Loading.hide();
    this.favorite["name"] = "";
    if (payload == null) return;
    Toasty.success("添加好了");
    Navigator.of(context).pop();
    this.fetch();
  }

  void fetch() async {
    setState(() {
      this.isLoading = true;
      this.loadError = false;
      this.noResult = false;
    });
    dynamic payload = await Fetch.instance.get("/favorite");
    if (!mounted) return;
    setState(() {
      this.isLoading = false;
    });
    if (payload == null) {
      setState(() {
        this.loadError = true;
      });
      return;
    }
    if (payload.length == 0) {
      setState(() {
        this.noResult = true;
      });
    }
    setState(() {
      this.items = payload;
    });
  }

  void _handleSelection(int index, String opt) {
    Map item = this.items[index];
    if (opt == "EDITOR") {
      this._handleOpenPrompt(
        title: "编辑收藏夹",
        defaultName: item["name"],
        submitFn: () async {
          if (this.favorite["name"] == "") {
            Toasty.warning("请输入收藏夹名称");
            return;
          }
          Loading.show();
          dynamic payload = await Fetch.instance
              .put("/favorite/" + item["_id"], data: this.favorite);
          Loading.hide();
          this.favorite["name"] = "";
          if (payload == null) return;
          Toasty.success("编辑好了");
          Navigator.of(context).pop();
          this.fetch();
        },
      );
      return;
    }
    if (opt == "REMOVE") {
      ShmyDialog.confirm(context, content: "确实要删除该收藏夹？", okFn: () async {
        Loading.show();
        dynamic payload =
            await Fetch.instance.delete("/favorite/" + item["_id"]);
        Loading.hide();
        if (payload == null) return;
        Toasty.success("删除好了");
        // Navigator.of(context).pop();
        this.fetch();
      });
      return;
    }
    Toasty.warning("尚未实现，敬请期待");
  }

  Widget _buildProgressIndicator() {
    if (this.noResult) {
      return NoResult(
        text: "暂无可用收藏夹。",
      );
    }
    if (this.loadError) {
      return Container(
        margin: EdgeInsets.only(top: 20.0),
        padding: EdgeInsets.only(left: 20.0, right: 20.0),
        child: MaterialButton(
          onPressed: fetch,
          height: 50.0,
          color: Theme.of(context).primaryColor,
          child: Text(
            "加载失败，点击重新加载",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
    if (this.isLoading) {
      return Container(
        margin: EdgeInsets.only(top: 20.0),
        child: Center(
          child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
        ),
      );
    }
    return EmptyWidget();
  }

  void _handleItemTaped(Map item) {
    Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (BuildContext context) => new FavoriteListPage(
                  name: item["name"],
                  id: item["_id"],
                ),
          ),
        );
  }
}

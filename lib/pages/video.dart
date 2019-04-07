import 'dart:io';
import 'package:dd_app/pages/feedback.dart';
import 'package:dd_player/player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dd_app/utils/dio.dart';

import 'package:dd_app/utils/db/record.dart';
import 'package:loading/loading.dart';
import 'package:dd_app/utils/modal.dart';
import 'package:toasty/toasty.dart';
import 'package:dd_app/widget/ad-item.dart';
import 'package:share/share.dart';

class VideoPage extends StatefulWidget {
  final Map item;
  String from;
  final String operatingSystem = Platform.operatingSystem;

  VideoPage({Key key, @required this.item, this.from}) : super(key: key);

  @override
  _VideoPageState createState() => new _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  // final double tabIconSize = 18.0;
  final List<Map> tabs = [
    {
      "icon": Icon(
        Icons.list,
        size: 18.0,
      ),
      "name": "播放列表",
    },
    {
      "icon": Icon(
        Icons.info,
        size: 18.0,
      ),
      "name": "视频介绍",
    },
    {
      "icon": Icon(
        Icons.comment,
        size: 18.0,
      ),
      "name": "用户评论",
    }
  ];
  bool isLoading = false;
  bool loadError = false;
  Map item;
  Map last;
  Map<String, List<Map>> pickedPlayItems = {};
  String playerUrl = "";

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height / 3,
              child: DdPlayer(
                url: playerUrl,
                enableDLNA: true,
                enablePip: true,
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: ListView(
                  children: buildContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildContent() {
    List<Widget> w = [];
    if (loadError) {
      w.add(Center(
        child: Container(
          height: 50.0,
          child: MaterialButton(
            onPressed: fetch,
            color: Theme.of(context).primaryColor,
            child: Text(
              "加载失败，点击重新加载",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ));
      return w;
    }
    if (isLoading) {
      w.add(Center(
        child: CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
      ));
      return w;
    }

    pickedPlayItems.forEach((key, val) {
      String type = val[0]["type"];
      String name = "外部播放";
      if (key == "m3u8") {
        name = "在线播放";
      } else if (key == "mp4") {
        name = "在线播放";
      }
      // 标题
      w.add(
        ListTile(
          title: Row(
            children: <Widget>[
              Image(
                height: 30.0,
                width: 30.0,
                image: AssetImage(
                  "images/format/" + type + ".webp",
                ),
              ),
              Container(
                width: 10.0,
              ),
              Text(
                name,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
      // 横向滚动区域
      w.add(
        SingleChildScrollView(
          padding: EdgeInsets.only(left: 10.0, right: 10.0),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _buildPlayButton(
              val.reversed.toList(),
            ),
          ),
        ),
      );
    });
    w.add(Container(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            item["name"],
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            item["region"] +
                " / " +
                item["released_at"] +
                " / " +
                item["classify"]["name"] +
                " / " +
                item["number"].toString() +
                "次播放",
            style: TextStyle(
              fontSize: 12.0,
            ),
          ),
          Text(
            "导演: " + item["director"].join(","),
            style: TextStyle(
              fontSize: 12.0,
            ),
          ),
          Text(
            "主演: " + item["starring"].join(","),
            style: TextStyle(
              fontSize: 12.0,
            ),
          ),
          Text(
            "\n简介: " + item["introduce"],
            style: TextStyle(
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    ));

    return w;
  }

  @override
  initState() {
    item = widget.item;
    // 设置来源
    if (widget.from == null) {
      widget.from = widget.operatingSystem;
    }
    super.initState();
    fetch();
    initLast();
  }

  void initLast() async {
    // 添加播放历史
    Record recordModel = await Record.instance;
    Map r = await recordModel.findObjectId(item["_id"]);
    setState(() {
      last = r;
    });
  }

  // 发起请求
  void fetch() async {
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
      loadError = false;
    });
    dynamic payload = await Fetch.instance.get("/video/" + item["_id"], data: {
      "from": widget.from,
    });
    // setState() called after dispose()
    if (!mounted) {
      return;
    }
    setState(() {
      isLoading = false;
    });
    if (payload == null) {
      setState(() {
        loadError = true;
      });
      return;
    }
    setState(() {
      item = payload;
      pickedPlayItems = _pickItems(payload["remote_url"]);
      autoPlay();
    });
  }

  void autoPlay() {
    String url = "";
    if (pickedPlayItems["m3u8"] != null) {
      url = pickedPlayItems["m3u8"][0]["url"];
    } else if (pickedPlayItems["mp4"] != null) {
      url = pickedPlayItems["mp4"][0]["url"];
    }
    if (url != "") {
      setState(() {
        playerUrl = url;
      });
    }
  }

  // 分组处理
  Map<String, List<Map>> _pickItems(List<dynamic> items) {
    Map<String, List<Map>> tmp = {};
    items.forEach((v) {
      String url = v["url"];
      String ext = "flash";
      if (url.endsWith(".m3u8")) {
        ext = "m3u8";
        v["type"] = "hls";
      } else if (url.endsWith(".mp4")) {
        ext = "mp4";
        v["type"] = "mp4";
      } else {
        v["type"] = "fla";
      }
      // 判断是否可以用自带播放器
      if (["m3u8", "mp4"].indexOf(ext) != -1) {
        v["inline"] = true;
      } else {
        v["inline"] = false;
      }
      if (tmp[ext] != null) {
        tmp[ext].add(v);
      } else {
        tmp[ext] = [v];
      }
    });
    return tmp;
  }

  // 构建单个菜单
  Widget _buildMenu({
    @required IconData icon,
    @required Color color,
    @required String text,
    @required Function onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Icon(
                icon,
                size: 32.0,
                color: color,
              ),
            ),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 10.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 打开更多剧集
  void _handleOpenMoreItem(List<Map> items) {
    ShmyDialog.customDialog(
      context,
      child: Container(
        padding: EdgeInsets.all(
          10.0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        height: MediaQuery.of(context).size.width * 1.2,
        child: SingleChildScrollView(
          child: Wrap(
            children: _buildButtons(items, []),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildButtons(List<Map> items, List<Map> allItems) {
    return items.map((v) {
      if (v == null) {
        // ... 按钮
        return FlatButton(
          onPressed: () => _handleOpenMoreItem(allItems),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.more_horiz,
                color: Theme.of(context).primaryColor,
              ),
              Icon(
                Icons.more_horiz,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
        );
      }
      String tag = v["tag"];
      String url = v["url"];
      bool inline = v["inline"];
      return FlatButton(
        onPressed: () => _handlePlayItemTap(
            item["name"], tag, url, item["thumbnail"], inline),
        child: Text(
          tag,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }).toList();
  }

  // 构建播放按钮
  List<Widget> _buildPlayButton(List<Map> items) {
    List<Map> mItems = [];
    if (items.length > 24) {
      // 节约性能 大于24个不再全部显示
      mItems = items.take(5).toList();
      mItems.add(null);
      mItems.addAll(items.reversed.take(5).toList().reversed);
    } else {
      mItems = items;
    }
    return _buildButtons(mItems, items);
  }

  void _handlePlayItemTap(
      String name, String tag, String url, String pic, bool inline) {
    if (url.startsWith("http://") && !url.endsWith(".mp4")) {
      url = url.replaceFirst("http://", "https://"); // 公司必须要https
    }
    if (pic.startsWith("http://")) {
      pic = pic.replaceFirst("http://", "https://"); // 公司必须要https
    }
    setState(() {
      playerUrl = url;
    });
  }

  void _handleSelectFavorite() async {
    // 如果正在加载或加载失败不做处理
    if (loadError || isLoading) return;
    // 如果已经收藏 进取消收藏
    if (item["favorited"] == true) {
      _handleCancelFavorite();
      return;
    }
    Loading.show();
    dynamic payload = await Fetch.instance.get("/favorite");
    Loading.hide();
    if (payload == null) return;
    // 如果已有收藏夹 自动新建一个
    if (payload.length == 0) {
      _handleInitFavorite();
      return;
    }
    ShmyDialog.chooseFavorite(
      context,
      title: "选择一个收藏夹",
      selection: payload,
      selectedFn: (v) {
        _handleSetFavorite(v);
      },
    );
  }

  // 取消收藏一个视频
  void _handleCancelFavorite() async {
    Loading.show();
    dynamic payload =
        await Fetch.instance.post("/favorite/remove_video", data: {
      "vid": item["_id"],
    });
    Loading.hide();
    if (payload == null) return;
    setState(() {
      item["favorited"] = payload["favorited"];
      item["favorited_count"] = payload["favorited_count"];
    });
    Toasty.success("取消成功");
  }

  // 收藏一个视频
  void _handleSetFavorite(Map v) async {
    Loading.show();
    dynamic payload = await Fetch.instance.post("/favorite/add_video", data: {
      "vid": item["_id"],
      "fid": v["_id"],
    });
    Loading.hide();
    if (payload == null) {
      return;
    }
    setState(() {
      item["favorited"] = payload["favorited"];
      item["favorited_count"] = payload["favorited_count"];
    });
    Toasty.success("收藏好了");
  }

  // 初始化一个文件夹
  void _handleInitFavorite() async {
    Loading.show();
    dynamic payload = await Fetch.instance.post("/favorite", data: {
      "name": "默认收藏夹",
    });
    Loading.hide();
    if (payload == null) return;
    _handleSelectFavorite();
  }

  // 构建广告位
  void _showAd(Map item) {
    if (item == null) return;
    double width = MediaQuery.of(context).size.width;
    ShmyDialog.customDialog(
      context,
      child: AdItem(
        imageUrl: item["image"],
        action: item["action"],
        width: width,
        height: width * item["height"],
      ),
    );
  }

  // 投诉
  void handleComplaints() {
    Navigator.of(context).push(
      new CupertinoPageRoute(
        builder: (context) => new FeedbackPage(
              appBarTitle: "版权投诉",
              titleHintText: "请输入投诉标题",
              titleHelperText: "包含投诉的视频名称",
              titleDefaultText: "我要投诉 ${item["name"]}",
              contentHintText: "请输入投诉证据",
              contentHelperText: "务必提供有力证明",
              // contentDefaultText: "",
            ),
      ),
    );
  }

  // 报错
  void _handleError() {
    Navigator.of(context).push(
      new CupertinoPageRoute(
        builder: (context) => new FeedbackPage(
              appBarTitle: "视频报错",
              titleHintText: "请输入视频名称",
              titleHelperText: "包含报错的视频名称",
              titleDefaultText: "我要报错 ${item["name"]}",
              contentHintText: "请输入报错内容",
              contentHelperText: "比如某集不能播放等等",
              // contentDefaultText: "",
            ),
      ),
    );
  }

  // 分享
  void _handleShare() {
    // Toasty.info("正在开发中...");
    Share.share(
        '我正在黑人视频看[${item["name"]}]，在线观看：https://dd.shmy.tech/client/video/${item["_id"]}，下载APP：https://dd.shmy.tech/download');
  }
}

class ShmyChip extends StatelessWidget {
  final String text;

  ShmyChip({@required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.all(
          Radius.circular(3.0),
        ),
      ),
      margin: EdgeInsets.only(
        bottom: 5.0,
      ),
      padding: EdgeInsets.only(
        left: 10.0,
        right: 10.0,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16.0,
          color: Colors.white,
        ),
      ),
    );
  }
}

class WhiteText extends StatelessWidget {
  final String text;
  final int maxLines;

  WhiteText({@required this.text, this.maxLines: 1});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16.0,
        color: Colors.white,
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}

import 'dart:io';
import 'package:dd_app/pages/feedback.dart';
import 'package:flutter/cupertino.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:dd_app/utils/dio.dart';
import 'package:dd_app/utils/util.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dd_app/widget/photo-hero.dart';
import 'package:dd_app/utils/db/record.dart';
import 'package:loading/loading.dart';
import 'package:dd_app/utils/modal.dart';
import 'package:toasty/toasty.dart';
import 'package:dd_app/widget/cached-image.dart';
import 'package:dd_app/widget/ad-item.dart';
import 'package:dd_app/widget/empty-widget.dart';
// import 'package:dd_app/widget/number.dart';
import 'package:share/share.dart';
import 'dart:ui' as ui;

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

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
  Map<String, List<Map>> pickedPlayItems = {};
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double expandedHeight = width * 1.05;
    return Scaffold(
      body: DefaultTabController(
        length: tabs.length,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                // SliverAppBar!
                elevation: 0.0,
                expandedHeight: expandedHeight,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  // title: 
                  title: Shimmer.fromColors(
                    baseColor: Colors.white,
                    highlightColor: Theme.of(context).primaryColor,
                    period: Duration(milliseconds: 6000),
                    child: Text(
                      item["name"],
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                      // textAlign: TextAlign.center,
                    ),
                  ),
                  background: _buildBackgroundCover(),
                ),
                actions: <Widget>[
                  IconButton(
                    onPressed: fetch,
                    icon: Icon(
                      Icons.refresh,
                      size: 28.0,
                    ),
                  )
                ],
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    labelColor: Theme.of(context).primaryColor,
                    labelStyle: TextStyle(
                      fontSize: 16.0,
                    ),
                    unselectedLabelColor: Colors.grey[500],
                    indicatorColor: Theme.of(context).primaryColor,
                    indicatorWeight: 3.0,
                    tabs: tabs.map<Tab>((v) {
                      return Tab(
                        child: Row(
                          children: <Widget>[
                            v["icon"],
                            Container(
                              width: 3.0,
                            ),
                            Expanded(
                              child: Text(
                                v["name"],
                                style: TextStyle(
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                pinned: true,
              )
            ];
          },
          body: _buildTableView(),
        ),
      ),
    );
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
    });
  }

  // 构建模糊背景图
  Widget _buildBackgroundCover() {
    double width = MediaQuery.of(context).size.width / 2 - 2;
    return Container(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0.0,
            left: 0.0,
            bottom: 0.0,
            right: 0.0,
            child: CachedImage(
              item["thumbnail"],
              fit: BoxFit.fitWidth,
            ),
          ),
          Positioned(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                decoration: BoxDecoration(color: Colors.black.withAlpha(60)),
              ),
            ),
          ),
          Positioned(
            top: 100.0,
            left: 0.0,
            bottom: 0.0,
            right: 0.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // 左边图
                Container(
                  height: width * 1.35,
                  margin: EdgeInsets.only(left: 10.0),
                  width: width,
                  child: PhotoHero(
                    item: widget.item,
                  ),
                  decoration: BoxDecoration(
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Color(0xcc000000),
                        offset: Offset(0.0, 2.0),
                        blurRadius: 4.0,
                      ),
                      BoxShadow(
                        color: Color(0x80000000),
                        offset: Offset(0.0, 4.0),
                        blurRadius: 10.0,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 10.0,
                ), // 留点空隙
                // 右边描述
                Expanded(
                  // height: width * 1.35,
                  // width: width,
                  // color: Colors.red,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      item["number"] != null
                          ? ShmyChip(
                              text: item["classify"]["name"],
                            )
                          : EmptyWidget(),
                      item["number"] != null
                          ? WhiteText(
                              text: '${item["language"]} / ${item["region"]}',
                            )
                          : EmptyWidget(),
                      item["number"] != null
                          ? WhiteText(
                              text:
                                  '${item["released_at"]} / ${item["running_time"] == 0 ? '内详时长' : item["running_time"].toString() + "分钟" }',
                            )
                          : EmptyWidget(),
                      item["number"] != null
                          ? WhiteText(
                              text: '${item["latest"]}',
                              maxLines: 2,
                            )
                          : EmptyWidget(),
                      item["number"] != null
                          ? WhiteText(
                              text: '${item["number"]}次浏览',
                            )
                          : EmptyWidget(),
                      // item["number"] != null
                      //     ? WhiteText(
                      //         text: '${item["favorited_count"]}人收藏',
                      //       )
                      //     : EmptyWidget(),
                      item["number"] != null
                          ? Row(
                              children: <Widget>[
                                Image(
                                  height: 20.0,
                                  width: 20.0,
                                  image: AssetImage(
                                    Util.getTypeIcon(item["source"]),
                                  ),
                                ),
                                Container(
                                  width: 5.0,
                                ),
                                Expanded(
                                  child: WhiteText(
                                    text:
                                        '收录于${Util.getTimeago(DateTime.parse(item["generated_at"]))}',
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            )
                          : EmptyWidget(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建tableview
  Widget _buildTableView() {
    if (loadError) {
      return Center(
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
      );
    }
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
      );
    }

    return TabBarView(
      children: <Widget>[
        ListView(
          padding: EdgeInsets.zero,
          children: _buildPlayButtonExpansionTile(),
        ),
        ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Padding(
              // 片名
              padding: EdgeInsets.all(10.0),
              child: item["name"] != null
                  ? Text(
                      "视频名称：" + item["name"],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16.0,
                      ),
                    )
                  : null,
            ),
            Padding(
              // 别名
              padding: EdgeInsets.all(10.0),
              child: item["alias"] != null
                  ? Text(
                      "视频别名：" + item["alias"].join(","),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16.0,
                      ),
                    )
                  : null,
            ),
            Padding(
              // 导演
              padding: EdgeInsets.all(10.0),
              child: item["director"] != null
                  ? Text(
                      "导演：" + item["director"].join(","),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16.0,
                      ),
                    )
                  : null,
            ),
            Padding(
              // 主演
              padding: EdgeInsets.all(10.0),
              child: item["starring"] != null
                  ? Text(
                      "主演：" + item["starring"].join(","),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16.0,
                      ),
                    )
                  : null,
            ),
            Padding(
              // 简介
              padding: EdgeInsets.all(10.0),
              child: item["introduce"] != null
                  ? Text(
                      "视频简介：" +
                          (item["introduce"] != "" ? item["introduce"] : "暂无"),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16.0,
                      ),
                    )
                  : null,
            ),
          ],
        ),
        ListView(
          padding: EdgeInsets.zero,
          children: [
            Center(
              child: Text("功能开发中，敬请期待。"),
            ),
          ],
        ),
      ],
    );
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

  List<Widget> _buildPlayButtonExpansionTile() {
    bool favorited = item["favorited"] ?? false;
    List<Widget> w = [];
    w.add(Container(
      height: 50.0,
      margin: EdgeInsets.only(
        bottom: 0.0,
        top: 10.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildMenu(
            icon: favorited ? Icons.favorite : Icons.favorite_border,
            text: item["favorited_count"].toString(),
            color: favorited ? Theme.of(context).primaryColor : Colors.black,
            onTap: _handleSelectFavorite,
          ),
          _buildMenu(
            icon: Icons.warning,
            text: "投诉",
            color: Colors.blue,
            onTap: handleComplaints,
          ),
          _buildMenu(
            icon: Icons.error,
            text: "报错",
            color: Colors.red,
            onTap: _handleError,
          ),
          _buildMenu(
            icon: Icons.share,
            text: "分享",
            color: Colors.orange,
            onTap: _handleShare,
          ),
        ],
      ),
    ));
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
                  fontSize: 17.0,
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

    return w;
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
            fontSize: 16.0,
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

  // 播放按钮点击事件
  void _handlePlayItemTap(
      String name, String tag, String url, String pic, bool inline) async {
    // mp4 不支持https
    if (url.startsWith("http://") && !url.endsWith(".mp4")) {
      url = url.replaceFirst("http://", "https://"); // 公司必须要https
    }
    if (pic.startsWith("http://")) {
      pic = pic.replaceFirst("http://", "https://"); // 公司必须要https
    }
    // 添加播放历史
    Record recordModel = await Record.instance;
    await recordModel.upsert(item["_id"], {
      "_id": item["_id"],
      "name": item["name"],
      "pic": item["thumbnail"],
      "tag_name": tag,
      "tag_time": 0,
      "time": DateTime.now().millisecondsSinceEpoch
    });
    print(Platform.isAndroid);
    print(Platform.isIOS);

    // 显示广告
    if (item["ads"] != null && item["ads"][0] != null) {
      _showAd(item["ads"][0]);
    }

    if (!inline) {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        print('Could not launch $url');
      }
      return;
    }
    bool isHlS = url.toLowerCase().endsWith(".m3u8");

    // 点播 hls需要exo2内核 并且硬件解码 mp4 需要ijk内核 软件解码
    // await VideoPlayer.play(
    //   name + "-" + tag + "【黑人视频】",
    //   url,
    //   pic,
    //   kernel: isHlS ? 2 : 0,
    // );
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
  void _handleError () {
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
  void _handleShare () {
    // Toasty.info("正在开发中...");
    Share.share('我正在黑人视频看[${item["name"]}]，在线观看：https://dd.shmy.tech/client/video/${item["_id"]}，下载APP：https://dd.shmy.tech/download');
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

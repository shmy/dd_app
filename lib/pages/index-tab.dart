import 'package:dd_app/widget/empty-widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:dd_app/utils/dio.dart';
import 'dart:async';
import 'package:dd_app/pages/video.dart';
import 'package:dd_app/widget/cached-image.dart';
import 'package:dd_app/widget/photo-hero.dart';
import 'package:dd_app/widget/ad-item.dart';
import 'package:dd_app/utils/action.dart';
import 'package:dd_app/utils/util.dart';

class IndexTabPage extends StatefulWidget {
  String id;
  String name;
  IndexTabPage({Key key, @required this.id, @required this.name})
      : super(key: key);
  @override
  _IndexTabPageState createState() => _IndexTabPageState();
}

/**
 * 目前支持的调起类型
 * # video -> 根据视频id跳转到视频详情
 * # webview -> 根据给定的网址跳转
 */
class _IndexTabPageState extends State<IndexTabPage>
    with AutomaticKeepAliveClientMixin {
  Map items = {
    "banner": <Map>[],
    "hots": <Map>[],
    "latests": <Map>[],
    "ads": <Map>[]
  };
  bool initialized = false; // 是否初始化过
  bool isLoading = false;
  bool loadError = false;
  bool noResult = false;
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        color: Theme.of(context).primaryColor,
        onRefresh: refresh,
        child: initialized
            ? ListView(
                children: _buildView(),
              )
            : _buildProgressIndicator(),
      ),
    );
  }

  // 刷新
  Future<Null> refresh() async {
    if (isLoading) {
      return null;
    }
    await fetch();
  }

  Future<bool> fetch() async {
    setState(() {
      isLoading = true;
      loadError = false;
      noResult = false;
    });
    dynamic payload = await Fetch.instance.get("/v2/video/index", data: {
      "id": widget.id,
    });
    // setState() called after dispose()
    if (!mounted) {
      return false;
    }
    setState(() {
      isLoading = false;
    });
    if (payload == null) {
      setState(() {
        loadError = true;
      });
      return false;
    }
    setState(() {
      items["banner"] = payload["banner"].cast<Map>(); // 这是类型转换？
      items["hots"] = payload["hots"].cast<Map>(); // 这是类型转换？
      items["latests"] = payload["latests"].cast<Map>(); // 这是类型转换？
      items["ads"] = payload["ads"].cast<Map>(); // 这是类型转换？
      initialized = true;
    });
    return true;
  }

  // 加载更多
  Widget _buildProgressIndicator() {
    if (noResult) {
      return Center(
        child: Text(": ( 没有找到符合条件的数据。"),
      );
    }
    if (loadError) {
      return Center(
        child: MaterialButton(
          height: 50.0,
          onPressed: refresh,
          color: Theme.of(context).primaryColor,
          child: Text(
            "加载失败，点击重新加载",
            style: TextStyle(color: Colors.white),
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
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  List<Widget> _buildView() {
    double width = MediaQuery.of(context).size.width;
    List<Widget> w = [];
    // banner
    if (items["banner"].length != 0) {
      w.add(
        Container(
          height: width * 0.65,
          child: Swiper(
            itemBuilder: (BuildContext context, int index) {
              Map banner = items["banner"][index];
              return _buildBanner(banner);
            },
            itemCount: items["banner"].length,
            // viewportFraction: 0.93,
            // scale: 0.97,
            autoplay: true,
            pagination: SwiperPagination(
              alignment: Alignment.bottomRight,
            ),
          ),
        ),
      );
    }

    // 最近更新的
    if (items["latests"].length != 0) {
      w.add(_buildTitle("最近更新的"));
      w.add(Wrap(runSpacing: 4.0, children: _buildGrid(items["latests"])));
    }
    // 广告 1
    if (items["ads"][0] != null) {
      w.add(_buildAd(items["ads"][0]));
    }
    // 近期热门的
    if (items["hots"].length != 0) {
      w.add(_buildTitle("近期热门的"));
      w.add(Wrap(runSpacing: 4.0, children: _buildGrid(items["hots"])));
    }
    // 广告2
    if (items["ads"][1] != null) {
      w.add(_buildAd(items["ads"][1]));
    }

    return w;
  }

  // 构建banner
  Widget _buildBanner(Map banner) {
    // bool isGoToVideo = banner["action"]["type"] == "video";
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: CachedImage(banner["image"]),
        ),
        Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: Container(
            height: 40.0,
            padding: EdgeInsets.only(
              left: 10.0,
              right: 10.0,
            ),
            color: Color.fromRGBO(0, 0, 0, 0.5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                banner["name"],
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () => Action.handleAction(context, banner["action"]),
            ),
          ),
        ),
      ],
    );
  }

  // 构建网格布局
  List<Widget> _buildGrid(List<Map> items) {
    double width = MediaQuery.of(context).size.width;

    return List.generate(items.length, (index) {
      Map item = items[index]; // TODO 获取index的优化
      item["timestamp"] = DateTime.now().millisecondsSinceEpoch.toString();
      bool isOdd = index % 2 != 0;
      double mwidth = width / 2;
      return Container(
        width: mwidth,
        height: mwidth * 1.3 - 20,
        padding: EdgeInsets.only(
          left: isOdd ? 2.0 : 0.0,
          right: !isOdd ? 2.0 : 0.0,
        ),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: PhotoHero(item: item),
            ),
            Positioned(
              top: 0.0,
              left: 0.0,
              child: Container(
                height: 20.0,
                padding: EdgeInsets.only(left: 5.0, right: 5.0),
                color: Color.fromRGBO(0, 0, 0, 0.5),
                child: Center(
                  child: Text(
                    item["latest"],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.0,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0.0,
              bottom: 0.0,
              right: 0.0,
              child: Container(
                height: 26.0,
                color: Color.fromRGBO(0, 0, 0, 0.5),
                padding: EdgeInsets.only(left: 5.0, right: 5.0),
                child: Center(
                  child: Text(
                    item["name"] +
                        "(" +
                        Util.getTimeago(DateTime.parse(item["generated_at"])) +
                        ")",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4.0,
              right: 4.0,
              child: Image(
                width: 20.0,
                height: 20.0,
                image: AssetImage(
                  Util.getTypeIcon(item["source"]),
                ),
              ),
            ),
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () => _handleMovieTap(item),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // 构建广告位
  Widget _buildAd(Map item) {
    if (item == null) return EmptyWidget();
    double width = MediaQuery.of(context).size.width;
    return AdItem(
      imageUrl: item["image"],
      action: item["action"],
      width: width,
      height: width * item["height"],
    );
  }

  // 构建title
  Widget _buildTitle(String prefix) {
    return Container(
      margin: EdgeInsets.only(bottom: 4.0),
      child: ListTile(
        // TODO 实现点击事件
        // onTap: () {},
        title: Text(
          "${prefix}${widget.name}",
          style: TextStyle(
            fontSize: 16.0,
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        // trailing: Icon(
        //   Icons.keyboard_arrow_right,
        //   color: Colors.black,
        //   size: 30.0,
        // ),
      ),
    );
  }

  void _handleMovieTap(Map item) {
    Navigator.of(context).push(
          new CupertinoPageRoute(
              builder: (context) => new VideoPage(item: item)),
        );
  }
}

import 'package:dd_app/pages/video.dart';
import 'package:dd_app/widget/cached-image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:dd_app/utils/dio.dart';

import 'package:flutter_swiper/flutter_swiper.dart';

class SeriesPage extends StatefulWidget {
  final Map item;
  SeriesPage({Key key, @required this.item}) : super(key: key);
  @override
  _SeriesPageState createState() => _SeriesPageState();
}

class _SeriesPageState extends State<SeriesPage> {
  List<dynamic> items = [];
  String intro = "";
  int currentIndex = 0;
  bool isLoading = false;
  bool loadError = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildContent(),
    );
  }

  Widget _buildBackground() {
    String thumbnail = "";
    if (items.length != 0) {
      thumbnail = items[currentIndex]["video"]["thumbnail"];
    }
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: CachedImage(
            thumbnail,
            fit: BoxFit.fill,
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              decoration: BoxDecoration(color: Colors.black.withAlpha(60)),
            ),
          ),
        ),
        Positioned.fill(
          child: Column(
            children: <Widget>[
              _buildHeader(),
              _buildIntro(),
              Expanded(
                child: _buildBanners(),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBanners() {
    // bool isGoToVideo = banner["action"]["type"] == "video";
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double describeHeight =
        height < 600 ? 120.0 : 200.0; // TODO 适配 4寸 - 4.5寸之间的
    return Container(
      height: height - 200,
      width: width,
      // color: Colors.red,
      child: Swiper(
        onIndexChanged: (int i) {
          setState(() {
            currentIndex = i;
          });
        },
        itemBuilder: (BuildContext context, int index) {
          Map item = items[index];
          return ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            ),
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 0.0,
                  left: 0.0,
                  right: 0.0,
                  bottom: describeHeight,
                  child: CachedImage(
                    item["video"]["thumbnail"],
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned(
                  left: 0.0,
                  bottom: 0.0,
                  child: Container(
                    height: describeHeight,
                    width: width,
                    color: Colors.white,
                    child: _buildDescribe(item),
                  ),
                ),
                Positioned.fill(
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: () => _handleItemTaped(item["video"]),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        itemCount: items.length,
        viewportFraction: 0.8,
        scale: 0.95,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: EdgeInsets.only(
        top: 30.0,
      ),
      height: 50.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Text(
              widget.item["name"],
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro() {
    return Container(
      padding: EdgeInsets.only(
        left: 40.0,
        right: 40.0,
        bottom: 20.0,
      ),
      child: Center(
        child: Text(
          intro,
          style: TextStyle(
            color: Colors.white,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      height: 50.0,
      // color: Colors.blue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.baseline,
        children: <Widget>[
          Text(
            (currentIndex + 1).toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
            ),
          ),
          Text(
            "/",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14.0,
            ),
          ),
          Text(
            items.length.toString(),
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescribe(Map item) {
    Map video = item["video"];
    return ListView(
      padding: EdgeInsets.only(
        top: 0.0,
        left: 10.0,
        right: 10.0,
      ),
      children: <Widget>[
        Text(
          video["name"],
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          "${video["language"]} / ${video["released_at"]}",
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[600],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text.rich(
          TextSpan(
            // text: 'Hello ',
            style: TextStyle(
              color: Colors.grey[600],
            ),
            children: <TextSpan>[
              TextSpan(
                text: '“',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30.0,
                ),
              ),
              TextSpan(
                text: item["describe"],
              ),
              TextSpan(
                text: '”',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleItemTaped(Map item) {
    Navigator.of(context).push(
          new CupertinoPageRoute(
            builder: (context) => new VideoPage(
                  item: item,
                ),
          ),
        );
  }

  Widget _buildButtons({@required Widget child, String exitText = "取消"}) {
    return Center(
      child: Container(
        height: 100.0,
        child: Column(
          children: <Widget>[
            child,
            Container(
              height: 20.0,
            ),
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              color: Theme.of(context).primaryColor,
              child: Text(
                exitText,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return _buildButtons(
        child: CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
      );
    }
    if (loadError) {
      return _buildButtons(
          child: MaterialButton(
            onPressed: () => fetch(),
            color: Theme.of(context).primaryColor,
            child: Text(
              "加载失败，点击重新加载",
              style: TextStyle(color: Colors.white),
            ),
          ),
          exitText: "退出播单");
    }
    return _buildBackground();
  }

  Future<bool> fetch() async {
    setState(() {
      this.isLoading = true;
      this.loadError = false;
    });
    dynamic payload = await Fetch.instance.get(
      "/series/" + widget.item["_id"],
    );
    // setState() called after dispose()
    if (!mounted) {
      return false;
    }
    setState(() {
      this.isLoading = false;
    });
    if (payload == null) {
      setState(() {
        this.loadError = true;
      });
      return false;
    }
    setState(() {
      // 如果本次没有数据
      items = payload["series"];
      intro = payload["intro"];
    });
    return true;
  }
}

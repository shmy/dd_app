import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dd_app/utils/dio.dart';
import 'dart:async';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:dd_app/widget/photo-hero.dart';
import 'package:dd_app/pages/video.dart';
import 'package:dd_app/utils/util.dart';

class FavoriteListPage extends StatefulWidget {
  String name;
  String id;
  FavoriteListPage({Key key, this.name, this.id}) : super(key: key);
  @override
  _FavoriteListPageState createState() => _FavoriteListPageState();
}

class _FavoriteListPageState extends State<FavoriteListPage> {
  List<dynamic> items = [];
  Map paging = {"page": 1, "per_page": 20};
  ScrollController _scrollController = new ScrollController();
  bool isLoading = false;
  bool loadError = false;
  bool noResult = false;
  bool noMore = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: <Widget>[
          IconButton(
            onPressed: () => refresh(),
            icon: Icon(
              Icons.refresh,
              size: 28.0,
            ),
          ),
        ],
        elevation: 0.0,
      ),
      body: StaggeredGridView.countBuilder(
        controller: this._scrollController,
        crossAxisCount: 4, // 4列
        itemCount: this.items.length + 1,
        itemBuilder: (BuildContext context, int index) =>
            _buildMovieItem(index),
        staggeredTileBuilder: (int index) {
          if (index == this.items.length) {
            return StaggeredTile.count(4, 0.7);
          }
          return StaggeredTile.count(2, 2.6);
        }, // 列宽 和 高
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.refresh();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        this.loadMore();
      }
    });
  }

  // 刷新
  Future<Null> refresh() async {
    if (this.isLoading) {
      return null;
    }
    int oldPage = this.paging["page"];
    this.paging["page"] = 1;
    if (!await fetch()) {
      this.paging["page"] = oldPage;
    }
  }

  // 加载下一页
  Future<Null> loadMore() async {
    if (this.isLoading) {
      return null;
    }
    this.paging["page"]++;
    if (!await fetch()) {
      this.paging["page"]--;
    }
  }

  Future<bool> fetch() async {
    setState(() {
      this.isLoading = true;
      this.loadError = false;
      this.noResult = false;
      this.noMore = false;
    });
    dynamic payload =
        await Fetch.instance.get("/collection/" + widget.id, data: this.paging);
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
      if (payload["result"].length == 0) {
        if (this.paging["page"] == 1) {
          this.noResult = true;
        } else {
          this.noMore = true;
        }
      }
      // 如果是第一页
      if (this.paging["page"] == 1) {
        this.items = payload["result"];
        this._scrollController.jumpTo(0.0);
      } else {
        // 否则
        var items = this.items;
        items.addAll(payload["result"]);
        this.items = items;
      }
    });
    return true;
  }

  Widget _buildMovieItem(int i) {
    // 加载指示器
    if (i == this.items.length) {
      return _buildProgressIndicator();
    }

    Map item = this.items[i];
    Map video = item["video"];
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: PhotoHero(
            item: video,
          ),
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
                  video["latest"],
                  style: TextStyle(color: Colors.white, fontSize: 10.0),
                ),
              )),
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
                video["name"] +
                    "(" +
                    Util.getTimeago(DateTime.parse(video["generated_at"])) +
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
              Util.getTypeIcon(video["source"]),
            ),
          ),
        ),
        Positioned.fill(
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () => _handleMovieTap(video),
            ),
          ),
        ),
      ],
    );
  }

  // 加载更多
  Widget _buildProgressIndicator() {
    if (this.noMore) {
      return Center(
        child: Text(": ( 没有更多数据了。"),
      );
    }
    if (this.noResult) {
      return Center(
        child: Text(": ( 没有找到符合条件的数据。"),
      );
    }
    if (this.loadError) {
      return MaterialButton(
        onPressed: () {
          // 当前列表没有数据 那么应该刷新
          if (this.items.length == 0) {
            refresh();
          } else {
            // 否则是重新加载下一页
            loadMore();
          }
        },
        color: Theme.of(context).primaryColor,
        child: Text(
          "加载失败，点击重新加载",
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    if (this.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
      );
    }
    return null;
  }

  void _handleMovieTap(Map item) {
    Navigator.of(context).push(
          new CupertinoPageRoute(
              builder: (context) => new VideoPage(item: item)),
        );
  }
}

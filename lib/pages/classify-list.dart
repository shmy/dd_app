import 'package:dd_app/widget/filterbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dd_app/utils/dio.dart';
import 'dart:async';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:dd_app/pages/video.dart';
import 'package:dd_app/widget/photo-hero.dart';
import 'package:dd_app/utils/util.dart';

class ClassifyListPage extends StatefulWidget {
  final String id;
  final String name;
  ClassifyListPage({Key key, @required this.id, @required this.name})
      : super(key: key);
  @override
  _ClassifyPageListState createState() => new _ClassifyPageListState();
}

class _ClassifyPageListState extends State<ClassifyListPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  List<dynamic> items = [];
  Map paging = {"page": 1, "per_page": 20};
  FilterIndexState initIndex = const FilterIndexState();
  Map filterParam = {
    "year": "",
    "area": "",
    "sort": "2",
    "query": "2",
    "source": "",
    "classindex": "",
  };
  ScrollController _scrollController = new ScrollController();
  bool isLoading = false;
  bool loadError = false;
  bool noResult = false;
  bool noMore = false;
  bool isOpen = false;
  @override
  initState() {
    super.initState();
    _scrollController.addListener(() {
      if (isOpen) {
        setState(() {
          isOpen = false;
        });
      }
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        loadMore();
      }
    });
    refresh();
  }

  // 刷新
  Future<Null> refresh() async {
    if (isLoading) {
      return null;
    }
    int oldPage = paging["page"];
    paging["page"] = 1;
    if (!await fetch()) {
      paging["page"] = oldPage;
    }
  }

  // 加载下一页
  Future<Null> loadMore() async {
    if (isLoading) {
      return null;
    }
    paging["page"]++;
    if (!await fetch()) {
      paging["page"]--;
    }
  }

  Future<bool> fetch() async {
    setState(() {
      isLoading = true;
      loadError = false;
      noResult = false;
      noMore = false;
    });

    dynamic payload = await Fetch.instance.get("/classification/" + widget.id,
        data: {}..addAll(paging)..addAll(filterParam));
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
      // 如果本次没有数据
      if (payload["result"].length == 0) {
        if (paging["page"] == 1) {
          noResult = true;
        } else {
          noMore = true;
        }
      }
      // 如果是第一页
      if (paging["page"] == 1) {
        items = payload["result"];
        _scrollController.jumpTo(0.0);
      } else {
        // 否则
        items = items..addAll(payload["result"]);
      }
    });
    return true;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            tooltip: "过滤",
            onPressed: () {
              setState(() {
                isOpen = !isOpen;
              });
            },
            icon: Icon(Icons.sort),
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        color: Theme.of(context).primaryColor,
        onRefresh: () => refresh(),
        child: Column(
          children: <Widget>[
            FilterBarWidget(
              // 过滤条
              isOpen: isOpen,
              onChange: (e) {
                setState(() {
                  filterParam = e;
                  _refreshIndicatorKey.currentState.show();
                });
              },
              initIndex: initIndex,
            ),
            Expanded(
              child: StaggeredGridView.countBuilder(
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
            ),
          ],
        ),
        // child: StaggeredGridView.countBuilder(
        //   controller: this._scrollController,
        //   crossAxisCount: 4, // 4列
        //   itemCount: this.items.length + 1,
        //   itemBuilder: (BuildContext context, int index) =>
        //       _buildMovieItem(index),
        //   staggeredTileBuilder: (int index) {
        //     if (index == this.items.length) {
        //       return StaggeredTile.count(4, 0.7);
        //     }
        //     return StaggeredTile.count(2, 2.6);
        //   }, // 列宽 和 高
        //   mainAxisSpacing: 4.0,
        //   crossAxisSpacing: 4.0,
        //   physics: BouncingScrollPhysics(),
        //   padding: EdgeInsets.only(
        //     top: 4.0,
        //     bottom: 4.0,
        //   ),
        // ),
      ),
    );
  }

  Widget _buildMovieItem(int i) {
    // 加载指示器
    if (i == this.items.length) {
      return _buildProgressIndicator();
    }

    Map item = this.items[i];
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: PhotoHero(
            item: item,
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
                  item["latest"],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.0,
                  ),
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
      return Padding(
        padding: EdgeInsets.only(
          left: 20.0,
          top: 10.0,
          right: 20.0,
        ),
        child: MaterialButton(
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
      new CupertinoPageRoute(builder: (context) => new VideoPage(item: item)),
    );
  }
  // Future<Null> _handleRefresh() async {
  //   await this.fetch(true);
  //   return null;
  // }

}

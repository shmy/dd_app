import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dd_app/pages/search.dart';
// import 'package:dd_app/pages/player.dart';
import 'package:dd_app/pages/index-tab.dart';

import 'package:dd_app/mixins/pageState.dart';

class IndexPage extends StatefulWidget {
  IndexPage({Key key}) : super(key: key);
  @override
  IndexPageState createState() => IndexPageState();
}

class IndexPageState extends State<IndexPage>
    with SingleTickerProviderStateMixin implements PageState {


  void onShow() {
    print('IndexPageState 呵呵呵1');
  }

  int tabIndex = 0;
  List<Map> list = [
    {"name": "电影", "_id": "5b1362ab30763a214430d036"},
    {"name": "连续剧", "_id": "5b1fce6330025ae5371a6a8a"},
    {"name": "综艺", "_id": "5b1fd85730025ae5371abaed"},
    {"name": "动漫", "_id": "5b1fdbee30025ae5371ac363"},
  ];
  TabController _tabController;
  List<Tab> tabs = [];
  List<Widget> tabBarViews = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabs = list.map((item) {
      return Tab(
        child: Text(item["name"]),
      );
    }).toList();
    tabBarViews = list.map((item) {
      return IndexTabPage(
        id: item["_id"],
        name: item["name"],
      );
    }).toList();
    _tabController = new TabController(
      vsync: this,
      length: tabs.length,
      initialIndex: tabIndex,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: null,
        titleSpacing: 0.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TabBar(
              isScrollable: true,
              indicatorColor: Colors.transparent,
              labelStyle: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
              tabs: tabs,
              controller: _tabController,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _handleSearchTap,
            icon: Icon(
              Icons.search,
              size: 28.0,
            ),
          ),
        ],
        elevation: 0.0,
      ),
      body: TabBarView(
        controller: _tabController,
        children: tabBarViews,
      ),
    );
  }

  void _handleSearchTap() {
    Navigator.of(context).push(
          new MaterialPageRoute(
              builder: (context) => new SearchPage(), fullscreenDialog: true),
              // builder: (context) => new PlayerPage(), fullscreenDialog: true),
        );
  }
}

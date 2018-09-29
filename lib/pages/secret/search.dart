import 'package:dd_app/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dd_app/utils/dio.dart';
import 'package:dd_app/pages/video.dart';
import 'package:dd_app/pages/secret/search-result.dart';
import 'package:toasty/toasty.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => new _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _controller = new TextEditingController();
  List<Map> items = [];
  String keyword = "";
  final String FROM = "search";

  @override
  initState() {
    super.initState();
  }

  void fetch() async {
    dynamic payload = await Fetch.instance.get("/v2/video/search_secret",
        data: {"keyword": keyword, "page": 1, "per_page": 10});
    if (payload != null) {
      setState(() {
        items = payload["result"].cast<Map>(); // 这是类型转换？;
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_downward),
          ),
          title: TextField(
            controller: _controller,
            onChanged: _handleChanged,
            onSubmitted: (String value) => _handleSearchSubmitted(value),
            decoration: InputDecoration(
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.white,
                hintText: "请输入视频关键字搜索"),
            style: TextStyle(color: Colors.black, fontSize: 16.0),
            autofocus: true,
            keyboardType: TextInputType.text,
          ),
          elevation: 0.0,
          actions: [
            keyword.isEmpty
                ? IconButton(
                    onPressed: () => _handleSearchSubmitted(keyword),
                    icon: Icon(
                      Icons.search,
                      size: 28.0,
                    ),
                  )
                : IconButton(
                    onPressed: () {
                      _controller.clear();
                      setState(() {
                        keyword = '';
                        items = [];
                      });
                    },
                    icon: Icon(
                      Icons.clear,
                      size: 28.0,
                    ),
                  ),
          ],
        ),
        body: ListView(
          physics: BouncingScrollPhysics(),
          children: _buildQuickItem(),
        ));
  }

  void _handleChanged(value) {
    setState(() => keyword = value);
    if (value == "") {
      setState(() => items = []);
      return;
    }
    fetch();
  }

  List<Widget> _buildQuickItem() {
    return items.map((v) {
      return InkWell(
        onTap: () => _handleMovieTap(v),
        child: Container(
          height: 50.0,
          padding: EdgeInsets.only(left: 10.0, right: 10.0),
          child: Row(
            children: <Widget>[
              Image(
                height: 20.0,
                width: 20.0,
                image: AssetImage(
                  Util.getTypeIcon(v["source"]),
                ),
              ),
              Container(
                width: 10.0,
              ),
              Expanded(
                child: Text(
                  v["name"],
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _handleMovieTap(Map item) {
    Navigator.of(context).push(
          new CupertinoPageRoute(
            builder: (context) => new VideoPage(
                  item: item,
                  from: FROM,
                ),
          ),
        );
  }

  void _handleSearchSubmitted(String keyword) async {
    if (keyword == "") {
      Toasty.info("请输入搜索关键字");
      return;
    }
    _toResultPage(keyword);
  }

  void _toResultPage(String keyword) async {
    Navigator.of(context).push(
          new CupertinoPageRoute(
            builder: (context) => new SearchResultPage(keyword: keyword),
          ),
        );
  }
}

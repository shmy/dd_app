import 'package:dd_app/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dd_app/utils/dio.dart';
import 'package:dd_app/pages/video.dart';
import 'package:dd_app/pages/search-result.dart';
import 'package:toasty/toasty.dart';
import 'package:dd_app/utils/db/search.dart';
import 'package:dd_app/utils/modal.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => new _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _controller = new TextEditingController();
  List<Map> items = [];
  List<Map> hots = [];
  List<Map> history = [];
  String keyword = "";
  final String FROM = "search";

  @override
  initState() {
    super.initState();
    fetchHistory();
    fetchHots();
  }

  void fetch() async {
    dynamic payload = await Fetch.instance.get("/video/search",
        data: {"keyword": keyword, "page": 1, "per_page": 10});
    if (payload != null) {
      setState(() {
        items = payload["result"].cast<Map>(); // 这是类型转换？;
      });
    }
  }

  void fetchHistory() async {
    Search searchModel = await Search.instance;
    List<Map> his = await searchModel.paging(1, 12, "time DESC");
    setState(() {
      history = his;
    });
  }

  void fetchHots() async {
    dynamic payload = await Fetch.instance.get("/video/hot");
    if (payload != null) {
      setState(() {
        hots = payload.cast<Map>(); // 这是类型转换？
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
          children: items.length == 0
              ? (_buildHistoryItem()..addAll(_buildHotItem()))
              : _buildQuickItem(),
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
          // child: Align(
          //   alignment: Alignment.centerLeft,
          //   child: Text(
          //     v["name"] + v["source"],
          //     style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
          //   ),
          // ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildHistoryItem() {
    if (history.length == 0) return [];
    List<Widget> w = [
      Container(
        margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: <Widget>[
                Container(
                  width: 15.0,
                ),
                Icon(
                  Icons.history,
                  color: Theme.of(context).primaryColor,
                ),
                Text(
                  " 搜索历史",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: _handleClearHistory,
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).primaryColor,
              ),
            )
          ],
        ),
      ),
    ];
    w.add(
      Padding(
        padding: EdgeInsets.only(left: 10.0),
        child: Wrap(
          spacing: 10.0, // gap between adjacent chips
          runSpacing: 10.0, // g
          children: history.map((v) {
            return RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              onPressed: () {
                _handleSearchSubmitted(v["keyword"]);
                //  _toResultPage(v["keyword"]);
                // _handleMovieTap({
                //   "name": v["name"],
                //   "_id": v["video"]["_id"],
                //   "thumbnail": v["video"]["thumbnail"],
                // });
              },
              elevation: 0.0,
              color: Theme.of(context).primaryColor,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 10.0,
                  right: 10.0,
                  top: 7.0,
                  bottom: 7.0,
                ),
                child: Text(
                  v["keyword"],
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
    return w;
  }

  List<Widget> _buildHotItem() {
    if (hots.length == 0) return [];
    List<Widget> w = [
      Container(
        margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 15.0,
            ),
            Icon(
              Icons.whatshot,
              color: Theme.of(context).primaryColor,
            ),
            Text(
              " 热门搜索",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 18.0,
              ),
            ),
          ],
        ),
      ),
    ];
    w.add(
      Padding(
        padding: EdgeInsets.only(left: 10.0),
        child: Wrap(
          spacing: 10.0, // gap between adjacent chips
          runSpacing: 10.0, // g
          children: hots.map((v) {
            return RaisedButton.icon(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              onPressed: () {
                _handleMovieTap({
                  "name": v["name"],
                  "_id": v["video"]["_id"],
                  "thumbnail": v["video"]["thumbnail"],
                });
              },
              elevation: 0.0,
              color: Theme.of(context).primaryColor,
              icon: Image(
                height: 20.0,
                width: 20.0,
                image: AssetImage(
                  Util.getTypeIcon(v["source"]),
                ),
              ),
              label: Text(
                v["name"],
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.white,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
    return w;
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
    Search searchModel = await Search.instance;
    await searchModel.upsert(
        keyword,
        {
          "keyword": keyword,
          "time": DateTime.now().millisecondsSinceEpoch,
        },
        "keyword");
    _toResultPage(keyword);
  }

  void _toResultPage(String keyword) async {
    await Navigator.of(context).push(
          new CupertinoPageRoute(
            builder: (context) => new SearchResultPage(keyword: keyword),
          ),
        );
    fetchHistory();
  }

  void _handleClearHistory() {
    ShmyDialog.confirm(context, content: "确实要清空搜索记录吗？", okFn: () async {
      Search searchModel = await Search.instance;
      searchModel.truncateTable();
      fetchHistory();
    });
  }
}

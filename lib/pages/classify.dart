import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dd_app/pages/classify-list.dart';
import 'package:video_player/video_player.dart';

import 'package:dd_app/mixins/pageState.dart';

class ClassifyPage extends StatefulWidget {
  ClassifyPage({Key key}) : super(key: key);
  @override
  ClassifyPageState createState() => ClassifyPageState();
}

class ClassifyPageState extends State<ClassifyPage> implements PageState {
  void onShow() {
    print('ClassifyPageState 嘻嘻嘻1');
  }

  int currentIndex = 0;
  ScrollController _scrollController;
  final List<Map> menus = [
    {
      "name": "电影",
      "children": [
        {"name": "全部电影", "_id": "5b1362ab30763a214430d036"},
        {"name": "动作片", "_id": "5b0fd14e7cad175a34a2ea8a"},
        {"name": "爱情片", "_id": "5b0fd14e7cad175a34a2ea8c"},
        {"name": "科幻片", "_id": "5b0fd14e7cad175a34a2ea8d"},
        {"name": "喜剧片", "_id": "5b0fd14e7cad175a34a2ea8b"},
        {"name": "战争片", "_id": "5b0fd14e7cad175a34a2ea90"},
        {"name": "恐怖片", "_id": "5b0fd14e7cad175a34a2ea8e"},
        {"name": "剧情片", "_id": "5b0fd14e7cad175a34a2ea8f"},
        {"name": "记录片", "_id": "5b6bd4eb50456c5fb99610f4"},
        // {"name": "伦理片", "_id": "5b6bd55a50456c5fb99610f5"},
      ]
    },
    {
      "name": "连续剧",
      "children": [
        {"name": "全部连续剧", "_id": "5b1fce6330025ae5371a6a8a"},
        {"name": "国产剧", "_id": "5b1fcf0b30025ae5371a6ad8"},
        {"name": "港台剧", "_id": "5b1fcf6330025ae5371a6b00"},
        {"name": "日韩剧", "_id": "5b1fcfb230025ae5371a6b22"},
        {"name": "欧美剧", "_id": "5b1fcffb30025ae5371a6b41"},
      ]
    },
    {
      "name": "综艺",
      "children": [
        {"name": "全部综艺", "_id": "5b1fd85730025ae5371abaed"}
      ]
    },
    {
      "name": "动漫",
      "children": [
        {"name": "全部动漫", "_id": "5b1fdbee30025ae5371ac363"}
      ]
    },
    {
      "name": "电视直播",
      "children": [
        {
          "name": "CCTV-1高清",
          "_id": "tv",
          // "url": "http://ivi.bupt.edu.cn/hls/cctv1hd.m3u8"
          "url": "http://183.207.249.15/PLTV/3/224/3221225530/index.m3u8"
        },
        // {
        //   "name": "汕头",
        //   "_id": "tv",
        //   // "url": "http://ivi.bupt.edu.cn/hls/cctv1hd.m3u8"
        //   "url": "http://www.szmgiptv.com:14436/hls/17.m3u8"
        // },
        {
          "name": "CCTV-3高清",
          "_id": "tv",
          "url": "http://ivi.bupt.edu.cn/hls/cctv3hd.m3u8"
        },
        {
          "name": "CCTV-5高清",
          "_id": "tv",
          "url": "http://ivi.bupt.edu.cn/hls/cctv5hd.m3u8"
        },
        {
          "name": "CCTV-5+高清",
          "_id": "tv",
          "url": "http://ivi.bupt.edu.cn/hls/cctv5phd.m3u8"
        },
        {
          "name": "CCTV-6高清",
          "_id": "tv",
          "url": "http://ivi.bupt.edu.cn/hls/cctv6hd.m3u8"
        },
        {
          "name": "CCTV-8高清",
          "_id": "tv",
          "url": "http://ivi.bupt.edu.cn/hls/cctv8hd.m3u8"
        },
        {
          "name": "CHC高清电影",
          "_id": "tv",
          "url": "http://ivi.bupt.edu.cn/hls/chchd.m3u8"
        },
        {
          "name": "北京卫视高清",
          "_id": "tv",
          "url": "http://ivi.bupt.edu.cn/hls/btv1hd.m3u8"
        },
        {
          "name": "北京文艺高清",
          "_id": "tv",
          "url": "http://ivi.bupt.edu.cn/hls/btv2hd.m3u8"
        },
        {
          "name": "北京体育高清",
          "_id": "tv",
          "url": "http://ivi.bupt.edu.cn/hls/btv6hd.m3u8"
        },
        {
          "name": "北京纪实高清",
          "_id": "tv",
          "url": "http://ivi.bupt.edu.cn/hls/btv11hd.m3u8"
        },
        {
          "name": "湖南卫视高清",
          "_id": "tv",
          "url": "http://ivi.bupt.edu.cn/hls/hunanhd.m3u8"
        },
        {
          "name": "浙江卫视高清",
          "_id": "tv",
          "url": "http://ivi.bupt.edu.cn/hls/zjhd.m3u8"
        },
        {
          "name": "江苏卫视高清",
          "_id": "tv",
          "url": "http://ivi.bupt.edu.cn/hls/jshd.m3u8"
        },
        {
          "name": "东方卫视高清",
          "_id": "tv",
          "url": "http://ivi.bupt.edu.cn/hls/dfhd.m3u8"
        },
        {
          "name": "安徽卫视高清",
          "_id": "tv",
          "url": "http://ivi.bupt.edu.cn/hls/ahhd.m3u8"
        },
        {
          "name": "黑龙江卫视高清",
          "_id": "tv",
          "url": "http://ivi.bupt.edu.cn/hls/hljhd.m3u8"
        },
        {
          "name": "辽宁卫视高清",
          "_id": "tv",
          "url": "http://ivi.bupt.edu.cn/hls/lnhd.m3u8"
        },
        {
          "name": "深圳卫视高清",
          "_id": "tv",
          "url": "http://ivi.bupt.edu.cn/hls/szhd.m3u8"
        },
        {
          "name": "广东卫视高清",
          "_id": "tv",
          "url": "http://ivi.bupt.edu.cn/hls/gdhd.m3u8"
        },
        {
          "name": "天津卫视高清",
          "_id": "tv",
          "url": "http://ivi.bupt.edu.cn/hls/tjhd.m3u8"
        },
        {
          "name": "湖北卫视高清",
          "_id": "tv",
          "url": "http://ivi.bupt.edu.cn/hls/hbhd.m3u8"
        },
        {
          "name": "山东卫视高清",
          "_id": "tv",
          "url": "http://ivi.bupt.edu.cn/hls/sdhd.m3u8"
        },
        {
          "name": "重庆卫视高清",
          "_id": "tv",
          "url": "http://ivi.bupt.edu.cn/hls/cqhd.m3u8"
        }
      ]
    }
  ];
  List<Map> subMenus = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("分类"),
          elevation: 0.0,
        ),
        body: _buildContent());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.subMenus = this.menus[currentIndex]["children"];
    this._scrollController = new ScrollController();
  }

  List<Widget> _buildLeftMenu() {
    return List.generate(menus.length, (i) {
      return InkWell(
        onTap: () => _handleLeftMenuTap(i),
        splashColor: Colors.grey[500],
        child: Container(
            height: 70.0,
            // width: 130.0,
            child: Align(
              child: Text(
                this.menus[i]["name"],
                style: TextStyle(
                  color: this.currentIndex == i
                      ? Theme.of(context).primaryColor
                      : Colors.grey[500],
                ),
              ),
            ),
            color: this.currentIndex == i
                ? Color.fromRGBO(240, 240, 240, 0.5)
                : Color.fromRGBO(255, 255, 255, 0.5)),
      );
    });
  }

  Widget _buildContent() {
    return Row(
      children: <Widget>[
        Container(
          width: 100.0,
          color: Color.fromRGBO(238, 238, 238, 0.5),
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: _buildLeftMenu(),
          ),
        ),
        Expanded(
          child: GridView.count(
            controller: _scrollController,
            physics: BouncingScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
            padding: EdgeInsets.all(4.0),
            children: _buildRightMenu(),
          ),
        )
      ],
    );
  }

  List<Widget> _buildRightMenu() {
    if (subMenus == null) {
      return [];
    }
    return List.generate(subMenus.length, (i) {
      Map item = subMenus[i];
      return Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image(
              image:
                  AssetImage("images/classify_icons/" + item["_id"] + ".webp"),
            ),
          ),
          Positioned(
            left: 0.0,
            bottom: 0.0,
            right: 0.0,
            child: Container(
              height: 24.0,
              color: Color.fromRGBO(0, 0, 0, 0.3),
              child: Center(
                child: Text(
                  item["name"],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () => _handleRightMenuTap(item),
              ),
            ),
          ),
        ],
      );
    });
  }

  void _handleLeftMenuTap(int index) {
    _scrollController.jumpTo(0.0);
    setState(() {
      this.currentIndex = index;
      this.subMenus = this.menus[index]["children"];
    });
  }

  void _handleRightMenuTap(Map item) async {
    if (item["url"] != null) {
      await VideoPlayer.play(
        item["name"] + "【黑人视频】",
        item["url"],
        "",
      );
      return;
    }
    Navigator.of(context).push(
          new CupertinoPageRoute(
            builder: (context) => new ClassifyListPage(
                  id: item["_id"],
                  name: item["name"],
                ),
          ),
        );
  }

  // 递归成树状
  // List<Map> _recursion(data, pid) {
  //   List<Map> result = [];
  //   List<Map> temp = [];
  //   for (Map item in data) {
  //     if (item["pid"] == pid) {
  //       temp = this._recursion(data, item["_id"]);
  //       if (temp.length != 0) {
  //         item["children"] = temp;
  //       }
  //       result.add(item);
  //     }
  //   }
  //   return result;
  // }

}

import 'package:flutter/material.dart';

// 全部分类类型
final List<Map> CLASSS1 = [
  {"title": "不限分类", "key": "pid", "value": ""},
  {"title": "电影", "key": "pid", "value": "5b1362ab30763a214430d036"},
  {"title": "连续剧", "key": "pid", "value": "5b1fce6330025ae5371a6a8a"},
  {"title": "综艺", "key": "pid", "value": "5b1fd85730025ae5371abaed"},
  {"title": "动漫", "key": "pid", "value": "5b1fdbee30025ae5371ac363"},
];
final List<Map> CLASSS2 = [
  {"title": "不限分类", "key": "pid", "value": ""},
  {"title": "伦理片", "key": "pid", "value": "5b6bd55a50456c5fb99610f5"},
  {"title": "福利片", "key": "pid", "value": "5b6c1f84adcfce70593225a9"},
];
// 来源网站
final List<Map> SOURCES = [
  {"title": "不限来源", "key": "source", "value": ""},
  {"title": "最大资源网", "key": "source", "value": "zuidazy"},
  {"title": "酷云资源网", "key": "source", "value": "kuyunzy"},
];

// 查询方式
final List<Map> TYPES = [
  {"title": "精确查询", "key": "query", "value": "1"},
  {"title": "模糊查询", "key": "query", "value": "2"},
];

// 排序方式
final List<Map> ORDERS = [
  {"title": "最新收录", "key": "sort", "value": "1"},
  {"title": "最新上映", "key": "sort", "value": "2"},
  {"title": "最多播放", "key": "sort", "value": "3"},
  // {"title": "最受好评", "key": "sort", "value": "4"},
];

// 年代
final List<Map> YEARS = [
  {"title": "不限年代", "key": "year", "value": ""},
  {"title": "2018", "key": "year", "value": "2018"},
  {"title": "2017", "key": "year", "value": "2017"},
  {"title": "2016", "key": "year", "value": "2016"},
  {"title": "2015", "key": "year", "value": "2015"},
  {"title": "2014", "key": "year", "value": "2014"},
  {"title": "2013", "key": "year", "value": "2013"},
  {"title": "2012", "key": "year", "value": "2012"},
  {"title": "2011", "key": "year", "value": "2011"},
  {"title": "2010", "key": "year", "value": "2010"},
  {"title": "00年代", "key": "year", "value": "00"},
  {"title": "90年代", "key": "year", "value": "90"},
  {"title": "80年代", "key": "year", "value": "80"},
  {"title": "70年代", "key": "year", "value": "70"},
  {"title": "更早", "key": "year", "value": "更早"},
];

// 区域
final List<Map> AREAS = [
  {"title": "不限地区", "key": "area", "value": ""},
  {"title": "大陆", "key": "area", "value": "大陆"},
  {"title": "香港", "key": "area", "value": "香港"},
  {"title": "台湾", "key": "area", "value": "台湾"},
  {"title": "日本", "key": "area", "value": "日本"},
  {"title": "韩国", "key": "area", "value": "韩国"},
  {"title": "美国", "key": "area", "value": "美国"},
  {"title": "法国", "key": "area", "value": "法国"},
  {"title": "德国", "key": "area", "value": "德国"},
  {"title": "英国", "key": "area", "value": "英国"},
  {"title": "其他", "key": "area", "value": "其他"},
];

class FilterIndexState {
  final int year;
  final int area;
  final int sort;
  final int query;
  final int source;
  final int classindex;
  const FilterIndexState({
    this.year = 0,
    this.area = 0,
    this.sort = 1,
    this.query = 1,
    this.source = 0,
    this.classindex = 0,
  });
}

class FilterBarWidget extends StatefulWidget {
  final bool isOpen; // 是否打开
  final bool withType; // 是否有查询方式
  final bool withClass; // 是否有分类
  final int classId; // 分类类型
  final Function onChange; // 回调
  final FilterIndexState initIndex; // 初始化选中状态

  FilterBarWidget(
      {Key key,
      this.isOpen = false,
      this.withType = false,
      this.withClass = false,
      this.classId = 1,
      @required this.onChange,
      @required this.initIndex})
      : super(key: key);

  @override
  FilterBarWidgetState createState() => FilterBarWidgetState();
}

class FilterBarWidgetState extends State<FilterBarWidget> {
  List<Map> ALL = [];
  Map qs;
  final double filterItemHeight = 50.0;
  double filterBarHeight = 0.0;
  @override
  void initState() {
    super.initState();
    ALL = [
      {
        "INDEX": widget.initIndex.year,
        "DATAS": YEARS,
      },
      {
        "INDEX": widget.initIndex.area,
        "DATAS": AREAS,
      },
      {
        "INDEX": widget.initIndex.source,
        "DATAS": SOURCES,
      },
      {
        "INDEX": widget.initIndex.sort,
        "DATAS": ORDERS,
      },
      // {
      //   "INDEX": widget.initializeIndex.query,
      //   "DATAS": TYPES,
      // },
      
    ];
    if (widget.withType) {
      ALL.insert(3, {
        "INDEX": widget.initIndex.query,
        "DATAS": TYPES,
      });
    }
    if (widget.withClass) {
      ALL.insert(0, {
        "INDEX": widget.initIndex.classindex,
        "DATAS": widget.classId == 1 ? CLASSS1 : CLASSS2,
      });
    }
    filterBarHeight = filterItemHeight * ALL.length;
  }

  // 给外部调用
  Map getQs() {
    Map m = {};
    ALL.forEach((el) {
      var c = el["DATAS"][el["INDEX"]];
      m[c["key"]] = c["value"];
    });
    return m;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(
        milliseconds: 300,
      ),
      height: widget.isOpen ? filterBarHeight : filterItemHeight,
      child: Wrap(
        children: ALL.map<Widget>((v) {
          return _buildFilterbarItems(
            v["DATAS"],
            v["INDEX"],
            pressedFn: (int i) {
              if (v["INDEX"] == i) return;
              setState(() {
                v["INDEX"] = i;
                if (widget.onChange != null) {
                  widget.onChange(getQs());
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterbarItems(
    List<dynamic> items,
    int currentIndex, {
    @required Function pressedFn,
    double height = 50.0,
  }) {
    return Container(
      height: height,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: List.generate(
          items.length,
          (i) {
            Map v = items[i];
            return Container(
              margin: EdgeInsets.all(5.0),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () {
                    if (pressedFn != null) {
                      pressedFn(i);
                    }
                  },
                  child: Container(
                    height: height - 10,
                    padding: EdgeInsets.only(left: 15.0, right: 15.0),
                    decoration: BoxDecoration(
                      color: currentIndex == i
                          ? Color.fromARGB(255, 245, 247, 249)
                          : Colors.transparent,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        v["title"],
                        style: TextStyle(
                          fontSize: 14.0,
                          color: currentIndex == i
                              ? Theme.of(context).primaryColor
                              : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// class FilterBarWidget extends StatefulWidget {
//   @override
//   _FilterBarWidgetState createState() => _FilterBarWidgetState();
// }

// class _FilterBarWidgetState extends State<FilterBarWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(

//     );
//   }
// }

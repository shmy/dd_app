import 'package:flutter/material.dart';
import 'package:flutter_dlan/flutter_dlan.dart';
import 'package:toasty/toasty.dart';
class DlnaPage extends StatefulWidget {
  final String url;

  DlnaPage({Key key, @required this.url}) : super(key: key);
  @override
  _DlnaPage createState() => _DlnaPage();
}

class _DlnaPage extends State<DlnaPage> {
  List<dynamic> devices = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }
  void init() async {
    FlutterDlan.init((List<dynamic> data) {
      if (!mounted) {
        return;
      }
      setState(() {
        devices = data;
      });
    });
    FlutterDlan.search();
    List<dynamic> d = await FlutterDlan.devices;
    setState(() {
      devices = d;
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("选择投屏设备"),
        elevation: 0.0,
      ),
      body: Column(
        children: <Widget>[
//          MaterialButton(
//            child: Text("getList"),
//            onPressed: () async {
//              print(await FlutterDlan.devices);
//            },
//          )
        ]..addAll(devices.map<Widget>((item) {
          return ListTile(
            title: Text(item["name"]),
            onTap: () {
              _play(item["uuid"]);
            },
          );
        })),
      ),
    );
  }
  void _play(String uuid) async {
    Toasty.success("已发送到投屏设备");
    Navigator.of(context).pop();
    await FlutterDlan.playUrl(uuid, widget.url);
  }
}
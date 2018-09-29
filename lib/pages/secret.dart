import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dd_app/pages/classify-list.dart';
import 'package:dd_app/pages/secret/search.dart';

final secretPages = [
  {"name": "伦理片", "_id": "5b6bd55a50456c5fb99610f5"},
  {"name": "福利片", "_id": "5b6c1f84adcfce70593225a9"},
];

class SecretPage extends StatefulWidget {
  @override
  _SecretPageState createState() => _SecretPageState();
}

class _SecretPageState extends State<SecretPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("秘密花园"),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            onPressed: _handleJumpSearch,
            icon: Icon(
              Icons.search,
              size: 28.0,
            ),
          )
        ],
      ),
      body: GridView.count(
        // controller: _scrollController,
        physics: BouncingScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        padding: EdgeInsets.all(4.0),
        children: _buildRightMenu(),
      ),
    );
  }

  List<Widget> _buildRightMenu() {
    return secretPages.map((v) {
      return GestureDetector(
        onTap: () => _handleJumpPage(v),
        child: Stack(
          children: <Widget>[
            Positioned(
                left: 0.0,
                bottom: 0.0,
                right: 0.0,
                top: 0.0,
                child: Image(
                    image: AssetImage(
                        "images/classify_icons/" + v["_id"] + ".webp"))),
            Positioned(
              left: 0.0,
              bottom: 0.0,
              right: 0.0,
              // width: 100.0,
              child: Container(
                height: 24.0,
                color: Color.fromRGBO(0, 0, 0, 0.3),
                child: Center(
                  child: Text(
                    v["name"],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    }).toList();
  }

  void _handleJumpSearch() {
    Navigator.of(context).push(
          new MaterialPageRoute(
            builder: (context) => new SearchPage(),
            fullscreenDialog: true,
          ),
        );
  }

  void _handleJumpPage(Map item) {
    Navigator.of(context).push(
          new CupertinoPageRoute(
            builder: (context) => new ClassifyListPage(
                  id: item["_id"],
                  name: item["name"],
                ),
          ),
        );
  }
}

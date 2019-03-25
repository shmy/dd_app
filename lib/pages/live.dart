import 'package:dd_player/player.dart';
import 'package:flutter/material.dart';
class LivePage extends StatelessWidget {
  String name = "";
  String url = "";
  LivePage({Key key, this.url, this.name});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Center(
        child: DdPlayer(
          url: url,
        ),
      ),
    );
  }
}

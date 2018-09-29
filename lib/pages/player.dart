import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class PlayerPage extends StatefulWidget {
  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  VideoPlayerController _controller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = new VideoPlayerController.network(
        'https://sohu.zuida-163sina.com/ppvod/1A3A2129F1136B515138D6BC92218449.m3u8');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("player"),
      ),
      body: ListView(
        children: <Widget>[
          Chewie(
            _controller,
            aspectRatio: 3 / 2,
            autoPlay: true,
            looping: true,
          )
        ],
      ),
    );
  }
}

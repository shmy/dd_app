import 'package:flutter/material.dart';
import 'package:dd_app/widget/cached-image.dart';
class PhotoHero extends StatelessWidget {
  const PhotoHero({ 
    Key key, 
    this.item, 
    this.width: 200.0,
    this.height: 400.0
    }) : super(key: key);

  final Map item;
  final double width;
  final double height;
  Widget build(BuildContext context) {
    // 转 https
    String thumbnail = item["thumbnail"];
    if (thumbnail.startsWith("http://")) {
      thumbnail = thumbnail.replaceFirst("http://", "https://");
    }
    if (item["timestamp"] == null) {
      item["timestamp"] = "-default";
    }
    return SizedBox(
      width: width,
      height: height,
      child: Hero(
        key: Key(item["_id"]),
        tag: item["_id"] + item["timestamp"],
        child: CachedImage(thumbnail),
      )
    );
  }
}

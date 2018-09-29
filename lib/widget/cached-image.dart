import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/**
 * 封装 cached_network_image
 */
class CachedImage extends StatelessWidget {
  String imageUrl = "";
  BoxFit fit;
  CachedImage(this.imageUrl, {this.fit: BoxFit.fill});
  Widget build(BuildContext context) {
    // 转 https
    if (imageUrl.startsWith("http://")) {
      imageUrl = imageUrl.replaceFirst("http://", "https://");
    }
    return CachedNetworkImage(
      key: Key(imageUrl),
      errorWidget: Image(
        image: AssetImage("images/img_load_failed.webp"),
        fit: BoxFit.fill,
      ),
      placeholder: Image(
        image: AssetImage("images/img_loading.webp"),
        fit: BoxFit.fill,
        repeat: ImageRepeat.repeat,
      ),
      fit: fit,
      imageUrl: imageUrl,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:dd_app/utils/action.dart';
import 'package:dd_app/widget/cached-image.dart';

class AdItem extends StatelessWidget {
  String imageUrl;
  dynamic action;
  double width;
  double height;
  double marginTop;
  double marginBottom;
  final Color adColor = Colors.white;
  AdItem(
      {Key key,
      this.imageUrl = "",
      this.action,
      this.width = 10.0,
      this.height = 10.0,
      this.marginTop = 4.0,
      this.marginBottom = 4.0})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: marginTop,
        bottom: marginBottom,
      ),
      height: height,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: CachedImage(imageUrl),
          ),
          Positioned(
            right: 10.0,
            top: 10.0,
            child: Container(
              height: 20.0,
              width: 20.0,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.all(
                  Radius.circular(30.0),
                ),
                border: Border.all(
                  color: adColor,
                ),
              ),
              child: Center(
                child: Text(
                  "AD",
                  style: TextStyle(
                    color: adColor,
                    fontSize: 10.0,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () => Action.handleAction(context, action),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

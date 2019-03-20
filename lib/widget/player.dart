import 'dart:async';

import 'package:dd_app/pages/dlna.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_statusbar_manager/flutter_statusbar_manager.dart';

class Video extends StatefulWidget {
  String url;

  Video({Key key, this.url});

  @override
  _Video createState() => _Video();
}

class _Video extends State<Video> {
  int quarterTurns = 0;
  bool isFullScreenMode = false;
  bool hiddenControls = true;
  bool isPlaying = false;
  double total = 1.0;
  double loaded = 0.0;
  Function dialogSetState;
  double videoWidth = 3.0;
  double videoHeight = 2.0;
  VideoPlayerController videoPlayerController;
  double panStartX = 0.0;
  double panStartY = 0.0;
  Timer timer;

  Widget build(BuildContext context) {
    if (quarterTurns == 0 && !isFullScreenMode) {
      return buildVideo();
    }
    return Container();
  }
  get setStateFn {
    if (isFullScreenMode) {
      return dialogSetState;
    }
    return setState;
  }
  @override
  void initState() {
    super.initState();
    buildPlayer();
  }

  @override
  void didUpdateWidget(Video oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      buildPlayer();
    }
  }

  @override
  void dispose() {
    if (videoPlayerController != null) {
      videoPlayerController.dispose();
    }
    if (timer != null) {
      timer.cancel();
    }
    super.dispose();
  }

  void buildPlayer() {
    if (widget.url == "") {
      return;
    }
    if (videoPlayerController != null) {
      videoPlayerController.removeListener(videoListener);
      videoPlayerController.pause();
      videoPlayerController.dispose();
    }
    videoPlayerController = VideoPlayerController.network(widget.url)
      ..addListener(videoListener)
      ..setVolume(1.0)
      ..initialize()
      ..play();
    switchControls();
  }

  Widget buildVideo() {
    return RotatedBox(
      quarterTurns: quarterTurns,
      child: Container(
        color: Colors.black,
        child: AspectRatio(
          aspectRatio: 3 / 2,
          child: Stack(
            children: <Widget>[
              Positioned(
                  top: 0.0,
                  left: 0.0,
                  right: 0.0,
                  bottom: 0.0,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: videoWidth / videoHeight,
                      child: videoPlayerController == null
                          ? Container(
                        color: Colors.black,
                      )
                          : VideoPlayer(videoPlayerController),
                    ),
                  )
              ),
              Positioned(
                top: 0.0,
                left: 0.0,
                right: 0.0,
                bottom: 0.0,
                child: GestureDetector(
                  onTap: () {
                    switchControls();
                  },
                  onDoubleTap: () {
                    // 双加切换播放/暂停
                    switchPlayState();
                  },
                  // 垂直
                  onVerticalDragDown: (DragDownDetails details) {
//                    panStartX = details.globalPosition.dx;
                    panStartY = details.globalPosition.dy;
                  },
                  // 水平
                  onHorizontalDragDown: (DragDownDetails details) {
                    panStartX = details.globalPosition.dx;
//                    panStartY = details.globalPosition.dy;
                  },
//                  onHorizontalDragUpdate: (DragUpdateDetails details) {
//                    print('-------onHorizontalDragUpdate------');
//                    print(details);
//                  },
                  onVerticalDragUpdate: (DragUpdateDetails details) {
                    print('-------onVerticalDragUpdate------');
                    double volume = details.globalPosition.dy - panStartY;
                    volume += videoPlayerController.value.volume;
                    print(volume);
                    videoPlayerController.setVolume(volume);
                  },
                  onHorizontalDragUpdate: (DragUpdateDetails details) {
//                    print('-------onVerticalDragUpdate------');
//                    print(details);
                  },
                ),
              ),
              // 上部控制条
//              hiddenControls
//                  ? emptyWidget()
//                  : Positioned(
//                top: 0.0,
//                left: 0.0,
//                right: 0.0,
//                child: Container(
//                  height: 30.0,
//                  color: Colors.white54,
//                ),
//              ),
              // 下部控制条
              hiddenControls
                  ? emptyWidget()
                  : Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  height: 30.0,
                  color: Colors.white24,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 24,
                          color: Colors.white,
                        ),
                        onPressed: () => switchPlayState(),
                      ),
                      Expanded(
                        child: Slider(
                            value: loaded,
                            max: total,
                            onChanged: (d) {
                              seekTo(d);
                            }),
                      ),
                      isFullScreenMode ? IconButton(
                        icon: Icon(
                          Icons.rotate_left,
                          size: 24,
                          color: Colors.white,
                        ),
                        onPressed: () => rotateScreen(),
                      ) : emptyWidget(),
                      IconButton(
                        icon: Icon( Icons.tv,
                          size: 20,
                          color: Colors.white,
                        ),
                        onPressed: () => enterDlna(),
                      ),
                      IconButton(
                        icon: Icon(
                          isFullScreenMode
                              ? Icons.fullscreen_exit
                              : Icons.fullscreen,
                          size: 24,
                          color: Colors.white,
                        ),
                        onPressed: () => switchFullMode(),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      )

    );
  }

  Widget emptyWidget() {
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }
  void rotateScreen() {
    setStateFn(() {
      quarterTurns = quarterTurns - 1;
    });
  }
  void enterDlna() async {
    if (videoPlayerController != null) {
      videoPlayerController.pause();
    }
    await Navigator.of(context).push(
      new CupertinoPageRoute(
        builder: (context) => new DlnaPage(url: widget.url),
      ),
    );
    videoPlayerController.play();
  }
  void enterFullScreen() async {
    setStateFn(() {
      quarterTurns = 1;
      isFullScreenMode = true;
    });
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    FlutterStatusbarManager.setFullscreen(true);
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return StatefulBuilder(builder: (context, _setState) {
            dialogSetState = _setState;
            return Scaffold(
              backgroundColor: Colors.black,
              body: Container(
                height: height,
                width: width,
                child: buildVideo(),
              ),
            );
          });
        });

    setStateFn(() {
      quarterTurns = 0;
      isFullScreenMode = false;
    });
  }

  void exitFullScreen() {
    Navigator.of(context).pop();
    FlutterStatusbarManager.setFullscreen(false);
    setStateFn(() {
      quarterTurns = 0;
      isFullScreenMode = false;
    });
  }

  void switchFullMode() {
    if (isFullScreenMode) {
      exitFullScreen();
    } else {
      enterFullScreen();
    }
  }
  void switchControls() {
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
    if (!hiddenControls == false) {
      timer = Timer(Duration(milliseconds: 3000), () {
        setStateFn(() {
          hiddenControls = true;
        });
      });
    }
    setStateFn(() {
      hiddenControls = !hiddenControls;
    });
  }
  void switchPlayState() {
    if (videoPlayerController == null) {
      return;
    }
    if (isPlaying) {
      videoPlayerController.pause();
    } else {
      videoPlayerController.play();
    }
  }

  void seekTo(double seconds) {
    if (videoPlayerController != null) {
      videoPlayerController.seekTo(Duration(seconds: seconds.toInt()));
      videoPlayerController.play();
    }
  }

  void videoListener() {
    if (!mounted) {
      return;
    }
    setStateFn(() {
      if (videoPlayerController != null) {
        if (videoPlayerController.value.size != null) {
          videoHeight = videoPlayerController.value.size.height;
          videoWidth = videoPlayerController.value.size.width;
        }
        isPlaying = videoPlayerController.value.isPlaying;
        if (videoPlayerController.value.duration != null) {
          total = videoPlayerController.value.duration.inSeconds.toDouble();
        }
        if (videoPlayerController.value.position != null) {
          loaded = videoPlayerController.value.position.inSeconds.toDouble();
        }
      }
    });
  }
}

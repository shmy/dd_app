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
  bool isLocked = false;
  VideoPlayerValue _lastValue;
  Function dialogSetState;
  VideoPlayerController videoPlayerController;

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
      ..initialize().then((_) {
        videoListener();
        videoPlayerController.play();
      });

    switchControls();
  }

  Widget buildVideo() {
    return WillPopScope(
      child: RotatedBox(
        quarterTurns: quarterTurns,
        child: Container(
          color: Colors.black,
          child: AspectRatio(
            aspectRatio: 3 / 2,
            child: Stack(
              children: <Widget>[
                // 播放区域
                Positioned(
                    top: 0.0,
                    left: 0.0,
                    right: 0.0,
                    bottom: 0.0,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio:
                            _lastValue != null ? _lastValue.aspectRatio : 3 / 2,
                        child: videoPlayerController == null
                            ? Container(
                                color: Colors.black,
                              )
                            : VideoPlayer(videoPlayerController),
                      ),
                    )),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: (_lastValue != null ? _lastValue.isBuffering : true)
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : emptyWidget(),
                ),
                // 手势区域
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
//                  onVerticalDragDown: (DragDownDetails details) {
//                    panStartY = details.globalPosition.dy;
//                  },
//                  // 水平
//                  onHorizontalDragDown: (DragDownDetails details) {
//                    panStartX = details.globalPosition.dx;
//                  },
//                  onHorizontalDragUpdate: (DragUpdateDetails details) {
//                    print('-------onHorizontalDragUpdate------');
//                    print(details);
//                  },
//                  onVerticalDragUpdate: (DragUpdateDetails details) {
//                  },
                  ),
                ),

                // 锁定按钮
                hiddenControls || !isFullScreenMode
                    ? emptyWidget()
                    : Positioned(
                        top: 0,
                        left: 0,
                        bottom: 0,
                        child: Container(
                          width: 40.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(
                                  isLocked ? Icons.lock_open : Icons.lock,
                                  size: 24,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setStateFn(() {
                                    isLocked = !isLocked;
                                  });
                                },
                              )
                            ],
                          ),
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
                hiddenControls || isLocked
                    ? emptyWidget()
                    : Positioned(
                        bottom: 0.0,
                        left: 0.0,
                        right: 0.0,
                        child: Container(
//                          height: 30.0,
                          color: Colors.white24,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              buildControlIconButton(
                                  _lastValue != null && _lastValue.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  switchPlayState),
                              Expanded(
                                  child: Row(
                                children: <Widget>[
                                  // 进度条
                                  Expanded(
                                    child: Container(
//                                      color: Colors.red,
                                      padding: EdgeInsets.all(0.0),
                                      child: Slider(
                                        value: _lastValue != null ? _lastValue.position.inSeconds.toDouble() : 0,
                                        max: _lastValue != null ? _lastValue.duration.inSeconds.toDouble() : 1,
                                        onChanged: (d) {
                                          seekTo(d);
                                        },
                                      ),
                                    ),
                                  ),
                                  buildSliderLabel(formatTime(_lastValue != null ? _lastValue.position.inSeconds.toDouble() : 0)),
                                  buildSliderLabel("/"),
                                  buildSliderLabel(formatTime(_lastValue != null ? _lastValue.duration.inSeconds.toDouble() : 1)),
                                ],
                              )),
                              isFullScreenMode
                                  ? buildControlIconButton(
                                      Icons.rotate_left, rotateScreen)
                                  : emptyWidget(),
                              isFullScreenMode
                                  ? buildControlIconButton(
                                      Icons.tv, enterDlna, 20)
                                  : emptyWidget(),
                              buildControlIconButton(
                                  isFullScreenMode
                                      ? Icons.fullscreen_exit
                                      : Icons.fullscreen,
                                  switchFullMode)
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
      onWillPop: () async {
        if (!isFullScreenMode) {
          return true;
        }
        return !isLocked;
      },
    );
  }

  Widget buildSliderLabel(String label) {
    return Text(label,
        style: TextStyle(
            color: Colors.white, fontSize: 10.0, fontWeight: FontWeight.bold));
  }

  Widget buildControlIconButton(IconData icon, Function onTap,
      [double size = 24]) {
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.only(left: 5.0, right: 5.0),
        child: Icon(
          icon,
          size: size,
          color: Colors.white,
        ),
      ),
      onTap: () => onTap(),
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
      timer = Timer(Duration(milliseconds: 5000), () {
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
    if (videoPlayerController == null || isLocked) {
      return;
    }
    if (_lastValue != null && _lastValue.isPlaying) {
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
        _lastValue = videoPlayerController.value;
      }
    });
  }

  String formatTime(double sec) {
    Duration d = Duration(seconds: sec.toInt());
    final ms = d.inMilliseconds;
    int seconds = ms ~/ 1000;
    final int hours = seconds ~/ 3600;
    seconds = seconds % 3600;
    var minutes = seconds ~/ 60;
    seconds = seconds % 60;

    final hoursString = hours >= 10 ? '$hours' : hours == 0 ? '00' : '0$hours';

    final minutesString =
        minutes >= 10 ? '$minutes' : minutes == 0 ? '00' : '0$minutes';

    final secondsString =
        seconds >= 10 ? '$seconds' : seconds == 0 ? '00' : '0$seconds';

    final formattedTime =
        '${hoursString == '00' ? '' : hoursString + ':'}$minutesString:$secondsString';

    return formattedTime;
  }
}

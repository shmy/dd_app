import 'dart:async';

import 'package:dd_app/pages/dlna.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

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
  bool isPlaying = false;
  bool isBuffering = false;
  DeviceOrientation defaultFullScreenOrientation =
      DeviceOrientation.landscapeLeft;
  double aspectRatio = 3 / 2;
  double duration = 0.0;
  double position = 0.0;
  VideoPlayerController videoPlayerController;

  Timer timer;

  Widget build(BuildContext context) {
    return buildVideo();
  }

  String get formatPosition {
    return formatTime(position);
  }

  String get formatDuration {
    return formatTime(duration);
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
      child: Container(
        color: Colors.black,
        height: isFullScreenMode
            ? MediaQuery.of(context).size.height
            : MediaQuery.of(context).size.height / 3,
        width: MediaQuery.of(context).size.width,
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
                    aspectRatio: aspectRatio,
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
              child: (isBuffering)
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
                              isLocked ? Icons.lock : Icons.lock_open,
                              size: 24,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                isLocked = !isLocked;
                              });
                            },
                          )
                        ],
                      ),
                    ),
                  ),
            // 上部控制条
            hiddenControls || isLocked
                ? emptyWidget()
                : Positioned(
                    top: isFullScreenMode ? 0.0 : 30.0,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      height: 45.0,
                      color: Colors.transparent,
                      padding: EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          buildControlIconButton(Icons.arrow_back, backTouched),
                          Row(
                            children: <Widget>[
                              isFullScreenMode
                                  ? buildControlIconButton(
                                      Icons.rotate_left, rotateScreen)
                                  : emptyWidget(),
                              isFullScreenMode
                                  ? buildControlIconButton(
                                      Icons.tv, enterDlna, 20)
                                  : emptyWidget(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
            // 下部控制条
            hiddenControls || isLocked
                ? emptyWidget()
                : Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      height: 30.0,
                      padding: EdgeInsets.only(left: 10.0, right: 10.0),
//                      color: Color.fromRGBO(244, 244, 244, 0.7),
                      decoration: BoxDecoration(
//                        boxShadow: [
//                          BoxShadow(
//                              color: Colors.yellow, blurRadius: 10.0, spreadRadius: 10.0),
//                        ],
                        gradient: new LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white10,
                              Colors.grey,
                            ]),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          buildControlIconButton(
                              isPlaying ? Icons.pause : Icons.play_arrow,
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
                                    value: position,
                                    max: duration,
                                    onChanged: (d) {
                                      seekTo(d);
                                    },
                                  ),
                                ),
                              ),
                              buildSliderLabel(formatPosition),
                              buildSliderLabel("/"),
                              buildSliderLabel(formatDuration),
                            ],
                          )),
                          !isFullScreenMode
                              ? buildControlIconButton(
                                  Icons.fullscreen, switchFullMode)
                              : emptyWidget()
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
      onWillPop: () async {
        if (!isFullScreenMode) {
          return true;
        }
        if (!isLocked) {
          exitFullScreen();
          return false;
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
    startTimer();
    defaultFullScreenOrientation =
        defaultFullScreenOrientation == DeviceOrientation.landscapeLeft
            ? DeviceOrientation.landscapeRight
            : DeviceOrientation.landscapeLeft;
    SystemChrome.setPreferredOrientations([defaultFullScreenOrientation]);
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
    setState(() {
      isFullScreenMode = true;
    });
    SystemChrome.setEnabledSystemUIOverlays([]);
    // 设置横屏
    SystemChrome.setPreferredOrientations([defaultFullScreenOrientation]);
  }

  void exitFullScreen() {
    // 退出全屏
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    // 返回竖屏
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    setState(() {
      isFullScreenMode = false;
    });
  }

  void backTouched() {
    if (isFullScreenMode) {
      switchFullMode();
      return;
    }
    Navigator.of(context).pop();
  }

  void switchFullMode() {
    startTimer();
    if (isFullScreenMode) {
      exitFullScreen();
    } else {
      enterFullScreen();
    }
  }

  void startTimer() {
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
    timer = Timer(Duration(milliseconds: 5000), () {
      setState(() {
        hiddenControls = true;
      });
    });
  }

  void switchControls() {
    if (!hiddenControls == false) {
      startTimer();
    }
    setState(() {
      hiddenControls = !hiddenControls;
    });
  }

  void switchPlayState() {
    if (videoPlayerController == null || isLocked) {
      return;
    }
    startTimer();
    if (isPlaying) {
      videoPlayerController.pause();
    } else {
      videoPlayerController.play();
    }
  }

  void seekTo(double seconds) {
    if (videoPlayerController != null) {
      startTimer();
      videoPlayerController.seekTo(Duration(seconds: seconds.toInt()));
      videoPlayerController.play();
    }
  }

  void videoListener() {
    if (!mounted) {
      return;
    }
    setState(() {
      if (videoPlayerController != null) {
        if (videoPlayerController.value != null) {
          duration = videoPlayerController.value.duration.inSeconds.toDouble();
          position = videoPlayerController.value.position.inSeconds.toDouble();
        }
        isPlaying = videoPlayerController.value.isPlaying;
        aspectRatio = videoPlayerController.value.aspectRatio;
        isBuffering = videoPlayerController.value.isBuffering;
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

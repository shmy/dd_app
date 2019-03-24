import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dlan/flutter_dlan.dart';
import 'package:toasty/toasty.dart';
import 'package:video_player/video_player.dart';
enum _PopupType {
  none, dlna, other
}
class DDVideo extends StatefulWidget {
  String url;

  DDVideo({Key key, this.url});

  @override
  _DDVideo createState() => _DDVideo();
}

class _DDVideo extends State<DDVideo> {
  VideoPlayerController _videoPlayerController;
  VoidCallback listener;

  Widget build(BuildContext context) {
    return VideoView(
      controller: _videoPlayerController,
    );
  }

  void _buildPlayer() {
    if (widget.url == "") {
      return;
    }
    if (_videoPlayerController != null) {
      _videoPlayerController.pause();
      _videoPlayerController.dispose();
    }
    _videoPlayerController = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        _videoPlayerController.play();
      });
  }

  void initState() {
    super.initState();
    listener = () {
      if (!mounted) {
        return;
      }
      setState(() {});
    };
    _buildPlayer();
  }

  @override
  void didUpdateWidget(DDVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _buildPlayer();
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_videoPlayerController != null) {
      _videoPlayerController.dispose();
      _videoPlayerController = null;
    }
  }
}

class VideoView extends StatefulWidget {
  VideoPlayerController controller;
  bool isFullScreenMode = false;

  VideoView({Key key, this.controller, this.isFullScreenMode = false});

  @override
  _VideoView createState() => _VideoView();
}

class _VideoView extends State<VideoView> with TickerProviderStateMixin {
  VideoPlayerController get _videoPlayerController => widget.controller;

  bool get _isFullScreenMode => widget.isFullScreenMode;
  bool _isHiddenControls = true;
  bool _isLocked = false;
  bool _isShowPopup = false;
  double _popupWidth = 260.0;
  DeviceOrientation _defaultFullScreenOrientation =
      DeviceOrientation.landscapeLeft;
  Timer _timer;
  AnimationController _animationController;
  Animation<double> _animation;
  AnimationController _slideTopAnimationController;
  Animation<double> _slideTopAnimation;
  AnimationController _slideBottomAnimationController;
  Animation<double> _slideBottomAnimation;

  List<dynamic> _devices = [];
  _PopupType _popupType = _PopupType.none;
  Widget build(BuildContext context) {
    if (_videoPlayerController?.value != null) {
      if (_videoPlayerController.value.initialized) {
        return _buildVideo();
      }
      if (_videoPlayerController.value.hasError &&
          !_videoPlayerController.value.isPlaying) {
        return _buildMask(errMsg: "加载失败,请稍后再试!");
      }
      return _buildMask(isLoading: true);
    }
    return _buildMask();
  }

  String get _formatPosition {
    return _formatTime(
        _videoPlayerController.value.position.inSeconds.toDouble());
  }

  String get _formatDuration {
    return _formatTime(
        _videoPlayerController.value.duration.inSeconds.toDouble());
  }

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _slideTopAnimationController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _slideBottomAnimationController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _animation =
        new Tween(begin: -_popupWidth, end: 0.0).animate(_animationController)
          ..addStatusListener((state) {
            if (state == AnimationStatus.forward) {
              setState(() {
                _isShowPopup = true;
              });
            } else if (state == AnimationStatus.reverse) {
              setState(() {
                _isShowPopup = false;
              });
            }
          });
    _slideTopAnimation =
        new Tween(begin: -75.0, end: 0.0).animate(_slideTopAnimationController)
          ..addStatusListener((state) {
            if (state == AnimationStatus.forward) {
              setState(() {
                _isHiddenControls = false;
              });
            } else if (state == AnimationStatus.reverse) {
              setState(() {
                _isHiddenControls = true;
              });
            }
          });
    _slideBottomAnimation = new Tween(begin: -30.0, end: 0.0)
        .animate(_slideBottomAnimationController)
          ..addStatusListener((state) {
            if (state == AnimationStatus.forward) {
              setState(() {
                _isHiddenControls = false;
              });
            } else if (state == AnimationStatus.reverse) {
              setState(() {
                _isHiddenControls = true;
              });
            }
          });
    if (_videoPlayerController != null) {
      _videoPlayerController
        ..addListener(listener)
        ..setVolume(1.0);
    }
    _initDlna();
  }

  void listener() {
    setState(() {});
  }

  @override
  void didUpdateWidget(VideoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller != null) {
        oldWidget.controller.removeListener(listener);
      }
      widget.controller.addListener(listener);
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
    if (_animationController != null) {
      _animationController.dispose();
    }
    if (_slideTopAnimationController != null) {
      _slideTopAnimationController.dispose();
    }
    if (_slideBottomAnimationController != null) {
      _slideBottomAnimationController.dispose();
    }
    if (_videoPlayerController != null) {
      _videoPlayerController.removeListener(listener);
    }
  }

  Widget _buildDlna() {
    if (_devices.length == 0) {
      return Container(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Text("暂无可用设备,请确保两者在同一wifi下.", style: TextStyle(
            color: Colors.white,
          ),),
        ),
      );
    }
    return ListView(
        children: []..addAll(
            _devices.map<Widget>((item) {
              return ListTile(
                title: Text(
                  item["name"],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                  ),
                ),
                subtitle: Text(
                  item["ip"],
                  style: TextStyle(
                    color: Colors.black38,
                    fontSize: 10.0,
                  ),
                ),
                onTap: () async {
                  Toasty.success("已发送到投屏设备");
                  _hidePopup();
                  await FlutterDlan.playUrl(
                      item["uuid"], _videoPlayerController.dataSource);
                },
              );
            }),
          ));
  }

  void _initDlna() async {
    FlutterDlan.init((List<dynamic> data) {
      if (!mounted) {
        return;
      }
      setState(() {
        _devices = data;
      });
    });
    FlutterDlan.search();
    List<dynamic> data = await FlutterDlan.devices;
    setState(() {
      _devices = data;
    });
//    print(devices);
  }

  Widget _buildMask({String errMsg = "", bool isLoading = false}) {
    Widget child = _emptyWidget();
    if (isLoading) {
      child = Center(
        child: CircularProgressIndicator(),
      );
    } else if (errMsg != "") {
      child = Center(
        child: Text(
          errMsg,
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    return Container(
      color: Colors.black,
      height: _isFullScreenMode
          ? MediaQuery.of(context).size.height
          : MediaQuery.of(context).size.height / 3,
      width: MediaQuery.of(context).size.width,
      child: child,
    );
  }

  Widget _buildVideo() {
    return WillPopScope(
      child: Container(
        color: Colors.black,
        height: _isFullScreenMode
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
                    aspectRatio: _videoPlayerController.value.aspectRatio,
                    child: _videoPlayerController == null
                        ? Container(
                            color: Colors.black,
                          )
                        : VideoPlayer(_videoPlayerController),
                  ),
                )),
            // 加载状态
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: (_videoPlayerController.value.isBuffering)
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : _emptyWidget(),
            ),
            // 手势区域
            Positioned(
              top: 0.0,
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: GestureDetector(
                onTap: () {
                  _switchControls();
                },
                onDoubleTap: () {
                  // 双加切换播放/暂停
                  _switchPlayState();
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
            !_isFullScreenMode || _isHiddenControls
                ? _emptyWidget()
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
                              _isLocked ? Icons.lock : Icons.lock_open,
                              size: 24,
                              color: Colors.white,
                            ),
                            onPressed: () {
//                              _hideControls();
                              if (!_isLocked) {
                                _hideControls();
                              } else {
                                _showControls();
                              }
                              setState(() {
                                _isLocked = !_isLocked;
                              });
                            },
                          )
                        ],
                      ),
                    ),
                  ),
            // 上部控制条
            SlideTransition(
              child: _buildTopControls(),
              animation: _slideTopAnimation,
            ),
            // 下部控制条
            SlideTransition(
              child: _buildBottomControls(),
              animation: _slideBottomAnimation,
              isBottom: true,
            ),
            PlayerPopupAnimated(
              animation: _animation,
              width: _popupWidth,
              child: _popupType == _PopupType.dlna ? _buildDlna() : _emptyWidget(),
            ),
          ],
        ),
      ),
      onWillPop: () async {
        if (!_isFullScreenMode) {
          return true;
        }
        if (!_isLocked) {
          _exitFullScreen();
          return false;
        }
        return !_isLocked;
      },
    );
  }

  Widget _buildSliderLabel(String label) {
    return Text(label,
        style: TextStyle(
            color: Colors.white, fontSize: 10.0, fontWeight: FontWeight.bold));
  }

  Widget _buildControlIconButton(IconData icon, Function onTap,
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

  Widget _buildTopControls() {
    return Container(
      height: 45.0,
      color: Colors.transparent,
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      margin: EdgeInsets.only(top: _isFullScreenMode ? 0.0 : 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildControlIconButton(Icons.arrow_back, _backTouched),
          Row(
            children: <Widget>[
//              _isFullScreenMode
//                  ? _buildControlIconButton(Icons.speaker_notes, _switchPopup)
//                  : _emptyWidget(),
              _isFullScreenMode
                  ? _buildControlIconButton(Icons.rotate_left, _rotateScreen)
                  : _emptyWidget(),
              _buildControlIconButton(Icons.tv, _enterDlna, 20)
//              _isFullScreenMode
//                  ? _buildControlIconButton(Icons.tv, _enterDlna, 20)
//                  : _emptyWidget(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      height: 30.0,
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      decoration: BoxDecoration(
        gradient: new LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white10,
              Colors.white54,
            ]),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildControlIconButton(
              _videoPlayerController.value.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow,
              _switchPlayState),
          Expanded(
              child: Row(
            children: <Widget>[
              // 进度条
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(0.0),
                  child: Slider(
                    value: _videoPlayerController.value.position.inSeconds
                        .toDouble(),
                    max: _videoPlayerController.value.duration.inSeconds
                        .toDouble(),
                    onChanged: (d) {
                      _seekTo(d);
                    },
                  ),
                ),
              ),
              _buildSliderLabel(_formatPosition),
              _buildSliderLabel("/"),
              _buildSliderLabel(_formatDuration),
            ],
          )),
          !_isFullScreenMode
              ? _buildControlIconButton(Icons.fullscreen, _switchFullMode)
              : _emptyWidget()
        ],
      ),
    );
  }

  Widget _emptyWidget() {
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  void _rotateScreen() {
    _startTimer();
    _defaultFullScreenOrientation =
        _defaultFullScreenOrientation == DeviceOrientation.landscapeLeft
            ? DeviceOrientation.landscapeRight
            : DeviceOrientation.landscapeLeft;
    SystemChrome.setPreferredOrientations([_defaultFullScreenOrientation]);
  }

  void _enterDlna() async {
    setState(() {
      _popupType = _PopupType.dlna;
    });
    _switchPopup();
  }

  void _enterFullScreen() async {
    SystemChrome.setEnabledSystemUIOverlays([]);
    // 设置横屏
    SystemChrome.setPreferredOrientations([_defaultFullScreenOrientation]);
    await Navigator.of(context).push(PageRouteBuilder(
      settings: RouteSettings(isInitialRoute: false),
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget child) {
            return Scaffold(
              body: VideoView(
                controller: _videoPlayerController,
                isFullScreenMode: true,
              ),
            );
          },
        );
      },
    ));
    _initDlna();

  }

  void _exitFullScreen() {
    _hidePopup();
    Navigator.of(context).pop();
    // 退出全屏
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    // 返回竖屏
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  void _backTouched() {
    if (_isFullScreenMode) {
      _switchFullMode();
      return;
    }
    Navigator.of(context).pop();
  }

  void _switchFullMode() {
    _startTimer();
    if (_isFullScreenMode) {
      _exitFullScreen();
    } else {
      _enterFullScreen();
    }
  }

  void _startTimer() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
    if (_isShowPopup) {
      return;
    }
    _timer = Timer(Duration(milliseconds: 5000), () {
      _hideControls();
    });
  }

  void _switchPopup() {
    if (_isShowPopup) {
      _animationController.reverse();
    } else {
      if (_timer != null) {
        _timer.cancel();
        _timer = null;
      }
      _hideControls();
      _animationController.forward();
    }
  }

  void _hidePopup() {
    if (_isShowPopup) {
      _animationController.reverse();
    }
  }

  void _switchControls() {
    _hidePopup();
    if (_isLocked) {
      setState(() {
        _isHiddenControls = !_isHiddenControls;
      });
      return;
    }
    if (!_isHiddenControls == false) {
      _startTimer();
    }
    if (_isHiddenControls) {
      _showControls();
    } else {
      _hideControls();
    }
  }

  void _showControls() {
    _slideTopAnimationController.forward();
    _slideBottomAnimationController.forward();
  }

  void _hideControls() {
    _slideTopAnimationController.reverse();
    _slideBottomAnimationController.reverse();
  }

  void _switchPlayState() {
    if (_videoPlayerController == null || _isLocked) {
      return;
    }
    _startTimer();
    if (_videoPlayerController.value.isPlaying) {
      _videoPlayerController.pause();
    } else {
      _videoPlayerController.play();
      _showControls();
    }
  }

  void _seekTo(double seconds) {
    _hidePopup();
    if (_videoPlayerController != null) {
      _startTimer();
      _videoPlayerController.seekTo(Duration(seconds: seconds.toInt()));
      _videoPlayerController.play();
    }
  }

  String _formatTime(double sec) {
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

class PlayerPopupAnimated extends AnimatedWidget {
  double width = 0.0;
  Widget child;

  PlayerPopupAnimated(
      {Key key,
      @required Animation<double> animation,
      @required this.width,
      @required this.child})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return Positioned(
      right: animation.value,
      top: 0.0,
      bottom: 0.0,
      width: width,
      child: Container(
        color: Colors.teal,
        child: child,
      ),
    );
  }
}

class SlideTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final bool isBottom;

  SlideTransition(
      {Key key,
      @required this.child,
      @required this.animation,
      this.isBottom = false});

  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget child) {
        if (isBottom) {
          return Positioned(
            bottom: animation.value,
            left: 0.0,
            right: 0.0,
            child: child,
          );
        }
        return Positioned(
          top: animation.value,
          left: 0.0,
          right: 0.0,
          child: child,
        );
      },
      child: child,
    );
  }
}

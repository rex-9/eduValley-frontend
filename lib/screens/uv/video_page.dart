import 'dart:async';
import 'dart:math';

import 'package:edu_valley/constants.dart';
import 'package:edu_valley/models/video.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

class VideoPage extends StatefulWidget {
  VideoPage({Key? key, this.clips, this.func, this.zip, this.ongoing})
      : super(key: key);
  final Function? func;
  final List<Video>? clips;
  final String? zip;
  final int? ongoing;

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  VideoPlayerController? _controller;
  List<Video>? get _clips {
    return widget.clips;
  }

  String? get _zip {
    return widget.zip;
  }

  int? get _ongoing {
    return widget.ongoing;
  }

  var _playingIndex = -1;
  var _disposed = false;
  var _isFullScreen = false;
  var _isEndOfClip = false;
  var _progress = 0.0;
  var _showingDialog = false;
  Timer? _timerVisibleControl;
  double _controlAlpha = 1.0;

  bool _playing = false;

  set _isPlaying(bool value) {
    _playing = value;
    _timerVisibleControl!.cancel();
    if (value) {
      _timerVisibleControl = Timer(Duration(seconds: 2), () {
        if (_disposed) return;
        setState(() {
          _controlAlpha = 0.0;
        });
      });
    } else {
      _timerVisibleControl = Timer(Duration(milliseconds: 200), () {
        if (_disposed) return;
        setState(() {
          _controlAlpha = 1.0;
        });
      });
    }
  }

  void _onTapVideo() {
    debugPrint("_onTapVideo $_controlAlpha");
    setState(() {
      _controlAlpha = _controlAlpha > 0 ? 0 : 1;
    });
    _timerVisibleControl!.cancel();
    _timerVisibleControl = Timer(Duration(seconds: 2), () {
      if (_playing) {
        setState(() {
          _controlAlpha = 0.0;
        });
      }
    });
  }

  @override
  void initState() {
    Wakelock.enable();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _clips!.length == 0 ? print("no clips") : _initializeAndPlay(0);
    super.initState();
  }

  @override
  void dispose() {
    _disposed = true;
    _timerVisibleControl?.cancel();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _exitFullScreen();
    _disposeController();
    super.dispose();
  }

  void _disposeController() async {
    final controller = VideoPlayerController.network(
        "https://rextutor.manishchudasama.com/courses/nosound.mp4");

    final old = _controller;
    _controller = controller;

    if (old != null) {
      old.removeListener(_onControllerUpdated);
      old.pause();
      old.dispose();
      debugPrint("---- old contoller paused.");
    }

    debugPrint("---- controller disposed.");
    setState(() {});
  }

  void _toggleFullscreen() async {
    if (_isFullScreen) {
      _exitFullScreen();
    } else {
      _enterFullScreen();
    }
  }

  void _enterFullScreen() async {
    debugPrint("enterFullScreen");
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // await SystemChrome.setEnabledSystemUIOverlays([]);
    _controller!.value.aspectRatio == 16 / 9
        ? SystemChrome.setPreferredOrientations(
            [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
          )
        : SystemChrome.setPreferredOrientations(
            [DeviceOrientation.portraitUp],
          );
    if (_disposed) return;
    setState(() {
      _isFullScreen = true;
    });
  }

  void _exitFullScreen() async {
    debugPrint("exitFullScreen");
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // await SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    if (_disposed) return;
    setState(() {
      _isFullScreen = false;
    });
  }

  void _initializeAndPlay(int index) async {
    // print("_initializeAndPlay ---------> $index");
    final clip = _clips![index];
    final controller = VideoPlayerController.network(clip.videoPath());

    final old = _controller;
    _controller = controller;

    if (old != null) {
      old.removeListener(_onControllerUpdated);
      old.pause();
      old.dispose();
      debugPrint("---- old contoller paused.");
    }

    debugPrint("---- controller changed.");
    setState(() {});

    controller
      ..initialize().then((_) {
        debugPrint("---- controller initialized");
        old == null ? print("old is null") : old.dispose();
        _playingIndex = index;
        _duration = null;
        _position = null;
        controller.addListener(_onControllerUpdated);
        controller.play();
        setState(() {});
      });
  }

  var _updateProgressInterval = 0.0;
  Duration? _duration;
  Duration? _position;

  void _onControllerUpdated() async {
    if (_disposed) return;
    // blocking too many updation
    // important !!
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_updateProgressInterval > now) {
      return;
    }
    _updateProgressInterval = now + 500.0;

    final controller = _controller;
    if (controller == null) return;
    if (!controller.value.isInitialized) return;
    if (_duration == null) {
      _duration = _controller!.value.duration;
    }
    var duration = _duration;
    if (duration == null) return;

    var position = await controller.position;
    _position = position!;
    final playing = controller.value.isPlaying;
    final isEndOfClip = position.inMilliseconds > 0 &&
        position.inSeconds + 1 >= duration.inSeconds;
    if (playing) {
      // handle progress indicator
      if (_disposed) return;
      setState(() {
        _progress = position.inMilliseconds.ceilToDouble() /
            duration.inMilliseconds.ceilToDouble();
      });
    }

    // handle clip end
    if (_playing != playing || _isEndOfClip != isEndOfClip) {
      _isPlaying = playing;
      _isEndOfClip = isEndOfClip;
      debugPrint(
          "updated -----> isPlaying=$playing / isEndOfClip=$isEndOfClip");
      if (isEndOfClip && !playing) {
        debugPrint(
            "========================== End of Clip / Handle NEXT ========================== ");
        final isComplete = _playingIndex == _clips!.length - 1;
        if (isComplete) {
          // print("played all!!");
          if (!_showingDialog) {
            _showingDialog = true;
            _showPlayedAllDialog().then((value) {
              _exitFullScreen();
              _showingDialog = false;
            });
          }
        } else {
          _initializeAndPlay(_playingIndex + 1);
        }
      }
    }
  }

  Future<bool?> _showPlayedAllDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(child: Text("Played all videos.")),
          actions: <Widget>[
            TextButton(
              child: Text("Close"),
              onPressed: () => Navigator.pop(context, true),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _isFullScreen
          ? SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: Center(child: _playView(context)),
                decoration: BoxDecoration(color: Colors.black),
              ),
            )
          : _clips!.length == 0
              ? const Center(
                  child: Text(
                    "No video available...",
                    style: TextStyle(fontSize: 20),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        child: Center(child: _playView(context)),
                        decoration: BoxDecoration(color: Colors.black),
                      ),
                      Flexible(
                        child: Container(
                          height: 425,
                          child: _listView(),
                        ),
                      ),
                      _zip == null
                          ? SizedBox()
                          : urlButton(context, _zip!, 'Available Resources'),
                      _ongoing == 0
                          ? SizedBox()
                          : Text(
                              'The course is not complete yet. \nMore lessons will be added...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                      _zip == null && _ongoing == 0
                          ? Text(
                              "Make sure to take notes and practise \nwhile following along the lessons.\n Have fun! 😉",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green[700],
                              ),
                              textAlign: TextAlign.center,
                            )
                          : SizedBox()
                    ],
                  ),
                ),
    );
  }

  void _onTapCard(int index) {
    _initializeAndPlay(index);
  }

  Widget _playView(BuildContext context) {
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        // aspectRatio: 16.0 / 9.0,
        child: Stack(
          children: <Widget>[
            GestureDetector(
              child: VideoPlayer(controller),
              onTap: _onTapVideo,
            ),
            _controlAlpha > 0
                ? AnimatedOpacity(
                    opacity: _controlAlpha,
                    duration: Duration(milliseconds: 250),
                    child: _controlView(context),
                  )
                : Container(),
            controller.value.isBuffering
                ? Center(
                    child: Container(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      strokeWidth: 5,
                      backgroundColor: Colors.white,
                    ),
                  ))
                : Container(),
          ],
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: 16.0 / 9.0,
        child: Center(
          child: Text(
            "Preparing ... ",
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
        ),
      );
    }
  }

  Widget _listView() {
    final controller = _controller;
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _clips!.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          splashColor: Colors.black45,
          onTap: () {
            if (controller != null && controller.value.isInitialized) {
              _onTapCard(index);
            }
          },
          child: _buildCard(index),
        );
      },
    ).build(context);
  }

  Widget _controlView(BuildContext context) {
    return Column(
      children: <Widget>[
        _topUI(),
        Expanded(child: _centerUI()),
        _bottomUI(),
      ],
    );
  }

  Widget _centerUI() {
    return Center(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextButton(
          onPressed: () async {
            final index = _playingIndex - 1;
            // if (index > 0 && _clips!.length > 0) {
            _initializeAndPlay(index);
            // }
            setState(() {});
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0.0, 0.0),
                  blurRadius: 4.0,
                  color: Color.fromARGB(50, 0, 0, 0),
                ),
              ],
            ),
            child: Icon(
              Icons.skip_previous,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            if (_playing) {
              _controller!.pause();
              setState(() {
                _playing = false;
              });
              print(_playing);
            } else {
              final controller = _controller;
              if (controller != null) {
                final pos = _position!.inSeconds;
                final dur = _duration!.inSeconds;
                final isEnd = pos == dur;
                if (isEnd) {
                  _initializeAndPlay(_playingIndex);
                } else {
                  controller.play();
                }
              }
            }
            setState(() {});
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0.0, 0.0),
                  blurRadius: 4.0,
                  color: Color.fromARGB(50, 0, 0, 0),
                ),
              ],
            ),
            child: Icon(
              _playing ? Icons.pause : Icons.play_arrow,
              size: 56.0,
              color: Colors.white,
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            final index = _playingIndex + 1;
            // if (index < _clips!.length - 1) {
            _initializeAndPlay(index);
            print('Initialize');
            // }
            setState(() {});
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0.0, 0.0),
                  blurRadius: 4.0,
                  color: Color.fromARGB(50, 0, 0, 0),
                ),
              ],
            ),
            child: Icon(
              Icons.skip_next,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
      ],
    ));
  }

  String convertTwo(int value) {
    return value < 10 ? "0$value" : "$value";
  }

  Widget _topUI() {
    final noMute = (_controller!.value.volume) > 0;
    return Row(
      children: <Widget>[
        SizedBox(width: 10),
        InkWell(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0.0, 0.0),
                    blurRadius: 8.0,
                    color: Color.fromARGB(50, 0, 0, 0),
                  ),
                ],
              ),
              child: Icon(
                noMute ? Icons.volume_up : Icons.volume_off,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          onTap: () {
            if (noMute) {
              _controller!.setVolume(0);
            } else {
              _controller!.setVolume(1.0);
            }
            setState(() {});
          },
        ),
        Expanded(
          child: Container(),
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            boxShadow: [
              BoxShadow(
                offset: const Offset(0.0, 0.0),
                blurRadius: 12.0,
                color: Color.fromARGB(50, 0, 0, 0),
              ),
            ],
          ),
          child: IconButton(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.yellow,
            icon: Icon(
              Icons.fullscreen,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              widget.func!(!_isFullScreen);
              _toggleFullscreen();
            },
          ),
        ),
        // IconButton(
        //   onPressed: null,
        //   // _download(_playingIndex),
        //   icon: Icon(
        //     Icons.download,
        //     color: Colors.white,
        //   ),
        // ),
        SizedBox(width: 10),
      ],
    );
  }

  Widget _bottomUI() {
    final duration = _duration!.inSeconds;
    final durationMin = convertTwo(duration ~/ 60.0);
    final durationSec = convertTwo(duration % 60);
    final head = _position!.inSeconds;
    final headMin = convertTwo(head ~/ 60.0);
    final headSec = convertTwo(head % 60);
    // final remained = max(0, duration - head);
    // final minutes = convertTwo(remained ~/ 60.0);
    // final sec = convertTwo(remained % 60);
    return Row(
      children: <Widget>[
        SizedBox(width: 10),
        Text(
          "$headMin:$headSec",
          // "$minutes:$sec",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            shadows: <Shadow>[
              Shadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 4.0,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ],
          ),
        ),
        Expanded(
          child: Slider(
            value: max(0, min(_progress * 100, 100)),
            min: 0,
            max: 100,
            onChanged: (value) {
              setState(() {
                _progress = value * 0.01;
              });
            },
            onChangeStart: (value) {
              debugPrint("-- onChangeStart $value");
              _controller!.pause();
            },
            onChangeEnd: (value) {
              debugPrint("-- onChangeEnd $value");
              final duration = _controller!.value.duration;
              var newValue = max(0, min(value, 99)) * 0.01;
              var millis = (duration.inMilliseconds * newValue).toInt();
              _controller!.seekTo(Duration(milliseconds: millis));
              _controller!.play();
            },
          ),
        ),
        Text(
          "$durationMin:$durationSec",
          // "$minutes:$sec",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            shadows: <Shadow>[
              Shadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 4.0,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ],
          ),
        ),
        SizedBox(width: 10),
      ],
    );
  }

  Widget _buildCard(int index) {
    final clip = _clips![index];
    final playing = index == _playingIndex;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(4),
      margin: EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          clip.thumbName == "null"
              ? SizedBox(width: 8)
              : Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      clip.thumbPath()!,
                      width: 70,
                      height: 50,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
          Expanded(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    clip.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: playing
                ? Icon(Icons.play_arrow)
                : Icon(
                    Icons.play_arrow_outlined,
                    color: Colors.grey.shade300,
                  ),
          ),
        ],
      ),
    );
  }
}

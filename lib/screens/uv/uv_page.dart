import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:edu_valley/models/audio.dart';
import 'package:edu_valley/models/video.dart';
import 'package:edu_valley/services/disable_capture.dart';
import 'package:edu_valley/widgets/appbar.dart';
import 'package:edu_valley/screens/uv/video_page.dart';
import 'package:edu_valley/widgets/drawer.dart';
import 'package:edu_valley/widgets/offline.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';
import 'audio_page.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key, required this.courseId, this.zip, this.ongoing})
      : super(key: key);
  final int courseId;
  final String? zip;
  final int? ongoing;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int get _courseId {
    return widget.courseId;
  }

  String? get _zip {
    return widget.zip;
  }

  int? get _ongoing {
    return widget.ongoing;
  }

  PageController? pageController;
  int pageIndex = 0;
  bool _isFullscreen = false;
  String _connectionStatus = 'ConnectivityResult.wifi';
  late StreamSubscription _subscription;

  BottomNavigationBar botNavBar() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.ondemand_video),
          label: 'video',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.audiotrack),
          label: 'audio',
        ),
      ],
      currentIndex: pageIndex,
      selectedItemColor: Theme.of(context).primaryColor,
      onTap: onTap,
    );
  }

  @override
  void initState() {
    super.initState();
    _subscription = Connectivity().onConnectivityChanged.listen((event) {
      setState(() {
        _connectionStatus = event.toString();
      });
    });
    pageController = PageController();
    disableCapture();
  }

  @override
  void dispose() {
    _subscription.cancel();
    pageController!.dispose();
    super.dispose();
  }

  onPageChanged(int index) {
    setState(() {
      this.pageIndex = index;
    });
  }

  onTap(int pageIndex) {
    pageController!.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  function(value) => setState(() => _isFullscreen = value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _isFullscreen ? null : appBar(context, "Unit", menu),
      endDrawer: CustomDrawer(),
      body: Stack(
        children: [
          PageView(
            children: [
              FutureBuilder<List<Video>>(
                future: fetchVideos(http.Client(), _courseId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "No video available...",
                        style: TextStyle(fontSize: 20),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    return VideoPage(
                      clips: snapshot.data!,
                      func: function,
                      zip: _zip,
                      ongoing: _ongoing,
                    );
                  } else {
                    return Container(
                      color: Theme.of(context).primaryColor,
                      height: MediaQuery.of(context).size.height,
                      child: splashScreen,
                    );
                  }
                },
              ),
              FutureBuilder<List<Audio>>(
                future: fetchAudios(http.Client(), _courseId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Center(
                        child: Text(
                          "No audio available...",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    return AudioPage(audio: snapshot.data!);
                  } else {
                    return Container(
                      color: Theme.of(context).primaryColor,
                      height: MediaQuery.of(context).size.height,
                      child: splashScreen,
                    );
                  }
                },
              ),
            ],
            controller: pageController,
            onPageChanged: onPageChanged,
            physics: NeverScrollableScrollPhysics(),
          ),
          _connectionStatus != 'ConnectivityResult.wifi'
              ? Offline(status: _connectionStatus)
              : SizedBox()
        ],
      ),
      bottomNavigationBar:
          _isFullscreen ? Container(height: 0, width: 0) : botNavBar(),
    );
  }
}

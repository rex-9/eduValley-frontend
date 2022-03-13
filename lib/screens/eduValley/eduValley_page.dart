import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:edu_valley/screens/eduValley/edu_page.dart';
import 'package:edu_valley/screens/eduValley/valley_page.dart';
import 'package:edu_valley/services/disable_capture.dart';
import 'package:edu_valley/widgets/offline.dart';
import 'package:flutter/material.dart';

class EduValleyPage extends StatefulWidget {
  EduValleyPage({
    Key? key,
    this.userId,
    this.courseIds,
    this.genres,
  }) : super(key: key);
  final int? userId;
  final List<dynamic>? courseIds;
  final List<dynamic>? genres;

  @override
  _EduValleyPageState createState() => _EduValleyPageState();
}

class _EduValleyPageState extends State<EduValleyPage> {
  List<dynamic>? get _courseIds {
    return widget.courseIds;
  }

  int? get _userId {
    return widget.userId;
  }

  List<dynamic>? get _genres {
    return widget.genres;
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
          icon: Icon(Icons.menu_book_rounded),
          label: 'Courses',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.star),
          label: 'Fun',
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
      body: Stack(
        children: [
          PageView(
            children: [
              // FutureBuilder<List<Video>>(
              //   future: fetchVideos(http.Client(), _courseId),
              //   builder: (context, snapshot) {
              //     if (snapshot.hasError) {
              //       return const Center(
              //         child: Text(
              //           "No video available...",
              //           style: TextStyle(fontSize: 20),
              //         ),
              //       );
              //     } else if (snapshot.hasData) {
              //       return
              EduPage(
                userId: _userId,
                courseIds: _courseIds,
                genres: _genres,
                // );
                // } else {
                //   return Container(
                //     color: Theme.of(context).primaryColor,
                //     height: MediaQuery.of(context).size.height,
                //     child: splashScreen,
                //   );
                // }
                // },
              ),
              // FutureBuilder<List<Audio>>(
              //   future: fetchAudios(http.Client(), _courseId),
              //   builder: (context, snapshot) {
              //     if (snapshot.hasError) {
              //       return Center(
              //         child: Center(
              //           child: Text(
              //             "No audio available...",
              //             style: TextStyle(fontSize: 20),
              //           ),
              //         ),
              //       );
              //     } else if (snapshot.hasData) {
              //       return
              ValleyPage(userId: _userId
                  // );
                  //   } else {
                  //     return Container(
                  //       color: Theme.of(context).primaryColor,
                  //       height: MediaQuery.of(context).size.height,
                  //       child: splashScreen,
                  //     );
                  //   }
                  // },
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

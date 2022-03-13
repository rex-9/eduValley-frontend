import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:edu_valley/models/minivideo.dart';
import 'package:edu_valley/models/poster.dart';
import 'package:edu_valley/widgets/appbar.dart';
import 'package:edu_valley/widgets/drawer.dart';
import 'package:edu_valley/widgets/offline.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import 'package:http/http.dart' as http;

import 'minivideo_page.dart';
import 'poster_page.dart';

class AdProfileScreen extends StatefulWidget {
  const AdProfileScreen(
      {Key? key, required this.name, required this.adId, this.site})
      : super(key: key);
  final int adId;
  final String name;
  final String? site;
  @override
  _AdProfileScreenState createState() => _AdProfileScreenState();
}

class _AdProfileScreenState extends State<AdProfileScreen> {
  int get _adId {
    return widget.adId;
  }

  String get _name {
    return widget.name;
  }

  String? get _site {
    return widget.site;
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
          label: 'Video',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.photo_library_outlined),
          label: 'Poster',
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
      appBar: _isFullscreen ? null : appBar(context, _name, menu),
      endDrawer: CustomDrawer(),
      body: Container(
        decoration: BoxDecoration(gradient: sky()),
        child: Stack(
          children: [
            PageView(
              children: [
                FutureBuilder<List<Minivideo>>(
                  future: fetchMinivideos(http.Client(), _adId),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          "It's a little boring here... x(\n No video available.",
                          style: TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else if (snapshot.hasData) {
                      return MinivideoPage(
                        clips: snapshot.data!,
                        func: function,
                        zip: _site,
                        name: _name,
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
                FutureBuilder<List<Poster>>(
                  future: fetchPosters(http.Client(), _adId),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Center(
                          child: Text(
                            "No poster available...",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      );
                    } else if (snapshot.hasData) {
                      return PosterPage(posters: snapshot.data!);
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
      ),
      bottomNavigationBar:
          _isFullscreen ? Container(height: 0, width: 0) : botNavBar(),
    );
  }
}

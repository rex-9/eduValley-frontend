import 'dart:convert';

import 'package:edu_valley/models/freeVideo.dart';
import 'package:edu_valley/screens/free_screen.dart';
import 'package:edu_valley/screens/loading_screen.dart';
import 'package:edu_valley/screens/splash_screen.dart';
import 'package:edu_valley/services/login_screen.dart';
import 'package:edu_valley/services/api.dart';
import 'package:edu_valley/screens/uv/uv_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';

class CheckAuth extends StatefulWidget {
  @override
  _CheckAuthState createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  int? isAuth;

  @override
  void initState() {
    _checkIfLoggedIn();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _checkIfLoggedIn() async {
    // var currentUser;
    // var res = await Network().getData('/user/current');
    // var body = json.decode(res.body);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    // var token = localStorage.getString('token');
    // localStorage.setString('currentUser', json.encode(body['currentUser']));
    localStorage.getString('currentUser') == null
        ? setState(() {
            isAuth = 0;
          })
        :
        // currentUser =
        // await jsonDecode(localStorage.getString('currentUser')!);

        // if (currentUser != null) {
        setState(() {
            isAuth = 1;
          });
    // } else {
    //   setState(() {
    //     isAuth = 0;
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (isAuth == 0) {
      child = LoginScreen();
    } else if (isAuth == 1) {
      child = LoadingScreen();
    } else {
      child = SplashScreen();
    }
    return Scaffold(
      body: child,
    );
  }
}

class UVScreen extends StatefulWidget {
  UVScreen({
    Key? key,
    this.courseId,
    this.userId,
    this.zip,
    this.ongoing,
  }) : super(key: key);
  final int? courseId;
  final int? userId;
  final String? zip;
  final int? ongoing;

  @override
  _UVScreenState createState() => _UVScreenState();
}

class _UVScreenState extends State<UVScreen> {
  int _purchased = 0;

  int? get _userId {
    return widget.userId;
  }

  int? get _courseId {
    return widget.courseId;
  }

  // String? get _token {
  //   return widget.token;
  // }

  String? get _zip {
    return widget.zip;
  }

  int? get _ongoing {
    return widget.ongoing;
  }
  // List<Video> _videos;
  // List<Audio> _audios;
  // List<FreeVideo> _freeVideos;

  // Future _fetchData() async {
  //   var videos = await fetchVideos(http.Client(), _courseId);
  //   var audios = await fetchAudios(http.Client(), _courseId);
  //   var freeVideos = await fetchFreeVideos(http.Client(), _courseId);
  //   setState(() {
  //     _videos = videos;
  //     _audios = audios;
  //     _freeVideos = freeVideos;
  //   });
  // }

  @override
  void initState() {
    // _fetchData();
    _loadUserData();
    // fetchVideos(http.Client(), _courseId).then((value) => setState(() {
    //       _videos = value;
    //     }));
    // fetchAudios(http.Client(), _courseId).then((value) => setState(() {
    //       _audios = value;
    //     }));
    // fetchFreeVideos(http.Client(), _courseId).then((value) => setState(() {
    //       _freeVideos = value;
    //     }));
    // print('videos:' "$_videos");
    // print('audios:' "$_audios");
    // print('freevideos:' "$_freeVideos");
    super.initState();
  }

  _loadUserData() async {
    var res = await Network().getData('/user/current');
    var body = json.decode(res.body);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.setString('currentUser', json.encode(body['currentUser']));
    var user = jsonDecode(localStorage.getString('currentUser')!);
    if (user != null) {
      var res =
          await Network().getData('/user_course/records/$_userId/$_courseId');
      var body = json.decode(res.body);
      print(body);
      if (body != null) {
        setState(() {
          _purchased = 1;
        });
      }
      print(_purchased);
    } else {
      setState(() {
        localStorage.remove('token');
        localStorage.remove('currentUser');
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_purchased == 1) {
      child = MainPage(
        courseId: _courseId!,
        zip: _zip,
        ongoing: _ongoing,
      );
    } else if (_purchased == 0) {
      child = FutureBuilder<List<FreeVideo>>(
        future: fetchFreeVideos(http.Client(), _courseId!),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('An error occured.');
          } else if (snapshot.hasData) {
            return FreeScreen(clips: snapshot.data!);
          } else {
            return Container(
              color: Theme.of(context).primaryColor,
              height: MediaQuery.of(context).size.height,
              child: splashScreen,
            );
          }
        },
      );
      // FreeScreen(clips: _freeVideos);
      // } else if (purchased == null) {
      //   child = Text("No data in this course");
    } else {
      child = SplashScreen();
    }
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: child,
          decoration: BoxDecoration(
            gradient: sky(),
          ),
        ),
      ),
    );
  }
}

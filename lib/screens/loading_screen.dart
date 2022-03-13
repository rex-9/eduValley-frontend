import 'dart:convert';

import 'package:edu_valley/services/api.dart';
import 'package:flutter/material.dart';
import 'package:native_updater/native_updater.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import 'package:http/http.dart' as http;

import 'eduValley/eduValley_page.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  var _currentUser;
  int? _userId;
  List<dynamic>? _courseIds;
  List<dynamic>? _genres;
  @override
  void initState() {
    // _loadUserData();
    checkVersion();
    super.initState();
    // startTime();
  }

  Future<void> checkVersion() async {
    Future.delayed(Duration.zero, () {
      NativeUpdater.displayUpdateAlert(
        context,
        forceUpdate: true,
      );
    });
  }

  Future fetchData(
    http.Client client,
  ) async {
    var token;
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = jsonDecode(localStorage.getString('token')!);
    print('token: $token');
    final currentUserResponse = await client.get(
      Uri.parse(
        '${Network.url}/currentUser',
      ),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    var currentUserBody = jsonDecode(currentUserResponse.body);
    await localStorage.setString(
        'currentUser', json.encode(currentUserBody['currentUser']));
    _currentUser = await jsonDecode(localStorage.getString('currentUser')!);
    print("currentUser: $_currentUser");
    if (_currentUser != null) {
      // setState(() {
      _userId = _currentUser['id'];
      // });
      print("userId: $_userId");

      final courseIdsResponse = await client.get(
        Uri.parse(
          '${Network.url}/pluckCourseIds/$_userId',
        ),
      );
      var courseIdsBody = jsonDecode(courseIdsResponse.body);
      await localStorage.setString('courseIds', json.encode(courseIdsBody));
      _courseIds = await jsonDecode(localStorage.getString('courseIds')!);
      print("courseIds: $_courseIds");

      final genresResponse = await http.get(
        Uri.parse(
          '${Network.url}/pluckGenres',
        ),
      );
      var genresBody = jsonDecode(genresResponse.body);
      await localStorage.setString('genres', json.encode(genresBody));
      _genres = await jsonDecode(localStorage.getString('genres')!);
      print("genres: $_genres");
      return await jsonDecode(localStorage.getString('genres')!);
      // Use the compute function to run parseTeachers in a separate isolate.
      // return compute(parseTeachers, response.body);
    } else {
      setState(() {
        localStorage.remove('token');
        localStorage.remove('currentUser');
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
      });
    }
  }

  // _loadUserData() async {
  //   var res = await Network().getData('/currentUser');
  //   var body = jsonDecode(res.body);
  //   SharedPreferences localStorage = await SharedPreferences.getInstance();
  //   await localStorage.setString(
  //       'currentUser', json.encode(body['currentUser']));
  //   _currentUser = await jsonDecode(localStorage.getString('currentUser')!);
  //   setState(() {
  //     _userId = _currentUser['id'];
  //   });
  //   print("_userId => $_userId");
  //   var res2 = await Network().getData('/pluckCourseIds/$_userId');
  //   var body2 = jsonDecode(res2.body);
  //   await localStorage.setString('courseIds', json.encode(body2));
  //   _courseIds = await jsonDecode(localStorage.getString('courseIds')!);
  //   print("_courseIds => $_courseIds");

  //   setState(() {});

  //   Navigator.pop(context);
  //   print("popped");
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => EduValleyScreen(
  //         userId: _userId,
  //         courseIds: _courseIds,
  //       ),
  //     ),
  //   );
  //   print('pushed');
  // setState(() {
  // _role = _currentUser['role'];
  // _room = _role.substring(_role.indexOf(".") + 1, _role.lastIndexOf("."));
  // var demo = _role.replaceAll("meet.", "").replaceAll(".Student", "");
  // .replaceAll(".Teacher", "")
  // .replaceAll(".Admin", "")
  // _rooms = demo.split(".");
  // });
  // print(_currentUser);
  // print(_role);
  // print(_room);
  // print(_rooms);
  // }

  @override
  void dispose() {
    super.dispose();
  }

  // login() {
  //   Navigator.pushReplacementNamed(
  //     context,
  //     '/login',
  //   );
  // }

  // startTime() async {
  //   var duration = Duration(seconds: 15);
  //   return Timer(
  //     duration,
  //     login,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: FutureBuilder<dynamic>(
        future: fetchData(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${snapshot.error}',
                // 'Data loading failed!',
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 20,
                ),
              ),
            );
          } else if (snapshot.hasData) {
            return EduValleyPage(
              userId: _userId,
              courseIds: _courseIds,
              genres: _genres,
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
    );
  }
}

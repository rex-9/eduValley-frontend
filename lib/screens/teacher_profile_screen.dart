import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:edu_valley/models/book.dart';
import 'package:edu_valley/widgets/offline.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';

class TeacherProfileScreen extends StatefulWidget {
  TeacherProfileScreen({
    Key? key,
    this.teacherId,
    this.teacherPhoto,
    this.teacherUrl,
    this.teacherName,
  }) : super(key: key);
  final int? teacherId;
  final String? teacherName;
  final String? teacherPhoto;
  final String? teacherUrl;
  @override
  _TeacherProfileScreenState createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  String? get _teacherPhoto {
    return widget.teacherPhoto;
  }

  String? get _teacherUrl {
    return widget.teacherUrl;
  }

  String? get _teacherName {
    return widget.teacherName;
  }

  int? get _teacherId {
    return widget.teacherId;
  }

  List<Book>? _books;
  String _connectionStatus = 'ConnectivityResult.wifi';
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = Connectivity().onConnectivityChanged.listen((event) {
      setState(() {
        _connectionStatus = event.toString();
      });
    });
    fetchBooks(http.Client(), _teacherId!).then((value) => setState(() {
          _books = value;
        }));
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height * 2,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(gradient: sky()),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _connectionStatus != 'ConnectivityResult.wifi'
                    ? Offline(status: _connectionStatus)
                    : SizedBox(),
                Column(
                  children: [
                    SizedBox(height: 25),
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(_teacherPhoto!),
                    ),
                    Divider(
                      height: 40,
                      thickness: 2,
                      indent: 100,
                      endIndent: 100,
                      color: Theme.of(context).primaryColor,
                    ),
                    // SizedBox(height: 25),
                    Text(
                      (() {
                        if (_books == null) {
                          return "loading...";
                        } else if (_teacherName == "Saya U Nyan Win Htet"
                            // _books!.length == 0 || _books!.length == 1
                            ) {
                          return "The books written and published by $_teacherName"
                              "\n(Sarpay Beikman) "
                              "are as follows: ";
                        }
                        return _teacherName!;
                      })(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 15),
                    (() {
                      if (_books == null) {
                        return Text('loading...');
                      } else if (_books!.length == 0) {
                        return Container(
                          child: Center(
                              child: Text("Still deciding what to display")),
                          height: MediaQuery.of(context).size.height * 0.2,
                        );
                      } else {
                        return Wrap(
                          children: _books!
                              .map((book) => GestureDetector(
                                    onTap: () =>
                                        Navigator.of(context).pushNamed(
                                      "/book",
                                      arguments: book.url,
                                    ),
                                    child: Container(
                                      margin: EdgeInsets.all(10),
                                      child: Stack(children: [
                                        Container(
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              backgroundColor: Colors.white,
                                            ),
                                          ),
                                          height: 100,
                                          width: 150,
                                        ),
                                        _books!.length == 1
                                            ? Image.network(book.url)
                                            : Image.network(
                                                book.url,
                                                height: 100,
                                                width: 150,
                                                cacheHeight: 100,
                                                cacheWidth: 150,
                                                fit: BoxFit.cover,
                                              ),
                                      ]),
                                    ),
                                  ))
                              .toList(),
                        );
                      }
                    })(),
                    SizedBox(height: 15),
                    Text(
                      (() {
                        if (_books == null) {
                          return "loading...";
                        } else if (_teacherName == "Saya U Nyan Win Htet"
                            // _books!.length == 0 || _books!.length == 1
                            ) {
                          return '''To purchase the books, 
please contact''';
                        } else
                          return _teacherUrl == null
                              ? ""
                              : "To contact $_teacherName";
                      })(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10),
                    _teacherUrl == null
                        ? Container()
                        : urlButton(
                            context,
                            _teacherUrl,
                            _teacherName,
                          ),
                    SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

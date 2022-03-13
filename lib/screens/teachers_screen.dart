import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:edu_valley/models/teacher.dart';
import 'package:edu_valley/screens/teacher_profile_screen.dart';
import 'package:edu_valley/services/api.dart';
import 'package:edu_valley/widgets/appbar.dart';
import 'package:edu_valley/widgets/offline.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';

class TeachersScreen extends StatefulWidget {
  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  List<dynamic>? _genres;
  String _search = '';
  String _selectedValue = "Basic";

  String _connectionStatus = 'ConnectivityResult.wifi';
  late StreamSubscription _subscription;

  List<DropdownMenuItem<String>> get _dropdownItems {
    List<DropdownMenuItem<String>> menuItems = _genres == null
        ? [
            DropdownMenuItem(child: Text("Basic"), value: "Basic"),
          ]
        : _genres!
            .map(
              (genre) => DropdownMenuItem(child: Text(genre), value: "$genre"),
            )
            .toList();
    return menuItems;
  }

  _pluckGenres() async {
    final response = await http.get(Uri.parse(
      '${Network.url}/pluckGenres',
    ));
    setState(() {
      _genres = jsonDecode(response.body);
    });
  }

  @override
  void initState() {
    _subscription = Connectivity().onConnectivityChanged.listen((event) {
      setState(() {
        _connectionStatus = event.toString();
      });
    });
    _pluckGenres();
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        context,
        "Teachers",
        Icon(
          Icons.ac_unit,
          size: 30,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _connectionStatus != 'ConnectivityResult.wifi'
                ? Offline(status: _connectionStatus)
                : SizedBox(),
            Container(
              height: MediaQuery.of(context).size.height * 2,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                gradient: sky(),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Role:',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(width: 25),
                        DropdownButton(
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          value: _selectedValue,
                          items: _dropdownItems,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedValue = newValue!;
                              _search = newValue;
                            });
                          },
                        ),
                      ],
                    ),
                    FutureBuilder<List<Teacher>>(
                      future: _search == ''
                          ? fetchTeachers(http.Client())
                          : searchTeachers(http.Client(), _search),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              'Coming soon...\n Stay tuned!',
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 20,
                              ),
                            ),
                          );
                        } else if (snapshot.hasData) {
                          return Column(
                            children: snapshot.data!
                                .map(
                                  (teacher) => Container(
                                    margin: EdgeInsets.only(
                                      left: 20,
                                      top: 10,
                                      right: 20,
                                      bottom: 0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: Offset(
                                            0,
                                            3,
                                          ), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: TextButton(
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TeacherProfileScreen(
                                            teacherId: teacher.id,
                                            teacherName: teacher.name,
                                            teacherPhoto: teacher.photo,
                                            teacherUrl: teacher.url,
                                          ),
                                        ),
                                      ),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        color: Colors.white,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              SizedBox(width: 5),
                                              CircleAvatar(
                                                radius: 40,
                                                backgroundImage:
                                                    NetworkImage(teacher.photo),
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                teacher.name,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
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
                    SizedBox(height: 20),
                    Text(
                      "Tap to know more about your teacher!",
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "More teachers coming... \nStay tuned!",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

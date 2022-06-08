import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:edu_valley/constants.dart';
import 'package:edu_valley/models/course.dart';
import 'package:edu_valley/models/teacher.dart';
import 'package:edu_valley/services/wrapper.dart';
import 'package:edu_valley/widgets/appbar.dart';
import 'package:edu_valley/widgets/drawer.dart';
import 'package:edu_valley/widgets/offline.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:connectivity/connectivity.dart';
import 'package:jitsi_meet/jitsi_meet.dart';

class EduPage extends StatefulWidget {
  EduPage({
    Key? key,
    this.userId,
    this.courseIds,
    this.genres,
  }) : super(key: key);
  final int? userId;
  final List<dynamic>? courseIds;
  final List<dynamic>? genres;
  @override
  _EduPageState createState() => _EduPageState();
}

class _EduPageState extends State<EduPage> {
  List<dynamic>? get _courseIds {
    return widget.courseIds;
  }

  int? get _userId {
    return widget.userId;
  }

  List<dynamic>? get _genres {
    return widget.genres;
  }

  final _formKey = GlobalKey<FormState>();
  final serverText = TextEditingController();
  final roomText = TextEditingController(
      // text: "eduValley"
      );
  final subjectText = TextEditingController(
      // text: "Topic"
      );
  final nameText = TextEditingController(
      // text: "Happy Student"
      );
  final emailText = TextEditingController(
      // text: "happystudent@eduvalley.com"
      );
  final iosAppBarRGBAColor =
      TextEditingController(text: "#0080FF80"); //transparent blue
  bool? isAudioOnly = true;
  bool? isAudioMuted = true;
  bool? isVideoMuted = true;

  TextEditingController? _controller;
  String? _search;
  bool _loading = false;
  String _selectedValue = "Basic";
  // String _role = 'Student';
  // String _room = 'eduValley';
  // List<dynamic>? _rooms;

  double _roundDouble(double value, int places) {
    num mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  List<DropdownMenuItem<String>> get _dropdownItems {
    List<DropdownMenuItem<String>> menuItems = _genres == null
        ? [
            DropdownMenuItem(child: Text("Basic"), value: "Basic"),
          ]
        : [
            DropdownMenuItem(child: Text("All"), value: "All"),
            ..._genres!
                .map(
                  (genre) =>
                      DropdownMenuItem(child: Text(genre), value: "$genre"),
                )
                .toList()
          ];
    return menuItems;
  }

  // List<DropdownMenuItem<String>> get _dropdownRooms {
  //   List<DropdownMenuItem<String>> menuItems = _rooms == null
  //       ? [
  //           DropdownMenuItem(child: Text("eduValley"), value: "eduValley"),
  //           DropdownMenuItem(child: Text("Meditate"), value: "Meditate"),
  //         ]
  //       : [
  //           DropdownMenuItem(child: Text("eduValley"), value: "eduValley"),
  //           DropdownMenuItem(child: Text("Meditate"), value: "Meditate"),
  //           ..._rooms!
  //               .map(
  //                 (room) => DropdownMenuItem(child: Text(room), value: "$room"),
  //               )
  //               .toList()
  //         ];
  //   return menuItems;
  // }

  void _searchOperation(String searchText) {
    setState(() {
      _loading = true;
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        _search = searchText;
        _loading = false;
      });
    });
  }

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    JitsiMeet.addListener(
      JitsiMeetingListener(
        onConferenceWillJoin: _onConferenceWillJoin,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
        onError: _onError,
      ),
    );
    print(_courseIds);
  }

  @override
  dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _subscription.cancel();
    JitsiMeet.removeAllListeners();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: appBar(context, "Course ", menu),
      endDrawer: CustomDrawer(),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(gradient: sky()),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _connectionStatus != 'ConnectivityResult.wifi'
                  ? Offline(status: _connectionStatus)
                  : SizedBox(),
              Column(
                children: [
                  _loading == true ? LinearProgressIndicator() : SizedBox(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 5,
                    ),
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search name, subject or grade...',
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                      onChanged: _searchOperation,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Genre:',
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
                            newValue == "All"
                                ? _search = ''
                                : _search = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                  FutureBuilder<List<Course>>(
                    future: _search == null
                        ? fetchCourses(http.Client())
                        : searchCourses(http.Client(), _search!),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: Center(
                            child: Column(
                              children: [
                                SizedBox(height: 50),
                                Text(
                                  // '${snapshot.error}',
                                  // 'Please search properly...',
                                  'Whoops! Something is wrong... \nPlease check your internet connection\nand try again...  ',
                                  // '       Too many requests \n or \n data not found \nplz be patient for a moment...',
                                  style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: 20,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      } else if (snapshot.hasData) {
                        return Column(
                          children: snapshot.data!
                              .map(
                                (course) => GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UVScreen(
                                        courseId: course.id,
                                        userId: _userId,
                                        zip: course.zip,
                                        ongoing: course.ongoing,
                                      ),
                                    ),
                                  ),
                                  child: Container(
                                    width: 350,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          spreadRadius: 2,
                                          blurRadius: 2,
                                          offset: const Offset(
                                            2,
                                            3,
                                          ), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AspectRatio(
                                          aspectRatio: 16 / 9,
                                          child: Container(
                                            // width: 350,
                                            // height: 220,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  course.image,
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 170,
                                          child: Row(
                                            children: [
                                              const SizedBox(width: 20),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    course.name,
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 0.8,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    course.subject +
                                                        ' (' +
                                                        course.grade +
                                                        ') ',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      letterSpacing: 0.8,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  FutureBuilder<Teacher>(
                                                    future: fetchTeacher(
                                                      course.teacherId,
                                                    ),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot.hasData) {
                                                        return Text(
                                                          snapshot.data!.name,
                                                          style: TextStyle(
                                                            color: Colors
                                                                .yellow[800],
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            letterSpacing: 0.3,
                                                          ),
                                                        );
                                                      } else if (snapshot
                                                          .hasError) {
                                                        return Text(
                                                          'Failed to load Teacher',
                                                          // '${snapshot.error}',
                                                        );
                                                      }
                                                      // By default, show a loading spinner.
                                                      return Text(
                                                        'loading ...',
                                                      );
                                                    },
                                                  ),
                                                  const SizedBox(height: 5),
                                                  ConstrainedBox(
                                                    constraints: BoxConstraints(
                                                      maxWidth: 170,
                                                    ),
                                                    child: Text(
                                                      course.students > 10000 &&
                                                              course.students <
                                                                  1000000
                                                          // ? "${course.students} students en..."
                                                          // ? "${_roundDouble(course.students * 0.001, 1)}K students enrolled"
                                                          ? "${course.students} students enrolled"
                                                          : course.students >
                                                                  1000000
                                                              ? "${_roundDouble(course.students * 0.000001, 1)}M students enrolled"
                                                              : "${course.students} students enrolled",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        letterSpacing: 0.2,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    course.price == 0
                                                        ? "Loving Kindness"
                                                        : _courseIds!.contains(
                                                                course.id)
                                                            // : _currentUser[course
                                                            //             .token] ==
                                                            //         1
                                                            ? "Purchased ✅"
                                                            : "${course.price} Kyat",
                                                    style: const TextStyle(
                                                      color: Colors.green,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      letterSpacing: 0.2,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: SizedBox(
                                                  width: double.infinity,
                                                  child: FutureBuilder<Teacher>(
                                                    future: fetchTeacher(
                                                      course.teacherId,
                                                    ),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot.hasData) {
                                                        return CircleAvatar(
                                                          minRadius: 20,
                                                          backgroundImage:
                                                              NetworkImage(
                                                            snapshot
                                                                .data!.photo,
                                                          ),
                                                        );
                                                      } else if (snapshot
                                                          .hasError) {
                                                        return Text(
                                                          '${snapshot.error}',
                                                        );
                                                      }
                                                      // By default, show a loading spinner.
                                                      return Container();
                                                    },
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                            ],
                                          ),
                                        ),
                                      ],
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
                  SizedBox(height: 25),
                  Text(
                    "More courses coming... \n\n Stay tuned!\n\n",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton:
          // _role.contains("meet")
          //     ?
          FloatingActionButton(
        child: Icon(Icons.video_call_outlined),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => showModalBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: kIsWeb
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: width * 0.30,
                            child: meetConfig(),
                          ),
                          Container(
                            width: width * 0.60,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                  color: Colors.white54,
                                  child: SizedBox(
                                    width: width * 0.60 * 0.70,
                                    height: width * 0.60 * 0.70,
                                    child: JitsiMeetConferencing(
                                      extraJS: [
                                        // extraJs setup example
                                        '<script>function echo(){console.log("echo!!!")};</script>',
                                        '<script src="https://code.jquery.com/jquery-3.5.1.slim.js" integrity="sha256-DrT5NfxfbHvMHux31Lkhxg42LY6of8TaYyK50jnxRnM=" crossorigin="anonymous"></script>'
                                      ],
                                    ),
                                  )),
                            ),
                          )
                        ],
                      )
                    : meetConfig(),
              );
            }),
      ),
      // : null,
    );
  }

  Widget meetConfig() {
    return SingleChildScrollView(
      child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return Container(
          height: MediaQuery.of(context).size.height * 1.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 14.0),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: roomText,
                      validator: (value) => value!.isEmpty || value.length < 3
                          ? 'Minimum of 3 digits!'
                          : null,
                      decoration: inputDecoration.copyWith(
                        prefixIcon: Icon(
                          Icons.meeting_room_outlined,
                          size: 30,
                        ),
                        hintText: 'RoomID',
                      ),
                    ),
                    SizedBox(height: 25),
                    TextFormField(
                      controller: subjectText,
                      validator: (value) =>
                          value!.isEmpty ? 'Topic should not be empty!' : null,
                      decoration: inputDecoration.copyWith(
                        prefixIcon: Icon(
                          Icons.topic_outlined,
                          size: 30,
                        ),
                        hintText: 'Topic',
                      ),
                    ),
                    SizedBox(height: 25),
                    TextFormField(
                      controller: nameText,
                      validator: (value) => value!.isEmpty
                          ? 'Your Name should not be empty!'
                          : null,
                      decoration: inputDecoration.copyWith(
                        prefixIcon: Icon(
                          Icons.person_pin_outlined,
                          size: 30,
                        ),
                        hintText: 'Your Name',
                      ),
                    ),
                    SizedBox(height: 25),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextButton(
                        child: Text(
                          'Join Meeting',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _joinMeeting();
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Note:\nTIME interval is UNLIMITED!\nNumber of PARTICIPANTS is UNLIMITED!\n\nCreating the meeting and\njoining the meeting are the same.\nJust use the same Room ID and Topic.\n\nThe meeting is still in development.\nSome features may not work as you expected.\nInvite link doesn't work.\n Less than 100 Users can smoothly meet.\n\nSo... enjoy your meeting. 😉 \n\nFriendly reminder:\nIf you enjoy eduValley,\ndon't forget to review our app and facebook page.\n\nWith love and best wishes.✨",
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // _role.contains("Teacher")
              //     ?
              // TextField(
              //   controller: roomText,
              //   decoration: InputDecoration(
              //     border: OutlineInputBorder(),
              //     labelText: "Room",
              //   ),
              // ),
              // : Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Text(
              //         "Room:",
              //         style: TextStyle(
              //           fontWeight: FontWeight.w500,
              //           fontSize: 18,
              //         ),
              //       ),
              //       SizedBox(width: 25),
              //       DropdownButton(
              //         style: TextStyle(
              //           fontWeight: FontWeight.w400,
              //           color: Colors.black,
              //           fontSize: 16,
              //         ),
              //         value: _room,
              //         items: _dropdownRooms,
              //         onChanged: (String? newValue) {
              //           setState(() {
              //             _room = newValue!;
              //           });
              //         },
              //       ),
              //     ],
              //   ),
              // _role.contains("Teacher") ?
              // SizedBox(height: 14.0),
              // : SizedBox(),
              // _role.contains("Teacher")
              //     ?
              // TextField(
              //   controller: subjectText,
              //   decoration: InputDecoration(
              //     border: OutlineInputBorder(),
              //     labelText: "Topic",
              //   ),
              // ),
              // : SizedBox(),
              // SizedBox(height: 14.0),
              // TextField(
              //   controller: nameText,
              //   decoration: InputDecoration(
              //     border: OutlineInputBorder(),
              //     labelText: "Your Name",
              //   ),
              // ),
              // SizedBox(height: 10),
              // Text(
              //   "Note: The meeting is still in development. \nInvite link doesn't work.",
              //   style: TextStyle(color: Colors.red),
              // ),
              // Divider(
              //   height: 25.0,
              //   thickness: 2.0,
              // ),
              // SizedBox(
              //   height: 64.0,
              //   width: double.maxFinite,
              //   child: ElevatedButton(
              //     onPressed: () {
              //       _joinMeeting();
              //     },
              //     child: Text(
              //       "Join Meeting",
              //       style: TextStyle(
              //         color: Colors.white,
              //         fontSize: 20,
              //       ),
              //     ),
              //     style: ButtonStyle(
              //         backgroundColor: MaterialStateColor.resolveWith(
              //             (states) => Colors.blue)),
              //   ),
              // ),
              // SizedBox(
              //   height: 48.0,
              // ),
            ],
          ),
        );
      }),
    );
  }

  _joinMeeting() async {
    String? serverUrl = serverText.text.trim().isEmpty ? null : serverText.text;

    // Enable or disable any feature flag here
    // If feature flag are not provided, default values will be used
    // Full list of feature flags (and defaults) available in the README
    Map<FeatureFlagEnum, bool> featureFlags = {
      FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
    };
    if (!kIsWeb) {
      // Here is an example, disabling features for each platform
      if (Platform.isAndroid) {
        // Disable ConnectionService usage on Android to avoid issues (see README)
        featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
      } else if (Platform.isIOS) {
        // Disable PIP on iOS as it looks weird
        featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
      }
    }
    // Define meetings options here
    var options = JitsiMeetingOptions(
        room:
            // _rooms!.contains("Teacher") ?
            roomText.text
        // : _room
        )
      ..serverURL = serverUrl
      ..subject = subjectText.text
      ..userDisplayName = nameText.text
      ..userEmail = emailText.text
      ..iosAppBarRGBAColor = iosAppBarRGBAColor.text
      ..audioOnly = isAudioOnly
      ..audioMuted = isAudioMuted
      ..videoMuted = isVideoMuted
      ..featureFlags.addAll(featureFlags)
      ..webOptions = {
        "roomName": roomText.text,
        "width": "100%",
        "height": "100%",
        "enableWelcomePage": false,
        "chromeExtensionBanner": null,
        "userInfo": {"displayName": nameText.text}
      };

    debugPrint("JitsiMeetingOptions: $options");
    await JitsiMeet.joinMeeting(
      options,
      listener: JitsiMeetingListener(
        onConferenceWillJoin: (message) {
          debugPrint("${options.room} will join with message: $message");
        },
        onConferenceJoined: (message) {
          debugPrint("${options.room} joined with message: $message");
        },
        onConferenceTerminated: (message) {
          debugPrint("${options.room} terminated with message: $message");
        },
        genericListeners: [
          JitsiGenericListener(
            eventName: 'readyToClose',
            callback: (dynamic message) {
              debugPrint("readyToClose callback");
            },
          ),
        ],
      ),
    );
  }

  void _onConferenceWillJoin(message) {
    debugPrint("_onConferenceWillJoin broadcasted with message: $message");
  }

  void _onConferenceJoined(message) {
    debugPrint("_onConferenceJoined broadcasted with message: $message");
  }

  void _onConferenceTerminated(message) {
    debugPrint("_onConferenceTerminated broadcasted with message: $message");
  }

  _onError(error) {
    debugPrint("_onError broadcasted: $error");
  }
}

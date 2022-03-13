import 'dart:convert';

import 'package:edu_valley/constants.dart';
import 'package:edu_valley/services/api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String? _name;
  String? _email;

  @override
  void initState() {
    _loadUserData();
    super.initState();
  }

  _loadUserData() async {
    // var res = await Network().getData('/user');
    // var body = json.decode(res.body);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    // await localStorage.setString('data', json.encode(body['data']));
    var currentUser = await jsonDecode(localStorage.getString('currentUser')!);

    if (currentUser != null) {
      setState(() {
        _name = currentUser['name'];
        _email = currentUser['email'];
      });
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
    double height = MediaQuery.of(context).size.height;
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      height = height * 2;
    }
    return Drawer(
      child: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: height,
            color: Colors.grey[200],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(height: 0),
                Column(
                  children: [
                    Text(
                      _name != null ? _name! : "...",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _email != null ? _email! : "...",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 5,
                  thickness: 2,
                  // indent: 25,
                  // endIndent: 25,
                  color: Theme.of(context).dividerColor,
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, "/teachers");
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 20),
                        Text(
                          'Teachers',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                // Container(
                //   margin: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                //   decoration: BoxDecoration(
                //     color: Colors.black45,
                //     border: Border.all(color: Colors.grey.shade400),
                //     borderRadius: BorderRadius.all(Radius.circular(50)),
                //   ),
                //   child: TextButton(
                //     onPressed: () {
                //       Navigator.pop(context);
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (context) => ValleyPage(
                //             userId: _id,
                //           ),
                //         ),
                //       );
                //     },
                //     child: SingleChildScrollView(
                //       scrollDirection: Axis.horizontal,
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           SizedBox(width: 20),
                //           Text(
                //             'Discover new interests✨',
                //             style: TextStyle(
                //               color: Colors.white,
                //               fontSize: 20,
                //             ),
                //             textAlign: TextAlign.center,
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                SizedBox(height: 20),
                Text(
                  '''If you are a wonderful teacher who wants to deploy your beautiful course onto this platform,\nplease contact''',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                urlButton(
                  context,
                  'https://www.facebook.com/EduValley-104744954899008',
                  "eduValley",
                ),
                SizedBox(height: 25),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: TextButton(
                    onPressed: () {
                      logout();
                    },
                    child: Text(
                      "Logout",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                SizedBox(height: 40)
              ],
            ),
          ),
        ),
      ),
    );
  }

  void logout() async {
    var res = await Network().postData('/logout');
    var body = json.decode(res.body);
    if (body["status"] == "success") {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.remove('token');
      localStorage.remove('currentUser');
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    } else {
      print('logout unsuccessful');
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.remove('token');
      localStorage.remove('currentUser');
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    }
  }
}

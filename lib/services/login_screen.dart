import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:edu_valley/screens/splash_screen.dart';
import 'package:edu_valley/services/api.dart';
import 'package:edu_valley/widgets/offline.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? _email, _password;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String _connectionStatus = 'ConnectivityResult.wifi';
  late StreamSubscription _subscription;

  @override
  void initState() {
    _subscription = Connectivity().onConnectivityChanged.listen((event) {
      setState(() {
        _connectionStatus = event.toString();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      height = height * 2;
    }
    return Stack(children: [
      SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          body: SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  height: height,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/img/bg.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome to ',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 25),
                          Text(
                            'eduValley',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 50),
                          TextFormField(
                            validator: (value) => value!.isEmpty ||
                                    !EmailValidator.validate(value.trim(), true)
                                ? 'Enter a valid Email!'
                                : null,
                            onChanged: (val) {
                              setState(() => _email = val.trim());
                            },
                            decoration: inputDecoration.copyWith(
                              prefixIcon: Icon(
                                Icons.mail_outline,
                                size: 30,
                              ),
                              hintText: 'Email',
                            ),
                          ),
                          SizedBox(height: 25),
                          TextFormField(
                            validator: (value) => value!.length < 6
                                ? 'Minimum of 6 digits!'
                                : null,
                            onChanged: (val) {
                              setState(() => _password = val);
                            },
                            decoration: inputDecoration.copyWith(
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                size: 30,
                              ),
                              hintText: 'Password',
                            ),
                            obscureText: true,
                          ),
                          SizedBox(height: 50),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: TextButton(
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _login();
                                }
                              },
                            ),
                          ),
                          SizedBox(height: 20),
                          TextButton(
                            child: Text(
                              "Forgot password?",
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            onPressed: () async {
                              if (await canLaunch(
                                  '${Network.url.replaceAll("/api", "")}/forgot-password')) {
                                await launch(
                                    '${Network.url.replaceAll("/api", "")}/forgot-password');
                              } else {
                                throw 'Could not launch ${Network.url}/forgot-password';
                              }
                            },
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "First time using eduValley?",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              TextButton(
                                child: Text(
                                  "Register here!",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/register',
                                  );
                                },
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                _connectionStatus != 'ConnectivityResult.wifi'
                    ? Offline(status: _connectionStatus)
                    : SizedBox(),
              ],
            ),
          ),
        ),
      ),
      isLoading ? SplashScreen() : Container(),
    ]);
  }

  void _login() async {
    setState(() {
      isLoading = true;
    });
    var data = {'email': _email, 'password': _password};

    var res = await Network().authData(data, '/login/api');
    var body = json.decode(res.body);
    if (body["status"] == "success") {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setString('token', json.encode(body['token']));
      localStorage.setString('currentUser', json.encode(body['data']));
      Navigator.pushReplacementNamed(
        context,
        '/loading',
      );
    } else {
      _showMsg(body['message']);
    }

    setState(() {
      isLoading = false;
    });
  }

  _showMsg(msg) {
    final snackBar = SnackBar(
      content: Text(msg),
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {
          // Some code to undo the change!
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

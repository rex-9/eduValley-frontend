import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:edu_valley/screens/splash_screen.dart';
import 'package:edu_valley/services/api.dart';
import 'package:edu_valley/widgets/offline.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String? name;
  String? phone;
  String? email;
  String? password;
  String? confirm;
  TextEditingController? _nameController;
  TextEditingController? _phoneController;
  TextEditingController? _emailController;
  TextEditingController? _passwordController;
  TextEditingController? _confirmPasswordController;

  bool isLoading = false;
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
    _nameController = TextEditingController(text: "");
    _phoneController = TextEditingController(text: "");
    _emailController = TextEditingController(text: "");
    _passwordController = TextEditingController(text: "");
    _confirmPasswordController = TextEditingController(text: "");
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height * 1.25;
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
                            controller: _nameController,
                            validator: (value) => value!.length < 3
                                ? 'Minimum of 3 digits!'
                                : null,
                            onChanged: (val) {
                              setState(() => name = val);
                            },
                            decoration: inputDecoration.copyWith(
                              prefixIcon: Icon(
                                Icons.face,
                                size: 30,
                              ),
                              hintText: 'Your Name',
                            ),
                          ),
                          SizedBox(height: 25),
                          TextFormField(
                            controller: _phoneController,
                            validator: (value) =>
                                value!.isEmpty ? 'Enter Phone Number!' : null,
                            decoration: inputDecoration.copyWith(
                              prefixIcon: Icon(
                                Icons.phone_iphone,
                                size: 30,
                              ),
                              hintText: 'Phone Number',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (val) {
                              setState(() => phone = val.trim());
                            },
                          ),
                          SizedBox(height: 25),
                          TextFormField(
                            controller: _emailController,
                            validator: (value) => value!.isEmpty ||
                                    !EmailValidator.validate(value.trim(), true)
                                ? 'Enter a valid Email!'
                                : null,
                            onChanged: (val) {
                              setState(() => email = val.trim());
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
                            controller: _passwordController,
                            validator: (value) => value!.length < 6
                                ? 'Minimum of 6 digits!'
                                : null,
                            onChanged: (val) {
                              setState(() => password = val);
                            },
                            decoration: inputDecoration.copyWith(
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  size: 30,
                                ),
                                hintText: 'Password'),
                            obscureText: true,
                          ),
                          SizedBox(height: 25),
                          TextFormField(
                            controller: _confirmPasswordController,
                            validator: (value) => value != password
                                ? 'Passwords do not match!'
                                : null,
                            onChanged: (val) {
                              setState(() => confirm = val);
                            },
                            decoration: inputDecoration.copyWith(
                                prefixIcon: Icon(
                                  Icons.check,
                                  size: 30,
                                ),
                                hintText: 'Confirm Password'),
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
                                'Register',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _register();
                                }
                              },
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Already have an account?"),
                              TextButton(
                                child: Text(
                                  "Login here!",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/login',
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

  void _register() async {
    setState(() {
      isLoading = true;
    });
    var data = {
      'email': email,
      'name': name,
      'phone': phone,
      'password': password,
    };

    var res = await Network().authData(data, '/apiregister');
    var body = json.decode(res.body);
    if (body['status'] == "success") {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setString('token', json.encode(body['token']));
      localStorage.setString('currentUser', json.encode(body['data']));
      Navigator.pushReplacementNamed(
        context,
        '/loading',
      );
    } else {
      _showMsg("This email is already taken!");
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

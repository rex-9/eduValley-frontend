import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // @override
  // void initState() async {
  //   // startTime();
  //   super.initState();
  // }

  // @override
  // void dispose() {
  //   super.dispose();
  // }

  // login() async {
  //   SharedPreferences localStorage = await SharedPreferences.getInstance();
  //   localStorage.remove('token');
  //   localStorage.remove('currentUser');
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
      body: Center(
        child: SpinKitDoubleBounce(
          color: Colors.white,
        ),
      ),
    );
  }
}

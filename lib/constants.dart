import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';

var icon;
var hintText;

var inputDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 15),
  prefixIcon: icon,
  hintText: hintText,
);

sky() {
  return LinearGradient(colors: [
    Color(0xFF35D6ED),
    Color(0xFF65DDEF),
    Color(0xFF7AE5F5),
    Color(0xFF97EBF4),
    Color(0xFFC9F6FF),
  ]);
}

Icon menu = Icon(
  Icons.menu,
  size: 35,
  color: Colors.black,
);

Center splashScreen = Center(
  child: SpinKitDoubleBounce(
    size: 50,
    color: Colors.white,
  ),
);

ElevatedButton urlButton(context, url, label) => ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          Theme.of(context).primaryColor,
        ),
      ),
      onPressed: () async {
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch $url';
        }
      },
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
    );

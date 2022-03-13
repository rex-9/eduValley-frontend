import 'package:flutter_windowmanager/flutter_windowmanager.dart';

Future disableCapture() async {
  await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
}

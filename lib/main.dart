import 'package:edu_valley/screens/ad/ad_profile_screen.dart';
import 'package:edu_valley/screens/eduValley/valley_page.dart';
import 'package:edu_valley/screens/loading_screen.dart';
import 'package:edu_valley/screens/teacher_profile_screen.dart';
import 'package:edu_valley/screens/teachers_screen.dart';
import 'package:edu_valley/widgets/fullbook.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'screens/eduValley/eduValley_page.dart';
import 'screens/splash_screen.dart';
import 'services/login_screen.dart';
import 'services/register_screen.dart';
import 'services/wrapper.dart';

void main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eduValley',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF6BA8E8),
        secondaryHeaderColor: Colors.green,
        cardColor: Colors.yellow[900],
        // accentColor: Colors.yellow[900],
        dividerColor: Color(0xFFC4C4C4),
        // secondaryHeaderColor: Color(0xFFC4C4C4),
        scaffoldBackgroundColor: Color(0xFFF0F0F0),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Quicksand',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => CheckAuth(),
        '/loading': (context) => LoadingScreen(),
        '/splash': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/eduValley': (context) => EduValleyPage(),
        '/book': (context) => FullBook(),
        '/uv': (context) => UVScreen(),
        '/teachers': (context) => TeachersScreen(),
        '/teacherprofile': (context) => TeacherProfileScreen(),
        '/valley': (context) => ValleyPage(),
        '/adprofile': (context) => AdProfileScreen(
              adId: 1,
              name: '',
            ),
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'navigation_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _fcmToken;
  @override
  void initState() {
    super.initState();
    checkAutoLogin();
  }


  Future<void> initLocalNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  _navigateToHome() async {

    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  Future<void> checkAutoLogin() async {
    await Future.delayed(Duration(seconds: 3), () {});
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('USERID');
    if (token != null) {
      // bool isValid = await verifyToken(jwtToken);
      // if (isValid) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
      //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
      // } else {
      //   await prefs.remove('jwt_token');
      //   LoginScreen();
      // }
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/icons/Profile.png',width: 250,),
      ),
    );
  }
}
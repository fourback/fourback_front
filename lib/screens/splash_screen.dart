import 'package:bemajor_frontend/screens/user_information_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'navigation_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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



  Future<void> checkAutoLogin() async {
    await Future.delayed(Duration(seconds: 3), () {});
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('USERID');
    if (token != null) {
      // 토큰이 있을 경우 프로필 정보 확인
      bool profileIncomplete = await _checkUserProfile(token);
      if (profileIncomplete) {
        // 프로필이 완전하지 않으면 프로필 입력 화면으로 이동
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => UserInformationScreen()));
      } else {
        // 프로필이 완전하면 네비게이션 스크린으로 이동
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => navigationScreen()));
      }
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  Future<bool> _checkUserProfile(String token) async {
    final url = Uri.http('116.47.60.159:8080', '/api/users');
    try {
      final response = await http.get(
        url,
        headers: {'access': '$token'},  // 토큰을 이용해 사용자 정보 요청
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));

        // 필수 정보 체크
        if (jsonData["userName"] == null || jsonData["userName"] == "" ||
            jsonData["email"] == null || jsonData["email"] == "" ||
            jsonData["birth"] == null || jsonData["birth"] == "" ||
            jsonData["belong"] == null || jsonData["belong"] == "" ||
            jsonData["department"] == null || jsonData["department"] == "" ||
            jsonData["hobby"] == null || jsonData["hobby"] == "" ||
            jsonData["objective"] == null || jsonData["objective"] == "" ||
            jsonData["address"] == null || jsonData["address"] == "" ||
            jsonData["techStack"] == null || jsonData["techStack"] == "") {
          return true;  // 프로필 정보가 불완전하면 true 반환
        }
      } else {
        print('Failed to load profile data: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }

    return false;  // 프로필 정보가 완전하면 false 반환
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
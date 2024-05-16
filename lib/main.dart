import 'dart:io';

import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

void main() async {
  // 웹 환경에서 카카오 로그인을 정상적으로 완료하려면 runApp() 호출 전 아래 메서드 호출 필요
  WidgetsFlutterBinding.ensureInitialized();

  // runApp() 호출 전 Flutter SDK 초기화
  KakaoSdk.init(
    nativeAppKey: 'dbcdac051802f0898252a47b136fe975',
  );

  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryColor: const Color.fromARGB(255, 0, 200, 188),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme().copyWith(
          titleLarge: const TextStyle(color: Colors.black),
        ),
      ),
      home: const LoginScreen(),

      //   community: const Community(
      //       title: "asdasd",
      //       averageAge: 20.1,
      //       descrition: "d",
      //       count: 10,
      //       address: "das",
      //       birth: "10/1",
      //       chatRoomId: "123"),
      // ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

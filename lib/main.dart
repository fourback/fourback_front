import 'dart:io';
import 'package:bemajor_frontend/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> createNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'default_channel', // 채널 ID (Manifest 파일과 동일해야 합니다)
    'Default Notifications', // 채널 이름 (사용자에게 표시될 이름)
     // 채널 설명
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  print('Message data: ${message.data}');
  if (message.notification != null) {
    print('Message also contained a notification: ${message.notification}');
  }
}

Future<void> requestNotificationPermission() async {
  if (Platform.isAndroid) {
    // Android 13 이상에서만 권한을 요청
    if (await Permission.notification.isDenied) {
      PermissionStatus status = await Permission.notification.request();
      if (status.isGranted) {
        print('알림 권한 허용됨');
      } else {
        print('알림 권한 거부됨');
      }
    }
  }
}


void main() async {
  // 웹 환경에서 카카오 로그인을 정상적으로 완료하려면 runApp() 호출 전 아래 메서드 호출 필요
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await initFCM();
  await createNotificationChannel();

  await requestNotificationPermission();

  // runApp() 호출 전 Flutter SDK 초기화
  KakaoSdk.init(
    nativeAppKey: '392f3fa3c82e15b86fdfc09fb4462e81',
  );

  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

Future<void> initFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // FCM 토큰 발급
  String? fcmToken = await messaging.getToken();
  print('FCM Token: $fcmToken'); // FCM 토큰을 콘솔에 출력

  // 토큰 갱신 시 처리
  messaging.onTokenRefresh.listen((newToken) {
    print('FCM Token refreshed: $newToken'); // 갱신된 토큰을 출력
    // 갱신된 토큰을 서버로 전송하는 로직 추가 가능
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received a message in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message notification: ${message.notification?.title}, ${message.notification?.body}');
      // 알림 처리 로직을 여기에 추가할 수 있습니다.
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Message opened from a background state!');
    if (message.notification != null) {
      print('Notification was: ${message.notification?.title}, ${message.notification?.body}');
      // 사용자가 알림을 클릭하고 앱을 열었을 때 처리할 작업을 여기에 추가
    }
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


}

// 백그라운드 메시지 처리 핸들러


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,

      ],
      supportedLocales:  [
        const Locale('ko', 'KR'),

      ],
      locale: const Locale('ko', 'KR'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryColor: const Color.fromARGB(255, 0, 200, 188),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme().copyWith(
          titleLarge: const TextStyle(color: Colors.black),
        ),
      ),
      home: SplashScreen(),


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

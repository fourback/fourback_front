import 'dart:convert';

import 'navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../ip.dart';
import '../models/user_info.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late UserInfo user;
  String? userId;
  String? userName;
  String? userBirth;
  int? userAge;
  String? userGender;
  String? userEmail;
  String? userPhoneNumber;
  String? userID;

  void _registerUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('USERID', userID!);

  }



    void _sendUserInfo() async {
      final url = Uri.http(address, "login");
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(
          {
            "userId": userId,
            "birthYear": userBirth,
            "email": userEmail,
            "gender": userGender,
            "name": userName,
            "registrationId": "KAKAO",
          },
        ),
      );

    userID = response.headers["authorization"]!;
    print("userID" + userID!);


    _registerUserId();
    user = UserInfo(
      userID: userID!,
      name: userName!,
      gender: userGender!,
      email: userEmail!,
      nickName: userName!,
    );
    // if (mounted) {
    //   Navigator.of(context).pushReplacement(
    //     MaterialPageRoute(
    //       builder: (ctx) => TabsScreen(user: user),
    //     ),
    //   );
    // }
  }

  void _loginKakao() async {
    // String? fcmToken = await FirebaseMessaging.instance.getToken();
    // print("token : $fcmToken");
    if (await isKakaoTalkInstalled()) {
      try {
        await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공');
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공');
      } catch (error) {
        print('카카오계정으로 로그인 실패 2$error');
      }
    }

    await getKakaoUserInfo();
    _sendUserInfo();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => navigationScreen()),
    );
  }

  Future<void> getKakaoUserInfo() async {
    User user;
    try {
      user = await UserApi.instance.me();
      print('사용자 정보 요청 성공'
          '\n회원번호: ${user.id}'
          '\n닉네임: ${user.kakaoAccount?.profile?.nickname}'
          '\n이메일: ${user.kakaoAccount?.email}');
    } catch (error) {
      print('사용자 정보 요청 실패 $error');
      return;
    }

    // 사용자의 추가 동의가 필요한 사용자 정보 동의항목 확인
    List<String> scopes = [];

    if (user.kakaoAccount?.emailNeedsAgreement == true) {
      scopes.add('account_email');
    }
    if (user.kakaoAccount?.birthdayNeedsAgreement == true) {
      scopes.add("birthday");
    }
    if (user.kakaoAccount?.birthyearNeedsAgreement == true) {
      scopes.add("birthyear");
    }
    if (user.kakaoAccount?.ciNeedsAgreement == true) {
      scopes.add("account_ci");
    }
    if (user.kakaoAccount?.phoneNumberNeedsAgreement == true) {
      scopes.add("phone_number");
    }
    if (user.kakaoAccount?.profileNeedsAgreement == true) {
      scopes.add("profile");
    }
    if (user.kakaoAccount?.ageRangeNeedsAgreement == true) {
      scopes.add("age_range");
    }

    if (scopes.isNotEmpty) {
      print('사용자에게 추가 동의 받아야 하는 항목이 있습니다');

      // OpenID Connect 사용 시
      // scope 목록에 "openid" 문자열을 추가하고 요청해야 함
      // 해당 문자열을 포함하지 않은 경우, ID 토큰이 재발급되지 않음
      // scopes.add("openid")

      // scope 목록을 전달하여 추가 항목 동의 받기 요청
      // 지정된 동의항목에 대한 동의 화면을 거쳐 다시 카카오 로그인 수행
      OAuthToken token;
      try {
        token = await UserApi.instance.loginWithNewScopes(scopes);
        print('현재 사용자가 동의한 동의항목: ${token.scopes}');
      } catch (error) {
        print('추가 동의 요청 실패 $error');
        return;
      }

      // 사용자 정보 재요청
      try {
        User user = await UserApi.instance.me();
        print('사용자 정보 요청 성공');
      } catch (error) {
        print('사용자 정보 요청 실패 $error');
      }
    }
    try {
      User user = await UserApi.instance.me();
      userId = user.id.toString();
      userBirth = user.kakaoAccount?.birthyear!;
      if (user.kakaoAccount?.gender == Gender.male) {
        userGender = "m";
      } else {
        userGender = "f";
      }
      userName = user.kakaoAccount?.name!.toString();
      userEmail = user.kakaoAccount?.email!.toString();
      setState(() {});
    } catch (error) {
      print('사용자 정보 요청 실패 $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image.asset(
              //   "assets/images/healthsenior_logo@4x.png",
              //   width: 240,
              //   height: 180,
              //   fit: BoxFit.cover,
              // ),
              const SizedBox(height: 20),
              // Image.asset(
              //   "assets/images/healthsenior_slogan@4x.png",
              //   width: 290,
              //   height: 45,
              //   fit: BoxFit.fill,
              // ),
              const SizedBox(height: 40),
              Container(
                width: 280,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromARGB(255, 250, 220, 0),
                ),
                child: TextButton.icon(
                  style: const ButtonStyle(
                    splashFactory: NoSplash.splashFactory,
                  ),
                  onPressed: _loginKakao,
                  icon: const Icon(
                    Icons.mode_comment,
                    color: Color.fromARGB(255, 25, 22, 0),
                    size: 20,
                  ),
                  label: const Text(
                    "카카오 로그인",
                    style: TextStyle(
                      color: Color.fromARGB(255, 25, 22, 0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

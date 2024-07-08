import 'package:bemajor_frontend/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '/api_url.dart';
import 'package:flutter/material.dart';



Future<String?> readAccess() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('USERID');
}

Future<String?> readRefresh() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('REFRESH');
}

void registerAccess(String access) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('USERID', access);
}

void registerRefresh(String refresh) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('REFRESH', refresh);
}

Future<bool> reissueToken(BuildContext context) async { //토큰 재발급
  try {
    print("reissueToken");
    String? refreshToken = await readRefresh();
    String? accessToken = await readAccess();


    final reissueResponse = await http.post(
      Uri.parse('${ApiUrl.baseUrl}/auth'),
      headers: {
        'refresh': '$refreshToken',
        'access': '$accessToken',
      },
    );

    if(reissueResponse.statusCode == 200) { //토큰 재발급 성공
      String? access;
      String? refresh;

      access = reissueResponse.headers['access'];
      refresh = reissueResponse.headers['refresh'];


      registerAccess(access!);
      registerRefresh(refresh!);
      return true;

    } else if(reissueResponse.statusCode == 401)  {
      print("바디 : ${reissueResponse.body}");//refresh 토큰 만료
      print("refresh 토큰 만료");
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false,
        );
      }
      return false;
    } else {
      print("fail:${reissueResponse.statusCode}");
      return false;
    }
  } catch(e) {
    print('Error: $e');
    return false;
  }

}
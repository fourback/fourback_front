import 'dart:convert';
import 'dart:math';

import 'package:bemajor_frontend/api_url.dart';
import 'package:bemajor_frontend/models/studyGroup.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import '../../auth.dart';
import '../../models/user_info.dart';

class FriendScreen extends StatefulWidget {
  @override
  State<FriendScreen> createState() => _StudyFriendScreenState();
}

class _StudyFriendScreenState extends State<FriendScreen> {
  final TextEditingController addUserController = TextEditingController();

  UserInfo? user;
  List<UserInfo> friendList = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> searchUser() async {
    // 친구 목록 가져오는 API 실행
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _UpperAppbar(
        context: context,
        onLogoPressed: () {},
        onlistPressed: () {},
      ),
      body: SingleChildScrollView(
        child: ListBody(
          children: _body(),
        ),
      ),
    );
  }

  @override
  PreferredSizeWidget _UpperAppbar({
    required BuildContext context,
    required Function onLogoPressed,
    required Function onlistPressed,
  }) {
    return AppBar(
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: IconButton(
          icon: Icon(Icons.navigate_before_outlined),
          onPressed: () => onLogoPressed(),
        ),
      ),
      title: Container(
        child: Text(
          '친구목록',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  List<Widget> _body() {
    List<Widget> widgets = [];
    widgets.add(
      Container(
        height: 600, // 화면 내에서 리스트가 차지할 수 있는 높이 지정
        child: ListView.builder(
          itemCount: 15, // friendList.length로 변경 가능
          itemBuilder: (context, index) {
            return Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text('title'),
                  subtitle: Text('subtitle'),
                  // trailing: IconButton(
                  //   onPressed: () {},
                  // ),
                ),
                Divider(
                  thickness: 1, // 선의 두께를 1로 설정
                  color: Colors.grey, // 선의 색상을 회색으로 설정
                ),
              ],
            );
          },
        ),
      ),
    );

    return widgets;
  }
}

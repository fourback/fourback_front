import 'dart:convert';
import 'dart:math';

import 'package:bemajor_frontend/api_url.dart';
import 'package:bemajor_frontend/models/studyGroup.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import '../../auth.dart';
import '../../models/user_info.dart';
import '../../publicImage.dart';

class StudyInvitationScreen extends StatefulWidget {
  final StudyGroup studyGroup;

  StudyInvitationScreen({required this.studyGroup});

  @override
  State<StudyInvitationScreen> createState() => _StudyInvitationScreenState();
}

class _StudyInvitationScreenState extends State<StudyInvitationScreen> {
  final TextEditingController addUserController = TextEditingController();

  UserInfo? user;

  @override
  void initState() {
    super.initState();
  }

  Future<void> SearchUser() async {
    String? token = await readAccess();

    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/api/users/${addUserController.text}'),
      headers: {'access': '$token'},
        );

    if (response.statusCode == 200) {
      final dynamic jsonMap2 = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        user = UserInfo.fromJson(jsonMap2);
      });
    }
  }
  Future<void> InviteUser() async {
    String? token = await readAccess();

    final response = await http.post(
      Uri.parse('${ApiUrl.baseUrl}/studygroup/${widget.studyGroup.id}/invitations/${user?.userId}'),
      headers: {'access': '$token'},
    );

    if (response.statusCode == 200) {
      Navigator.pop(context);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('초대 실패'),
            content: Text('사용자를 초대하는 데 실패했습니다. 다시 시도해주세요.'),
            actions: <Widget>[
              TextButton(
                child: Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop(); // 알림창 닫기
                },
              ),
            ],
          );
        },
      );
    }
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
    required BuildContext context, // BuildContext 추가
    required Function onLogoPressed,
    required Function onlistPressed,
  }) {
    return AppBar(
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: IconButton(
          icon: Icon(Icons.navigate_before_outlined,),
            onPressed: () {
              Navigator.pop(context);
            }
        ),
      ),
      title: Container(
        child: Text('스터디 그룹 초대', textAlign: TextAlign.center,),
      ),
    );
  }

  List<Widget> _body() {
    List<Widget> widgets = [];
    widgets.add(
      Container(
        margin: const EdgeInsets.fromLTRB(10,10,10,10),
        height: 65,
        alignment: Alignment.center,

        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: addUserController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '이메일을 입력하세요',
                ),
              ),
            ),
            SizedBox(width: 10), // TextField와 버튼 사이에 여백 추가
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                  SearchUser();
              },
            ),
          ],
        ),
      )
    );

        if(user != null) {
          widgets.add(

              Container(
                  margin: const EdgeInsets.all(10),
                  height: 200,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15), //모서리를 둥글게
                    border: Border.all(color: Colors.black12, width: 3),
                  ),
                  child:
      Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              margin: const EdgeInsets.fromLTRB(10,10,10,10),
              height: 100,
              alignment: Alignment.center,
              child:Row(
                children: [
                  PublicImage(
                    imageUrl: user!.fileName != null
                        ? 'http://116.47.60.159:8080/api/images/${user!.fileName}'
                        : 'http://116.47.60.159:8080/api/images/default_profile_image.jpg',
                    placeholderPath: 'assets/icons/loading.gif',
                    width: 40.0, // 원하는 크기로 조정하세요
                    height: 40.0, // 원하는 크기로 조정하세요
                    fit: BoxFit.cover, // 이미지 맞춤 설정
                    isCircular: true, // 원형으로 표시
                  ),
                  SizedBox(width: 8.0,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 22),
                      Text(user!.userName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),

                      Text((user!.belong ?? "Unknown") + ", " + (user!.department ?? "Unknown"),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),

                ],
              ),
            ),

            GestureDetector(
                onTap: () {
                  InviteUser();
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15), //모서리를 둥글게
                    border: Border.all(color: Colors.black12, width: 3),
                    color: Colors.black,
                  ),
                  child: Text('초대하기', style: const TextStyle(fontSize: 15, color: Colors.white)),
                )
            ),


          ]
      )
              )
              );
    }


    return widgets;
  }
}

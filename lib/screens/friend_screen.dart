import 'package:flutter/material.dart';
import 'package:bemajor_frontend/screens/friend/friend_alarm_screen.dart';
import 'package:bemajor_frontend/screens/friend/friend_invitation_screen.dart';

class FriendScreen extends StatefulWidget {
  const FriendScreen({super.key});

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  final List<String> friends = [
    '김수현',
    '김지은',
    '소지섭',
    '강예담',
    '안정현',
    '김수영',
    '원빈',
    '아이유',
  ]; // 친구 목록 패치해서 받아오기!

  int friendRequests = 3; // 받은 친구 요청 개수

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _friendAppbar(context),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20, right: 20, left: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xff22172A),
                          width: 0.3,
                        ),
                      ),
                    ),
                    height: deviceHeight * 0.1,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 30, // 프로필 이미지 크기 설정
                        ),
                        SizedBox(width: 15), // 프로필 이미지와 텍스트 간격
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start, // Column 내에서 왼쪽 정렬
                          mainAxisAlignment: MainAxisAlignment.start, // 텍스트를 상단에 배치
                          children: [
                            Text(
                              friends[index],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch, // 버튼의 너비를 최대화
              children: [
                GestureDetector(
                  onTap: () {
                    // 친구 요청 화면으로 이동하는 코드
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FriendAlarmScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.black, // 검정색 배경
                      borderRadius: BorderRadius.circular(16), // 모서리 둥글게
                    ),
                    child: Center(
                      child: Text(
                        '받은 친구 요청 $friendRequests개',
                        style: TextStyle(
                          color: Colors.white, // 하얀색 텍스트
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10), // 버튼 간 간격 추가
                GestureDetector(
                  onTap: () {
                    // 친구 추가하기 화면으로 이동하는 코드
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FriendInvitationScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.black, // 검정색 배경
                      borderRadius: BorderRadius.circular(16), // 모서리 둥글게
                    ),
                    child: Center(
                      child: Text(
                        '친구 추가하기',
                        style: TextStyle(
                          color: Colors.white, // 하얀색 텍스트
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

PreferredSizeWidget _friendAppbar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.white,
    scrolledUnderElevation: 0,
    title: Text(
      "친구목록",
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
    centerTitle: true,
  );
}
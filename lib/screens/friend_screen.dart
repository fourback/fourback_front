import 'package:flutter/material.dart';
import 'package:bemajor_frontend/screens/friend/friend_alarm_screen.dart';
import 'package:bemajor_frontend/screens/friend/friend_detail_screen.dart';
import 'package:bemajor_frontend/screens/friend/friend_invitation_screen.dart';

class FriendScreen extends StatefulWidget {
  const FriendScreen({super.key});

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  // 친구 목록을 이름과 학교, 학과 정보로 저장
  final List<Map<String, String>> friends = [
    {'name': '김수현', 'school': '서울대학교', 'major': '컴퓨터학부'},
    {'name': '김지은', 'school': '고려대학교', 'major': '경영학과'},
    {'name': '소지섭', 'school': '연세대학교', 'major': '심리학과'},
    {'name': '강예담', 'school': '한양대학교', 'major': '건축학부'},
    {'name': '안정현', 'school': '성균관대학교', 'major': '화학공학과'},
    {'name': '김수영', 'school': '서울시립대학교', 'major': '도시공학과'},
    {'name': '원빈', 'school': '중앙대학교', 'major': '연극영화과'},
    {'name': '아이유', 'school': '이화여자대학교', 'major': '음악학과'},
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
                return GestureDetector(
                  onTap: () {
                    // 친구 타일을 클릭했을 때 친구 상세 화면으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FriendDetailScreen(
                          friendName: friends[index]['name']!,
                          school: friends[index]['school']!,
                          major: friends[index]['major']!,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20, left: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xff22172A),
                            width: 0.3,
                          ),
                        ),
                      ),
                      height: deviceHeight * 0.12, // 높이를 약간 늘림
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center, // 수직 중앙 정렬
                        children: [
                          // 임시 프로필 이미지 적용
                          CircleAvatar(
                            radius: 30, // 프로필 이미지 크기 설정
                            backgroundColor: Color(0xFFD8BFD8), // 임시 배경색
                            child: Icon(
                              Icons.person, // 사람 아이콘 사용
                              size: 30,
                              color: Colors.white, // 아이콘 색상
                            ),
                          ),
                          SizedBox(width: 20), // 프로필 이미지와 텍스트 간격
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start, // Column 내에서 왼쪽 정렬
                            mainAxisAlignment: MainAxisAlignment.center, // 텍스트를 중앙에 배치
                            children: [
                              Text(
                                friends[index]['name']!,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                '${friends[index]['school']} ${friends[index]['major']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600], // 부가 정보는 회색으로 표시
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
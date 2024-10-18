import 'dart:convert';

import 'package:flutter/material.dart';

import '../../api_url.dart';
import '../../auth.dart';
import '../../models/friendDelete.dart';
import 'friend_chat_screen.dart';
import 'package:http/http.dart' as http;

class FriendDetailScreen extends StatelessWidget {
  final int friendId;
  final String friendName;
  final String email;
  final String belong;
  final String department;
  final String birth;
  final String hobby;
  final String objective;
  final String address;
  final String techStack;
  final String fileName;

  const FriendDetailScreen({
    super.key,
    required this.friendId,
    required this.friendName,
    required this.email,
    required this.belong,
    required this.department,
    required this.birth,
    required this.hobby,
    required this.objective,
    required this.address,
    required this.techStack,
    required this.fileName

  });

  Future<void> deleteFriend(BuildContext context) async {
    String? token = await readAccess();

    try {
      final response = await http.delete(
      Uri.parse('${ApiUrl.baseUrl}/api/friend'),
      headers: {
        'access': '$token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(FriendDelete(friendId)),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제되었습니다.')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('친구 삭제에 실패했습니다.')),
      );
      print('Response body: ${response.body}');
    }

    } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('친구 삭제 중 오류가 발생했습니다.')),
    );
    print('Error: $e');
    }

}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          '프로필',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
            children: [
              Container(
                height: constraints.maxHeight * 0.3, // 30% of the screen height
                child: Center(
                  child: Stack(
                    children: [
                      // 임시 프로필 이미지 표시
                      CircleAvatar(
                        radius: 80, // 160x160 크기 설정
                        backgroundColor: Colors.grey[300], // 임시 배경색
                        child: Icon(
                          Icons.person, // 사람 아이콘 사용
                          size: 80,
                          color: Colors.white, // 아이콘 색상
                        ),
                      ),
                      // 이미지 선택 또는 삭제 버튼
                      Positioned(
                        bottom: 0, // 하단 중앙에 배치
                        right: 0,
                        child: IconButton(
                          onPressed: () {}, // 임시로 동작하지 않게 설정
                          icon: CircleAvatar(
                            radius: 20, // 아이콘 배경 크기
                            backgroundColor: Color(0xff242760),
                            child: Icon(
                              Icons.camera_alt, // 카메라 아이콘
                              color: Colors.white,
                              size: 24, // 아이콘 크기
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  //받아와야 할 데이터들
                  children: [
                    _buildInfoTile('이름', friendName ?? ""),
                    _buildInfoTile('이메일', email ?? ""),
                    _buildInfoTile('대학교/소속기관', belong ?? ""),
                    _buildInfoTile('생년월일', birth ?? ""),
                    _buildInfoTile('학과', department ?? ""),
                    _buildInfoTile('취미', hobby ?? ""),
                    _buildInfoTile('희망 직무', objective ?? ""),
                    _buildInfoTile('거주 지역', address ?? ""),
                    _buildInfoTile('기술 스택', techStack ?? ""),
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            deleteFriend(context);
                          },
                          style: ElevatedButton.styleFrom(
                              minimumSize: Size(200, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              backgroundColor:
                              const Color.fromARGB(255, 211, 44, 44)),
                          child: const Text(
                            '친구 삭제',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,

                              MaterialPageRoute(builder: (context) => FriendChatScreen(friendId: friendId,friendName: friendName,friendProfile: fileName,)),
                            );

                          },
                          style: ElevatedButton.styleFrom(
                              minimumSize: Size(200, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              backgroundColor: Colors.black),
                          child: const Text(
                            '채팅 시작하기',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper method to build each info tile with a border
  Widget _buildInfoTile(String title, String data) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      subtitle: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey, // 테두리 색상 설정
            width: 1.0, // 테두리 두께 설정
          ),
          borderRadius: BorderRadius.circular(8), // 둥근 모서리 설정
        ),
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Text(data),
      ),
    );
  }
}
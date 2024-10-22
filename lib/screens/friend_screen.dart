import 'dart:convert';

import 'package:bemajor_frontend/publicImage.dart';
import 'package:flutter/material.dart';
import 'package:bemajor_frontend/screens/friend/friend_alarm_screen.dart';
import 'package:bemajor_frontend/screens/friend/friend_detail_screen.dart';
import 'package:bemajor_frontend/screens/friend/friend_invitation_screen.dart';

import '../api_url.dart';
import '../auth.dart';
import 'package:http/http.dart' as http;

import '../models/user_info.dart';

class FriendScreen extends StatefulWidget {
  const FriendScreen({super.key});

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  List<UserInfo> friendInfo = [];
  int friendSize = 0;
  int friendRequests = 0; // 받은 친구 요청 개수

  @override
  void initState() {
    super.initState();
    // 화면이 로드될 때 친구 목록과 친구 요청 개수 정보를 불러옴
    _loadData();
  }

  // 친구 정보와 친구 요청 개수 데이터를 동시에 불러오는 메서드
  Future<void> _loadData() async {
    await fetchFriendInfo();
    await countFriendApply();
  }

  Future<void> countFriendApply() async {
    String? token = await readAccess();

    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/api/friend/apply/count'), // 사용자 ID가 필요 없음
      headers: {
        'access': '$token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = jsonDecode(response.body);

      setState(() {
        friendRequests = jsonMap['count'];
      });
    }else if(response.statusCode == 401) {
      bool success = await reissueToken(context);
      if(success) {
        await countFriendApply();
      } else {
        print('토큰 재발급 실패');
      }
    }
  }

  Future<void> fetchFriendInfo() async {
    String? token = await readAccess();

    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/api/friend'), // 사용자 ID가 필요 없음
      headers: {
        'access': '$token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = jsonDecode(response.body);

      setState(() {
        List<dynamic> jsonData = jsonMap['result'];
        friendSize = jsonMap['size'];
        friendInfo = jsonData.map((data) => UserInfo.fromJson(data)).toList();
      });
    } else if(response.statusCode == 401) {
      bool success = await reissueToken(context);
      if(success) {
        await fetchFriendInfo();
      } else {
        print('토큰 재발급 실패');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _friendAppbar(context),
      body: RefreshIndicator(
        onRefresh: _loadData, // 새로고침 시 친구 목록과 친구 요청 갯수 다시 불러옴
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: friendInfo.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // 친구 타일을 클릭했을 때 친구 상세 화면으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FriendDetailScreen(
                            friendId: friendInfo[index].userId,
                            friendName: friendInfo[index].userName ?? "Unknown",
                            email: friendInfo[index].email ?? "No email",
                            belong: friendInfo[index].belong ?? "No belong",
                            department: friendInfo[index].department ?? "No department",
                            birth: friendInfo[index].birth ?? "Unknown",
                            hobby: friendInfo[index].hobby ?? "No hobby",
                            objective: friendInfo[index].objective ?? "No objective",
                            address: friendInfo[index].address ?? "No address",
                            techStack: friendInfo[index].techStack ?? "No tech stack",
                            fileName: friendInfo[index].imageUrl ?? "",
                          ),
                        ),
                      ).then((_) {
                        // 돌아왔을 때 무조건 데이터를 새로고침
                        _loadData();
                      });
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
                            PublicImage(
                              imageUrl: friendInfo[index].imageUrl != null
                                  ? friendInfo[index].imageUrl!
                                  : "https://www.pngarts.com/files/10/Default-Profile-Picture-PNG-Download-Image.png",
                              placeholderPath: 'assets/icons/loading.gif',
                              width: 40.0, // 원하는 크기로 조정하세요
                              height: 40.0, // 원하는 크기로 조정하세요
                              fit: BoxFit.cover, // 이미지 맞춤 설정
                              isCircular: true, // 원형으로 표시
                            ),
                            SizedBox(width: 20), // 프로필 이미지와 텍스트 간격
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start, // Column 내에서 왼쪽 정렬
                              mainAxisAlignment: MainAxisAlignment.center, // 텍스트를 중앙에 배치
                              children: [
                                Text(
                                  friendInfo[index].userName!,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '${friendInfo[index].belong} ${friendInfo[index].department}',
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
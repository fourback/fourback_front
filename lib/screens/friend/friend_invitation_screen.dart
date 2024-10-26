import 'dart:convert';

import 'package:bemajor_frontend/models/friendApply.dart';
import 'package:bemajor_frontend/publicImage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../api_url.dart';
import '../../auth.dart';
import '../../models/userInvitateFriend.dart';

class FriendInvitationScreen extends StatefulWidget {
  const FriendInvitationScreen({super.key});

  @override
  State<FriendInvitationScreen> createState() => _FriendInvitationScreenState();
}

class _FriendInvitationScreenState extends State<FriendInvitationScreen> {
  List<UserInviteFriend> friends = [];// 친구 목록을 저장할 리스트
  List<UserInviteFriend> filteredFriends = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserList();

    // fetchFriendList().then((friendList) {
    //   setState(() {
    //     invitaionfriends = friendList;
    //     filteredFriends = friendList; // 초기값으로 전체 친구 목록 설정
    //   });
    // });
    searchController.addListener(_filterFriends);
  }

  Future<List<String>> fetchFriendList() async {
    String? token = await readAccess();

    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/api/friend/invitation-list'),
      headers: {
        'access': '$token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> friendList = jsonDecode(response.body);
      print(friendList); // 응답 로그 출력
      return friendList.map((friend) => friend.toString()).toList();
    } else {
      print('Error: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to load friend list');
    }
  }

  Future<void> fetchUserList() async {
    String? token = await readAccess();
    // 친구 초대에 사용할 유저 목록을 가져옵니다.
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/api/friend/invitation-list'), // 사용자 ID 없이 호출
      headers: {
        'access': '$token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = jsonDecode(response.body);

      setState(() {
        List<dynamic> jsonData = jsonMap['result'];
        friends =
            jsonData.map((data) => UserInviteFriend.fromJson(data)).toList();
        filteredFriends = friends; //  검색 초기값을 friends로 설정
      });
    } else if(response.statusCode == 401) {
      bool success = await reissueToken(context);
      if(success) {
        await fetchUserList();
      } else {
        print('토큰 재발급 실패');
      }
    }
  }

  Future<int> addFriendApply(int friendId) async {
    String? token = await readAccess();

    final response = await http.post(
      Uri.parse('${ApiUrl.baseUrl}/api/friend/apply'),
      headers: {
        'access': '$token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(FriendApply(friendId)),
    );

    // 상태 코드를 반환하여 성공/실패를 구분
    return response.statusCode;
  }

  void _filterFriends() {
    setState(() {
      filteredFriends = friends
          .where((friend) => friend.userName.contains(searchController.text)) // 검색어가 포함된 친구만 필터링
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _friendinvitationAppbar(context),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: '친구 검색',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredFriends.isEmpty
                ? Center(child: Text('친구 목록이 없습니다.'))
                : ListView.builder(
              itemCount: filteredFriends.length,
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
                    height: deviceHeight * 0.2, // 타일 크기 조정
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            PublicImage(
                              imageUrl: filteredFriends[index].imageUrl.isNotEmpty
                                  ? filteredFriends[index].imageUrl!
                                  : "https://www.pngarts.com/files/10/Default-Profile-Picture-PNG-Download-Image.png",
                              placeholderPath: 'assets/icons/loading.gif',
                              width: 40.0,
                              // 원하는 크기로 조정하세요
                              height: 40.0,
                              // 원하는 크기로 조정하세요
                              fit: BoxFit.cover,
                              // 이미지 맞춤 설정
                              isCircular: true, // 원형으로 표시
                            ),
                            SizedBox(width: 15), // 프로필 이미지와 텍스트 간격
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  filteredFriends[index].userName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  filteredFriends[index].belong + ", " + filteredFriends[index].department, // 작성자 학교 표시
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 40), // 프로필과 수락 버튼 간격
                        Align(
                          alignment: Alignment.center, // 버튼을 가운데 정렬
                          child: SizedBox(
                            width: double.infinity, // 버튼의 너비를 늘림
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0), // 좌우 여백 설정
                              child: GestureDetector(
                                onTap: () {
                                  _showAcceptDialog(context, filteredFriends[index], addFriendApply);
                                },
                                child: Container(
                                  width: double.infinity, // 버튼 가로 크기를 최대한으로 설정
                                  padding: EdgeInsets.symmetric(vertical: 10), // 세로 크기를 줄임
                                  decoration: BoxDecoration(
                                    color: Colors.black, // 버튼 배경색 검정
                                    borderRadius: BorderRadius.circular(20), // 라운드 처리
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "친구 요청 보내기",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white, // 텍스트 색상 흰색
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

  void _showAcceptDialog(BuildContext context, UserInviteFriend friend, Function addFriendApply) async {
    int statusCode = await addFriendApply(friend.userId);  // HTTP 상태 코드를 확인

    String message;

    // 상태 코드에 따라 메시지 설정
    if (statusCode >= 200 && statusCode < 300) {
      message = "${friend.userName}님에게 친구 요청을 보냈습니다.";  // 성공
    } else if (statusCode == 400) {
      message = "잘못된 요청입니다. 다시 시도해주세요.";  // 400 Bad Request
    } else if (statusCode == 401) {
      message = "이미 요청했거나 이미 친구입니다.";  // 401 Unauthorized
    } else {
      message = "알 수 없는 오류가 발생했습니다. 상태 코드: $statusCode";  // 기타 에러
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("알림"),
        content: Text(message),  // 설정된 메시지를 다이얼로그에 표시
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();  // 다이얼로그 닫기
            },
            child: Text("확인"),
          ),
        ],
      ),
    );
  }

PreferredSizeWidget _friendinvitationAppbar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.white,
    scrolledUnderElevation: 0,
    leading: IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context, true);
      },
    ),
    title: Text(
      "친구 추가",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
    ),
    centerTitle: true,
  );
}
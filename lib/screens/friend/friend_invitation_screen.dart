import 'dart:convert';

import 'package:bemajor_frontend/models/friendApply.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../api_url.dart';
import '../../auth.dart';

class FriendInvitationScreen extends StatefulWidget {
  const FriendInvitationScreen({super.key});

  @override
  State<FriendInvitationScreen> createState() => _FriendInvitationScreenState();
}

Future<void> addFriendApply() async {
  String? token = await readAccess();

  final response = await http.post(
    Uri.parse('${ApiUrl.baseUrl}/api/friend/apply'),
    headers: {
      'access': '$token',
      'Content-Type': 'application/json',
    },
    // body에 사용자 id, 친구를 신청할 유저의 id로 넘기면 됩니다.
    body: jsonEncode(FriendApply(4, 3)),
  );
}


class _FriendInvitationScreenState extends State<FriendInvitationScreen> {
  final List<String> invitaionfriends = [
    '김수현',
    '김지은',
    '소지섭',
    '강예담',
    '안정현',
    '김수영',
    '원빈',
    '아이유',
  ]; // 친구 추가 목록 받아오기
  List<String> filteredFriends = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredFriends = invitaionfriends; // 초기값으로 전체 친구 목록 설정
    searchController.addListener(_filterFriends);
  }

  void _filterFriends() {
    setState(() {
      filteredFriends = invitaionfriends
          .where((friend) => friend.contains(searchController.text)) // 검색어가 포함된 친구만 필터링
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
            child: ListView.builder(
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
                            CircleAvatar(
                              backgroundColor: Colors.black,
                              radius: 30, // 프로필 이미지 크기 설정
                            ),
                            SizedBox(width: 15), // 프로필 이미지와 텍스트 간격
                            Text(
                              filteredFriends[index],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
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
                                  _showAcceptDialog(context, filteredFriends[index]);
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

void _showAcceptDialog(BuildContext context, String friendName) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      title: Text("알림"),
      content: Text("$friendName님에게 친구 요청을 보냈습니다."),
      actions: [
        TextButton(
          onPressed: () {
            addFriendApply();
            Navigator.of(context).pop();
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
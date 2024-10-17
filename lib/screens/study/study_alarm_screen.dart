import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../api_url.dart';
import '../../auth.dart';
import 'package:bemajor_frontend/models/study_alarm.dart';
import '../../models/studyGroup.dart';

// StudyGroupApplicationResponse에 해당하는 모델을 만들어야 합니다.
class StudyAlarmScreen extends StatefulWidget {
  final StudyGroup studyGroup;

  StudyAlarmScreen({required this.studyGroup});

  @override
  State<StudyAlarmScreen> createState() => _StudyAlarmScreenState();
}

class _StudyAlarmScreenState extends State<StudyAlarmScreen> {
  List<StudyGroupApplicationResponse> applicants = [];

  @override
  void initState() {
    super.initState();
    // 화면이 로드될 때 신청자 목록을 불러옴
    fetchApplicants();
  }

  Future<void> fetchApplicants() async {
    String? token = await readAccess();

    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/studygroup/applications/${widget.studyGroup.id}'),
      headers: {
        'access': '$token',
        'Content-Type': 'application/json; charset=utf-8',  // UTF-8 인코딩 명시
      },
    );

    if (response.statusCode == 200) {
      // UTF-8로 디코딩된 JSON 응답 사용
      final List<dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

      // 디버깅 출력: 받은 응답 확인
      print("Response Body: ${response.body}");
      print("Parsed JSON: $jsonResponse");

      // jsonResponse 데이터를 StudyGroupApplicationResponse 객체로 변환
      setState(() {
        applicants = jsonResponse
            .map((data) => StudyGroupApplicationResponse.fromJson(data))
            .toList()
            .cast<StudyGroupApplicationResponse>();
      });
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  Future<void> acceptApplicant(int? studyApplicationId) async {
    if (studyApplicationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('유효한 신청 ID가 없습니다.')));
      return;
    }

    String? token = await readAccess();

    final response = await http.post(
      Uri.parse('${ApiUrl.baseUrl}/studygroup/applications/$studyApplicationId/accept'),
      headers: {
        'access': '$token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('신청을 수락했습니다.')));
      // 신청 목록 새로 고침
      fetchApplicants();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('신청 수락에 실패했습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _studyalarmAppbar(context),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: applicants.length,
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
                              applicants[index].userName,
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
                                  _showAcceptDialog(context, applicants[index].userName, applicants[index].studyApplicationId);
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
                                    "수락",
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

  // 수락 버튼 눌렀을 때 팝업 창으로 알림
  void _showAcceptDialog(BuildContext context, String userName, int? studyApplicationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text("알림"),
        content: Text("$userName의 스터디 신청을 수락하시겠습니까?"),
        actions: [
          TextButton(
            onPressed: () {
              acceptApplicant(studyApplicationId); // 신청자 ID 전달
              Navigator.of(context).pop();
            },
            child: Text("확인"),
          ),
        ],
      ),
    );
  }
}

PreferredSizeWidget _studyalarmAppbar(BuildContext context) {
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
      "받은 스터디 신청",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
    ),
    centerTitle: true,
  );
}
import 'dart:convert';
import 'dart:math';

import 'package:bemajor_frontend/models/user_info.dart';
import 'package:bemajor_frontend/screens/group_screen.dart';
import 'package:bemajor_frontend/screens/study/study_invitation_screen.dart';
import 'package:bemajor_frontend/screens/study/study_schedule_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../api_url.dart';
import '../../auth.dart';
import '../../models/studyGroup.dart';

class StudyInnerScreen extends StatefulWidget {

  final StudyGroup studyGroup;

  StudyInnerScreen({required this.studyGroup});

  @override
  State<StudyInnerScreen> createState() => _StudyInnerScreenState();
}

class _StudyInnerScreenState extends State<StudyInnerScreen> {
  final TextEditingController inviteFriendController = TextEditingController();

  bool isStudyRule = false;
  bool isStudyTime = false;
  bool isStudyPlace = false;
  bool isStudyTerm = false;
  bool isStudySchedule = false;

  List<UserInfo> user = [];

  @override
  void initState() {
    super.initState();
    fetchStudys();
  }

  Future<void> _navigateToStudyScheduleScreen() async {
    // 계획 수정 화면으로 이동하고, 결과를 기다림
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudyScheduleScreen(studyGroup: widget.studyGroup),
      ),
    );

    // 돌아오면 화면을 갱신하기 위해 fetchStudys 호출
    fetchStudys();
  }


  Future<void> fetchStudys() async {
    String? token = await readAccess();
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/studygroup/members/${widget.studyGroup.id}'),
      headers: {'access': '$token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonMap2 = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        user = jsonMap2.map((data) => UserInfo.fromJson(data)).toList();
      });
    }
  }

  Future<void> deleteStudys() async {
    String? token = await readAccess();
    final response = await http.delete(
      Uri.parse('${ApiUrl.baseUrl}/studygroup/${widget.studyGroup.id}'),
      headers: {'access': '$token'},
    );

    if (response.statusCode == 200) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => GroupScreen()));
    }
  }

  Future<void> updateStudys() async {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _UpperAppbar(
        context: context, // context 전달
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
          onPressed: () => onLogoPressed(),
        ),
      ),
      title: Container(
        child: Text(widget.studyGroup.studyName, textAlign: TextAlign.center,),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'delete') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('삭제 확인'),
                      content: Text('정말로 삭제하시겠습니까?'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('아니오'),
                          onPressed: () {
                            Navigator.of(context).pop(); // 다이얼로그 닫기
                          },
                        ),
                        TextButton(
                          child: Text('예'),
                          onPressed: () {
                            deleteStudys();
                            Navigator.of(context).pop(); // 다이얼로그 닫기
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('삭제'),
                ),
                PopupMenuItem<String>(
                  value: 'update',
                  child: Text('수정'),
                ),
              ];
            },
            icon: Icon(Icons.list),
            offset: Offset(0, 50),
          ),
        ),
      ],
    );
  }

  List<Widget> _body() {
    List<Widget> widgets = [];
    widgets.add(
      Container(
        margin: const EdgeInsets.all(10),
        height: 300,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), //모서리를 둥글게
          border: Border.all(color: Colors.black12, width: 3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(3),
              padding: EdgeInsets.all(3),
              child: Text(
                '그룹 멤버',
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20.0,),
            Container(
              margin: const EdgeInsets.all(5),
              height: 140,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15), //모서리를 둥글게
                border: Border.all(color: Colors.black12, width: 3),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double width = constraints.maxWidth / 2 - 10;
                  return Wrap(
                    spacing: 10.0, // 항목 간의 수평 간격
                    runSpacing: 10.0, // 항목 간의 수직 간격
                    children: List.generate(user.length, (index) {
                      return Container(
                        width: width, // 한 줄에 두 개씩 배치하기 위한 너비 조절
                        child: Text(
                            user[index].userName,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
            GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => StudyInvitationScreen(studyGroup: widget.studyGroup)));
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
                  child: Text('구성원 초대하기', style: const TextStyle(fontSize: 15, color: Colors.white)),
                )
            ),

          ],
        ),
      ),
    );

    if(isStudyRule == false) {
      widgets.add(
          Container(
            margin: const EdgeInsets.all(10),
            height: 70,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15), //모서리를 둥글게
              border: Border.all(color: Colors.black12, width: 3),
            ),
            child: GestureDetector(
              child: Text(
                '그룹 규칙 ▽',
                style: const TextStyle(
                    fontSize: 25, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                setState(() {
                  isStudyRule = true;
                });
              },
            ),
          )
      );
    }
    else if(isStudyRule == true) {
      widgets.add(
          Container(
              margin: const EdgeInsets.all(10),
              height: 300,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15), //모서리를 둥글게
                border: Border.all(color: Colors.black12, width: 3),
              ),
              child: GestureDetector(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Text(
                        '그룹 규칙 ▲',
                        style: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Text(
                        widget.studyGroup.studyRule,
                        style: const TextStyle(
                            fontSize: 18),
                      ),
                    )
                  ],
                ),
                onTap: () {
                  setState(() {
                    isStudyRule = false;
                  });
                },
              )
          )
      );
    }

    if(isStudyTime == false) {
      widgets.add(
          Container(
              margin: const EdgeInsets.all(10),
              height: 70,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15), //모서리를 둥글게
                border: Border.all(color: Colors.black12, width: 3),
              ),
              child: GestureDetector(
                child: Text(
                  '그룹 기간 ▽',
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  setState(() {
                    isStudyTime = true;
                  });
                },
              )
          )
      );
    }
    else if(isStudyTime == true) {
      widgets.add(
          Container(
              margin: const EdgeInsets.all(10),
              height: 300,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15), //모서리를 둥글게
                border: Border.all(color: Colors.black12, width: 3),
              ),
              child: GestureDetector(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Text(
                        '그룹 기간 ▲',
                        style: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Text(
                          DateFormat('yyyy.MM.dd').format(widget.studyGroup.startDate) + " - " +
                              DateFormat('yyyy.MM.dd').format(widget.studyGroup.endDate),
                        style: const TextStyle(
                            fontSize: 18),
                      ),
                    )
                  ],
                ),
                onTap: () {
                  setState(() {
                    isStudyTime = false;
                  });
                },
              )
          )
      );
    }

    if(isStudyPlace == false) {
      widgets.add(
          Container(
              margin: const EdgeInsets.all(10),
              height: 70,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15), //모서리를 둥글게
                border: Border.all(color: Colors.black12, width: 3),
              ),
              child: GestureDetector(
                child: Text(
                  '모임 장소 ▽',
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  setState(() {
                    isStudyPlace = true;
                  });
                },
              )
          )
      );
    }
    else if(isStudyPlace == true) {
      widgets.add(
          Container(
              margin: const EdgeInsets.all(10),
              height: 300,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15), //모서리를 둥글게
                border: Border.all(color: Colors.black12, width: 3),
              ),
              child: GestureDetector(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Text(
                        '모임 장소 ▲',
                        style: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Text(
                        widget.studyGroup.studyLocation,
                        style: const TextStyle(
                            fontSize: 18),
                      ),
                    )
                  ],
                ),
                onTap: () {
                  setState(() {
                    isStudyPlace = false;
                  });
                },
              )
          )
      );
    }

    if(isStudyTerm == false) {
      widgets.add(
          Container(
              margin: const EdgeInsets.all(10),
              height: 70,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15), //모서리를 둥글게
                border: Border.all(color: Colors.black12, width: 3),
              ),
              child: GestureDetector(
                child: Text(
                  '모임 주기 ▽',
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  setState(() {
                    isStudyTerm = true;
                  });
                },
              )
          )
      );
    }
    else if(isStudyTerm == true) {
      widgets.add(
          Container(
              margin: const EdgeInsets.all(10),
              height: 300,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15), //모서리를 둥글게
                border: Border.all(color: Colors.black12, width: 3),
              ),
              child: GestureDetector(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Text(
                        '모임 주기 ▲',
                        style: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Text(
                        widget.studyGroup.studyCycle,
                        style: const TextStyle(
                            fontSize: 18),
                      ),
                    )
                  ],
                ),
                onTap: () {
                  setState(() {
                    isStudyTerm = false;
                  });
                },
              )
          )
      );
    }

    if(isStudySchedule == false) {
      widgets.add(
          Container(
              margin: const EdgeInsets.all(10),
              height: 70,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15), //모서리를 둥글게
                border: Border.all(color: Colors.black12, width: 3),
              ),
              child: GestureDetector(
                child: Text(
                  '스터디 계획 ▽',
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  setState(() {
                    isStudySchedule = true;
                  });
                },
              )
          )
      );
    }
    else if(isStudySchedule == true) {
      widgets.add(
        Column(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15), // 모서리를 둥글게
                border: Border.all(color: Colors.black12, width: 3),
              ),
              child: GestureDetector(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Text(
                        '스터디 계획 ▲',
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10), // 바깥쪽 상자와의 간격 조정
                      padding: const EdgeInsets.fromLTRB(140, 10, 140, 10), // 전체 컨텐츠의 내부 여백
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(15), // 모서리를 둥글게
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(widget.studyGroup.studySchedule.length, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 5), // 각 항목 간의 간격
                            child: Text(
                              'ㆍ' + widget.studyGroup.studySchedule[index],
                              style: const TextStyle(fontSize: 18),
                              softWrap: true,  // 텍스트 줄 바꿈 허용
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    isStudySchedule = false;
                  });
                },
              ),
            ),
            GestureDetector(
              onTap: _navigateToStudyScheduleScreen,  // 함수 호출
              child: Container(
                margin: const EdgeInsets.all(10),
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.black12, width: 3),
                  color: Colors.black,
                ),
                child: Text(
                  '스터디 계획 수정하기',
                  style: const TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            ),

          ],
        ),
      );
    }
    widgets.add(
      GestureDetector(
        onTap: () {
          // 그룹 톡 관련 기능 구현
        },
        child: Container(
          margin: const EdgeInsets.all(10),
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), // 모서리를 둥글게
            border: Border.all(color: Colors.black12, width: 3),
            color: Colors.black,
          ),
          child: Text(
            '그룹 톡',
            style: const TextStyle(fontSize: 15, color: Colors.white),
          ),
        ),
      ),
    );

    return widgets;
  }
}
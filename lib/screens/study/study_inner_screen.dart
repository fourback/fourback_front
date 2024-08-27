import 'dart:convert';
import 'dart:math';
import 'package:bemajor_frontend/models/user_info.dart';
import 'package:bemajor_frontend/screens/group/group_chat_screen.dart';
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
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudyScheduleScreen(studyGroup: widget.studyGroup),
      ),
    );
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

  Future<void> updateStudys() async {}

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
      centerTitle: true, // 가운데 정렬을 위해 centerTitle을 true로 설정
      leading: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: IconButton(
          icon: Icon(
            Icons.navigate_before_outlined,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      title: Text(
        widget.studyGroup.studyName,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold, // 제목을 Bold로 설정
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Theme(
            data: Theme.of(context).copyWith(
              popupMenuTheme: PopupMenuThemeData(
                color: Colors.white, // 팝업 메뉴의 배경색을 흰색으로 설정
              ),
            ),
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
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('예'),
                            onPressed: () {
                              deleteStudys();
                              Navigator.of(context).pop();
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
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              spreadRadius: 2,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(3),
              padding: const EdgeInsets.only(left: 8.0, top: 16.0), // 상단과 좌측 여백을 추가
              child: Text(
                '그룹 멤버',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              margin: const EdgeInsets.all(5),
              height: 140,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double width = constraints.maxWidth / 2 - 10;
                  return Wrap(
                    spacing: 10.0,
                    runSpacing: 10.0,
                    children: List.generate(user.length, (index) {
                      return Container(
                        width: width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10), // 테두리만 둥글게 설정
                          color: Colors.transparent, // 배경색 없이 투명하게 설정
                        ),
                        child: Text(
                          user[index].userName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
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
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: Offset(0, 3),
                      ),
                    ],
                    color: Colors.black,
                  ),
                  child: Text('구성원 초대하기', style: const TextStyle(fontSize: 14, color: Colors.white)),
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
            height: 60,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: GestureDetector(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  '그룹 규칙 ▽',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
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
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: GestureDetector(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Text(
                        '그룹 규칙 ▲',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Text(
                        widget.studyGroup.studyRule,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.left,
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
              height: 60,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '그룹 기간 ▽',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
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
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: GestureDetector(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Text(
                        '그룹 기간 ▲',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Text(
                        DateFormat('yyyy.MM.dd').format(widget.studyGroup.startDate) + " - " +
                            DateFormat('yyyy.MM.dd').format(widget.studyGroup.endDate),
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.left,
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
              height: 60,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '모임 장소 ▽',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
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
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: GestureDetector(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Text(
                        '모임 장소 ▲',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Text(
                        widget.studyGroup.studyLocation,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.left,
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
              height: 60,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '모임 주기 ▽',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
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
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: GestureDetector(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Text(
                        '모임 주기 ▲',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Text(
                        widget.studyGroup.studyCycle,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.left,
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
              height: 60,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '스터디 계획 ▽',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
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
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: GestureDetector(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Text(
                        '스터디 계획 ▲',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(widget.studyGroup.studySchedule.length, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              'ㆍ' + widget.studyGroup.studySchedule[index],
                              style: const TextStyle(fontSize: 16),
                              softWrap: true,
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
              onTap: _navigateToStudyScheduleScreen,
              child: Container(
                margin: const EdgeInsets.all(10),
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: Offset(0, 3),
                    ),
                  ],
                  color: Colors.black,
                ),
                child: Text(
                  '스터디 계획 수정하기',
                  style: const TextStyle(fontSize: 14, color: Colors.white),
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GroupChatScreen()),
          );

          // 그룹 톡 관련 기능 구현
        },
        child: Container(
          margin: const EdgeInsets.all(10),
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                spreadRadius: 2,
                offset: Offset(0, 3),
              ),
            ],
            color: Colors.black,
          ),
          child: Text(
            '그룹 톡',
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ),
      ),
    );

    return widgets;
  }
}
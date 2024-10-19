import 'dart:convert';
import 'package:bemajor_frontend/models/study_group_goal.dart';
import 'package:bemajor_frontend/screens/group/group_add_goal_screen.dart';
import 'package:bemajor_frontend/screens/group/group_subgoals_screen.dart';
import 'package:bemajor_frontend/screens/group/group_update_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bemajor_frontend/models/user_info.dart';
import 'package:bemajor_frontend/screens/group/group_chat_screen.dart';
import 'package:bemajor_frontend/screens/group_screen.dart';
import 'package:bemajor_frontend/screens/study/study_invitation_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'study_alarm_screen.dart';
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
  late StudyGroup studyGroup;
  bool enableNotification = false;


  final TextEditingController inviteFriendController = TextEditingController();

  bool isStudyRule = false;
  bool isStudyTime = false;
  bool isStudyPlace = false;
  bool isStudyTerm = false;
  bool isStudySchedule = false;

  List<UserInfo> user = [];
  bool isMember = false;
  bool isLoading = true;
  bool isOwner = false; // 그룹 생성자인지 확인할 변수
  int pendingApprovalCount = 0; // 그룹 참여 승인 대기 인원
  late List<StudyGroupGoalResponse> goals = [];


  @override
  void initState() {
    super.initState();
    studyGroup = widget.studyGroup;
    fetchStudys();
    loadInitialData();
    checkGroupRole(); // 그룹 생성자인지 확인
    fetchPendingApplications();
    fetchStudyGroupGoals();
  }

  Future<void> fetchStudys() async {
    String? token = await readAccess();
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/studygroup/members/${widget.studyGroup.id}'),
      headers: {'access': '$token'},
    );

    if (response.statusCode == 200) {

      final List<dynamic> jsonMap2 = jsonDecode(utf8.decode(response.bodyBytes));
      // final Map<String, dynamic> jsonMap2 = jsonDecode(utf8.decode(response.bodyBytes));

      setState(() {
        user = jsonMap2.map((data) => UserInfo.fromJson(data)).toList();
        // enableNotification = jsonMap2['enableNotification'];
        // user = (jsonMap2['users'] as List<dynamic>)
        //     .map((data) => UserInfo.fromJson(data))
        //     .toList();
      });
    } else if(response.statusCode == 401) {
      bool success = await reissueToken(context);
      if(success) {
        await fetchStudys();
      } else {
        print('토큰 재발급 실패');
      }
    }
  }

  Future<void> checkGroupRole() async {
    String? token = await readAccess();
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/studygroup/${widget.studyGroup.id}/role'),
      headers: {'access': '$token'},
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      print('Role: ${result['role']}');

      setState(() {
        // 역할에 따라 소유자 또는 멤버 여부 설정
        isOwner = result['role'] == 'ADMIN';
        isMember = result['role'] == 'MEMBER';
      });
    }
  }
  Future<void> loadInitialData() async {
    await checkGroupRole(); // 역할 먼저 확인
    await fetchStudys(); // 멤버 정보 가져오기
    await fetchPendingApplications(); // 승인 대기 인원 가져오기
    setState(() {
      isLoading = false; // 데이터 로드 완료 후 로딩 상태 해제
    });
  }
  Future<void> fetchPendingApplications() async {
    String? token = await readAccess();
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/studygroup/applications/${widget.studyGroup.id}/count'),
      headers: {'access': '$token'},
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      setState(() {
        pendingApprovalCount = result['count'] ?? 0; // null 체크 후 값 설정
      });
    } else {
      print('Failed to fetch pending applications. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');  // 응답 본문 출력
    }
  }

  Future<void> requestToJoinGroup() async {
    String? token = await readAccess();
    final response = await http.post(
      Uri.parse('${ApiUrl.baseUrl}/studygroup/joingroup/${widget.studyGroup.id}'),
      headers: {'access': '$token'},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("그룹 참여 신청이 완료되었습니다.")),
      );
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

  Future<void> _navigateToStudyScheduleScreen() async {
    final newGoal = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddGoalScreen(studyGroupId: studyGroup.id,),
      ),
    );
    if (newGoal != null) {
      fetchStudyGroupGoals();
    }

  }

  Future<void> notificationOn() async {
    String? token = await readAccess();
    final url = Uri.parse('${ApiUrl.baseUrl}/studyGroup/notification/${widget.studyGroup.id}');

    final response = await http.post(
      url,
      headers: {'access': '$token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        enableNotification = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('채팅 알림 켜짐')),
      );
    } else {
      throw Exception('알림 켜기 실패: ${response.statusCode}');
    }
  }

  Future<void> notificationOff() async {
    String? token = await readAccess();
    final url = Uri.parse('${ApiUrl.baseUrl}/studyGroup/notification/${widget.studyGroup.id}');

    final response = await http.delete(
      url,
      headers: {'access': '$token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        enableNotification = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('채팅 알림 꺼짐')),
      );
    } else {
      throw Exception('알림 끄기 실패: ${response.statusCode}');
    }
  }


  Future<void> fetchStudyGroupGoals() async {
    String? token = await readAccess();
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/studygroup/${widget.studyGroup.id}/goals'),
      headers: {
        'access': '$token'
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        goals = body.map((dynamic item) {
          return StudyGroupGoalResponse.fromJson(item);
        }).toList();
      });

    } else {
      throw Exception('Failed to load study group goals');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // 로딩 중일 때는 로딩 스피너를 보여줌
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _UpperAppbar(

        context: context,
        onLogoPressed: () {},
        onlistPressed: () {},
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (isOwner) // 소유자인 경우 승인 대기 인원 보여줌
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,MaterialPageRoute(
                      builder: (context) => StudyAlarmScreen(studyGroup: widget.studyGroup),
                    ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black,
                    ),
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: Center(
                      child: Text(
                        '$pendingApprovalCount명의 유저가 그룹 참여 승인을 기다리고 있어요!',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (!isOwner && !isMember) // 소유자도 멤버도 아닌 경우 참여 신청 버튼
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: GestureDetector(
                  onTap: () {
                    requestToJoinGroup();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black,
                    ),
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: Center(
                      child: Text(
                        '그룹 참여 신청하기',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ListBody(
              children: _body(),
            ),
          ],
        ),
      ),
    );
  }

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
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      title: Text(
        studyGroup.studyName,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold, // 제목을 Bold로 설정
        ),
      ),
      actions: [
        if (isOwner || isMember)
          Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Theme(
            data: Theme.of(context).copyWith(
              popupMenuTheme: PopupMenuThemeData(
                color: Colors.white, // 팝업 메뉴의 배경색을 흰색으로 설정
              ),
            ),
            child: PopupMenuButton<String>(
              onSelected: (String value) async {
                if (value == 'delete') {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.white,
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
                } else if(value == 'update') {
                  final updatedStudyGroup = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupUpdateScreen(studyGroup: studyGroup),
                    ),
                  );


                  if (updatedStudyGroup != null) {
                    setState(() {
                      studyGroup  = updatedStudyGroup;
                    });
                  }
                }
                else if (value == 'notifications_on') {
                   notificationOn();
                } else if (value == 'notifications_off') {
                  notificationOff();
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
                  if (enableNotification)
                    PopupMenuItem<String>(
                      value: 'notifications_off',
                      child: Text('채팅 알림 끄기'),
                    )
                  else
                    PopupMenuItem<String>(
                      value: 'notifications_on',
                      child: Text('채팅 알림 켜기'),
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
              padding: const EdgeInsets.only(left: 8.0, top: 16.0),
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
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.transparent,
                        ),
                        child: Text(
                          user[index].userName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
            if(isOwner)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StudyInvitationScreen(studyGroup: widget.studyGroup)),
                );
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
              ),
            ),
          ],
        ),
      ),
    );

    if (!isStudySchedule) {
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
                '진행 현황 ▽',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            onTap: () {
              setState(() {
                isStudySchedule = true;
              });
            },
          ),
        ),
      );
    } else {
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
                        '진행 현황 ▲',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (goals.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(goals.length, (index) {
                            final goal = goals[index];
                            return GoalCard(
                              title: goal.name,
                              date: goal.endDate,
                              progress: goal.percentage.toDouble(),
                              onTap: () async {
                                if(isOwner || isMember) {
                                    await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SubGoalsScreen(
                                        goal: goal,
                                      ),
                                    ),
                                  );
                                }
                                setState(() {
                                  fetchStudyGroupGoals();
                                });
                              },
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
            if(isOwner || isMember)
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
                  '목표 추가하기',
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    }

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
                        studyGroup.studyRule,
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
                        DateFormat('yyyy.MM.dd').format(studyGroup.startDate) + " - " +
                            DateFormat('yyyy.MM.dd').format(studyGroup.endDate),
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
                        studyGroup.studyLocation,
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
                        studyGroup.studyCycle,
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

    if(isOwner || isMember) {
      widgets.add(

        GestureDetector(
          onTap: () {
            Navigator.push(
              context,

              MaterialPageRoute(builder: (context) => GroupChatScreen(studyGroup: widget.studyGroup,user: user)),
            );


          },
          child: Container(
            margin: const EdgeInsets.all(10),
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
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
    }

    return widgets;
  }
}

class GoalCard extends StatelessWidget {
  final String title;
  final String? date;
  final double progress;
  final VoidCallback onTap;

  GoalCard({
    required this.title,
    this.date,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final goalDate = date != null
        ? DateFormat('yyyy년 MM월 dd일').format(DateTime.parse(date!))
        : 'No Due Date';

    return Card(
      color: Colors.white,
      margin: EdgeInsets.all(10),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '마감일: $goalDate',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    '${(progress).toInt()}%',
                    style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.grey.shade300, // 진행바의 배경색
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Container(
                          width: constraints.maxWidth * progress/100, // progress 값에 따른 너비 설정
                          height: 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            gradient: LinearGradient(
                              colors: [
                                Colors.lightBlueAccent,
                                Colors.blue,
                                Colors.blueAccent,
                              ],
                            ),
                          ),

                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bemajor_frontend/screens/group_screen.dart';
import '../../models/study_group_invitation.dart';
import '../../api_url.dart';
import '../../auth.dart';

class GroupAlarmScreen extends StatefulWidget {
  const GroupAlarmScreen({super.key});

  @override
  State<GroupAlarmScreen> createState() => _GroupAlarmScreenState();
}

class _GroupAlarmScreenState extends State<GroupAlarmScreen> {
  int? _selectedIndex;
  List<StudyGroupInvitation> invitations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInvitedStudyGroups();
  }

  Future<void> _fetchInvitedStudyGroups() async {
    try {
      setState(() {
        isLoading = true;
      });

      List<StudyGroupInvitation> fetchedInvitations = await fetchInvitedStudyGroups(context);
      setState(() {
        invitations = fetchedInvitations;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching invitations: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('초대 목록을 불러오는 중 오류가 발생했습니다.')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<StudyGroupInvitation>> fetchInvitedStudyGroups(BuildContext context) async {
    String? token = await readAccess();
    final url = '${ApiUrl.baseUrl}/studygroup/invitations';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'access': '$token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => StudyGroupInvitation.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        bool success = await reissueToken(context);
        if (success) {
          return await fetchInvitedStudyGroups(context);
        } else {
          throw Exception('토큰 재발급 실패');
        }
      } else {
        throw Exception('Failed to fetch invited study groups: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch invited study groups');
    }
  }

  Future<void> acceptInvitation(BuildContext context, String invitationId) async {
    String? token = await readAccess();
    final url = '${ApiUrl.baseUrl}/studygroup/invitations/accept/$invitationId';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'access': '$token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('초대 수락이 완료되었습니다.')),
        );
        // 초대 수락 후 화면을 리로드하여 목록을 새로고침
        await _fetchInvitedStudyGroups();
      } else if (response.statusCode == 401) {
        bool success = await reissueToken(context);
        if (success) {
          return await acceptInvitation(context, invitationId);
        } else {
          throw Exception('토큰 재발급 실패');
        }
      }  else if(response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('현재 그룹 정원이 가득 찼습니다.'),duration: Duration(seconds: 1)));
      } else {
        throw Exception('Failed to accept invitation: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('초대 수락에 실패했습니다.')),
      );
    }
  }

  void _goBackToGroupManagement(BuildContext context) {

    Navigator.pop(context, true); // 그룹 알람 화면을 닫을 때 true 값을 함께 전달



  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var itemWidth = (screenSize.width - 20) / 2;
    var itemHeight = itemWidth * 1.5;

    return WillPopScope(
      onWillPop: () async {
        _goBackToGroupManagement(context); // 뒤로 가기 시 그룹 관리 화면으로 돌아가도록
        return false; // 기본 뒤로 가기 동작 막기
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            "받은 스터디 그룹 초대",
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              _goBackToGroupManagement(context); // 뒤로 가기 버튼을 누르면 그룹 관리 화면으로 돌아가기
            },
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : invitations.isEmpty
            ? Center(child: Text('받은 초대가 없습니다.', style: GoogleFonts.inter(fontSize: 16)))
            : Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: invitations.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_selectedIndex == index) {
                          _selectedIndex = null;
                        } else {
                          _selectedIndex = index;
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: itemWidth,
                        height: itemHeight * 1.1,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: _selectedIndex == index
                              ? Colors.blue.shade50
                              : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Container(
                                    width: itemWidth * 1.8,
                                    height: itemHeight * 0.53,
                                    child: Image.asset(
                                          () {
                                        if (invitations[index].category == "프로젝트") {
                                          return "assets/icons/ex5.png";
                                        } else if (invitations[index].category == '스터디') {
                                          return "assets/icons/ex6.png";
                                        } else if (invitations[index].category == '친목') {
                                          return "assets/icons/ex7.png";
                                        } else {
                                          return "assets/icons/eximage.png";
                                        }
                                      }(),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      invitations[index].studyName,
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "카테고리 : ${invitations[index].category}",
                                      style: GoogleFonts.inter(fontSize: 14),
                                    ),
                                    Text(
                                      "모임 장소 : ${invitations[index].studyLocation}",
                                      style: GoogleFonts.inter(fontSize: 14),
                                    ),
                                    Text(
                                      invitations[index].studyCycle,
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _selectedIndex == null
                    ? null
                    : () async {
                  await acceptInvitation(context, invitations[_selectedIndex!].invitationId.toString());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  "스터디 그룹 초대 수락하기",
                  style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
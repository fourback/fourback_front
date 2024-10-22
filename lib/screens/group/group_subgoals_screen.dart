import 'package:bemajor_frontend/models/study_group_goal.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api_url.dart';
import '../../auth.dart';




class SubGoalsScreen extends StatefulWidget {
  final StudyGroupGoalResponse goal;


  SubGoalsScreen({required this.goal});

  @override
  _SubGoalsScreenState createState() => _SubGoalsScreenState();
}

class _SubGoalsScreenState extends State<SubGoalsScreen> {
  late List<StudyGroupGoalDetailResponse> subGoals;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSubGoals();
  }

  Future<void> fetchSubGoals() async {
    String? token = await readAccess(); // 인증 토큰을 가져온다고 가정

    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/studygroup/goals/${widget.goal.studyGroupGoalId}/details'),
      headers: {'access': '$token'}, // 필요한 헤더 추가
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes)) ?? [];
      setState(() {
        subGoals =  body.map((dynamic item) {
          return StudyGroupGoalDetailResponse.fromJson(item);
        }).toList();
        isLoading = false;
      });

    } else {
      setState(() {
        isLoading = true;
      });
      throw Exception('Failed to load sub-goals');
    }
  }

  Future<void> addSubGoal(String subGoalName) async {
    String? token = await readAccess();
    final url = Uri.parse('${ApiUrl.baseUrl}/studygroup/goals/details');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'access': '$token'
      },
      body: jsonEncode(<String, dynamic>{
        'studyGroupGoalId': widget.goal.studyGroupGoalId,
        'detailGoalName': subGoalName,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        fetchSubGoals();
      });
    } else {
      print(response.body);
    }
  }

  Future<void> checkSubGoal(int detailGoalId, bool check) async {
    String? token = await readAccess();
    final url = Uri.parse('${ApiUrl.baseUrl}/studygroup/goals/detail/$detailGoalId/check');

    final response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'access': '$token',
      },
      body: jsonEncode(<String, dynamic>{
        'check': check,
      }),
    );

    if (response.statusCode == 200) {
      print("Check status updated successfully");
      setState(() {
        fetchSubGoals();
      });
    } else {
      print("Failed to update check status: ${response.body}");
    }
  }

  Future<void> deleteSubGoal(int detailGoalId) async {
    String? token = await readAccess();
    final url = Uri.parse('${ApiUrl.baseUrl}/studygroup/goals/details/$detailGoalId');

    final response = await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'access': '$token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        fetchSubGoals();
      });
    } else {
      print("Failed to delete sub-goal: ${response.body}");
    }
  }

  Future<void> deleteGoal(int goalId) async {
    String? token = await readAccess();
    final url = Uri.parse('${ApiUrl.baseUrl}/studygroup/goals/$goalId');

    final response = await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'access': '$token',
      },
    );

    if (response.statusCode == 200) {
      Navigator.of(context).pop();


    } else {
      print("Failed to delete sub-goal: ${response.body}");
    }
  }



  void _addSubGoal() {
    TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('세부 목표'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // 다이얼로그 닫기
              },
              child: Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  addSubGoal(_controller.text);
                }
                Navigator.of(context).pop();  // 다이얼로그 닫기
              },
              child: Text('추가'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(int subGoalId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                deleteSubGoal(subGoalId);
                Navigator.of(context).pop(); // 다이얼로그 닫기 및 목표 삭제
              },
              child: Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.goal.name),
        actions: [
          IconButton(
            icon: Icon(Icons.close), // 삭제 아이콘
            onPressed: () {
              // 삭제 동작을 여기에 추가
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    title: Text('목표를 삭제하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          deleteGoal(widget.goal.studyGroupGoalId);
                          Navigator.of(context).pop();
                        },
                        child: Text('삭제'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: isLoading ? Center(child: CircularProgressIndicator())
          : subGoals.isEmpty ? Center(child: Text('세부 목표가 없습니다')) :
      ListView.builder(
        itemCount: subGoals.length ,
        itemBuilder: (context, index) {
          final subGoal = subGoals[index];
          return Card(
            color: Colors.white,

            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(subGoal.name),
              onTap: () {
                _confirmDelete(subGoal.id); // 세부 목표 눌렀을 때 삭제 확인 다이얼로그 띄움
              },
              trailing: Checkbox(
                value: subGoal.checked,
                onChanged: (bool? value) {

                  checkSubGoal(subGoal.id, value!);

                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSubGoal,  // 목표 추가 버튼 클릭 시 다이얼로그 열기
        child: Icon(Icons.add),
      ),
    );
  }
}
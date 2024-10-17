import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../api_url.dart';
import '../../auth.dart';


class AddGoalScreen extends StatefulWidget {
  final int studyGroupId;

  AddGoalScreen({required this.studyGroupId});
  @override
  _AddGoalScreenState createState() => _AddGoalScreenState();
}



class _AddGoalScreenState extends State<AddGoalScreen> {
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();


  Future<void> _submitGoal() async {
    String? token = await readAccess();
    final url = Uri.parse('${ApiUrl.baseUrl}/studygroup/goals');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'access': '$token'
      },
      body: jsonEncode(<String, dynamic>{
        'studyGroupId': widget.studyGroupId,
        'goalName': _titleController.text,
        'endDate': _dateController.text,
      }),
    );

    if (response.statusCode == 200) {
      // 성공적으로 목표가 저장되면 이전 화면으로 돌아감
      Navigator.pop(context, {
        'title': _titleController.text,
        'date': _dateController.text,
      });
    } else {
      print(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('목표 설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '목표',
                border: OutlineInputBorder(), // 네모박스
              ),
            ),
            SizedBox(height: 16.0), // 입력 박스 간의 간격 추가
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: '마감일',
                border: OutlineInputBorder(), // 네모박스
              ),
              onTap: () async {
                FocusScope.of(context).unfocus(); // 키보드 숨기기
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: ColorScheme.light(
                          surface: Colors.white, // 달력 배경색 변경
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedDate != null) {
                  setState(() {
                    _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                  });
                }
              },
            ),
            SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              child: ElevatedButton(
                onPressed: () {
                  if (_titleController.text.isNotEmpty && _dateController.text.isNotEmpty) {
                    _submitGoal();

                  }
                },
                child: Text(
                  '만들기',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // 둥근 모서리
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {

    _titleController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}
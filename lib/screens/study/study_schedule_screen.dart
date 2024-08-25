import 'dart:convert';
import 'dart:math';

import 'package:bemajor_frontend/api_url.dart';
import 'package:bemajor_frontend/models/studyGroup.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import '../../auth.dart';

class StudyScheduleScreen extends StatefulWidget {
  final StudyGroup studyGroup;

  StudyScheduleScreen({required this.studyGroup});

  @override
  State<StudyScheduleScreen> createState() => _StudyScheduleScreenState();
}

class _StudyScheduleScreenState extends State<StudyScheduleScreen> {
  final TextEditingController addScheduleController = TextEditingController();
  final TextEditingController ScheduleController1 = TextEditingController();
  final TextEditingController ScheduleController2 = TextEditingController();
  final TextEditingController ScheduleController3 = TextEditingController();
  final TextEditingController ScheduleController4 = TextEditingController();
  final TextEditingController ScheduleController5 = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchSchedule() async {
    String? token = await readAccess();
    try {
      final response = await http.put(
        Uri.parse('${ApiUrl.baseUrl}/studygroup/${widget.studyGroup.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'access': '$token',
        },
        body: jsonEncode(<String, dynamic>{
          'studyName': widget.studyGroup.studyName,
          'studyLocation': widget.studyGroup.studyLocation,
          'studyCycle': widget.studyGroup.studyCycle,
          'studyRule': widget.studyGroup.studyRule,
          'category': widget.studyGroup.category,
          'teamSize': widget.studyGroup.teamSize,
          'startDate': widget.studyGroup.startDate,
          'endDate': widget.studyGroup.endDate,
          'studySchedule': widget.studyGroup.studySchedule
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('계획이 성공적으로 수정 되었습니다.'),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        print("${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      print('Network error: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _UpperAppbar(
        context: context, // context 전달
        onLogoPressed: () {},
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
          child: Text("스터디 계획 수정"),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                setState(() {
                  widget.studyGroup.studySchedule.add(addScheduleController.text);
                  addScheduleController.clear();
                });
              },
            ),
          ),
        ]
    );
  }

  List<Widget> _body() {
    List<Widget> widgets = [];
    widgets.add(
      Container(
        margin: const EdgeInsets.all(10),
        height: widget.studyGroup.studySchedule.length * 65 + 65,
        alignment: Alignment.center,

        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), //모서리를 둥글게
            border: Border.all(color: Colors.black12, width: 3)
        ),

        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.0,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(widget.studyGroup.studySchedule.length,(index) {
                    return Container(
                        margin: EdgeInsets.all(3), padding: EdgeInsets.all(3),
                        child: Text('ㆍ' + widget.studyGroup.studySchedule[index], style: const TextStyle(fontSize: 25))
                    );
                  }),
                ),
                  Container(
                      margin: EdgeInsets.all(3), padding: EdgeInsets.all(3),
                      child: TextField(
                          controller: addScheduleController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: '계획 추가',
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                          )
                  )
                  )
            ]
        ),
      ),
    );

    return widgets;
  }
}

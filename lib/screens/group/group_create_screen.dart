import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bemajor_frontend/auth.dart';

import '../../api_url.dart';



class GroupCreateScreen extends StatefulWidget {
  @override
  _GroupCreateScreenState createState() => _GroupCreateScreenState();
}

class _GroupCreateScreenState extends State<GroupCreateScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController cycleController = TextEditingController();
  final TextEditingController ruleController = TextEditingController();
  String? selectedCategory;
  int maxMembers = 1;
  DateTime selectedDate = DateTime.now();
  DateTimeRange? selectedDateRange;
  DateRangePickerController _controller = DateRangePickerController();
  String dateRangeText = '기간 선택';

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    cycleController.dispose();
    ruleController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    String? token = await readAccess();
    try {
      final response = await http.post(
        Uri.parse('${ApiUrl.baseUrl}/studygroup'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'access': '$token',
        },
        body: jsonEncode(<String, dynamic>{
          'studyName': nameController.text,
          'studyLocation': locationController.text,
          'studyCycle': cycleController.text,
          'studyRule': ruleController.text,
          'category': selectedCategory,
          'teamSize': maxMembers,
          'startDate': selectedDateRange!.start.toIso8601String(),
          'endDate': selectedDateRange!.end.toIso8601String(),
          'studySchedule': [],
        }),
      );


      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('그룹이 성공적으로 생성되었습니다.'),
            duration: Duration(seconds: 1),
          ),
        );
        Navigator.of(context).pop();
      } else {
        print("${response.statusCode}, ${response.body}");
      }
    } catch (e) {

      print('Network error: $e');
    }


  }


  @override
  Widget build(BuildContext context) {
    final int currentYear = DateTime.now().year;
    final DateTime minDate = DateTime(currentYear, 1, 1);
    final DateTime maxDate = DateTime(currentYear + 1, 12, 31);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          '그룹 만들기',
          style: TextStyle(
            color: Colors.black, // 텍스트 색상을 지정
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 2.0, 16.0, 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xfff8f8f8),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                // 배경색 지정
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('기간', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(dateRangeText, style: TextStyle(fontSize: 14)),
                    SizedBox(height: 6.0,),
                    SfDateRangePicker(
                      backgroundColor: Color(0xfff8f8f8),
                      headerStyle: DateRangePickerHeaderStyle(
                        backgroundColor: Color(0xfff8f8f8),
                      ),
                      controller: _controller,
                      selectionMode: DateRangePickerSelectionMode.range,
                      minDate: minDate,
                      maxDate: maxDate,
                      onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                        if (args.value is PickerDateRange) {
                          final PickerDateRange range = args.value;
                          setState(() {
                            selectedDateRange = DateTimeRange(
                              start: range.startDate!,
                              end: range.endDate ?? range.startDate!,
                            );
                            dateRangeText = '${DateFormat('yyyy-MM-dd').format(selectedDateRange!.start)} ~ ${DateFormat('yyyy-MM-dd').format(selectedDateRange!.end)}';
                          });
                        }
                      },

                    ),

                    Text('그룹 이름', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6.0,),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        border: OutlineInputBorder(

                        ),
                        isDense: true,
                        // Added this to make the input field height smaller
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.0,),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xfff8f8f8),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                // 배경색 지정
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('그룹 방식', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10.0,),
                    Container(

                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),

                      ),
                      child: Row(
                        children: [

                          SvgPicture.asset(
                            'assets/icons/person.svg',
                          ),
                          SizedBox(width: 8.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '스터디 인원',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('최대 인원은 몇명?'),
                            ],
                          ),
                          Spacer(),
                          Row(
                            children: [
                              IconButton(icon: Icon(Icons.remove), onPressed: () {
                                setState(() {
                                  if (maxMembers > 1) maxMembers--;
                                });
                              }),
                              Text('$maxMembers'),
                              IconButton(icon: Icon(Icons.add), onPressed: () {

                                setState(() {
                                  if (maxMembers >= 20) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('최대 인원은 20명입니다.'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  } else {
                                    maxMembers++;
                                  }

                                });
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),

                    Container(

                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),

                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/category.svg',
                          ),
                          SizedBox(width: 8.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '카테고리',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('모임 종류는?'),
                            ],
                          ),
                          Spacer(),
                          DropdownButton<String>(

                            value: selectedCategory,
                            hint: Text('선택하세요'),
                            dropdownColor: Colors.white,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedCategory = newValue;
                              });
                            },
                            items: <String>['스터디', '프로젝트', '친목', '정보공유']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),

                    Container(

                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),

                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/place.svg',
                          ),
                          SizedBox(width: 8.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '모임 장소',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('모이는 장소는 어디?'),
                            ],
                          ),
                          Spacer(),
                          Container(
                            width: 120.0,
                            child: TextField(
                              controller: locationController,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                isDense: true, // Added this to make the input field height smaller
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(

                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),

                      ),
                      child: Row(
                        children: [
                          Icon(Icons.today),
                          SizedBox(width: 8.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '모임 주기',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('모임은 언제?'),
                            ],
                          ),
                          Spacer(),
                          Container(
                            width: 120.0,
                            child: TextField(
                              controller: cycleController,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                isDense: true, // Added this to make the input field height smaller
                              ),

                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),


                    Container(

                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),

                      ),
                      child: Row(
                        children: [
                          Icon(Icons.rule),
                          SizedBox(width: 8.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '모임 규칙',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('모임 어떻게?'),
                            ],
                          ),
                          Spacer(),
                          Container(
                            width: 120.0,
                            child: TextField(
                              controller: ruleController,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                isDense: true, // Added this to make the input field height smaller
                              ),

                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.0,),
              Center(
                child: Column(
                    children: [
                      Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: ElevatedButton(
                          onPressed: () {
                            if (nameController.text.trim().isEmpty ||
                                locationController.text.trim().isEmpty ||
                                cycleController.text.trim().isEmpty ||
                                ruleController.text.trim().isEmpty ||
                                selectedCategory == null ||
                                selectedDateRange == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('필수 정보를 모두 입력해주세요.'),
                                  duration: Duration(seconds: 1),
                                ),

                              );
                              return;
                            } else {
                              _createGroup();


                            }

                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30), // 둥근 모서리
                            ),
                          ),
                          child: Text(
                            '만들기',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),

                      ),
                      SizedBox(height: 10.0,),

                      Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black, backgroundColor: Colors.grey[200],
                            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30), // 둥근 모서리
                            ),
                          ),
                          child: Text(
                            '취소',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),

                      ),
                    ]
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
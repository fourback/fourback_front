import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bemajor_frontend/models/studyGroup.dart';

class GroupSearchScreen extends StatefulWidget {
  final List<StudyGroup> studyGroups;

  GroupSearchScreen({required this.studyGroups});

  @override
  _GroupSearchScreenState createState() => _GroupSearchScreenState();
}

class _GroupSearchScreenState extends State<GroupSearchScreen> {
  List<StudyGroup> filteredStudyGroups = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredStudyGroups = widget.studyGroups;
  }

  void filterStudyGroups(String query) {
    setState(() {
      filteredStudyGroups = widget.studyGroups.where((group) {
        final studyName = group.studyName.toLowerCase();
        final category = group.category.toLowerCase();
        final location = group.studyLocation.toLowerCase();
        final searchQuery = query.toLowerCase();

        return studyName.contains(searchQuery) ||
            category.contains(searchQuery) ||
            location.contains(searchQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double itemWidth = (screenSize.width - 20) / 2;
    double itemHeight = itemWidth * 1.5; // GroupScreen과 동일한 비율 적용

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: TextField(
          controller: searchController,
          onChanged: (value) {
            filterStudyGroups(value);
          },
          decoration: InputDecoration(
            hintText: "검색: 이름, 카테고리, 모임 장소",
            border: InputBorder.none,
          ),
          style: GoogleFonts.inter(fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: filteredStudyGroups.isEmpty
          ? Center(child: Text("검색 결과가 없습니다."))
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: filteredStudyGroups.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 한 줄에 두 개의 아이템
            crossAxisSpacing: 10, // 아이템 간의 가로 간격
            mainAxisSpacing: 10, // 아이템 간의 세로 간격
            childAspectRatio: (itemWidth / itemHeight),
          ),
          itemBuilder: (context, index) {
            final studyGroup = filteredStudyGroups[index];
            return Container(
              width: itemWidth,
              height: itemHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이미지
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    child: Image.asset(
                          () {
                        if (studyGroup.category == "프로젝트") {
                          return "assets/icons/ex5.png";
                        } else if (studyGroup.category == '스터디') {
                          return "assets/icons/ex6.png";
                        } else if (studyGroup.category == '친목') {
                          return "assets/icons/ex7.png";
                        } else {
                          return "assets/icons/ex8.png";
                        }
                      }(),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: itemHeight * 0.48,
                    ),

                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 스터디 그룹 이름
                        Text(
                          studyGroup.studyName,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        // 카테고리
                        Text(
                          "카테고리: ${studyGroup.category}",
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                        // 모임 장소
                        Text(
                          "모임 장소: ${studyGroup.studyLocation}",
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                        // 모임 주기
                        Text(
                          studyGroup.studyCycle,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
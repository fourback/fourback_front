import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupAlarmScreen extends StatefulWidget {
  const GroupAlarmScreen({super.key});

  @override
  State<GroupAlarmScreen> createState() => _GroupAlarmScreenState();
}

class _GroupAlarmScreenState extends State<GroupAlarmScreen> {
  int? _selectedIndex; // Variable to keep track of the selected index

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var itemWidth = (screenSize.width - 20) / 2;
    var itemHeight = itemWidth * 1.5;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "받은 스터디 그룹 초대",
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 1, // This should be dynamic based on your data
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      // Toggle selection: if the same item is clicked again, deselect it
                      if (_selectedIndex == index) {
                        _selectedIndex = null; // Deselect if already selected
                      } else {
                        _selectedIndex = index; // Select the new item
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
                            ? Colors.blue.shade50 // Highlight selected item
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
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  width: itemWidth * 1.8,
                                  height: itemHeight * 0.53,
                                  child: Image.asset(
                                    "assets/icons/eximage.png",
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
                                    "선릉역 모각코 모임",
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ), // 스터디 그룹 이름
                                  SizedBox(height: 8),
                                  Text(
                                    "카테고리 : 스터디",
                                    style: GoogleFonts.inter(fontSize: 14),
                                  ), // 카테고리
                                  Text(
                                    "모임 장소 : 선릉역",
                                    style: GoogleFonts.inter(fontSize: 14),
                                  ), // 모임 장소
                                  Text(
                                    "월/수/금 12:00", // study_cycle
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ), // 시간
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
              onPressed: () {
                // 버튼 클릭 시 실행할 코드
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
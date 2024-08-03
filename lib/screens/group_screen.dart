import 'dart:async';
import 'package:bemajor_frontend/api_url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:convert';
import 'navigation_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:http/http.dart' as http;
import '../../auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bemajor_frontend/models/studyGroup.dart';

class GroupScreen extends StatefulWidget {
  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  Timer? timer;
  PageController controller = PageController();
  List<StudyGroup> studyGroups = [];
  List<StudyGroup> filteredStudyGroups = [];
  String selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    fetchStudyGroups().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        timer = Timer.periodic(Duration(seconds: 5), (timer) {
          if (!mounted || !controller.hasClients) return;

          int currentPage = controller.page?.toInt() ?? 0;
          int nextPage = currentPage + 1;

          if (nextPage > 3) {
            nextPage = 0;
          }
          controller.animateToPage(
            nextPage,
            duration: Duration(milliseconds: 500),
            curve: Curves.linear,
          );
        });
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    controller.dispose();
    super.dispose();
  }

  Future<void> fetchStudyGroups() async {
    String? token = await readAccess();
    final url = '${ApiUrl.baseUrl}/studygroup';
    print('Fetching study groups from $url'); // 로깅 추가
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'access': '$token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          studyGroups = parseStudyGroups(response.body);
          filteredStudyGroups = studyGroups;
        });
      } else if (response.statusCode == 401) {
        bool success = await reissueToken(context);
        if (success) {
          await fetchStudyGroups();
        } else {
          print('토큰 재발급 실패');
        }
      } else {
        print('Failed to load study groups: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load study groups');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load study groups');
    }
  }

  List<StudyGroup> parseStudyGroups(String responseBody) {
    final parsed = json.decode(utf8.decode(responseBody.codeUnits)).cast<Map<String, dynamic>>();
    return parsed.map<StudyGroup>((json) => StudyGroup.fromJson(json)).toList();
  }

  void filterStudyGroups(String category) {
    setState(() {
      if (selectedCategory == category) {
        selectedCategory = "All";
        filteredStudyGroups = studyGroups;
      } else {
        selectedCategory = category;
        filteredStudyGroups = studyGroups.where((group) => group.category == category).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appbarWidget(),
      body: studyGroups.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Column(
            children: [
              _buildPageView(),
              SizedBox(height: 20),
              _buildCategoryIcons(),
              SizedBox(height: 20),
              _buildStudyGroupGrid(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/logo.svg',
            width: 28,
            height: 28,
          ),
          onPressed: () {}, // 미정
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {},
                icon: SvgPicture.asset(
                  'assets/icons/search.svg',
                  width: 30,
                  height: 30,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: IconButton(
                  onPressed: () {},
                  icon: Image.asset(
                    'assets/icons/More.png',
                    height: 50,
                    width: 50,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPageView() {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    print(screenHeight);
    return Stack(
      children: [
        Container(
          width: screenWidth,
          height: screenHeight*0.24,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: PageView(
            controller: controller,
            children: [
              Image.asset("assets/icons/ex1.png", fit: BoxFit.cover),
              Image.asset("assets/icons/ex2.png", fit: BoxFit.cover),
              Image.asset("assets/icons/ex3.png", fit: BoxFit.cover),
              Image.asset("assets/icons/ex4.png", fit: BoxFit.cover),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: screenWidth*0.5, // 절반의 너비
            height: screenHeight*0.24,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Container(
                width: 146,
                height: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 32.0, bottom: 12),
                      child: Container(
                        width: 50,
                        child: Divider(
                          thickness: 7,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    Text(
                        "전공자가 되자!",
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => navigationScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF333333),
                      ),
                      child: Text(
                        '커뮤니티로 가기',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12,color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Center(
            child: SmoothPageIndicator(
              controller: controller, // PageController
              count: 4,
              effect: ExpandingDotsEffect(), // 점의 애니메이션 효과
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryIcons() {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    return Container(
      width: screenWidth*0.98,
      height: screenHeight*0.1,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildIconColumn("assets/icons/mygroup.svg", "내 그룹", "내 그룹"),
          _buildIconColumn("assets/icons/study.svg", "스터디", "스터디"),
          _buildIconColumn("assets/icons/project.svg", "프로젝트", "프로젝트"),
          _buildIconColumn("assets/icons/share.svg", "정보 공유", "정보 공유"),
          _buildIconColumn("assets/icons/amity.svg", "친목", "친목"),
        ],
      ),
    );
  }

  Widget _buildIconColumn(String assetPath, String label, String category) {
    bool isSelected = selectedCategory == category;
    return GestureDetector(
      onTap: () => filterStudyGroups(category),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Color(0xFF7C3AED).withOpacity(0.2) : Colors.transparent,
            ),
            child: IconButton(
              onPressed: null, // GestureDetector의 onTap 사용
              icon: SvgPicture.asset(
                assetPath,
                color: isSelected ? Color(0xFF7C3AED) : null,
              ),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              color: isSelected ? Color(0xFF7C3AED) : Color(0xFF808080),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyGroupGrid() {
    var screenSize = MediaQuery.of(context).size;
    var itemWidth = (screenSize.width - 20) / 2;
    var itemHeight = itemWidth * 1.5;

    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: filteredStudyGroups.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: (itemWidth / itemHeight),
      ),
      itemBuilder: (context, index) {
        final studyGroup = filteredStudyGroups[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
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
              children: [
                Container(
                  width: itemWidth * 0.9,
                  height: itemHeight * 0.48,
                  child: Image.asset("assets/icons/eximage.png", fit: BoxFit.cover),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        studyGroup.studyName,
                        textAlign: TextAlign.start, // study_name
                        style: GoogleFonts.inter(fontSize: 16,fontWeight: FontWeight.w600),
                      ), // 스터디 그룹 이름
                      SizedBox(height: 8),
                      Text(
                        "카테고리 : ${studyGroup.category}",
                        textAlign: TextAlign.start, // category
                        style: GoogleFonts.inter(fontSize: 14),
                      ), // 카테고리
                      Text(
                        "모임 장소 : ${studyGroup.studyLocation}",
                        style: GoogleFonts.inter(fontSize: 14),
                      ), // 모임 장소
                      Text(
                        studyGroup.studyCycle, // study_cycle
                        style: GoogleFonts.inter(fontSize: 16,fontWeight: FontWeight.w600),
                      ), // 시간
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
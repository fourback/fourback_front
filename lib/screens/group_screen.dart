import 'dart:async';
import 'package:bemajor_frontend/api_url.dart';
import 'package:bemajor_frontend/screens/group/group_ alarm_screen.dart';
import 'package:bemajor_frontend/screens/group/group_create_screen.dart';
import 'package:bemajor_frontend/screens/group/group_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  int invitationCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    await fetchStudyGroups();
    await fetchInvitationCount();
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

  Future<void> fetchMyStudyGroups() async {
    String? token = await readAccess();
    final url = '${ApiUrl.baseUrl}/studygroup/mygroups';
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
          filteredStudyGroups = parseStudyGroups(response.body);
          selectedCategory = "내 그룹"; // 선택된 카테고리 상태 업데이트
        });
      } else if (response.statusCode == 401) {
        bool success = await reissueToken(context);
        if (success) {
          await fetchMyStudyGroups();
        } else {
          print('토큰 재발급 실패');
        }
      } else {
        print('Failed to load my study groups: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load my study groups');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load my study groups');
    }
  }

  Future<int> fetchInvitationCount() async {
    String? token = await readAccess();
    final url = '${ApiUrl.baseUrl}/studygroup/invitation/count';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'access': '$token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          invitationCount = data['invitationCount']; // 초대 개수 업데이트
        });
        return data['invitationCount']; // 백엔드에서 invitationCount 값을 반환
      } else if (response.statusCode == 401) {
        bool success = await reissueToken(context);
        if (success) {
          return await fetchInvitationCount();
        } else {
          throw Exception('토큰 재발급 실패');
        }
      } else {
        throw Exception('Failed to fetch invitation count: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch invitation count');
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
        if (category != "내 그룹") {
          filteredStudyGroups = studyGroups.where((group) => group.category == category).toList();
        }
      }
    });
  }
  Future<void> _refreshData() async {
    // 데이터를 다시 불러옵니다.
    await fetchStudyGroups();
    await fetchInvitationCount();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appbarWidget(),
      body: RefreshIndicator(
        onRefresh: _refreshData, // 당겨서 새로고침
        child: studyGroups.isEmpty
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GroupAlarmScreen()),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black,
                    ),
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.05,
                    child: Center(
                      child: Text(
                        '$invitationCount개의 스터디 그룹 초대가 승인을 기다리고 있어요!',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                _buildPageView(),
                SizedBox(height: 20),
                _buildCategoryIcons(),
                SizedBox(height: 20),
                _buildStudyGroupGrid(),
              ],
            ),
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
          onPressed: () async {
            await _refreshData(); // 로고 버튼을 눌렀을 때 새로고침
          }, // 미정
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupSearchScreen(studyGroups: studyGroups),
                    ),
                  );
                },
                icon: SvgPicture.asset(
                  'assets/icons/search.svg',
                  width: 30,
                  height: 30,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GroupCreateScreen()),
                    );
                  },
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

    return Stack(
      children: [
        Container(
          width: screenWidth,
          height: screenHeight * 0.24,
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
            width: screenWidth * 0.5, // 절반의 너비
            height: screenHeight * 0.24,
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
                    Text("전공자가 되자!",
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => navigationScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF333333),
                      ),
                      child: Text(
                        '커뮤니티로 가기',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Colors.white),
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
      width: screenWidth * 0.98,
      height: screenHeight * 0.1,
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
      nTap: () {
        if (category == "내 그룹") {
          fetchMyStudyGroups(); // 내 그룹 API 호출
        } else {
          filterStudyGroups(category); // 기존 카테고리 필터링
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? Color(0xFF7C3AED).withOpacity(0.2)
                  : Colors.transparent,
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
                  child: Image.asset("assets/icons/eximage.png",
                      fit: BoxFit.cover),
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
                        style: GoogleFonts.inter(
                            fontSize: 16, fontWeight: FontWeight.w600),
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
                        style: GoogleFonts.inter(
                            fontSize: 16, fontWeight: FontWeight.w600),
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

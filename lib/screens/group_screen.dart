import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:async';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class GroupScreen extends StatefulWidget {
  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  Timer? timer;
  PageController controller = PageController();

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      int currentPage = controller.page!.toInt();
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
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 358,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: PageView(
                    controller: controller,
                    children: [
                      Image.asset("assets/icons/ex1.png",fit: BoxFit.cover,),
                      Image.asset("assets/icons/ex2.png",fit: BoxFit.cover),
                      Image.asset("assets/icons/ex3.png",fit: BoxFit.cover),
                      Image.asset("assets/icons/ex4.png",fit: BoxFit.cover),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 179, // 절반의 너비
                    height: 200,
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
                                  child: Divider(thickness: 7, color: Color(0xFF333333),)),
                            ),
                            Text("전공자가 되자!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            SizedBox(height: 24,),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF333333),
                              ),
                              child: Text('커뮤니티로 가기', style: TextStyle(color: Colors.white),),
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
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: 358,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: Image.asset("assets/icons/mygroup.png")),
                  IconButton(
                      onPressed: () {},
                      icon: Image.asset("assets/icons/study.png")),
                  IconButton(
                      onPressed: () {},
                      icon: Image.asset("assets/icons/project.png")),
                  IconButton(
                      onPressed: () {},
                      icon: Image.asset("assets/icons/FYI.png")),
                  IconButton(
                      onPressed: () {},
                      icon: Image.asset("assets/icons/amity.png")),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: 358,
              height: 272,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 10, //스터디 모임 갯수 데이터를 가져와야함.
                  itemBuilder: (context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 173,
                        height: 272,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white,
                        ),
                        child: ListTile(
                            title: Container(
                              width: 157,
                              height: 132,
                              child: Image.asset("assets/icons/eximage.png"),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "플로터 스터디 ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 18),
                                ), //스터디 그룹 이름
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  "카테고리 : 스터디",
                                  style: TextStyle(fontSize: 13),
                                ), //카테고리
                                Text(
                                  "모임 장소 : 수원 ",
                                  style: TextStyle(fontSize: 13),
                                ), //모임 장소
                                Text(
                                  "토/일 12:00 ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 18),
                                ) //시간
                              ],
                            )),
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
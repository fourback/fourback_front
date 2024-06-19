import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bemajor_frontend/models/community.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _HomeAppbar(),
      body: _HomeBody(),
    );
  }
}



PreferredSizeWidget _HomeAppbar() {
  return AppBar(
    backgroundColor: Colors.white,
    leading: Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: IconButton(
        icon: SvgPicture.asset(
          'assets/icons/logo.svg',
          width: 28,
          height: 28,
        ),
        onPressed: () {}, // refresh 새로고침 기능!
      ),
    ),
    title: Container(
      height: 30,
      child: TextField(
        decoration: InputDecoration(
          hintText: '검색어를 입력하세요.',
          hintStyle: TextStyle(color: Colors.white, fontSize: 14),
          fillColor: Colors.black,
          filled: true,
          prefixIcon: Icon(Icons.search, color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.zero,
        ),
        style: TextStyle(color: Colors.white),
      ),
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: IconButton(
          onPressed: () {},
          icon: SvgPicture.asset(
            'assets/icons/bell.svg',
            height: 28,
            width: 28,
          ),
        ),
      ),
    ],
  );
}


class _HomeBody extends StatelessWidget {

  const _HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(

          height: 40, // 버튼 컨테이너의 높이 설정
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(10, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: Size(114,28)
                    ),
                    child: Text('버튼 ${index + 1}',style: TextStyle(color: Colors.white),),

                  ),
                );
              }),
            ),
          ),
        ),
        Expanded(
          child: Center(child: Text('HomeScreen')),
        ),
      ],
    );
  }
}





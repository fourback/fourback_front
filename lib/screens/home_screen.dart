import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: SvgPicture.asset('assets/icons/logo.svg',
            width: 28,height: 28,),
            onPressed: () {},//refresh 새로고침 기능!
          ),
        ),
        title: Container(
          height: 30,
          child: TextField(
            decoration: InputDecoration(
              hintText: '검색어를 입력하세요.',
              hintStyle: TextStyle(color: Colors.white,fontSize: 14),
              fillColor: Colors.black,
              filled: true,
              prefixIcon: Icon(Icons.search,color: Colors.white,),
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
                onPressed: (){},
                icon: SvgPicture.asset('assets/icons/bell.svg',
                height: 28,width: 28,)),
          )
        ],
      ),

    );
  }
}



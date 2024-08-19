import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_screen.dart';
import 'chat_screen.dart';
import 'community/community_screen.dart';
import 'group_screen.dart';
import 'mypage_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class navigationScreen extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<navigationScreen> {
  int _currentIndex = 0;

  static List<Widget> _pages = <Widget>[
    HomeScreen(),
    BoardScreen(),
    GroupScreen(),
    ChatScreen(),
    MypageScreen(),
  ];



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,

      ],
      supportedLocales:  [
        const Locale('ko', 'KR'),

      ],
      locale: const Locale('ko', 'KR'),

      home: Scaffold(
        backgroundColor: Colors.white,

        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });

          },
          items:  <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/icons/home.svg'),
              activeIcon: SvgPicture.asset('assets/icons/home.svg',color: Color(0xFF7C3AED),),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/icons/board.svg'),
              activeIcon: SvgPicture.asset('assets/icons/board.svg',color: Color(0xFF7C3AED),),
              label: '커뮤니티',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/icons/group.svg'),
              activeIcon: SvgPicture.asset('assets/icons/group.svg',color: Color(0xFF7C3AED),),
              label: '그룹관리',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/icons/botchat.svg'),
              activeIcon: SvgPicture.asset('assets/icons/botchat.svg',color: Color(0xFF7C3AED),),
              label: '채팅',
            ),BottomNavigationBarItem(
              icon: SvgPicture.asset('assets/icons/mypage.svg'),
              activeIcon: SvgPicture.asset('assets/icons/mypage.svg',color: Color(0xFF7C3AED),),
              label: '마이페이지',
            ),

          ],

          selectedItemColor: Color(0xff7C3AED),

          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
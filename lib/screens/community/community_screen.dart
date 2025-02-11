import 'dart:async';
import 'package:bemajor_frontend/screens/community/post_list_screen2.dart';
import 'package:bemajor_frontend/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import '../../auth.dart';
import 'post_list_screen.dart';
import '/api_url.dart';
import 'search_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/community.dart';



class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  State<BoardScreen> createState() => _BoardState();
}

class _BoardState extends State<BoardScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: _appbarWidget(),
      backgroundColor: Colors.white,
      body: _bodyWidget(),
    );
  }




  @override
  void initState() {
    super.initState();
    fetchBoards();
  }

  @override
  void dispose() {

    super.dispose();
  }

  late List<BoardDto> boards = [];


  Future<void> fetchBoards() async {
    String? token = await readAccess();

    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/api/board'),
      headers: {'access': '$token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      setState(() {
        boards = jsonData.map((data) => BoardDto.fromJson(data)).toList();
      });
    } else if(response.statusCode == 401) {
      bool success = await reissueToken(context);
      if(success) {
        await fetchBoards();
      } else {
        print('토큰 재발급 실패');
      }
    }
    else {
      throw Exception('Failed to load posts');

    }
  }

  Future<void> favoriteBoard(String boardName) async {

    // API 엔드포인트 설정
    String apiUrl = "${ApiUrl.baseUrl}/api/board/favorite";
    String? token = await readAccess();

    // POST 요청으로 즐겨찾기 토글 요청 보내기
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'access': '$token'
        },
        body: jsonEncode(FavoriteBoard(boardName)),
      );

      if (response.statusCode == 200) {

      } else if(response.statusCode == 401) {
        bool success = await reissueToken(context);
        if(success) {
          await fetchBoards();
        } else {
          print('토큰 재발급 실패');
        }
      }
      else {
        // 오류 발생 시 에러 메시지 출력
        print('Failed to favorite: ${response.statusCode}');
      }
    } catch (error) {
      // 네트워크 오류 발생 시 에러 메시지 출력
      print('Network error: $error');
    }
  }


  PreferredSizeWidget _appbarWidget(){
    return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('커뮤니티',
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen()),
              );
            },
              icon:  SvgPicture.asset('assets/icons/search.svg',width: 30,height: 30,),),
          ),

        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Color(0xffe9ecef),
            height: 1.3,
          ),
        )
    );
  }


  Widget _bodyWidget() {

    return SingleChildScrollView(
      child: Column(

      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Container(



              height: MediaQuery.of(context).size.height * 0.27, // 화면 높이의 25%
              width: MediaQuery.of(context).size.width * 0.9, // 화면 너비의 90%
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Color(0xffe9ecef),width: 1.3)
                  )
              ),
              child: ListView(
                children: [

                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    leading: SvgPicture.asset('assets/icons/list.svg',width: 25,height: 25,),
                    title: Text('내가 쓴 글', style: GoogleFonts.inter(fontWeight: FontWeight.w600,fontSize: 18),),
                    onTap: (){
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PostListScreen2(1,'내가 쓴 글')),
                    );
                      },
                  ),
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    leading: SvgPicture.asset('assets/icons/chat.svg',width: 25,height: 25,),
                    title: Text('댓글 단 글', style: GoogleFonts.inter(fontWeight: FontWeight.w600,fontSize: 18),),
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PostListScreen2(2,"댓글 단 글")),
                      );
                    },
                  ),
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    leading: SvgPicture.asset('assets/icons/good.svg',width: 25,height: 25,),
                    title: Text('좋아요 누른 글', style: GoogleFonts.inter(fontWeight: FontWeight.w600,fontSize: 18),),
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PostListScreen2(3,'좋아요 누른 글')),
                      );
                    },
                  ),
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    leading: SvgPicture.asset('assets/icons/fire.svg',width: 25,height: 25,),
                    title: Text('실시간 인기글', style: GoogleFonts.inter(fontWeight: FontWeight.w600,fontSize: 18),),
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PostListScreen2(4,'실시간 인기글')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        Container(
          height: MediaQuery.of(context).size.height * 0.5, // 화면 높이의 25%
          width: MediaQuery.of(context).size.width * 0.9, // 화면 너비의 90%

          child: ListView.builder(
              itemCount: boards.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                  leading: IconButton(
                    icon: Icon(
                      boards[index].isfavorite ? Icons.star : Icons.star_border,
                      color: boards[index].isfavorite ? Color(0xff7C3AED): Color(0xff7C3AED),
                    ),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: () async {
                      await favoriteBoard(boards[index].boardName);
                      await fetchBoards();
                      setState(() {});
                    },
                  ),
                  title: Text(
                    boards[index].boardName,

                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PostListScreen(boards[index].boardName, boards[index].id)),
                    );

                    // 게시판을 선택했을 때의 동작을 추가할 수 있습니다.

                  },
                );
              }),

        )
      ],

    ));
  }
}


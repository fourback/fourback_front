import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'post_list_screen.dart';
import '/api_url.dart';
import 'search_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/community.dart';


Future<String?> readJwt() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('USERID');
}

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
    String? token = await readJwt();

    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/api/board'),
      headers: {'authorization': '$token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      setState(() {
        boards = jsonData.map((data) => BoardDto.fromJson(data)).toList();
      });
    } else {
      throw Exception('Failed to load posts');

    }
  }


  PreferredSizeWidget _appbarWidget(){
    return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: Text('커뮤니티',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
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


              height: 200,
              width: 341,
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
                    title: Text('내가 쓴 글', style: TextStyle(fontWeight: FontWeight.normal,fontSize: 18),),
                    onTap: (){print('내가 쓴글');},
                  ),
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    leading: SvgPicture.asset('assets/icons/chat.svg',width: 25,height: 25,),
                    title: Text('댓글 단 글', style: TextStyle(fontWeight: FontWeight.normal,fontSize: 18),),
                    onTap: (){print('댓글 단 글');},
                  ),
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    leading: SvgPicture.asset('assets/icons/good.svg',width: 25,height: 25,),
                    title: Text('좋아요 누른 글', style: TextStyle(fontWeight: FontWeight.normal,fontSize: 18),),
                    onTap: (){print('좋아요 누른 글');},
                  ),
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    leading: SvgPicture.asset('assets/icons/fire.svg',width: 25,height: 25,),
                    title: Text('실시간 인기글', style: TextStyle(fontWeight: FontWeight.normal,fontSize: 18),),
                    onTap: (){print('HOT 게시글');},
                  ),
                ],
              ),
            ),
          ),
        ),

        Container(
          height: 300,
          width: 355,

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
                      await favoriteboard(boards[index].boardName);
                      await fetchBoards();
                      setState(() {});
                    },
                  ),
                  title: Text(
                    boards[index].boardName,

                    style: TextStyle(
                      fontWeight: FontWeight.normal,
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

Future<void> favoriteboard(String boardName) async {

  // API 엔드포인트 설정
  String apiUrl = "${ApiUrl.baseUrl}/api/board/favorite";
  String? token = await readJwt();

  // POST 요청으로 즐겨찾기 토글 요청 보내기
  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': '$token'
      },
      body: jsonEncode(FavoriteBoard(boardName)),
    );

    if (response.statusCode == 200) {
      // 즐겨찾기 상태가 토글되었으므로 UI 갱신
    } else {
      // 오류 발생 시 에러 메시지 출력
      print('Failed to favorite: ${response.statusCode}');
    }
  } catch (error) {
    // 네트워크 오류 발생 시 에러 메시지 출력
    print('Network error: $error');
  }
}
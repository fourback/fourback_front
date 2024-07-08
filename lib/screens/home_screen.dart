import 'package:bemajor_frontend/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth.dart';
import '../models/post.dart';
import 'community/post_list_screen.dart';
import '/api_url.dart';
import '../../models/community.dart';
import 'community/post_screen.dart';

Future<String?> readJwt() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('USERID');
}

Future<String?> readRefresh() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('REFRESH');
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<BoardDto> boards = [];
  bool isLoading = true;

  void _registerUserId(String userID) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('USERID', userID);
  }

  void _registerRefresh(String refresh) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('REFRESH', refresh);
  }


  @override
  void initState() {
    super.initState();
    fetchBoards();
  }

  Future<void> fetchBoards() async {
    String? token = await readJwt();
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/api/board'),
      headers: {'access': '$token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);

      setState(() {
        boards = jsonData.map((data) => BoardDto.fromJson(data)).toList();
        isLoading = false;
      });
    } else if(response.statusCode == 401 ) {
      print("홈화면 상태코드 ${response.statusCode} 바디: ${response.body} 끝");
      bool success = await reissueToken(context);
      if(success) {
        await fetchBoards();
      } else {
        print('토큰 재발급 실패');
      }
    }
    else {
      print("${response.statusCode}");
      throw Exception('Failed to load boards');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _HomeAppbar(),
      body: isLoading ? Center(child: CircularProgressIndicator()) : _HomeBody(boards: boards),
    );
  }
}

PreferredSizeWidget _HomeAppbar() {
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
  final List<BoardDto> boards;

  const _HomeBody({Key? key, required this.boards}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 40, // 버튼 컨테이너의 높이 설정
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(boards.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostListScreen(
                            boards[index].boardName,
                            boards[index].id,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: Size(114, 28),
                    ),
                    child: Text(
                      boards[index].boardName,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        Expanded(

          child: ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) {
              // 임시 데이터
              final List<Map<String, String>> posts = [
                {
                  'boardName': '자유게시판',
                  'title': '첫 번째 게시글 제목',
                  'content': '첫 번째 게시글 내용',
                  'author': '작성자1',
                  'date': '2023-06-24',
                },
                {
                  'boardName': '프로젝트 홍보',
                  'title': '두 번째 게시글 제목',
                  'content': '두 번째 게시글 내용',
                  'author': '작성자2',
                  'date': '2023-06-23',
                },
                {
                  'boardName': 'Q&A',
                  'title': '세 번째 게시글 제목',
                  'content': '세 번째 게시글 내용',
                  'author': '작성자3',
                  'date': '2023-06-22',
                },
              ];

              return Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Container(
                  padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 0,
                        blurRadius: 0,
                        offset: Offset(0, 1), // 그림자의 위치 조정
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      title: Container(
                        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Posted in ',
                                style: DefaultTextStyle.of(context).style,
                                children: <TextSpan>[
                                  TextSpan(
                                    text: posts[index]['boardName']!,
                                    style: TextStyle(
                                        color: Color(0xff7C3AED),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Divider(),
                            SizedBox(height: 8.0),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: Icon(Icons.person, color: Colors.white),
                                ),
                                SizedBox(
                                    width: 8), // CircleAvatar와 작성자 이름 사이의 간격 조절
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          posts[index]['author']!, // 작성자 이름 표시
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '수원대학교', // 작성자 학교 표시
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 8), // 각 항목 사이의 간격 추가
                                  ],
                                ),
                                Spacer(), // 작성자 이름과 날짜 사이에 공간을 확장합니다.
                                Text(
                                  posts[index]['date']!, // 날짜 표시 예시
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            posts[index]['title']!,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            posts[index]['content']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.0),
                          Divider(),
                          SizedBox(height: 4.0),
                          // 각 항목 사이의 간격 추가
                          Row(
                            children: [
                              Icon(Icons.favorite_border),
                              SizedBox(width: 4), // 아이콘 사이의 간격 조절
                              Text(
                                '0', // 좋아요 수 임시 값
                              ),
                              SizedBox(width: 16.0), // 아이콘 사이의 간격 조절
                              SvgPicture.asset('assets/icons/comment.svg'),
                              SizedBox(width: 4), // 아이콘 사이의 간격 조절
                              Text(
                                '0', // 댓글 수 임시 값
                              ),
                              Spacer(), // 오른쪽으로 확장되는 공간을 만듭니다.
                              SvgPicture.asset('assets/icons/viewcount.svg'),
                              SizedBox(width: 4),
                              Text(
                                '0', // 조회 수 임시 값
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        // 게시글을 눌렀을 때의 동작을 추가할 수 있습니다.
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
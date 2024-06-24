import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'community/post_list_screen.dart';
import '/api_url.dart';
import '../../models/community.dart';

Future<String?> readJwt() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('USERID');
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<BoardDto> boards = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBoards();
  }

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
        isLoading = false;
      });
    } else {
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
          child: Center(child: Text('HomeScreen')),
        ),
      ],
    );
  }
}



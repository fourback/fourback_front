import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth.dart';
import '../publicImage.dart';
import 'community/post_list_screen.dart';
import '/api_url.dart';
import '../../models/community.dart';
import 'community/post_screen.dart';
import 'community/search_screen.dart';
import '../../models/post.dart';

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
  late List<Post> allPosts = []; // 모든 Post 리스트 추가
  late List<Post> filteredPosts = []; // 필터링된 Post 리스트 추가
  bool isLoading = true;
  String? selectedBoardName; // 선택된 보드 이름 추가
  final ScrollController _scrollController = ScrollController(); // ScrollController 추가

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
      });
      fetchAllPosts(); // 게시판 목록을 불러온 후 게시글을 불러옵니다.
    } else if(response.statusCode == 401) {
      bool success = await reissueToken(context);
      if(success) {
        await fetchBoards();
      } else {
        print('토큰 재발급 실패');
      }
    } else {
      throw Exception('Failed to load boards');
    }
  }

  Future<void> fetchAllPosts() async {
    String? token = await readJwt();
    List<Post> allFetchedPosts = [];
    for (var board in boards) {
      final response = await http.get(
        Uri.parse('${ApiUrl.baseUrl}/api/post?page=0&pageSize=10&boardId=${board.id}'),
        headers: {'access': '$token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        allFetchedPosts.addAll(jsonData.map((data) => Post.fromJson(data)).toList());
      } else if(response.statusCode == 401) {
        bool success = await reissueToken(context);
        if(success) {
          await fetchAllPosts();
        } else {
          print('토큰 재발급 실패');
        }
      }
    }

    allFetchedPosts.sort((a, b) => b.id.compareTo(a.id));

    setState(() {
      allPosts = allFetchedPosts;
      filteredPosts = allFetchedPosts; // 초기에는 모든 게시글을 보여줍니다.
      isLoading = false;
    });
  }

  void filterPosts(String? boardName) {
    setState(() {
      if (boardName == null) {
        filteredPosts = allPosts; // 모든 게시글을 보여줍니다.
      } else {
        filteredPosts = allPosts.where((post) => post.boardName == boardName).toList();
      }
    });
  }

  Future<void> refreshPosts() async {
    setState(() {
      isLoading = true;
    });
    await fetchAllPosts();
    filterPosts(selectedBoardName);
  }

  void removePostAt(int index) {
    setState(() {
      filteredPosts.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _HomeAppbar(
        context: context, // context 전달
        onLogoPressed: () {
          _scrollController.animateTo(
            0.0,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
          refreshPosts();
        },
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: refreshPosts,
        child: _HomeBody(
          boards: boards,
          posts: filteredPosts,
          onBoardSelected: (boardName) {
            setState(() {
              selectedBoardName = boardName;
            });
            filterPosts(boardName);
          },
          scrollController: _scrollController, // ScrollController 전달
        ),
      ),
    );
  }
}

PreferredSizeWidget _HomeAppbar({
  required BuildContext context, // BuildContext 추가
  required Function onLogoPressed,
}) {
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
        onPressed: () => onLogoPressed(), // refresh 새로고침 기능!
      ),
    ),
    title: Container(
      child: Text("Be전공자"),
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchScreen()),
                );
              },
              icon: SvgPicture.asset(
                'assets/icons/search.svg',
                width: 30,
                height: 30,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: SvgPicture.asset(
                'assets/icons/bell.svg',
                height: 28,
                width: 28,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _HomeBody extends StatefulWidget {
  final List<BoardDto> boards; // Board 리스트 추가
  final List<Post> posts; // Post 리스트 추가
  final Function(String?) onBoardSelected; // 보드 선택 콜백 함수 추가
  final ScrollController scrollController; // ScrollController 추가

  const _HomeBody({
    Key? key,
    required this.boards,
    required this.posts,
    required this.onBoardSelected,
    required this.scrollController,
  }) : super(key: key);

  @override
  _HomeBodyState createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 40, // 버튼 컨테이너의 높이 설정
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onBoardSelected(null); // 모든 게시글을 표시합니다.
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: Size(114, 28),
                    ),
                    child: Text(
                      'All',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                ...List.generate(widget.boards.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onBoardSelected(widget.boards[index].boardName); // 선택한 보드의 게시글을 필터링합니다.
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: Size(114, 28),
                      ),
                      child: Text(
                        widget.boards[index].boardName,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController, // ScrollController 설정
            itemCount: widget.posts.length,
            itemBuilder: (context, index) {
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
                                    text: widget.posts[index].boardName,
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
                                          widget.posts[index].memberName, // 작성자 이름 표시
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
                                  widget.posts[index].postDate, // 날짜 표시 예시
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
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.posts[index].title,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      widget.posts[index].content,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                  ],
                                ),
                              ),
                              if (widget.posts[index].imageName.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: PublicImage(
                                      placeholderPath: 'assets/icons/loading.gif',
                                      imageUrl: 'http://116.47.60.159:8080/image/' + widget.posts[index].imageName[0],
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      key: ValueKey('http://116.47.60.159:8080/image/' + widget.posts[index].imageName[0]),
                                    ),
                                  ),
                                ),
                            ],
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
                                widget.posts[index].goodCount.toString(), // 좋아요 수
                              ),
                              SizedBox(width: 16.0), // 아이콘 사이의 간격 조절
                              SvgPicture.asset('assets/icons/comment.svg'),
                              SizedBox(width: 4), // 아이콘 사이의 간격 조절
                              Text(
                                widget.posts[index].commentCount.toString(), // 댓글 수
                              ),
                              Spacer(), // 오른쪽으로 확장되는 공간을 만듭니다.
                              SvgPicture.asset('assets/icons/viewcount.svg'),
                              SizedBox(width: 4),
                              Text(
                                widget.posts[index].viewCount.toString(), // 조회 수
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () async {
                        final ifDelete = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(
                              post: widget.posts[index],
                              boardName: widget.posts[index].boardName,
                            ),
                          ),
                        );

                        if (ifDelete == true) {
                          setState(() {
                            widget.posts.removeAt(index);
                          });
                        }
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
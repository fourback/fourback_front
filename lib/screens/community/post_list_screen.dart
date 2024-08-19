import 'package:flutter/cupertino.dart';

import '../../publicImage.dart';
import '/auth.dart';
import 'post_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'write_screen.dart';
import '/api_url.dart';
import '/models/post.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostListScreen extends StatefulWidget {
  final String boardName;
  final int boardId;

  PostListScreen(this.boardName, this.boardId);

  @override
  _PostListScreenState createState() => _PostListScreenState();
}



class _PostListScreenState extends State<PostListScreen> {
  late ScrollController _scrollController;
  late List<Post> posts = [];
  bool isFavorite = false;
  int page = 0;
  int pageSize = 10;
  bool isLoading = false;
  Color iconColor = Colors.grey;
  bool isUpdate = false;


  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    fetchPosts();
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose the controller when not needed
    super.dispose();
  }

  Future<void> fetchPosts() async {
    String? token = await readAccess();
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/api/post?page=$page&pageSize=$pageSize&boardId=${widget.boardId}'),
      headers: {'access': '$token'},);

    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      setState(() {
        posts.addAll(jsonData.map((data) => Post.fromJson(data)).toList());
        page++;
      });
    } else if(response.statusCode == 401) {
      bool success = await reissueToken(context);
      if(success) {
        await fetchPosts();
      } else {
        print('토큰 재발급 실패');
      }
    } else {
      print("${response.statusCode}");
      throw Exception('Failed to load posts');

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffe9ecef),
      appBar: AppBar(
        shape: Border(
          bottom: BorderSide(
            color: Color(0xffe9ecef),
            width: 1.3,
          ),
        ),
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: Text(widget.boardName),
      ),
      body: ListView.builder(
        itemCount: posts.length + (isLoading ? 1 : 0),
        itemBuilder: (BuildContext context, int index) {
          if (index < posts.length) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Container(
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
                child: ListTile(
                  title: Container(
                    padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        SizedBox(width: 8), // CircleAvatar와 작성자 이름 사이의 간격 조절
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  posts[index].memberName, // 작성자 이름 표시
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
                          posts[index].postDate, // 날짜 표시 예시
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey,
                          ),
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
                                  posts[index].title,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  posts[index].content,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (posts[index].imageName.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: PublicImage(
                                  imageUrl: 'http://116.47.60.159:8080/api/images/' + posts[index].imageName[0],
                                  placeholderPath: 'assets/icons/loading.gif',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  key: ValueKey('http://116.47.60.159:8080/api/images/' + posts[index].imageName[0]),
                                ),
                              ),
                            ),
                        ],
                      ),


                      SizedBox(height: 5.0),
                      Divider(),
                      SizedBox(height: 5.0),
                      // 각 항목 사이의 간격 추가
                      Row(
                        children: [
                          Icon(Icons.favorite_border),
                          SizedBox(width: 4), // 아이콘 사이의 간격 조절
                          Text(
                            posts[index].goodCount.toString(),
                            // 좋아요 수
                          ),
                          SizedBox(width: 16.0), // 아이콘 사이의 간격 조절
                          SvgPicture.asset('assets/icons/comment.svg'),
                          SizedBox(width: 4), // 아이콘 사이의 간격 조절
                          Text(
                            posts[index].commentCount.toString(), // 댓글 수
                          ),
                          Spacer(), // 오른쪽으로 확장되는 공간을 만듭니다.
                          SvgPicture.asset('assets/icons/viewcount.svg'),
                          SizedBox(width: 4),
                          Text(
                            posts[index].viewCount.toString(), // 조회 수
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
                          post: posts[index],
                          boardName: widget.boardName,
                        ),
                      ),
                    );

                    setState(()  {
                      if(ifDelete == true) {
                        posts.clear();
                        page = 0;
                        fetchPosts();
                      }


                    });
                  },
                ),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
        controller: _scrollController,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WriteScreen(widget.boardId, widget.boardName)),
          );
          // 버튼을 눌렀을 때 수행할 작업을 추가할 수 있습니다.
        },
        child: SvgPicture.asset(
          'assets/icons/pencil.svg',
          width: 35,
          color: Colors.white,
        ),
      ),
    );
  }

  void _scrollListener() {
    if (isLoading) return;

    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      fetchPosts();
    }
  }
}
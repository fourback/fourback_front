import 'package:bemajor_frontend/screens/community/post_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/post.dart';
import '/api_url.dart';
import '/models/postsearch.dart';
import 'package:shared_preferences/shared_preferences.dart';



class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

Future<String?> readJwt() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('USERID');
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  bool isLoading = false;
  bool beforeSearch = true;
  int page = 0;
  int pageSize = 10;
  late List<Post> posts = [];
  late ScrollController _scrollController;
  String currentQuery = '';




  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener as VoidCallback);
  }

  Future<void> fetchPostSearch(String keyword) async {
    String? token = await readJwt();
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });



    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/api/post/search?page=$page&pageSize=$pageSize&keyword=$keyword'),
      headers: {'access': '$token'},
    );
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      setState(() {
        posts.addAll(jsonData.map((data) => Post.fromJson(data)).toList());
        page++;
      });
    } else {
      throw Exception('Failed to load posts');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Color(0xffe9ecef),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight), // 앱 바의 세로 크기 조절
        child: AppBar(
          scrolledUnderElevation: 0,
          shape: Border(
            bottom: BorderSide(
              color: Color(0xffe9ecef),
              width: 1.3,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              FocusScope.of(context).unfocus();
              Future.delayed(Duration(milliseconds: 100), () {
                Navigator.pop(context);
              });
            },
            color: Colors.black,
          ),
          backgroundColor: Colors.white,
          titleSpacing: 0, // 타이틀과 왼쪽 경계 사이의 간격을 없앰
          title: Padding(
            padding: EdgeInsets.only(top: 4.0), // 검색 필드를 약간 위로 이동
            child: TextField(
              autofocus: true,
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '글 제목, 내용을 검색하세요.',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              ),
              onSubmitted: (query) {
                if(query.trim().isNotEmpty) {
                  setState(() {
                    beforeSearch = false;
                    posts.clear(); // 검색 결과 초기화
                    page = 0;
                    currentQuery = query; // 검색된 쿼리를 업데이트
                  });
                  fetchPostSearch(query);
                }
              },
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                String query = _searchController.text;
                if(query.trim().isNotEmpty) {
                  setState(() {
                    beforeSearch = false;
                    posts.clear(); // 검색 결과 초기화
                    page = 0;
                    currentQuery = query; // 검색된 쿼리를 업데이트
                  });
                  fetchPostSearch(query);
                }

              },
            ),
          ],
        ),
      ),
      body:
      beforeSearch
          ? Center(
        child:  Text('글 제목, 내용을 검색하세요.')// 로딩 표시
      )
      : posts.isNotEmpty // 게시글이 있는 경우
        ? ListView.builder(

        itemCount: posts.length + (isLoading ? 1 : 0),
        itemBuilder: (BuildContext context, int index) {
          if(index < posts.length) {
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

                    padding: EdgeInsets.only(bottom: 5.0),
                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Posted in ',
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                text: posts[index].boardName,
                                style: TextStyle(color: Color(0xff7C3AED),fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),

                        Divider(),
                        SizedBox(height: 4.0,),


                        Row(

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
                                child: FadeInImage.assetNetwork(
                                  placeholder: 'assets/icons/loading.gif',
                                  image: 'http://116.47.60.159:8080/images/' + posts[index].imageName[0],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  imageErrorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[200],
                                      child: Icon(Icons.error, color: Colors.red),
                                    );
                                  },
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
                          boardName: posts[index].boardName,
                        ),
                      ),
                    );

                    setState(()  {



                    });
                    // 게시글을 눌렀을 때의 동작을 추가할 수 있습니다.
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

      ) : Center(
          child: Text('검색 결과가 없습니다.')
      ),
    );



  }

  void _scrollListener() {
    if (isLoading) return;

    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      fetchPostSearch(currentQuery);
    }
  }

}


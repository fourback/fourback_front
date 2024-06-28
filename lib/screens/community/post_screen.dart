import 'package:bemajor_frontend/models/commentWrite.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bemajor_frontend/api_url.dart';
import '../../models/commentResult.dart';
import '/models/post.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailScreen extends StatefulWidget {
  final Post post;
  final String boardName;

  DetailScreen({required this.post, required this.boardName});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

Future<String?> readJwt() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('USERID');
}

class _DetailScreenState extends State<DetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool isReplying = false;
  int? replyingToCommentIndex;

  bool isLoading = false;
  List<CommentResult> commentsResult = [];

  int size = 0;
  int page = 0;

  List<bool> _isReplyVisible = List.generate(12, (index) => false); // 글 갯수 12
  bool isLiked = false; // 글 좋아요 상태를 나타내는 변수
  int likeCount = 3; // 글 좋아요 수 goodCount

  List<bool> _commentLikes = List.generate(12, (index) => false); // 댓글 좋아요 상태
  List<int> _commentLikeCounts = List.generate(12, (index) => 3); // 댓글 좋아요 수

  List<List<bool>> _replyLikes = List.generate(12, (index) => List.generate(3, (replyIndex) => false)); // 대댓글 좋아요 상태
  List<List<int>> _replyLikeCounts = List.generate(12, (index) => List.generate(3, (replyIndex) => 3)); // 대댓글 좋아요 수 테이블 수정

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> fetchComments() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    final response = await http.get(Uri.parse('${ApiUrl.baseUrl}/api/comment/list?postID=${widget.post.id}'));
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = jsonDecode(response.body);

      setState(() {
        List<dynamic> jsonData = jsonMap['result'];
        commentsResult = jsonData.map((data) => CommentResult.fromJson(data)).toList();
        size = jsonMap['size'];
        page++;
      });
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<void> _addComment(String content, int parentCommentId) async {
    String apiUrl = '${ApiUrl.baseUrl}/api/comment';
    String? token = await readJwt();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'authorization': '$token'
        },
        body: jsonEncode(CommentWrite(widget.post.id, content, parentCommentId)),
      );

      if (response.statusCode == 200) {
        print('댓글이 성공적으로 전송되었습니다.');
        await fetchComments(); // 새로운 댓글을 작성한 후 댓글 리스트를 다시 로드
      } else {
        print('API 요청이 실패했습니다.');
      }
    } catch (e) {
      print('오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1.0,
            thickness: 1.0,
          ),
        ),
        scrolledUnderElevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 글 내용 컨테이너
              Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: "Posted in ",
                        style: TextStyle(color: Colors.black, fontSize: 14.0),
                        children: [
                          TextSpan(
                            text: widget.boardName,
                            style: TextStyle(
                              color: Colors.purple,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
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
                        SizedBox(width: 8.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.post.memberName,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('수원대학교 컴퓨터학부'), // 출신 및 과
                              SizedBox(height: 8.0),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (String value) {
                            // Edit 및 Delete 액션 처리
                            if (value == 'edit') {
                              // Edit action
                            } else if (value == 'delete') {
                              // Delete action
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem<String>(
                                value: 'edit',
                                child: Text('수정'), // 수정 액션 Ontap 시 글 작성 화면 이동
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('삭제'), // 삭제 액션 Ontap 시 글 삭제
                              ),
                            ];
                          },
                          icon: Icon(Icons.more_vert),
                          color: Colors.white,
                        ),
                      ],
                    ),
                    Text(
                      widget.post.title, // 글 제목
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
                    ),
                    Text(
                      widget.post.content, // 글 내용
                      style: TextStyle(fontSize: 18.0),
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.postDate, // 글 작성 날짜
                          style: TextStyle(color: Colors.grey, fontSize: 14.0),
                        ),
                        Flexible(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border_outlined,
                                  color: isLiked ? Colors.purple : Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isLiked = !isLiked;
                                    if (isLiked) {
                                      likeCount++;
                                    } else {
                                      likeCount--;
                                    }
                                  });
                                },
                              ),
                              Text(
                                '좋아요 $likeCount', // 좋아요 수
                                style: TextStyle(color: Colors.grey, fontSize: 14.0),
                              ),
                              SizedBox(width: 16.0),
                              Icon(Icons.visibility, color: Colors.grey, size: 16.0),
                              SizedBox(width: 4.0),
                              Text(
                                '조회 수 123', // 예시 조회 수 viewcount
                                style: TextStyle(color: Colors.grey, fontSize: 14.0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(),
              SizedBox(height: 20.0),
              // Comment 텍스트
              Text(
                'Comment',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
              // 댓글 리스트
              SingleChildScrollView(
                child: Column(
                  children: List.generate(size, (index) {
                    List<dynamic> jsonData = commentsResult[index].reply?['result'];
                    List<CommentResult> repliesResult = [];
                    // 대댓글 리스트
                    repliesResult.addAll(jsonData.map((data) => CommentResult.fromJson(data)).toList());
                    final memberId = '${commentsResult[index].userName}';
                    final comment = '${commentsResult[index].content}'; // comment

                    final List<CommentResult> replies = List.generate(
                        jsonData.length,
                            (replyIndex) => repliesResult[replyIndex]);

                    return Column(
                      children: [
                        ListTile(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              SizedBox(width: 8.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    memberId,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text('수원대학교 컴퓨터학부'),
                                ],
                              ),
                              Spacer(),
                              PopupMenuButton<String>(
                                onSelected: (String value) {
                                  // Edit 및 Delete 액션 처리
                                  if (value == 'edit') {
                                    // Edit action
                                  } else if (value == 'delete') {
                                    // Delete action
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  return [
                                    PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Text('수정'), // 수정 액션
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Text('삭제'), // 삭제 액션
                                    ),
                                  ];
                                },
                                icon: Icon(Icons.more_vert, color: Colors.grey),
                              ),
                            ],

                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 16.0),
                              Text(comment, style: TextStyle(fontSize: 16.0)),
                              SizedBox(height: 10.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('${commentsResult[index].dateDiff}'), // 댓글 날짜 텍스트
                                  Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        if (replyingToCommentIndex == index) {
                                          // 대댓글 작성 모드 종료
                                          isReplying = false;
                                          replyingToCommentIndex = null;
                                        } else {
                                          // 대댓글 작성 모드 시작
                                          isReplying = true;
                                          replyingToCommentIndex = index;
                                        }
                                        _isReplyVisible[index] = !_isReplyVisible[index];
                                      });
                                    },
                                    icon: Icon(Icons.chat_bubble_outline, color: Colors.black),
                                  ),
                                  Text('${jsonData.length}'), // 대댓글 갯수 표시
                                  SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(
                                      _commentLikes[index]
                                          ? Icons.favorite
                                          : Icons.favorite_border_outlined,
                                      color: _commentLikes[index] ? Colors.purple : Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _commentLikes[index] = !_commentLikes[index];
                                        if (_commentLikes[index]) {
                                          _commentLikeCounts[index]++;
                                        } else {
                                          _commentLikeCounts[index]--;
                                        }
                                      });
                                    },
                                  ),
                                  Text("${_commentLikeCounts[index]}"), // 좋아요 숫자
                                ],
                              ),
                              // 대댓글 리스트 표시
                              if (_isReplyVisible[index])
                                ...replies.map((reply) {
                                  int replyIndex = replies.indexOf(reply);
                                  return Padding(
                                    padding: EdgeInsets.only(left: 20.0, top: 10.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey, width: 1),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor: Colors.grey,
                                                  child: Icon(Icons.person, color: Colors.white),
                                                  radius: 16,
                                                ),
                                                SizedBox(width: 8.0),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${replies[replyIndex].userName}',
                                                      // 대댓글 사용자명
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14.0,
                                                      ),
                                                    ),
                                                    Text(
                                                      '수원대학교 컴퓨터학부',
                                                      style: TextStyle(fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                                Spacer(),
                                                PopupMenuButton<String>(
                                                  onSelected: (String value) {
                                                    // Edit 및 Delete 액션 처리
                                                    if (value == 'edit') {
                                                      // Edit action
                                                    } else if (value == 'delete') {
                                                      // Delete action
                                                    }
                                                  },
                                                  itemBuilder: (BuildContext context) {
                                                    return [
                                                      PopupMenuItem<String>(
                                                        value: 'edit',
                                                        child: Text('수정'), // 수정 액션
                                                      ),
                                                      PopupMenuItem<String>(
                                                        value: 'delete',
                                                        child: Text('삭제'), // 삭제 액션
                                                      ),
                                                    ];
                                                  },
                                                  icon: Icon(Icons.more_vert, color: Colors.grey),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 16.0),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  isReplying = true;
                                                  replyingToCommentIndex = index;
                                                });
                                              },
                                              child: Text(
                                                reply.content,
                                                style: TextStyle(fontSize: 14.0),
                                              ),
                                            ),
                                            SizedBox(height: 8.0),
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: Icon(
                                                      _replyLikes[index][replyIndex]
                                                          ? Icons.favorite
                                                          : Icons.favorite_border_outlined,
                                                      color: _replyLikes[index][replyIndex]
                                                          ? Colors.purple
                                                          : Colors.grey,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _replyLikes[index][replyIndex] =
                                                        !_replyLikes[index][replyIndex];
                                                        if (_replyLikes[index][replyIndex]) {
                                                          _replyLikeCounts[index][replyIndex]++;
                                                        } else {
                                                          _replyLikeCounts[index][replyIndex]--;
                                                        }
                                                      });
                                                    },
                                                  ),
                                                  Text(
                                                    "${_replyLikeCounts[index][replyIndex]}",
                                                    style: TextStyle(fontSize: 12.0), // 텍스트 크기 조정
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.0)
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color(0xffffff),
          border: Border(
            top: BorderSide(color: Colors.grey, width: 1.0),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 12.0,
            right: 12.0,
            top: 8.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 8.0,
          ),
          child: Row(
            children: [
              SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: isReplying ? '대댓글을 입력하세요.' : '댓글을 입력하세요.',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(width: 6),
              IconButton(
                icon: Icon(Icons.send, color: Colors.purple),
                onPressed: () async {
                  if (isReplying && replyingToCommentIndex != null) {
                    // 대댓글 작성 로직
                    int parentCommentId = commentsResult[replyingToCommentIndex!].id;
                    await _addComment(_commentController.text, parentCommentId);
                  } else {
                    // 댓글 작성 로직
                    await _addComment(_commentController.text, -1);
                  }

                  setState(() {
                    if (!isReplying) {
                      replyingToCommentIndex = null;
                    }
                    _commentController.clear();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
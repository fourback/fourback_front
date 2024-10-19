import 'dart:io';

import 'package:bemajor_frontend/models/commentWrite.dart';
import 'package:bemajor_frontend/models/user_info.dart';
import 'package:bemajor_frontend/screens/community/post_update_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bemajor_frontend/api_url.dart';
import '../../auth.dart';
import '../../models/commentModify.dart';
import '../../models/commentResult.dart';
import '../../publicImage.dart';
import '/models/post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'fullimage_screen.dart';

class DetailScreen extends StatefulWidget {
  Post post;
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
  List<UserInfo> usersInfo = [];

  bool isModifying = false;
  int? modifyingToCommentId;
  List<CommentResult> modifyingToReply = [];

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
    viewCountUp();
    fetchComments();
  }

  Future<void> _updatePost() async {
    String? access = await readAccess();
    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/api/post/${widget.post.id}'),
      headers: {
        'access': '$access'
      },
    );
    if (response.statusCode == 200) {
      final updatedData = jsonDecode(response.body);
      setState(() {
        widget.post.title = updatedData['title'];
        widget.post.content = updatedData['content'];
        widget.post.postDate = updatedData['updateDate'];
        widget.post.imageName = List<String>.from(updatedData['imageName'] ?? []);
      });

    } else if(response.statusCode == 401) {
      bool success = await reissueToken(context);
      if(success) {
        await _updatePost();
      } else {
        print('토큰 재발급 실패');
      }
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<void> _deletePost() async {
    String? access = await readAccess();
    final response = await http.delete(
      Uri.parse('${ApiUrl.baseUrl}/api/post/${widget.post.id}'),
      headers: {
        'access': '$access'
      },
    );
    if (response.statusCode == 200) {


      Navigator.pop(context,true);

    } else if(response.statusCode == 401) {
      bool success = await reissueToken(context);
      if(success) {
        await _deletePost();
      } else {
        print('토큰 재발급 실패');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 실패')),
      );
    }
  }

  Future<void> _favoritePost() async {

    // API 엔드포인트 설정
    String apiUrl = "${ApiUrl.baseUrl}/api/post/${widget.post.id}/favorite";
    String? token = await readJwt();


    // POST 요청으로 즐겨찾기 토글 요청 보내기
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'access': '$token'},
      );

      if (response.statusCode == 200) {
        // 즐겨찾기 상태가 토글되었으므로 UI 갱신
        setState(() {
          widget.post.postGood = !widget.post.postGood;
          if(widget.post.postGood) {
            widget.post.goodCount += 1;
          } else {
            widget.post.goodCount -= 1;
          }
        });
      } else if(response.statusCode == 401) {
        bool success = await reissueToken(context);
        if(success) {
          await _favoritePost();
        } else {
          print('토큰 재발급 실패');
        }
      } else {
        // 오류 발생 시 에러 메시지 출력
        print('Failed to favorite: ${response.statusCode}');
      }
    } catch (error) {
      // 네트워크 오류 발생 시 에러 메시지 출력
      print('Network error: $error');
    }
  }

  Future<void> viewCountUp() async {
    String? token = await readAccess();
    final url = Uri.parse('${ApiUrl.baseUrl}/api/post/${widget.post.id}/view');
    final response = await http.patch(
        url,
        headers: {'access': '$token'}
    );

    if (response.statusCode == 200) {
      setState(() {
        widget.post.viewCount += 1; // 조회수를 증가시킵니다.
      });
    } else if(response.statusCode == 401) {
      bool success = await reissueToken(context);
      if(success) {
        await viewCountUp();
      } else {
        print('토큰 재발급 실패');
      }
    } else {
      // 오류 처리
      print('Failed to favorite: ${response.statusCode}');
    }
  }

  Future<void> fetchComments() async {
    if (isLoading) return;
    String? token = await readAccess();

    setState(() {
      isLoading = true;
    });

    final response = await http.get(
      Uri.parse('${ApiUrl.baseUrl}/api/comment/list?postID=${widget.post.id}'),
      headers: {'access': '$token'},);setState(() {
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
    } else if(response.statusCode == 401) {
      bool success = await reissueToken(context);
      if (success) {
        await _favoritePost();
      } else {
        print('토큰 재발급 실패');
      }
    }


    else {
      throw Exception('Failed to load comments');
    }
  }

  Future<void> _addComment(String content, int parentCommentId) async {
    String apiUrl = '${ApiUrl.baseUrl}/api/comment';
    String? token = await readAccess();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'access': '$token'
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

  Future<void> _modifyComment(String content, int commentId) async {
    String apiUrl = '${ApiUrl.baseUrl}/api/comment';
    String? token = await readJwt();

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'access': '$token'
        },
        body: jsonEncode(CommentModify(commentId, content)),
      );

      if (response.statusCode == 200) {
        print('댓글이 성공적으로 수정되었습니다.');
        await fetchComments(); // 댓글을 수정한 후 댓글 리스트를 다시 로드
      } else {
        print('API 요청이 실패했습니다.');
      }
    } catch (e) {
      print('오류: $e');
    }
  }

  Future<void> _deleteComment(int commentId) async {
    String apiUrl = '${ApiUrl.baseUrl}/api/comment?commentID=${commentId}';
    String? token = await readJwt();

    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'access': '$token'
        },
      );

      if (response.statusCode == 200) {
        print('댓글이 성공적으로 삭제되었습니다.');
        await fetchComments(); // 댓글을 수정한 후 댓글 리스트를 다시 로드
      } else {
        print('API 요청이 실패했습니다.');
      }
    } catch (e) {
      print('오류: $e');
    }
  }

  Future<void> _getFavoriteComment(int commentID, int index) async {
    String apiUrl = await '${ApiUrl.baseUrl}/api/comment/favorite?commentID=${commentID}';
    String? token = await readAccess();

    final response = await http.get(Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'access': '$token'
      },
    );
    _commentLikes[index] = jsonDecode(response.body);
  }

  Future<void> _getFavoriteReply(int commentID, int index, int replyIndex) async {
    String apiUrl = await '${ApiUrl.baseUrl}/api/comment/favorite?commentID=${commentID}';
    String? token = await readAccess();

    final response = await http.get(Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'access': '$token'
      },
    );
    _replyLikes[index][replyIndex] = jsonDecode(response.body);
  }

  Future<void> _addFavoriteComment(CommentResult commentResult, int index) async {
    String apiUrl = '${ApiUrl.baseUrl}/api/comment/favorite?commentID=${commentResult.id}';
    String? token = await readJwt();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'access': '$token'
        },
      );

      if (response.statusCode == 200 && commentsResult[index].status != 1) {
        print('좋아요가 성공적으로 추가되었습니다.');
        _getFavoriteComment(commentResult.id, index);
        await fetchComments(); // 새로운 댓글을 작성한 후 댓글 리스트를 다시 로드
      } else {
        print('API 요청이 실패했습니다.');
      }
    } catch (e) {
      print('오류: $e');
    }
  }

  Future<void> _deleteFavoriteComment(CommentResult commentResult, int index) async {
    String apiUrl = '${ApiUrl.baseUrl}/api/comment/favorite?commentID=${commentResult.id}';
    String? token = await readAccess();

    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'access': '$token'
        },
      );

      if (response.statusCode == 200 && commentsResult[index].status != 1) {
        print('좋아요가 성공적으로 제거되었습니다.');
        _getFavoriteComment(commentResult.id, index);
        await fetchComments(); // 새로운 댓글을 작성한 후 댓글 리스트를 다시 로드
      } else {
        print('API 요청이 실패했습니다.');
      }
    } catch (e) {
      print('오류: $e');
    }
  }

  Future<void> _addFavoriteReply(CommentResult commentResult, int index, int replyIndex) async {
    String apiUrl = '${ApiUrl.baseUrl}/api/comment/favorite?commentID=${commentResult.id}';
    String? token = await readAccess();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'access': '$token'
        },
      );

      if (response.statusCode == 200) {
        print('좋아요가 성공적으로 추가되었습니다.');
        _getFavoriteReply(commentResult.id, index, replyIndex);
        await fetchComments(); // 새로운 댓글을 작성한 후 댓글 리스트를 다시 로드
      } else {
        print('API 요청이 실패했습니다.');
      }
    } catch (e) {
      print('오류: $e');
    }
  }

  Future<void> _deleteFavoriteReply(CommentResult commentResult, int index, int replyIndex) async {
    String apiUrl = '${ApiUrl.baseUrl}/api/comment/favorite?commentID=${commentResult.id}';
    String? token = await readAccess();

    try {
      final response = await http.delete(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'access': '$token'
        },
      );

      if (response.statusCode == 200) {
        print('좋아요가 성공적으로 제거되었습니다.');
        _getFavoriteReply(commentResult.id, index, replyIndex);
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
            Navigator.pop(context,true);
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
                        PublicImage(
                          imageUrl: widget.post.profileImage.isNotEmpty
                              ? widget.post.profileImage
                              : "https://www.pngarts.com/files/10/Default-Profile-Picture-PNG-Download-Image.png",
                          placeholderPath: 'assets/icons/loading.gif',
                          width: 40.0, // 원하는 크기로 조정하세요
                          height: 40.0, // 원하는 크기로 조정하세요
                          fit: BoxFit.cover, // 이미지 맞춤 설정
                          isCircular: true, // 원형으로 표시
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
                              Text(
                                widget.post.belong + ", " + widget.post.department,
                              ), // 출신 및 과 // User.belong, dapartment 가져와서 수정해야함
                              SizedBox(height: 8.0),
                            ],
                          ),
                        ),
                        if(widget.post.userCheck == true)
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
                                  child: Text('수정'),
                                  onTap: () async {
                                    final updatedPost = await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => PostUpdateScreen(widget.post)),
                                    );


                                    // 수정된 게시글 정보를 받아오고 상태를 업데이트

                                    if (updatedPost == true) {
                                      _updatePost();
                                    }


                                  },
                                  // 수정 액션 Ontap 시 글 작성 화면 이동
                                ),
                                PopupMenuItem<String>(
                                  onTap: () async {
                                    await _deletePost();


                                  },
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
                    if (widget.post.imageName.isNotEmpty) ...widget.post.imageName.map((imageName) {
                      return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullImageScreen(imageUrl: 'http://116.47.60.159:8080/api/images/' + imageName),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: PublicImage(
                                imageUrl: imageName,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.cover,
                                placeholderPath: 'assets/icons/loading.gif',
                                key: ValueKey(imageName),
                              ),
                            ),
                          )
                      );
                    }).toList(),

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
                                  widget.post.postGood ? Icons.favorite : Icons.favorite_border_outlined,
                                  color:  widget.post.postGood ? Colors.purple : Colors.grey,
                                ),
                                onPressed: () async {
                                  await _favoritePost();

                                },
                              ),
                              Text(
                                '좋아요 ${widget.post.goodCount}', // 좋아요 수
                                style: TextStyle(color: Colors.grey, fontSize: 14.0),
                              ),
                              SizedBox(width: 16.0),
                              Icon(Icons.visibility, color: Colors.grey, size: 16.0),
                              SizedBox(width: 4.0),
                              Text(
                                '조회 수 ${widget.post.viewCount}', // 예시 조회 수 viewcount
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
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey,
                        width: 1
                      ),
                    ),
                    //border: Border.all(color: Colors.grey, width: 1),
                    //borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: List.generate(size, (index) {
                      List<dynamic> jsonData = commentsResult[index].reply?['result'];
                      List<CommentResult> repliesResult = [];
                      // 대댓글 리스트
                      repliesResult.addAll(jsonData.map((data) => CommentResult.fromJson(data)).toList());
                      final memberId = '${commentsResult[index].userName}';
                      final comment = '${commentsResult[index].content}'; // comment
                      _commentLikeCounts[index] = commentsResult[index].goodCount;
                      _commentLikes[index] = commentsResult[index].isFavorite;

                      final List<CommentResult> replies = List.generate(
                          jsonData.length,
                              (replyIndex) => repliesResult[replyIndex]);



                      return Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                PublicImage(
                                  imageUrl: commentsResult[index].profileImage != null
                                      ? commentsResult[index].profileImage!
                                      : "https://www.pngarts.com/files/10/Default-Profile-Picture-PNG-Download-Image.png",
                                  placeholderPath: 'assets/icons/loading.gif',
                                  width: 40.0, // 원하는 크기로 조정하세요x`
                                  height: 40.0, // 원하는 크기로 조정하세요
                                  fit: BoxFit.cover, // 이미지 맞춤 설정
                                  isCircular: true, // 원형으로 표시
                                ),
                                SizedBox(width: 8.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      memberId,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text('${commentsResult[index].belong}, ${commentsResult[index].department}'),
                                  ],
                                ),
                                Spacer(),
                                if(commentsResult[index].userCheck == true && commentsResult[index].status == 0)
                                  PopupMenuButton<String>(
                                    onSelected: (String value) {
                                      // Edit 및 Delete 액션 처리
                                      if (value == 'edit') {
                                        // Edit action
                                        if (modifyingToCommentId == commentsResult[index].id) {
                                          isModifying = false;
                                          _commentController.text = '';
                                        }
                                        else {
                                          isModifying = true;
                                          modifyingToCommentId = commentsResult[index].id;
                                          _commentController.text = commentsResult[index].content;
                                        }
                                      } else if (value == 'delete') {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              content: Text("댓글을 삭제하시겠습니까?"),
                                              actions: [
                                                TextButton(
                                                  child: Text("예"),
                                                  // Delete action
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    _deleteComment(commentsResult[index].id);
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text("아니오"),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      };
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
                                commentsResult[index].status != 1 ?
                                Text(comment, style: TextStyle(fontSize: 16.0)) :
                                Text(comment, style: TextStyle(fontSize: 14.0, color: Colors.grey))

                                ,SizedBox(height: 10.0),
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

                                          if(_commentLikes[index] == true) {
                                            _deleteFavoriteComment(commentsResult[index], index);
                                          } else {
                                            _addFavoriteComment(commentsResult[index], index);
                                          }
                                        });
                                      },
                                    ),
                                    Text("${commentsResult[index].goodCount}"), // 좋아요 숫자
                                  ],
                                ),
                                // 대댓글 리스트 표시
                                if (_isReplyVisible[index])
                                  ...replies.map((reply) {
                                    int replyIndex = replies.indexOf(reply);
                                    _replyLikes[index][replyIndex] = repliesResult[replyIndex].isFavorite;
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
                                                  PublicImage(
                                                    imageUrl: replies[replyIndex].profileImage != null
                                                        ? replies[replyIndex].profileImage!
                                                        : "https://www.pngarts.com/files/10/Default-Profile-Picture-PNG-Download-Image.png",
                                                    placeholderPath: 'assets/icons/loading.gif',
                                                    width: 40.0, // 원하는 크기로 조정하세요
                                                    height: 40.0, // 원하는 크기로 조정하세요
                                                    fit: BoxFit.cover, // 이미지 맞춤 설정
                                                    isCircular: true, // 원형으로 표시
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
                                                        '${replies[replyIndex].belong} ${replies[replyIndex].department}',
                                                        style: TextStyle(fontSize: 12),
                                                      ),
                                                    ],
                                                  ),
                                                  Spacer(),
                                                  if(replies[replyIndex].userCheck == true && replies[replyIndex].status == 0)
                                                    PopupMenuButton<String>(
                                                      onSelected: (String value) {
                                                        // Edit 및 Delete 액션 처리
                                                        if (value == 'edit') {
                                                          // Edit action
                                                          if (modifyingToCommentId == replies[replyIndex].id) {
                                                            isModifying = false;
                                                            _commentController.text = '';
                                                          }
                                                          else {
                                                            isModifying = true;
                                                            modifyingToCommentId = replies[replyIndex].id;
                                                            modifyingToReply = replies;
                                                            _commentController.text = replies[replyIndex].content;
                                                          }
                                                        } else if (value == 'delete') {
                                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) {
                                                              return AlertDialog(
                                                                content: Text("대댓글을 삭제하시겠습니까?"),
                                                                actions: [
                                                                  TextButton(
                                                                    child: Text("예"),
                                                                    // Delete action
                                                                    onPressed: () {
                                                                      Navigator.of(context).pop();
                                                                      _deleteComment(replies[replyIndex].id);
                                                                    },
                                                                  ),
                                                                  TextButton(
                                                                    child: Text("아니오"),
                                                                    onPressed: () {
                                                                      Navigator.of(context).pop();
                                                                    },
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                          // Delete action
                                                        }
                                                      },
                                                      itemBuilder: (BuildContext context) {
                                                        return [
                                                          PopupMenuItem<String>(
                                                            value: 'edit',
                                                            child: Text('수정'), // 대댓글 수정 액션
                                                          ),
                                                          PopupMenuItem<String>(
                                                            value: 'delete',
                                                            child: Text('삭제'), // 대댓글 삭제 액션
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
                                                child:
                                                Text(reply.content,
                                                    style: replies[replyIndex].status != 1 ?
                                                    TextStyle(fontSize: 14.0) :
                                                    TextStyle(fontSize: 12.0, color: Colors.grey)
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
                                                          _replyLikeCounts[index][replyIndex] = repliesResult[replyIndex].goodCount;
                                                          if (_replyLikes[index][replyIndex] == true) {
                                                            _deleteFavoriteReply(replies[replyIndex], index, replyIndex);
                                                          } else {
                                                            _addFavoriteReply(replies[replyIndex], index, replyIndex);
                                                          }
                                                        });
                                                      },
                                                    ),
                                                    Text(
                                                      "${replies[replyIndex].goodCount}",
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
                          Divider(color: Colors.grey),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      //resizeToAvoidBottomInset: true,
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
                  if (isReplying == true && isModifying == false && replyingToCommentIndex != null) {
                    // 대댓글 작성 로직
                    int parentCommentId = commentsResult[replyingToCommentIndex!].id;
                    await _addComment(_commentController.text, parentCommentId);
                  } else if (isReplying == false && isModifying == false) {
                    // 댓글 작성 로직
                    await _addComment(_commentController.text, -1);
                  } else if (isReplying == false && isModifying == true) {
                    // 댓글 수정 로직
                    await _modifyComment(_commentController.text, modifyingToCommentId!);
                  } else if (isReplying == true && isModifying == true) {
                    // 대댓글 수정 로직
                    await _modifyComment(_commentController.text, modifyingToCommentId!);
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
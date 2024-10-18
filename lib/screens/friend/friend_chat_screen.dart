import 'dart:async';


import 'package:bemajor_frontend/ip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../auth.dart';
import '../../chat_database_helper.dart';
import 'package:bemajor_frontend/friend_chat_database_helper.dart';

import '../../models/user_info.dart';
import '../../publicImage.dart';

class FriendChatScreen extends StatefulWidget {
  final int friendId;
  final String friendName;
  final String friendProfile;

  FriendChatScreen({required this.friendId, required this.friendName,required this.friendProfile});

  @override
  _FriendChatScreenState createState() => _FriendChatScreenState();
}

class _FriendChatScreenState extends State<FriendChatScreen> {
  final ScrollController _scrollController = ScrollController();
  StompClient? stompClient;
  List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  late WebSocketChannel _channel;
  late String userProfile;
  late String userName;
  late int userId;
  StreamSubscription? _chatSubscription;


  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // 사용자 정보를 먼저 가져온 후에 메시지 로드 및 WebSocket 연결
    await fetchUserInfo();  // userId 설정 후 계속 진행
    _loadMessages();  // 메시지 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectWebSocket();  // WebSocket 연결
    });
  }

  String formatTime(String isoString) {
    DateTime dateTime = DateTime.parse(isoString);
    String formattedTime = DateFormat('a hh:mm').format(dateTime); // "a hh:mm"은 "오전/오후 00:00" 형식
    return formattedTime.replaceFirst('AM', '오전').replaceFirst('PM', '오후'); // "AM" -> "오전", "PM" -> "오후"
  }

  String formatDate(String isoString) {
    DateTime dateTime = DateTime.parse(isoString);
    return DateFormat('yyyy년 MM월 dd일').format(dateTime); // "yyyy-MM-dd" 형식으로 날짜 표시
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _chatSubscription?.cancel(); // 화면이 종료될 때 리스너를 해제합니다.
    _channel.sink.close(); // WebSocket 연결 닫기
    super.dispose();
  }

  void _scrollToBottom() {
    // 스크롤 가능한 상태인지 확인 후 실행
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> fetchUserInfo() async {
    String? accessToken = await readAccess();
    Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken!);
    userId = decodedToken['userId'];// 사용자 ID 가져오기

    final url = Uri.http(
      address,
      "/api/users",
    );
    try {
      final response = await http.get(
        url,
        headers: {'access': '$accessToken'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          userProfile = jsonData["fileName"];
          userName = jsonData["userName"];
        });
        print(userName);

      } else if(response.statusCode == 401) {
        bool success = await reissueToken(context);
        if(success) {
          await fetchUserInfo();
        } else {
          print('토큰 재발급 실패');
        }
      }
      else {
        print('실패 Failed to load data${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _loadMessages() async {



    String chatRoomId = userId < widget.friendId
        ? '$userId\_${widget.friendId}'
        : '${widget.friendId}\_$userId';


    List<Map<String, dynamic>> savedMessages = await FriendChatDatabaseHelper().getMessages(chatRoomId);

    setState(() {
      _messages = savedMessages.map((message) {
        print("메시지$message");
        return ChatMessage(
          sender: message['sender'],
          text: message['message'],
          time: formatTime(message['timestamp']),
          date: formatDate(message['timestamp']),
          isMine: message['userId'] == userId,
          profileImageName: message['userId'] == userId
              ? userProfile
              : widget.friendProfile,
        );
      }).toList();
    });
  }

  Future<void> _connectWebSocket() async {
    print("연결 실행");
    String? accessToken = await readAccess();


    final headers = {
      'access': '$accessToken', // 헤더에 토큰 추가
    };
    try {
      String chatRoomId = userId < widget.friendId
          ? '$userId\_${widget.friendId}'
          : '${widget.friendId}\_$userId';
      _channel = IOWebSocketChannel.connect(
        Uri.parse('ws://116.47.60.159:8080/friendChat?chatRoomId=$chatRoomId'),
        headers: headers,
      );

      // 수신된 메시지를 처리합니다.
      _channel.stream.listen((message) async {
        print("WebSocket 연결 성공!");
        final decodedMessage = jsonDecode(message);
        print("디코드 메시지$decodedMessage");

        await FriendChatDatabaseHelper().insertMessage({
          'chatRoomId': chatRoomId,
          'userId': decodedMessage['senderId'], // 발신자 ID
          'sender': decodedMessage['senderName'], // 발신자 이름
          'message': decodedMessage['content'], // 메시지 내용
          'timestamp': decodedMessage['sendTime'], // 현재 시간을 저장
        });

        if (mounted) {
          setState(() {
            print("메시지: ${decodedMessage['content']}");
            _messages.add(ChatMessage(
              sender: decodedMessage['senderName'],
              text: decodedMessage['content'],
              time: formatTime(decodedMessage['sendTime']),
              date: formatDate(decodedMessage['sendTime']),
              isMine: decodedMessage['senderId'] == userId,
              profileImageName: decodedMessage['senderId'] == userId
                  ? userProfile
                  : widget.friendProfile,
            ));

          });
        }

        _scrollToBottom();
      }, onError: (error) {
        print("WebSocket 연결 실패: $error");
      }, onDone: () {
        print("WebSocket 연결이 종료되었습니다.");

      }, cancelOnError: true);
    } catch (e) {
      print("WebSocket 연결 중 예외 발생: $e");
    }
  }

  void _sendMessage(String text) {
    if (text.isEmpty) return;

    // 서버로 전송할 메시지 형식
    final message = {
      "content": text,
      "senderName": userName, // 실제 본인 이름으로 변경
      "sendTime": DateTime.now().toUtc().add(Duration(hours: 9)).toIso8601String(), // 현재 시간을 ISO8601 형식으로 전송
    };

    // 서버로 메시지를 보냅니다.
    _channel.sink.add(jsonEncode(message));

    // 로컬에서도 메시지를 추가합니다.

    print("메시지 전송됨: $text");

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,

        title: Text('${widget.friendName}'),

      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus(); // <-- 가상 키보드 숨기기
              },
              child: Align(
                alignment: Alignment.topCenter,
                child: ListView.builder(
                  shrinkWrap: true,
                  reverse: true,  // ListView가 역순으로 메시지를 표시하도록 설정
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    // 역순으로 접근하므로, 리스트의 뒤에서부터 접근
                    final message = _messages[_messages.length - 1 - index];
                    final previousMessage = index < _messages.length - 1
                        ? _messages[_messages.length - 2 - index]
                        : null;

                    final bool hideProfile = previousMessage != null &&
                        previousMessage.sender == message.sender &&
                        previousMessage.time == message.time;

                    // 역순 접근이므로 다음 메시지와 비교해야 함
                    final bool isNewDate = (index == _messages.length - 1) ||
                        message.date != _messages[_messages.length - 2 - index].date;



                    final bool showTime = index == 0 ||
                        message.time != _messages[_messages.length - index].time ||
                        message.sender != _messages[_messages.length - index].sender;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isNewDate) ...[
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                message.date,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                        ChatMessageWidget(
                          message: message,
                          showTime: showTime,
                          hideProfile: hideProfile,),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          const Divider(
            color: Color(0xffEEFAF8),
            height: 0.5,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4.0, 10.0, 0.0, 10.0),
            child: Row(
              children: [
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/clip.svg',
                    width: 30,
                    height: 30,
                  ),
                  onPressed: () {
                    // 버튼이 눌렸을 때의 동작
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: '메시지를 입력하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0), // 둥근 모서리 설정
                        borderSide: BorderSide.none, // 테두리 없앰
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16.0),
                      fillColor: Color(0xFFF3F6F6),
                      filled: true,
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/camera2.svg',
                    width: 30,
                    height: 30,
                  ),
                  onPressed: () {
                    // 버튼이 눌렸을 때의 동작
                  },
                ),
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/send.svg',
                    height: 30,
                  ),
                  onPressed: () {
                    _sendMessage(_controller.text);
                    FocusScope.of(context).unfocus();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String sender;
  final String text;
  final String time;
  final String date; // 추가된 필드
  final bool isMine;
  final String? image;
  final String? profileImageName;

  const ChatMessage({
    required this.sender,
    required this.text,
    required this.time,
    required this.date, // 추가된 필드
    required this.isMine,
    this.image,
    this.profileImageName
  });
}

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget({
    required this.message,
    required this.showTime,
    required this.hideProfile,
    Key? key,
  }) : super(key: key);

  final ChatMessage message;
  final bool showTime;
  final bool hideProfile;// 시간을 표시할지 여부를 제어하는 속성

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isMine)
            hideProfile
                ? SizedBox(width: 40.0, height: 40.0) // 프로필 이미지 공간을 차지하는 빈 공간
                : PublicImage(
              imageUrl: message.profileImageName != null
                  ? message.profileImageName!
                  : "https://www.pngarts.com/files/10/Default-Profile-Picture-PNG-Download-Image.png",
              placeholderPath: 'assets/icons/loading.gif',
              width: 40.0, // 원하는 크기로 조정하세요
              height: 40.0, // 원하는 크기로 조정하세요
              fit: BoxFit.cover, // 이미지 맞춤 설정
              isCircular: true, // 원형으로 표시
            ),
          const SizedBox(width: 8.0),
          Flexible(
            child: Column(
              crossAxisAlignment: message.isMine
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!message.isMine && !hideProfile)
                  Text(
                    message.sender,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                SizedBox(height: 4.0),
                Row(
                  mainAxisAlignment: message.isMine
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    if (showTime && message.isMine) // 자신의 메시지인 경우 시간을 왼쪽에 표시
                      Padding(
                        padding: const EdgeInsets.only(top:20.0,right: 8.0),
                        child: Text(
                          message.time,
                          style: const TextStyle(
                            fontSize: 10.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.6,
                        ),
                        decoration: BoxDecoration(
                          color: message.isMine
                              ? Color(0xff20A090)
                              : Color(0xffF2F7FB),
                          borderRadius: message.isMine
                              ? const BorderRadius.only(
                            topLeft: Radius.circular(12.0),
                            topRight: Radius.circular(0),
                            bottomLeft: Radius.circular(12.0),
                            bottomRight: Radius.circular(12.0),
                          )
                              : const BorderRadius.only(
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(12.0),
                            bottomLeft: Radius.circular(12.0),
                            bottomRight: Radius.circular(12.0),
                          ),
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: message.isMine ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    if (showTime && !message.isMine) // 자신의 메시지가 아닌 경우 시간을 오른쪽에 표시
                      Padding(
                        padding: const EdgeInsets.only(top:20.0,left: 8.0),
                        child: Text(
                          message.time,
                          style: const TextStyle(
                            fontSize: 10.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
                if (message.image != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.asset(
                      message.image!,
                      width: 200.0,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
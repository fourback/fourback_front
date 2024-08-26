import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';

import '../../auth.dart';

class GroupChatScreen extends StatefulWidget {


  GroupChatScreen();

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  StompClient? stompClient;
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  Future<void> _connectWebSocket() async {
    String? accessToken = await readAccess();
    Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken!);

    // 사용자 ID 가져오기
    int userId = decodedToken['userId'];

    final headers = {
      'access': '$accessToken', // 헤더에 토큰 추가
    };
    try{
      _channel = IOWebSocketChannel.connect(
        Uri.parse('ws://116.47.60.159:8080/groupChat?studyGroupId=1'),
        headers: headers,
      );


      // 수신된 메시지를 처리합니다.
      _channel.stream.listen((message) {
        print("WebSocket 연결 성공!");
        final decodedMessage = jsonDecode(message);
        int senderId = decodedMessage['senderId'];
        print("$senderId");
        setState(() {
          _messages.add(ChatMessage(
            sender: decodedMessage['senderName'],
            text: decodedMessage['content'],
            time: "몇시",
            studyGroupName: decodedMessage['studyGroupName'] ?? 'Unknown Group',
            isMine: senderId != userId,
            // 사용자 본인 여부 판단
          ));
        });
      }, onError: (error) {
        print("WebSocket 연결 실패: $error");
      },
        onDone: () {
          print("WebSocket 연결이 종료되었습니다.");
        },
        cancelOnError: true,
      );
    } catch (e) {
      print("WebSocket 연결 중 예외 발생: $e");
    }







  }


  void _sendMessage(String text) {
    if (text.isEmpty) return;

    // 서버로 전송할 메시지 형식
    final message = {
      "content": text,
      "senderName": "김현수", // 실제 본인 이름으로 변경
      "sendTime": DateTime.now().toIso8601String(), // 현재 시간을 ISO8601 형식으로 전송
      "studyGroupName": "스터디 그룹 이름" // 스터디 그룹 이름을 실제로 변경
    };

    // 서버로 메시지를 보냅니다.
    _channel.sink.add(jsonEncode(message));

    // 로컬에서도 메시지를 추가합니다.

    print("메시지 전송됨: $text");

    _controller.clear();
  }


  final List<ChatMessage> messages = const [
    ChatMessage(
      sender: '김민재',
      text: '감사합니다!',
      time: '09:25 AM',
      isMine: false, studyGroupName: '',
    ),
    ChatMessage(
      sender: '손홍민',
      text: '디자인 이거 어때요?',
      time: '09:25 AM',
      isMine: false,
      image: 'assets/icons/ex1.png', studyGroupName: '', // 이미지 경로
    ),
    ChatMessage(
      sender: '김연아',
      text: '좋아요',
      time: '09:25 AM',
      isMine: false, studyGroupName: '',
    ),
    ChatMessage(
      sender: '나',
      text: 'ㅇㅇ 꽤 괜찮',
      time: '09:25 AM',
      isMine: true, studyGroupName: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('선릉역 모각코 모임'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatMessageWidget(message: message);
              },
            ),
          ),
          const Divider(
            color: Color(0xffEEFAF8),
            height: 0.5,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4.0,10.0,0.0,10.0),
            child: Row(
              children: [
                IconButton(
                  icon:  SvgPicture.asset('assets/icons/clip.svg',width: 30,height: 30,),
                  // 아이콘 크기 조정
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
                  icon:  SvgPicture.asset('assets/icons/camera2.svg',width: 30,height: 30,),
                  // 아이콘 크기 조정
                  onPressed: () {
                    // 버튼이 눌렸을 때의 동작
                  },
                ),
                IconButton(
                  icon:  SvgPicture.asset('assets/icons/send.svg',height: 30,),
                  // 아이콘 크기 조정
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
  final String studyGroupName;
  final bool isMine;
  final String? image;

  const ChatMessage({
    required this.sender,
    required this.text,
    required this.time,
    required this.isMine,
    required this.studyGroupName,
    this.image,
  });
}

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget({required this.message, Key? key}) : super(key: key);

  final ChatMessage message;

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
            CircleAvatar(
              child: Text(message.sender[0]),
            ),
          const SizedBox(width: 8.0),
          Column(
            crossAxisAlignment: message.isMine
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (!message.isMine)
                Text(
                  message.sender,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              SizedBox(height: 6.0,),

              Container(
                padding: const EdgeInsets.all(10.0),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6, // 화면 너비의 70%로 설정
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
              if (message.image != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Image.asset(
                    message.image!,
                    width: 200.0,
                  ),
                ),
              const SizedBox(height: 4.0),
              Text(
                message.time,
                style: const TextStyle(
                  fontSize: 10.0,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
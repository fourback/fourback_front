import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'post_list_screen.dart';
import '/api_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/write.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'dart:io';







Future<String?> readJwt() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('USERID');
}

class WriteScreen extends StatefulWidget {
  final int boardId;
  final String boardName;
  WriteScreen(this.boardId,this.boardName);
  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<WriteScreen> {

  TextEditingController _textEditingController = TextEditingController();
  TextEditingController _textEditingController2 = TextEditingController();
  List<File> images = [];

  Future<void> _sendTextToAPI(Write textModel) async {
    // 여기에 API 엔드포인트를 적절히 설정하세요.
    String apiUrl = '${ApiUrl.baseUrl}/api/post';
    String? token = await readJwt();
    final url = Uri.parse('${ApiUrl.baseUrl}/api/post');
    final request = http.MultipartRequest('POST', url);

    request.fields['title'] = textModel.title;
    request.fields['content'] = textModel.content;
    request.fields['boardId'] = textModel.boardId.toString();

    request.headers['authorization'] = '$token';


    if (images.isNotEmpty) {
      for (var image in images) {

        request.files.add(await http.MultipartFile.fromPath(
          'images', // Assuming your server expects an array of images under the key 'images'
          image.path,
        ));
      }

    }


    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        print('텍스트가 성공적으로 전송되었습니다.');
      } else {
        print('API 요청이 실패했습니다.');
      }
    } catch (e) {
      print('오류: $e');
    }

    // try {
    //   final response = await http.post(
    //     Uri.parse(apiUrl),
    //     headers: <String, String>{
    //       'Content-Type': 'application/json; charset=UTF-8',
    //       'authorization': '$token'
    //     },
    //
    //     body: jsonEncode(textModel.toJson()),
    //   );
    //
    //   if (response.statusCode == 200) {
    //     // 성공적으로 API에 데이터를 전송한 경우 처리할 내용
    //     print('텍스트가 성공적으로 전송되었습니다.');
    //   } else {
    //     // API 요청이 실패한 경우 처리할 내용
    //     print('API 요청이 실패했습니다.');
    //   }
    // } catch (e) {
    //   // 오류 발생 시 처리
    //   print('오류: $e');
    // }
  }

  void _removeImage(int index) {
    setState(() {
      images.removeAt(index);
    });
  }

  Future<void> pickImages() async {
    if (images.length >= 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진은 최대 9장까지 첨부할 수 있어요.')),
      );
      return;
    }

    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      List<File> tempImages = [];
      for (var pickedFile in pickedFiles) {
        final mimeType = lookupMimeType(pickedFile.path);
        if (images.length + tempImages.length >= 9) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('사진은 최대 9장까지 첨부할 수 있어요.')),
          );
          break;
        }
        if (mimeType != null && mimeType.startsWith('image/')) {
          tempImages.add(File(pickedFile.path));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('이미지 파일을 업로드 해주세요.')),
          );
        }

      }
      setState(() {
        images.addAll(tempImages);
      });
    }

  }



  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(

      appBar: AppBar(
        title: Text('글쓰기', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,),),
        centerTitle: true,
        shape: Border(
          bottom: BorderSide(
            color: Color(0xffe9ecef),
            width: 1.3,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.black,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 8.0),
            child: ElevatedButton(
              onPressed: ()  async {
                String inputText = _textEditingController.text;
                String inputText2 = _textEditingController2.text;

                // 모델을 사용하여 텍스트를 래핑하여 API로 전송
                await _sendTextToAPI(Write(inputText,inputText2,widget.boardId));
                // 입력 후에는 텍스트 필드를 초기화합니다.
                _textEditingController.clear();
                _textEditingController2.clear();
                Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
                Navigator.push(context, MaterialPageRoute(builder: (context) => PostListScreen(widget.boardName, widget.boardId)));

              },
              child: Text('완료', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14, color:Colors.white)),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder( // 네모낳게 만드는 부분
                  borderRadius: BorderRadius.circular(3), // 여기서 원하는 네모낳은 정도를 조절할 수 있습니다.
                ),
                minimumSize: Size.zero,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                backgroundColor: Color(0xff7C3AED),

              ),

            ),
          )


        ],

        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(

        padding: EdgeInsets.only(top: 10.0, left: 20.0, right:20.0 , bottom:20.0),
        child: Column(
          children: <Widget>[
            TextField(
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                decorationThickness: 0,
              ),
              controller: _textEditingController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '제목',
                hintStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFADB5BD)
                ),
              ),
            ),
            Divider(),
            TextFormField(
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: TextStyle(
                  decorationThickness: 0
              ),
              controller: _textEditingController2,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '내용을 입력하세요',
                hintStyle: TextStyle(
                    color: Color(0xFFADB5BD)
                ),
              ),
            ),



            images.isEmpty
                ? SizedBox.shrink()
                :


            Column(
                  children: [
                    Container(

                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: images.asMap().entries.map((entry) {
                          int index = entry.key;
                          File image = entry.value;
                          return Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),

                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16.0),
                                  child: FadeInImage(
                                    placeholder: AssetImage('assets/icons/loading.gif'),
                                    image: FileImage(image),
                                    width: screenSize.width / 3 - 10,
                                    height: screenSize.height / 6 - 10,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                child: IconButton(
                                  icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                                  onPressed: () => _removeImage(index),
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    ),
                    Row(
                      children: [
                        Spacer(),
                        Text("${images.length} / 9",style: TextStyle(fontWeight: FontWeight.bold),),
                      ],
                    ),
                  ],
                ),

          ],

        ),

      ),
      backgroundColor: Colors.white,

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(width: 1.3, color: Color(0xffe9ecef)), // 위쪽 선을 추가합니다.
          ),
        ),

        child: Padding(

          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // 왼쪽 이미지 버튼
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/add_photo.svg',
                  color: Color(0xff7C3AED),
                  width: 30,
                  height: null,
                ),
                onPressed: pickImages,

              ),
            ],
          ),

        ),

      ),

      resizeToAvoidBottomInset: true,

    );

  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
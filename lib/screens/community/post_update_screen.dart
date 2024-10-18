import 'dart:convert';

import 'package:bemajor_frontend/auth.dart';
import 'package:bemajor_frontend/publicImage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'post_list_screen.dart';
import '/api_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/write.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'dart:io';
import '/models/post.dart';


class ImageItem {
  final File? file;
  final String? url;

  ImageItem({this.file, this.url});
}





class PostUpdateScreen extends StatefulWidget {
  final Post post;
  PostUpdateScreen(this.post);
  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<PostUpdateScreen> {

  TextEditingController _textEditingController = TextEditingController();
  TextEditingController _textEditingController2 = TextEditingController();
  List<ImageItem> images = [];
  List<String> deletedImages = [];
  @override
  void initState() {
    super.initState();
    // 기존 게시글 데이터로 텍스트 필드 초기화
    _textEditingController.text = widget.post.title;
    _textEditingController2.text = widget.post.content;
    images.addAll(widget.post.imageName.map((imageName) => ImageItem(url: imageName)));
  }

  Future<void> _deleteImage(List<String> fileNames) async {
    final url = Uri.parse('${ApiUrl.baseUrl}/api/post/${widget.post.id}/images/}');
    String? token = await readAccess();
    final response = await http.delete(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'access': '$token'
        },
        body: jsonEncode(fileNames),
    );

    if (response.statusCode == 200) {
      print('이미지가 삭제되었습니다');
    } else if(response.statusCode == 401) {
      bool success = await reissueToken(context);
      if(success) {
        await _deleteImage(fileNames);
      } else {
        print('토큰 재발급 실패');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 삭제 오류')),
      );
    }
  }

  Future<void> _updatePost(Write textModel) async {
    String? token = await readAccess();
    final url = Uri.parse('${ApiUrl.baseUrl}/api/post/${widget.post.id}');
    final request = http.MultipartRequest('PATCH', url);

    request.fields['title'] = textModel.title;
    request.fields['content'] = textModel.content;

    request.headers['access'] = '$token';


    if (images.isNotEmpty) {
      for (var image in images) {
        if(image.file != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'images', // Assuming your server expects an array of images under the key 'images'
            image.file!.path,
          ));
        }


      }

    }


    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        print('텍스트가 성공적으로 전송되었습니다.');
        if(deletedImages.isNotEmpty) {
          await _deleteImage(deletedImages);
        }

      } else if(response.statusCode == 401) {
        bool success = await reissueToken(context);
        if(success) {
          await _updatePost(textModel);
        } else {
          print('토큰 재발급 실패');
        }
      }else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수정에 실패하였습니다.')),
        );
      }
    } catch (e) {
      print('오류: $e');
    }

  }

  void _removeImage(int index) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          elevation: 0,
          content: Text('삭제하시겠습니까?',style: TextStyle(fontSize: 18)),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('삭제'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      if (images[index].url != null) {
        Uri uri = Uri.parse(images[index].url!);
        deletedImages.add(uri.pathSegments.last);
      }
      setState(() {
        images.removeAt(index);
      });
    }

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
      List<ImageItem> tempImages = [];
      for (var pickedFile in pickedFiles) {
        final mimeType = lookupMimeType(pickedFile.path);
        if (images.length + tempImages.length >= 9) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('사진은 최대 9장까지 첨부할 수 있어요.')),
          );
          break;
        }
        if (mimeType != null && mimeType.startsWith('image/')) {
          tempImages.add(ImageItem(file: File(pickedFile.path)));
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
        title: Text('글 수정', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,),),
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
                if(inputText.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('제목을 입력해주세요.'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                } else if(inputText2.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('내용을 입력해주세요.'),
                      duration: Duration(seconds: 1),
                    ),

                  );
                } else {
                  await _updatePost(Write(inputText,inputText2,null));
                  Navigator.pop(context, true);


                }

                // 모델을 사용하여 텍스트를 래핑하여 API로 전송
                //await _sendTextToAPI(Write(inputText,inputText2,widget.boardId));


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
                    child:


                    Row(
                      children: images.asMap().entries.map((entry) {
                        int index = entry.key;
                        ImageItem imageItem = entry.value;
                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),

                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.0),

                                child:imageItem.url != null
                                ?
                                PublicImage(
                                  placeholderPath: 'assets/icons/loading.gif',
                                  imageUrl: imageItem.url!,
                                  width: screenSize.width / 3 - 10,
                                  height: screenSize.height / 6 - 10,
                                  fit: BoxFit.cover,
                                  key: ValueKey(imageItem.url),
                                )
                                    : FadeInImage(
                                  placeholder: AssetImage('assets/icons/loading.gif'),
                                  image: FileImage(imageItem.file!),
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
    _textEditingController2.dispose();
    super.dispose();
  }
}
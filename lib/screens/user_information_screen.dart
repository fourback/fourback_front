import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bemajor_frontend/ip.dart';
import 'package:bemajor_frontend/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:bemajor_frontend/publicImage.dart';

import '../auth.dart';
import 'navigation_screen.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends State<UserInformationScreen> {
  var isLoading = false;
  late TextEditingController userNameController;
  late TextEditingController emailController;
  late TextEditingController birthController;
  late TextEditingController belongController;
  late TextEditingController departmentController;
  late TextEditingController hobbyController;
  late TextEditingController objectiveController;
  late TextEditingController addressController;
  late TextEditingController techStackController;
  String? userImage;
  final ImagePicker _picker = ImagePicker();
  XFile? selectImage;

  Future<void> _pickImg() async {
    XFile? image = await _picker.pickImage(
      source: ImageSource.gallery, //위치는 갤러리
      maxHeight: 150,
      maxWidth: 150,
    );
    if (image != null) {
      setState(() {
        selectImage = image;
      });
    }
    uploadImage(image!);
  }

  Future<void> fetchUserInfo() async {
    setState(() {
      isLoading = true;
    });
    String? accessToken = await readAccess();

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
        final Map<String, dynamic> jsonData =
            jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          userImage = jsonData["imageUrl"];
          userNameController.text = jsonData["userName"] ?? "";
          emailController.text = jsonData["email"] ?? "";
          birthController.text = jsonData["birth"] ?? "";
          belongController.text = jsonData["belong"] ?? "";
          departmentController.text = jsonData["department"] ?? "";
          hobbyController.text = jsonData["hobby"] ?? "";
          objectiveController.text = jsonData["objective"] ?? "";
          addressController.text = jsonData["address"] ?? "";
          techStackController.text = jsonData["techStack"] ?? "";
          print(userImage);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('실패 Failed to load data${response.body}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  Future<void> sendUserInfo() async {
    String? accessToken = await readAccess();
    /*
    * ***
    * multipartfile 보내는 양식으로 고쳐야 함
    * */
    final url = Uri.http(
      address,
      "api/users",
    );
    final headers = {
      "Content-Type": "application/json",
      'access': '$accessToken'
    };
    final body = {
      "userName": userNameController.text,
      "email": emailController.text,
      "birth": birthController.text,
      "belong": belongController.text,
      "department": departmentController.text,
      "hobby": hobbyController.text,
      "objective": objectiveController.text,
      "address": addressController.text,
      "techStack": techStackController.text
    };

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        print('Data sent successfully');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => navigationScreen()),
        );
      } else {
        print('${response.body} Failed to send data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> uploadImage(XFile image) async {
    String? accessToken = await readAccess();
    final url = Uri.http(
      address,
      "api/users/image",
    );
    var request = http.MultipartRequest('POST', url);
    request.headers['access'] = '$accessToken';
    /*  ***
      access token, refresh token 없애는 로직 구현
      + 헤더에 access token, refresh token 전송해줘야 함
     */
    request.files.add(await http.MultipartFile.fromPath('file', image.path));
    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        setState(() {
          userImage = responseBody;
        });
        print('upload successfully');
        print(userImage);
      } else {
        print('Failed');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> deleteImage() async {
    if (userImage == null || userImage!.isEmpty) {
      print('No image to delete');
      return;
    }

    String? accessToken = await readAccess();
    final url = Uri.http(
      address,
      "api/users/image",
    );

    final headers = {
      "Content-Type": "application/json",
      'access': '$accessToken',
    };

    try {
      final response = await http.delete(
        url,
        headers: headers,
        body: jsonEncode({"fileName": userImage}),
      );

      if (response.statusCode == 200) {
        setState(() {
          selectImage = null;
          userImage = null; // 이미지 삭제 후 기본 이미지로 변경
          print('State updated: userImage set to null');
        });
      } else {
        print('Failed to delete image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during image deletion: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
    userNameController = TextEditingController();
    emailController = TextEditingController();
    birthController = TextEditingController();
    belongController = TextEditingController();
    departmentController = TextEditingController();
    hobbyController = TextEditingController();
    objectiveController = TextEditingController();
    addressController = TextEditingController();
    techStackController = TextEditingController();
  }

  @override
  void dispose() {
    userNameController.dispose();
    emailController.dispose();
    birthController.dispose();
    belongController.dispose();
    departmentController.dispose();
    hobbyController.dispose();
    objectiveController.dispose();
    addressController.dispose();
    techStackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: Text('프로필 등록',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
            children: [
              Container(
                height: constraints.maxHeight * 0.3, // 30% of the screen height
                child: Center(
                  child: Stack(
                    children: [
                      // 사용자가 이미지를 선택했을 경우
                      selectImage != null
                          ? Container(
                        width: 160, // 크기를 일관되게 유지합니다.
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, // 이미지를 원형으로 만듭니다.
                          border: Border.all(
                            color: Color(0xff242760), // 원하는 테두리 색상
                            width: 2.0, // 테두리 두께
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0), // 이미지와 테두리 사이의 여백 추가
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle, // 이미지를 원형으로 만듭니다.
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: FileImage(File(selectImage!.path)),
                              ),
                            ),
                          ),
                        ),
                      )
                      // 사용자가 이미지를 선택하지 않았을 경우

                          : Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color(0xff242760),  // 원하는 테두리 색상
                            width: 2.0, // 테두리 두께
                          ),
                        ),

                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: PublicImage(
                            imageUrl: () {
                              final url = userImage != null
                                  ? userImage!
                                  : "https://www.pngarts.com/files/10/Default-Profile-Picture-PNG-Download-Image.png";

                              print('Image URL: $url'); // URL을 출력
                              return url;
                            }(),
                            placeholderPath: 'assets/icons/loading.gif',
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                            isCircular: true,
                          ),
                        ),
                      ),

                      // 이미지 선택 또는 삭제 버튼
                      Positioned(
                        bottom: 0, // 하단 중앙에 배치됩니다.
                        right: 0,
                        child: IconButton(
                          onPressed: userImage == null ? _pickImg : deleteImage,
                          icon: CircleAvatar(
                            radius: 20, // 아이콘 배경의 크기 설정
                            backgroundColor: userImage == null ? Color(0xff242760) : Color(0xff242760), // 배경색 설정
                            child: Icon(
                              userImage == null ? Icons.camera_alt : Icons.close,
                              color: userImage != null ? Colors.white : Colors.white, // 아이콘 색상 설정
                              size: 24, // 아이콘 크기 설정
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      title: Text(
                        "이름",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: TextField(
                        style: TextStyle(color: Colors.black),
                        controller: userNameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),

                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "이메일",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: TextField(
                        style: TextStyle(color: Colors.black),
                        controller: emailController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),

                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "대학교/소속기관",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: TextField(
                        style: TextStyle(color: Colors.black),
                        controller: belongController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),

                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "생년월일",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: TextField(
                        style: TextStyle(color: Colors.black),
                        controller: birthController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),

                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "학과",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: TextField(
                        style: TextStyle(color: Colors.black),
                        controller: departmentController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),

                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "취미",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: TextField(
                        style: TextStyle(color: Colors.black),
                        controller: hobbyController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),

                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "희망 직무",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: TextField(
                        style: TextStyle(color: Colors.black),
                        controller: objectiveController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),

                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "거주 지역",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: TextField(
                        style: TextStyle(color: Colors.black),
                        controller: addressController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),

                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "기술 스택",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: TextField(
                        style: TextStyle(color: Colors.black),
                        controller: techStackController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),

                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 16.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      children: [

                        SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (userNameController.text.trim().isEmpty ||
                                emailController.text.trim().isEmpty ||
                                birthController.text.trim().isEmpty ||
                                belongController.text.trim().isEmpty ||
                                departmentController.text.trim().isEmpty ||
                                hobbyController.text.trim().isEmpty ||
                                objectiveController.text.trim().isEmpty ||
                                addressController.text.trim().isEmpty ||
                                techStackController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('필수 정보를 모두 입력해주세요.'),
                                  duration: Duration(seconds: 1),
                                ),

                              );
                              return;
                            } else {
                              sendUserInfo();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              minimumSize: Size(200, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              backgroundColor: Colors.black),
                          child: const Text(
                            '프로필 등록',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

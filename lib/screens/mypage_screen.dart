import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bemajor_frontend/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:bemajor_frontend/publicImage.dart';

import '../auth.dart';

class MypageScreen extends StatefulWidget {
  const MypageScreen({super.key});

  @override
  State<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
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
      imageQuality: 70, // 이미지 크기 압축을 위해 퀄리티를 30으로 낮춤.
    );
    if (image != null) {
      setState(() {
        selectImage = image;
      });
    }
    uploadImage(image!);
  }

  Future<void> fetchUserInfo() async {
    if (isLoading) return;
    String? accessToken = await readAccess();

    final url = Uri.http(
      "116.47.60.159:8080",
      "user",
      {
        "username": "naver123",
      },
    );
    try {
      final response = await http.get(
        url,
        headers: {'access': '$accessToken'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          userNameController.text = jsonData["userName"] ?? "";
          emailController.text = jsonData["email"] ?? "";
          birthController.text = jsonData["birth"] ?? "";
          belongController.text = jsonData["belong"] ?? "";
          departmentController.text = jsonData["department"] ?? "";
          hobbyController.text = jsonData["hobby"] ?? "";
          objectiveController.text = jsonData["objective"] ?? "";
          addressController.text = jsonData["address"] ?? "";
          techStackController.text = jsonData["techStack"] ?? "";
          userImage = jsonData["imageName"];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  Future<void> sendUserInfo() async {
    /*
    * ***
    * multipartfile 보내는 양식으로 고쳐야 함
    * */
    final url = Uri.http(
      "116.47.60.159:8080",
      "user",
      {
        "username": "naver123",
        "userName": userNameController.text,
        "email": emailController.text,
        "birth": birthController.text,
        "belong": belongController.text,
        "department": departmentController.text,
        "hobby": hobbyController.text,
        "objective": objectiveController.text,
        "address": addressController.text,
        "techStack": techStackController.text
      },
    );
    final headers = {"Content-Type": "application/json"};
    try {
      final response = await http.put(url, headers: headers);
      if (response.statusCode == 200) {
        print('Data sent successfully');
      } else {
        print('Failed to send data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> logout() async {
    final url = Uri.http(
      "116.47.60.159:8080",
      "logout",
    );
    /*  ***
      access token, refresh token 없애는 로직 구현
      + 헤더에 access token, refresh token 전송해줘야 함
     */
    final headers = {"Content-Type": "application/json", };
    try {
      final response = await http.post(
        url,
        headers: headers,
      );
      if (response.statusCode == 200) {
        print('logout successfully');
      } else {
        print('Failed logout');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> uploadImage(XFile image) async {
    String? accessToken = await readAccess();
    final url = Uri.http(
      "116.47.60.159:8080",

      "api/users/image",


    );
    var request = http.MultipartRequest('POST', url);
    request.headers['access'] = '$accessToken';
    /*  ***
      access token, refresh token 없애는 로직 구현
      + 헤더에 access token, refresh token 전송해줘야 함
     */
    request.files.add(
      await http.MultipartFile.fromPath('file', image.path)
    );
    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        setState(() {
          userImage=responseBody;
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
    String? accessToken = await readAccess();
    final url = Uri.http(
      "116.47.60.159:8080",

      "api/users/image",
    );
    /*  ***
      access token, refresh token 없애는 로직 구현
      + 헤더에 access token, refresh token 전송해줘야 함
     */
    final headers = {"Content-Type": "application/json", 'access': '$accessToken'};
    try {
      final response = await http.delete(
        url,
        headers: headers,
        body: jsonEncode([userImage])
      );
      if (response.statusCode == 200) {
        setState(() {
          selectImage=null;
          userImage=null;
        });
        print('delete successfully');
      } else {
        print("${response.body},${response.statusCode}");
        print('Failed');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    userNameController = TextEditingController();
    emailController = TextEditingController();
    birthController = TextEditingController();
    belongController = TextEditingController();
    departmentController = TextEditingController();
    hobbyController = TextEditingController();
    objectiveController = TextEditingController();
    addressController = TextEditingController();
    techStackController = TextEditingController();
    fetchUserInfo();
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

        title: Text('프로필',
            style: TextStyle(
              fontSize: 25,fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
      ),
      body:LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
            children: [
              Container(
                height: constraints.maxHeight * 0.3, // 30% of the screen height
                child: Center(
                  child: Stack(
                    children: [
                      userImage != null
                          ? PublicImage(
                        imageUrl:
                        'http://116.47.60.159:8080/api/images/$userImage',
                        placeholderPath: 'assets/icons/loading.gif',
                        width: 150,

                        fit: BoxFit.cover,
                        isCircular: true,
                      )
                          : selectImage == null
                          ? Image.asset("assets/icons/basic_image.png")
                          : Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(
                              File(selectImage!.path),
                            ),
                          ),
                        ),
                      ),

                      if(userImage != null)
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () {
                              print("asdasd");
                              deleteImage();
                            },
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ),
                        ),

                      Positioned(
                        top: 140,
                        left: 140,
                        child: TextButton(
                          onPressed: userImage==null? _pickImg:deleteImage,
                          child: userImage == null
                              ? Image.asset(
                            'assets/icons/camera.png',
                            width: 50,
                          )
                              : Image.asset(
                            'assets/icons/x.png',
                            color: Colors.red,
                            width: 50,
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
                        controller: userNameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '이름',
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
                        controller: emailController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '이메일',
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
                        controller: belongController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '대학교/소속기관',
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
                        controller: birthController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '생년월일',
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
                        controller: departmentController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '학과',
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
                        controller: hobbyController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '취미',
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
                        controller: objectiveController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '희망 직무',
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
                        controller: addressController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '거주 지역',
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
                        controller: techStackController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '기술 스택',
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
                        ElevatedButton(
                          onPressed: logout,
                          style: ElevatedButton.styleFrom(
                              minimumSize: Size(200, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              backgroundColor:
                              const Color.fromARGB(255, 211, 44, 44)),
                          child: const Text(
                            '로그아웃',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: sendUserInfo,
                          style: ElevatedButton.styleFrom(
                              minimumSize: Size(200, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              backgroundColor: Colors.black),
                          child: const Text(
                            '프로필 변경',
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
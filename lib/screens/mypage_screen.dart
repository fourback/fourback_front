import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:bemajor_frontend/publicImage.dart';

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
      maxHeight: 75,
      maxWidth: 75,
      imageQuality: 30, // 이미지 크기 압축을 위해 퀄리티를 30으로 낮춤.
    );
    if (image != null) {
      setState(() {
        selectImage = image;
      });
    }
  }

  Future<void> fetchUserInfo() async {
    if (isLoading) return;
    final url = Uri.http(
      "localhost:8080",
      "user",
      {
        "username": "naver123",
      },
    );
    try {
      final response = await http.get(url);
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
      "localhost:8080",
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
    final headers = {"Content-Type": "multipart/form-data"};
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
      "localhost:8080",
      "logout",
    );
    /*  ***
      access token, refresh token 없애는 로직 구현
      + 헤더에 access token, refresh token 전송해줘야 함
     */
    final headers = {"Content-Type": "application/json"};
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

  Future<void> deleteImage() async {
    final url = Uri.http(
      "localhost:8080",
      "image",
      {
        "fileNames": [userImage],
      },
    );
    /*  ***
      access token, refresh token 없애는 로직 구현
      + 헤더에 access token, refresh token 전송해줘야 함
     */
    final headers = {"Content-Type": "application/json"};
    try {
      final response = await http.delete(
        url,
        headers: headers,
      );
      if (response.statusCode == 200) {
        setState(() {
          selectImage=null;
          userImage=null;
        });
        print('delete successfully');
      } else {
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
      body: ListView(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {}, // 이전 화면으로 이동해줘야 함 ***
              child: const Text(
                '<',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
            ),
          ),
          Center(
            child: isLoading
                ? const CircularProgressIndicator()
                : Column(
              children: [
                const Text(
                  '프로필',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
                Stack(
                  children: [
                    userImage != null
                        ? PublicImage(
                      imageUrl:
                      'http://localhost:8080/image/$userImage',
                      placeholderPath: 'assets/icons/loading.gif',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
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
                    Positioned(
                      top: 70,
                      left: 80,
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
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 350,
                  height: 30,
                  child: TextField(
                    controller: userNameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '이름',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 16.0),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 350,
                  height: 30,
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '이메일',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 16.0),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 350,
                  height: 30,
                  child: TextField(
                    controller: belongController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '대학교/소속기관',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 16.0),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 350,
                  height: 30,
                  child: TextField(
                    controller: birthController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '생년월일',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 16.0),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 350,
                  height: 30,
                  child: TextField(
                    controller: departmentController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '학과',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 16.0),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 350,
                  height: 30,
                  child: TextField(
                    controller: hobbyController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '취미',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 16.0),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 350,
                  height: 30,
                  child: TextField(
                    controller: objectiveController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '희망 직무',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 16.0),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 350,
                  height: 30,
                  child: TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '거주 지역',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 16.0),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 350,
                  height: 30,
                  child: TextField(
                    controller: techStackController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '기술 스택',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 16.0),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: logout, // 이 부분 대신 로그인 페이지로 이동과 같이 바꿔야함 ***
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
                const SizedBox(
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
          ),
        ],
      ),
    );
  }
}

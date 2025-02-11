/*class UserInfo {
  UserInfo({
    required this.userID,
  });

  final String userID;
}*/
import 'dart:ffi';

class UserInfo {
  UserInfo(
      {required this.userId,
        required this.userName,
        required this.email,
        required this.birth,
        required this.belong,
        required this.department,
        required this.hobby,
        required this.objective,
        required this.address,
        required this.techStack,
        required this.imageUrl});

  final int userId;
  final String userName;
  final String? email;
  final String? birth;
  final String? belong;
  final String? department;
  final String? hobby;
  final String? objective;
  final String? address;
  final String? techStack;
  final String? imageUrl;

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      userId: json['userId'],
      userName: json['userName'],
      email:json['email'],
      birth:json['birth'],
      belong:json['belong'],
      department:json['department'],
      hobby:json['hobby'],
      objective:json['objective'],
      address:json['address'],
      techStack:json['techStack'],
      imageUrl:json['imageUrl'],
    );
  }

  factory UserInfo.fromJson2(Map<String, dynamic> json) {
    return UserInfo(
      userId: json['userId'],
      userName: json['name'],
      imageUrl:json['profileImage'], email: '', birth: ''
        '', belong:json['belong'], department:json['department'], hobby: '', objective: '', address: '', techStack: '',
    );
  }
  @override
  String toString() {
    return 'UserInfo{id: $userId, name: $userName, email: $email $imageUrl}';
  }
}




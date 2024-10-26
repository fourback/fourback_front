class UserInviteFriend {
  final int userId;
  final String userName;
  final String imageUrl;
  final String belong;
  final String department;

  UserInviteFriend({
  required this.userId,
  required this.userName,
    required this.imageUrl,
    required this.belong,
    required this.department,
  });

  factory UserInviteFriend.fromJson(Map<String, dynamic> json) {
    return UserInviteFriend(
        userId: json['userId'],
        userName: json['userName'],
      imageUrl: json['imageUrl'] ?? "",
      belong: json['belong'],
      department: json['department'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId' : userId,
      'userName': userName,
      'imageUrl': imageUrl,
      'belong': belong,
      'department': department,
    };
  }

}
class UserInvitateFriend {
  final int userId;
  final String userName;

  UserInvitateFriend({
  required this.userId,
  required this.userName,});

  factory UserInvitateFriend.fromJson(Map<String, dynamic> json) {
    return UserInvitateFriend(
        userId: json['userId'],
        userName: json['userName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId' : userId,
      'userName': userName,
    };
  }

}
class UserInviteFriend {
  final int userId;
  final String userName;

  UserInviteFriend({
  required this.userId,
  required this.userName,});

  factory UserInviteFriend.fromJson(Map<String, dynamic> json) {
    return UserInviteFriend(
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
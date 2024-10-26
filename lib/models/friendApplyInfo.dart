class FriendApplyInfo {
  final int applyId;
  final int userId;
  final int friendId;
  final String friendName;
  final String? friendImage;
  final String belong;
  final String department;

  FriendApplyInfo({
  required this.applyId,
  required this.userId,
  required this.friendId,
  required this.friendName,
  required this.friendImage,
    required this.belong,
    required this.department,
  });

  factory FriendApplyInfo.fromJson(Map<String, dynamic> json) {
    return FriendApplyInfo(
        applyId: json['applyId'],
        userId: json['userId'],
        friendId:json['friendId'],
        friendName: json['friendName'],
        friendImage:json['friendImage'] ?? "",
      belong: json['belong'],
      department: json['department'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applyId' : applyId,
      'userId': userId,
      'friendId': friendId,
      'friendName': friendName,
      'friendImage': friendImage
    };
  }

}
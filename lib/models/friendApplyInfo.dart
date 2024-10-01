class FriendApplyInfo {
  final int applyId;
  final int userId;
  final int friendId;
  final String friendName;
  final String? friendImage;

  FriendApplyInfo({
  required this.applyId,
  required this.userId,
  required this.friendId,
  required this.friendName,
  required this.friendImage});

  factory FriendApplyInfo.fromJson(Map<String, dynamic> json) {
    return FriendApplyInfo(
        applyId: json['applyId'],
        userId: json['userId'],
        friendId:json['friendId'],
        friendName: json['friendName'],
        friendImage:json['friendImage']
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
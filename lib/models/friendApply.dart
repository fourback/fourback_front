class FriendApply {
  final int userId;
  final int friendId;

  FriendApply(this.userId,this.friendId);

  Map<String, dynamic> toJson() {
    return {
      'userId' : userId,
      'friendId': friendId,
    };
  }
}
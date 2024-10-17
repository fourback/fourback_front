class FriendApply {
  final int friendId;

  FriendApply(this.friendId);

  Map<String, dynamic> toJson() {
    return {
      'friendId': friendId,
    };
  }
}
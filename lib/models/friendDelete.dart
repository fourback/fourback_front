class FriendDelete {
  final int friendId;

  FriendDelete(this.friendId);

  Map<String, dynamic> toJson() {
    return {
      'friendId': friendId,
    };
  }
}
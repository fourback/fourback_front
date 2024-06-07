class CommentResult {
  final int id;
  final String content;
  final String userName;
  final int goodCount;
  final String commentDate;
  final int postId;
  final int parentId;
  final Map<String, dynamic> reply;

  CommentResult({
  required this.id,
  required this.userName,
  required this.content,
  required this.goodCount,
  required this.commentDate,
  required this.postId,
  required this.parentId,
  required this.reply
  });

  factory CommentResult.fromJson(Map<String, dynamic> json) {
  return CommentResult(
  id: json['id'],
  userName: json['userName'],
  content: json['content'],
  goodCount: json['goodCount'],
  commentDate: json['commentDate'],
  postId: json['postId'],
  parentId: json['parentId'],
  reply: json['reply'],
  );
  }

  Map<String, dynamic> toJson() {
  return {
  'id': id,
  'userName': userName,
    'content': content,
  'goodCount': goodCount,
  'commentDate': commentDate,
    'postId': postId,
    'parentId': parentId,
    'reply': reply
  };
  }
  }
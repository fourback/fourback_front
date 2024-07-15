class CommentResult {
  final int id;
  final String content;
  final int goodCount;
  final String commentDate;
  final int postId;
  final int parentId;
  final String? dateDiff;
  final bool isFavorite;
  final int status;
  final bool userCheck;

  final Map<String, dynamic>? reply;
  final Map<String, dynamic>? user;

  CommentResult({
  required this.id,
  required this.content,
  required this.goodCount,
  required this.commentDate,
  required this.postId,
  required this.parentId,
  required this.dateDiff,
  required this.isFavorite,
  required this.status,
  required this.reply,
  required this.user,
  required this.userCheck
  });

  factory CommentResult.fromJson(Map<String, dynamic> json) {
  return CommentResult(
  id: json['id'],
  content: json['content'],
  goodCount: json['goodCount'],
  commentDate: json['commentDate'],
  postId: json['postId'],
  parentId: json['parentId'],
  dateDiff: json['dateDiff'],
  isFavorite: json['favorite'],
  status: json['status'],
  reply: json['reply'],
  user: json['user'],
  userCheck: json['userCheck']
  );
  }

  Map<String, dynamic> toJson() {
  return {
  'id': id,
  'content': content,
  'goodCount': goodCount,
  'commentDate': commentDate,
  'postId': postId,
  'parentId': parentId,
  'dateDiff': dateDiff,
  'status': status,
  'Favorite': isFavorite,
  'reply': reply,
  'user': user,
   'userCehck': userCheck
  };
  }
  }
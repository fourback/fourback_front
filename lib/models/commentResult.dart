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

  final String? profileImage;
  final String? userName;
  final String? email;
  final String? birth;
  final String? oauth2Id;
  final String? role;
  final String? belong;
  final String? department;

  final Map<String, dynamic>? reply;

  CommentResult({
    required this.id,
    required this.profileImage,
    required this.content,
    required this.goodCount,
    required this.commentDate,
    required this.postId,
    required this.parentId,
    required this.dateDiff,
    required this.isFavorite,
    required this.status,
    required this.reply,
    required this.userCheck,
    required this.userName,
    required this.email,
    required this.birth,
    required this.oauth2Id,
    required this.role,
    required this.belong,
    required this.department
  });

  factory CommentResult.fromJson(Map<String, dynamic> json) {
    return CommentResult(
      id: json['id'],
      profileImage: json['profileImage'],
      content: json['content'],
      goodCount: json['goodCount'],
      commentDate: json['commentDate'],
      postId: json['postId'],
      parentId: json['parentId'],
      dateDiff: json['dateDiff'],
      isFavorite: json['favorite'],
      status: json['status'],
      reply: json['reply'],
      userCheck: json['userCheck'],
      userName: json['userName'],
      email: json['email'],
      birth: json['birth'],
      oauth2Id: json['oauth2Id'],
      role: json['role'],
      belong: json['belong'],
      department: json['department'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'profileImage': profileImage,
      'goodCount': goodCount,
      'commentDate': commentDate,
      'postId': postId,
      'parentId': parentId,
      'dateDiff': dateDiff,
      'status': status,
      'Favorite': isFavorite,
      'reply': reply,
      'userCehck': userCheck,
      'userName': userName,
      'email': email,
      'birth': birth,
      'oauth2Id': oauth2Id,
      'role': role,
      'belong': belong,
      'department': department,
    };
  }
}
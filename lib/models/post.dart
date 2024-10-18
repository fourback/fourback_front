class Post {
  final int id;
  String title;
  String content;
  final String memberName;
  final String belong;
  final String department;
  final String profileImage;
  int goodCount;
  int commentCount;
  int viewCount;
  String postDate;
  List<String> imageName;
  bool postGood;
  final String boardName;
  final bool userCheck;

  Post({required this.id,required this.title, required this.content,required this.memberName,
    required this.goodCount,required this.commentCount,required this.viewCount,required this.postDate,
    required this.imageName,required this.postGood,required this.boardName,required this.userCheck,
    required this.belong, required this.department, required this.profileImage});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        memberName: json['memberName'],
        belong: json['belong'] ?? '',
        department: json['department'] ?? '',
        profileImage: json['profileImage'] ?? '',
        goodCount: json['goodCount'],
        commentCount: json['commentCount'],
        viewCount: json['viewCount'],
        postDate: json['postDate'],
        imageName: List<String>.from(json['imageUrl'] ?? []),
        postGood:  json['postGood'],
        boardName: json['boardName'],
        userCheck: json['userCheck'],
    );
  }
}
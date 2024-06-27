class Post {
  final int id;
  String title;
  String content;
  final String memberName;
  final int goodCount;
  final int commentCount;
  final int viewCount;
  String postDate;
  List<String> imageName;

  Post({required this.id,required this.title, required this.content,required this.memberName,
    required this.goodCount,required this.commentCount,required this.viewCount,required this.postDate,
    required this.imageName});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        memberName: json['memberName'],
        goodCount: json['goodCount'],
        commentCount: json['commentCount'],
        viewCount: json['viewCount'],
        postDate: json['postDate'],
        imageName: List<String>.from(json['imageName'] ?? []),
    );
  }
}
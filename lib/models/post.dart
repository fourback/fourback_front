class Post {
  final int id;
  final String title;
  final String content;
  final String memberName;
  final int goodCount;
  final int commentCount;
  final int viewCount;
  final String postDate;

  Post({required this.id,required this.title, required this.content,required this.memberName,
    required this.goodCount,required this.commentCount,required this.viewCount,required this.postDate});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        memberName: json['memberName'],
        goodCount: json['goodCount'],
        commentCount: json['commentCount'],
        viewCount: json['viewCount'],
        postDate: json['postDate']
    );
  }
}
class PostSearch {
  final int id;
  final String title;
  final String content;
  final String memberName;
  final int goodCount;
  final int commentCount;
  final int viewCount;
  final String postDate;
  final String boardName;

  PostSearch({required this.id,required this.title, required this.content,required this.memberName,
    required this.goodCount,required this.commentCount,required this.viewCount,required this.postDate, required this.boardName});

  factory PostSearch.fromJson(Map<String, dynamic> json) {
    return PostSearch(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        memberName: json['memberName'],
        goodCount: json['goodCount'],
        commentCount: json['commentCount'],
        viewCount: json['viewCount'],
        postDate: json['postDate'],
        boardName: json['boardName']
    );
  }
}
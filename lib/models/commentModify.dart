class CommentModify {
  final int commentId;
  final String content;

  CommentModify(this.commentId, this.content);

  Map<String, dynamic> toJson() {
    return {
      'commentId' : commentId,
      'content': content,
    };
  }
}
class CommentWrite {
  final int postId;
  final String content;
  final int parentCommentId;

  CommentWrite(this.postId, this.content,this.parentCommentId);

  Map<String, dynamic> toJson() {
    return {
      'title' : postId,
      'content': content,
      'boardId' : parentCommentId,
    };
  }
}
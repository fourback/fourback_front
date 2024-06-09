class CommentWrite {
  final int postId;
  final String content;
  final int parentCommentId;

  CommentWrite(this.postId, this.content,this.parentCommentId);

  Map<String, dynamic> toJson() {
    return {
      'postId' : postId,
      'content': content,
      'parentCommentId' : parentCommentId,
    };
  }
}
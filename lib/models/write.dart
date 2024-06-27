class Write {
  final String content;
  final String title;
  final int? boardId;

  Write(this.title, this.content,this.boardId);

  Map<String, dynamic> toJson() {
    return {
      'title' : title,
      'content': content,
      'boardId' : boardId,
    };
  }
}
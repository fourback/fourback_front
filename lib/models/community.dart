class FavoriteBoard {

  final String boardName;
  FavoriteBoard(this.boardName);

  Map<String, dynamic> toJson() {
    return {
      'boardName': boardName,
    };
  }
}

class BoardDto {
  final int id;
  final String boardName;
  bool isfavorite ;

  BoardDto({required this.id,required this.boardName,this.isfavorite = false});

  factory BoardDto.fromJson(Map<String, dynamic> json) {
    return BoardDto(
      id: json['id'],
      boardName: json['boardName'],
      isfavorite: json['isfavorite'] ?? false,
    );
  }
}
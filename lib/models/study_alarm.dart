class StudyGroupApplicationResponse {
  final int? studyApplicationId;
  final String userName;
  final String imageUrl;
  final String belong;
  final String department;

  StudyGroupApplicationResponse({required this.studyApplicationId, required this.userName,
    required this.imageUrl,required this.belong,required this.department,});

  // fromJson 메서드를 통해 JSON 데이터를 객체로 변환
  factory StudyGroupApplicationResponse.fromJson(Map<String, dynamic> json) {
    return StudyGroupApplicationResponse(
      studyApplicationId: json['id'],  // id 필드를 studyApplicationId로 매핑
      userName: json['userName'],
        imageUrl: json['imageUrl'] ?? "",
        belong: json['belong'],
        department: json['department']
    );
  }
}
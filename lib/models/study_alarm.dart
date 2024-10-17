class StudyGroupApplicationResponse {
  final int? studyApplicationId;
  final String userName;

  StudyGroupApplicationResponse({required this.studyApplicationId, required this.userName});

  // fromJson 메서드를 통해 JSON 데이터를 객체로 변환
  factory StudyGroupApplicationResponse.fromJson(Map<String, dynamic> json) {
    return StudyGroupApplicationResponse(
      studyApplicationId: json['id'],  // id 필드를 studyApplicationId로 매핑
      userName: json['userName'],      // userName 필드를 userName으로 매핑
    );
  }
}
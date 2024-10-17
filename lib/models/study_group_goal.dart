class StudyGroupGoalResponse {
  final int studyGroupGoalId;
  final String name;
  final String endDate;
  final int percentage;

  StudyGroupGoalResponse({
    required this.studyGroupGoalId,
    required this.name,
    required this.endDate,
    required this.percentage,
  });


  factory StudyGroupGoalResponse.fromJson(Map<String, dynamic> json) {
    return StudyGroupGoalResponse(
      studyGroupGoalId: json['studyGroupGoalId'],
      name: json['name'],
      endDate: json['endDate'],
      percentage: json['percentage'],
    );
  }
}

class StudyGroupGoalDetailResponse {
  final int id;
  final String name;
  final bool checked;

  StudyGroupGoalDetailResponse({
    required this.id,
    required this.name,
    required this.checked,
  });


  factory StudyGroupGoalDetailResponse.fromJson(Map<String, dynamic> json) {
    return StudyGroupGoalDetailResponse(
      id: json['id'],
      name: json['name'],
      checked: json['checked'],
    );
  }
}
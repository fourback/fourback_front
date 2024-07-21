class StudyGroup {
  final int id;
  final String studyName;
  final DateTime startDate;
  final DateTime endDate;
  final int teamSize;
  final String studyLocation;
  final String category;
  final String studyCycle;
  final String studyRule;
  final String ownerOauth2Id;

  StudyGroup({
    required this.id,
    required this.studyName,
    required this.startDate,
    required this.endDate,
    required this.teamSize,
    required this.studyLocation,
    required this.category,
    required this.studyCycle,
    required this.studyRule,
    required this.ownerOauth2Id,
  });

  factory StudyGroup.fromJson(Map<String, dynamic> json) {
    return StudyGroup(
      id: json['id'],
      studyName: json['studyName'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      teamSize: json['teamSize'],
      studyLocation: json['studyLocation'],
      category: json['category'],
      studyCycle: json['studyCycle'],
      studyRule: json['studyRule'],
      ownerOauth2Id: json['ownerOauth2Id'],
    );
  }
}
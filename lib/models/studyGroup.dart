import 'dart:convert';

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
  final List<String> studySchedule;
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
    required this.studySchedule,
    required this.ownerOauth2Id,
  });

  factory StudyGroup.fromJson(Map<String, dynamic> json) {
    return StudyGroup(
      id: json['id'],
      studyName: json['studyName'] ?? '',
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : DateTime.now(),
      teamSize: json['teamSize'] ?? 0,
      studyLocation: json['studyLocation'] ?? '',
      category: json['category'] ?? '',
      studyCycle: json['studyCycle'] ?? '',
      studyRule: json['studyRule'] ?? '',
      studySchedule: json['studySchedule'] != null
          ? List<String>.from(json['studySchedule'].map((item) => item.toString())) // 명시적 변환
          : [],
      ownerOauth2Id: json['ownerOauth2Id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studyName': studyName,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'teamSize': teamSize,
      'studyLocation': studyLocation,
      'category': category,
      'studyCycle': studyCycle,
      'studyRule': studyRule,
      'ownerOauth2Id': ownerOauth2Id,
    };
  }
}
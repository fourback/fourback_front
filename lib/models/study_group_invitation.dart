class StudyGroupInvitation {
  final int invitationId;
  final String studyName;
  final String category;
  final String studyLocation;
  final String studyCycle;

  StudyGroupInvitation({
    required this.invitationId,
    required this.studyName,
    required this.category,
    required this.studyLocation,
    required this.studyCycle,
  });

  factory StudyGroupInvitation.fromJson(Map<String, dynamic> json) {
    return StudyGroupInvitation(
      invitationId: json['invitationId'],
      studyName: json['studyName'],
      category: json['category'],
      studyLocation: json['studyLocation'],
      studyCycle: json['studyCycle'],
    );
  }
}
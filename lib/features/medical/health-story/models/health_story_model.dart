import 'dart:convert';

class HealthStoryModel {
  final String healthStoryId;
  final String doctorId;
  final String title;
  final String description;
  final int createdAt;
  final String? thumbnail;

  HealthStoryModel({
    required this.healthStoryId,
    required this.doctorId,
    required this.title,
    required this.description,
    required this.createdAt,
    this.thumbnail,
  });

  Map<String, dynamic> toJson() {
    return {
      "healthStoryId": healthStoryId,
      "doctorId": doctorId,
      "title": title,
      "description": description,
      "createdAt": createdAt,
    };
  }

  HealthStoryModel.fromJson(Map<String, dynamic> json)
      : healthStoryId = json["healthStoryId"],
        doctorId = json["doctorId"],
        title = json["title"],
        description = json["description"],
        createdAt = json["createdAt"],
        thumbnail = _toGetThumbnail(json["description"]);
}

String _toGetThumbnail(String description) {
  final List<dynamic> decoded = jsonDecode(description);
  final imageUrl = decoded
      .whereType<Map<String, dynamic>>()
      .map((e) => e['insert'])
      .whereType<Map<String, dynamic>>()
      .firstWhere((insert) => insert.containsKey('image'),
          orElse: () => {})['image'];
  return imageUrl;
}

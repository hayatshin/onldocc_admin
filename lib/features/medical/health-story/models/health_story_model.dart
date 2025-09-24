import 'dart:convert';

class HealthStoryModel {
  final String healthStoryId;
  final String doctorId;
  final String title;
  final String description;
  final int createdAt;
  final String? thumbnail;
  int? views;

  HealthStoryModel({
    required this.healthStoryId,
    required this.doctorId,
    required this.title,
    required this.description,
    required this.createdAt,
    this.thumbnail,
    this.views,
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
        thumbnail = toGetThumbnail(json["description"]),
        views = (json["health_story_views"]).length;
}

String? toGetThumbnail(String description) {
  try {
    final decoded = jsonDecode(description);

    if (decoded is! List) return null;

    for (final op in decoded) {
      if (op is! Map) continue;

      final insert = op['insert'];
      if (insert is Map) {
        final img = insert['image'];
        if (img is String && img.isNotEmpty) {
          return img;
        }
      }
    }
    return null;
  } catch (e) {
    return null;
  }
}

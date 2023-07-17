class CommentModel {
  final String userId;
  final String diaryId;
  final String commentId;
  final String description;
  final DateTime timestamp;

  CommentModel({
    required this.userId,
    required this.diaryId,
    required this.commentId,
    required this.description,
    required this.timestamp,
  });

  CommentModel.empty()
      : userId = "",
        diaryId = "",
        commentId = "",
        description = "",
        timestamp = DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "diaryId": diaryId,
      "commentId": commentId,
      "description": description,
      "timestamp": timestamp,
    };
  }

  CommentModel.fromJson(Map<String, dynamic> json)
      : userId = json["userId"],
        diaryId = json["diaryId"],
        commentId = json["commentId"],
        description = json["description"],
        timestamp = json["timestamp"];

  CommentModel copyWith({
    final String? userId,
    final String? diaryId,
    final String? commentId,
    final String? description,
    final DateTime? timestamp,
  }) {
    return CommentModel(
      userId: userId ?? this.userId,
      diaryId: diaryId ?? this.diaryId,
      commentId: commentId ?? this.commentId,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

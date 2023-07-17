class DiaryModel {
  final String userId;
  final String diaryId;
  final String monthDate;
  final DateTime timestamp;
  final bool secret;
  final List<String> images;
  final int numLikes;
  final int numComments;
  final String todayDiary;
  final List<String> blockedBy;

  DiaryModel({
    required this.userId,
    required this.diaryId,
    required this.monthDate,
    required this.timestamp,
    required this.secret,
    required this.images,
    required this.numLikes,
    required this.numComments,
    required this.todayDiary,
    required this.blockedBy,
  });

  DiaryModel.empty()
      : userId = "",
        diaryId = "",
        monthDate = "",
        timestamp = DateTime.now(),
        secret = false,
        images = [],
        numLikes = 0,
        numComments = 0,
        todayDiary = "",
        blockedBy = [];

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "diaryId": diaryId,
      "monthDate": monthDate,
      "timestamp": timestamp,
      "secret": secret,
      "images": images,
      "numLikes": numLikes,
      "numComments": numComments,
      "todayDiary": todayDiary,
      "blockedBy": blockedBy,
    };
  }

  DiaryModel.fromJson(Map<String, dynamic> json)
      : userId = json["userId"],
        diaryId = json["diaryId"],
        monthDate = json["monthDate"],
        timestamp = json["timestamp"],
        secret = json["secret"],
        images = json["images"],
        numLikes = json["numLikes"],
        numComments = json["numComments"],
        todayDiary = json["todayDiary"],
        blockedBy = json["blockedBy"];

  DiaryModel copyWith({
    final String? userId,
    final String? diaryId,
    final String? monthDate,
    final DateTime? timestamp,
    final bool? secret,
    final List<String>? images,
    final int? numLikes,
    final int? numComments,
    final String? todayDiary,
    final List<String>? blockedBy,
  }) {
    return DiaryModel(
      userId: userId ?? this.userId,
      diaryId: diaryId ?? this.diaryId,
      monthDate: monthDate ?? this.monthDate,
      timestamp: timestamp ?? this.timestamp,
      secret: secret ?? this.secret,
      images: images ?? this.images,
      numLikes: numLikes ?? this.numLikes,
      numComments: numComments ?? this.numComments,
      todayDiary: todayDiary ?? this.todayDiary,
      blockedBy: blockedBy ?? this.blockedBy,
    );
  }
}

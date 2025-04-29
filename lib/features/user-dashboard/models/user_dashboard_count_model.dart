class UserDashboardCountModel {
  final String id;
  final int? diaryTodayMood;
  final bool? quizCorrect;

  UserDashboardCountModel({
    required this.id,
    this.diaryTodayMood,
    this.quizCorrect,
  });

  UserDashboardCountModel.from(Map<String, dynamic> json)
      : id = json.containsKey("diaryId")
            ? json["diaryId"]
            : json.containsKey("commentId")
                ? json["commentId"]
                : json.containsKey("likeId")
                    ? json["likeId"]
                    : json.containsKey("quizId")
                        ? json["quizId"]
                        : "",
        diaryTodayMood = json.containsKey("todayMood") ? json["todayMood"] : 0,
        quizCorrect = json.containsKey("correct") ? json["correct"] : false;
}

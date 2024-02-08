class QuizModel {
  final String userId;
  final String diaryId;
  final int createdAt;
  final bool correct;
  final String quiz;
  final int quizAnswer;
  final int userAnswer;
  final String userSubdistrictId;
  final String userContractCommunityId;

  QuizModel({
    required this.userId,
    required this.diaryId,
    required this.createdAt,
    required this.correct,
    required this.quiz,
    required this.quizAnswer,
    required this.userAnswer,
    required this.userSubdistrictId,
    required this.userContractCommunityId,
  });

  QuizModel.empty()
      : userId = "",
        diaryId = "",
        createdAt = 0,
        correct = false,
        quiz = "",
        quizAnswer = 0,
        userAnswer = 0,
        userSubdistrictId = "",
        userContractCommunityId = "";

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "diaryId": diaryId,
      "createdAt": createdAt,
      "correct": correct,
      "quiz": quiz,
      "realAnswer": quizAnswer,
      "userAnswer": userAnswer,
    };
  }

  QuizModel.fromJson(Map<String, dynamic> json)
      : userId = json["userId"] ?? "",
        diaryId = json["diaryId"] ?? "",
        createdAt = json["createdAt"] ?? 0,
        correct = json["correct"] ?? false,
        quiz = json["quiz"] ?? "",
        quizAnswer = json["quizAnswer"] ?? 0,
        userAnswer = json["userAnswer"] ?? 0,
        userSubdistrictId = json["users"]["subdistrictId"],
        userContractCommunityId = json["users"]["contactCommunityId"];
}

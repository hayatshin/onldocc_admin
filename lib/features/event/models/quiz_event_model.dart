class QuizEventModel {
  final String quizEventId;
  final String eventId;
  final String quiz;
  final String firstChoice;
  final String secondChoice;
  final String thirdChoice;
  final String fourthChoice;
  final int quizAnswer;

  QuizEventModel({
    required this.quizEventId,
    required this.eventId,
    required this.quiz,
    required this.firstChoice,
    required this.secondChoice,
    required this.thirdChoice,
    required this.fourthChoice,
    required this.quizAnswer,
  });

  QuizEventModel.empty()
      : quizEventId = "",
        eventId = "",
        quiz = "",
        firstChoice = "",
        secondChoice = "",
        thirdChoice = "",
        fourthChoice = "",
        quizAnswer = 0;

  Map<String, dynamic> toJson() {
    return {
      "quizEventId": quizEventId,
      "eventId": eventId,
      "quiz": quiz,
      "firstChoice": firstChoice,
      "secondChoice": secondChoice,
      "thirdChoice": thirdChoice,
      "fourthChoice": fourthChoice,
      "quizAnswer": quizAnswer,
    };
  }

  QuizEventModel.fromJson(Map<String, dynamic> json)
      : quizEventId = json["quizEventId"] ?? "",
        eventId = json["eventId"] ?? "",
        quiz = json["quiz"] ?? "",
        firstChoice = json["firstChoice"] ?? "",
        secondChoice = json["secondChoice"] ?? "",
        thirdChoice = json["thirdChoice"] ?? "",
        fourthChoice = json["fourthChoice"] ?? "",
        quizAnswer = json["quizAnswer"] ?? 0;
}

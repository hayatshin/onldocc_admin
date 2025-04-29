import 'package:onldocc_admin/utils.dart';

class UserDashboardQuizModel {
  final String date;
  final String quiz;
  final int quizAnswer;
  final int userAnswer;
  final bool isUserAnswerCorrect;

  UserDashboardQuizModel({
    required this.date,
    required this.quiz,
    required this.quizAnswer,
    required this.userAnswer,
    required this.isUserAnswerCorrect,
  });

  UserDashboardQuizModel.fromMath(Map<String, dynamic> json)
      : date = secondsToStringLine(json["createdAt"]),
        quiz = json["quiz"],
        quizAnswer = json["quizAnswer"],
        userAnswer = json["userAnswer"],
        isUserAnswerCorrect = json["correct"];

  UserDashboardQuizModel.fromMultipleChoices(Map<String, dynamic> json)
      : date = secondsToStringLine(json["createdAt"]),
        quiz = json["quizzes_multiple_choices_db"]["quiz"],
        quizAnswer = json["quizzes_multiple_choices_db"]["quizAnswer"],
        userAnswer = json["userAnswer"],
        isUserAnswerCorrect = json["correct"];

  String toMathString() {
    return '''
    UserMathQuizModel(date: $date, quiz: $quiz, quizAnswer: $quizAnswer, userAnswer: $userAnswer, isUserAnswerCorrect: $isUserAnswerCorrect)
    ''';
  }

  String toMultipleString() {
    return '''
    UserMultipleChoicesQuizModel(date: $date, quiz: $quiz, quizAnswer: $quizAnswer, userAnswer: $userAnswer, isUserAnswerCorrect: $isUserAnswerCorrect)
    ''';
  }
}

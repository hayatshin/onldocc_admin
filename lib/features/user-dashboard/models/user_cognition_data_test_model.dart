import 'package:onldocc_admin/features/ca/consts/cognition_test_questionnaire.dart';
import 'package:onldocc_admin/features/ca/view/self_test_screen.dart';
import 'package:onldocc_admin/utils.dart';

class UserCognitionDataTestModel {
  final String date;
  final String testType;
  final String testTypeDesc;
  final List<Questionnaire> userQuestionnaire;
  final String? result;

  UserCognitionDataTestModel({
    required this.date,
    required this.testType,
    required this.testTypeDesc,
    required this.userQuestionnaire,
    this.result,
  });

  UserCognitionDataTestModel.from(Map<String, dynamic> json)
      : date = secondsToStringLine(json["createdAt"]),
        testType = json["testType"],
        testTypeDesc = testTypes
            .where((test) => test.testType == json["testType"])
            .toList()[0]
            .testName,
        userQuestionnaire =
            iterateQuestionnaire(json["testType"], (json["userAnswers"])),
        result = json["result"];

  @override
  String toString() {
    return '''
    UserSelfExaminationData(date: $date, testType: $testTypeDesc, userQuestionnaire: $userQuestionnaire, result: $result)
    ''';
  }
}

List<Questionnaire> iterateQuestionnaire(
    String testType, Map<String, dynamic> userAnswers) {
  final List<Questionnaire> questionnaires = userAnswers.entries.map((entry) {
    final quizIndex = int.parse((entry.key).replaceAll("a", ""));
    String quiz = "";
    switch (testType) {
      case "alzheimer_test":
        quiz = alzheimer_questionnaire_strings[quizIndex];
        break;
      case "depression_test":
        quiz = depression_questionnaire_strings[quizIndex];
        break;
      case "stress_test":
        quiz = stressQuestionnaireStrings[quizIndex];
        break;
      case "anxiety_test":
        quiz = anxietyQuestionnaireStrings[quizIndex];
        break;
      case "trauma_test":
        quiz = traumaQuestionnaireStrings[quizIndex];
        break;
      case "esteem_test":
        quiz = esteemQuestionnaireStrings[quizIndex];
        break;
      case "sleep_test":
        quiz = sleepQuestionnaireStrings[quizIndex];
        break;
    }

    return Questionnaire(quiz: quiz, answer: entry.value);
  }).toList();
  return questionnaires;
}

class Questionnaire {
  final String quiz;
  final bool answer;

  Questionnaire({required this.quiz, required this.answer});
}

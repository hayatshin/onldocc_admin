import 'package:cloud_firestore/cloud_firestore.dart';

class CaModel {
  final String userId;
  final String diaryId;
  final DateTime timestamp;
  final bool recognitionResult;
  final String recognitionQuestion;
  final String realAnswer;
  final String userAnswer;

  CaModel({
    required this.userId,
    required this.diaryId,
    required this.timestamp,
    required this.recognitionResult,
    required this.recognitionQuestion,
    required this.realAnswer,
    required this.userAnswer,
  });

  CaModel.empty()
      : userId = "",
        diaryId = "",
        timestamp = DateTime.now(),
        recognitionResult = false,
        recognitionQuestion = "",
        realAnswer = "",
        userAnswer = "";

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "diaryId": diaryId,
      "timestamp": timestamp,
      "recognitionResult": recognitionResult,
      "recognitionQuestion": recognitionQuestion,
      "realAnswer": realAnswer,
      "userAnswer": userAnswer,
    };
  }

  CaModel.fromJson(Map<String, dynamic> json)
      : userId = json["userId"] ?? "",
        diaryId = json["diaryId"] ?? "",
        timestamp = (json["timestamp"] as Timestamp).toDate(),
        recognitionResult = json["recognitionResult"] ?? false,
        recognitionQuestion = json["recognitionQuestion"] ?? "",
        realAnswer = json["realAnswer"] ?? "",
        userAnswer = json["userAnswer"] ?? "";
}

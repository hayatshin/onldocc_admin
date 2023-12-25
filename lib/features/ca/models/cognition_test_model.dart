import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onldocc_admin/utils.dart';

class CognitionTestModel {
  final String testType;
  final String testId;
  final String userId;
  final String timestamp;
  final List<dynamic> answerList;
  final int totalPoint;
  final String result;
  final String? userName;
  final String? userGender;
  final String? userAge;
  final String? userPhone;

  CognitionTestModel({
    required this.testType,
    required this.testId,
    required this.userId,
    required this.timestamp,
    required this.answerList,
    required this.totalPoint,
    required this.result,
    this.userName,
    this.userGender,
    this.userAge,
    this.userPhone,
  });

  CognitionTestModel.fromJson(Map<String, dynamic> json)
      : testType = json.containsKey("testType") ? json["testType"] : "",
        testId = json.containsKey("testId") ? json["testId"] : "",
        userId = json.containsKey("userId") ? json["userId"] : "",
        timestamp = json.containsKey("timestamp")
            ? convertTimettampToStringDateTime(
                (json["timestamp"] as Timestamp).toDate())
            : "",
        answerList = json.containsKey("answerList") ? json["answerList"] : [],
        totalPoint = json.containsKey("totalPoint") ? json["totalPoint"] : 0,
        result = json.containsKey("result") ? json["result"] : "",
        userName = "",
        userGender = "",
        userAge = "",
        userPhone = "";

  CognitionTestModel copyWith({
    String? userName,
    String? userGender,
    String? userAge,
    String? userPhone,
  }) {
    return CognitionTestModel(
      testType: testType,
      testId: testId,
      userId: userId,
      timestamp: timestamp,
      answerList: answerList,
      totalPoint: totalPoint,
      result: result,
      userName: userName ?? this.userName,
      userGender: userGender ?? this.userGender,
      userAge: userAge ?? this.userAge,
      userPhone: userPhone ?? this.userPhone,
    );
  }
}

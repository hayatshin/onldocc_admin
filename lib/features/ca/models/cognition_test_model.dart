import 'package:onldocc_admin/utils.dart';

class CognitionTestModel {
  final String testType;
  final String testId;
  final String userId;
  final int createdAt;
  final Map<String, bool> userAnswers;
  final int totalPoint;
  final String result;
  final String? userName;
  final String? userGender;
  final String? userAge;
  final String? userPhone;
  final String userSubdistrictId;
  final String userContractCommunityId;

  CognitionTestModel({
    required this.testType,
    required this.testId,
    required this.userId,
    required this.createdAt,
    required this.userAnswers,
    required this.totalPoint,
    required this.result,
    this.userName,
    this.userGender,
    this.userAge,
    this.userPhone,
    required this.userSubdistrictId,
    required this.userContractCommunityId,
  });

  CognitionTestModel.fromJson(Map<String, dynamic> json)
      : testType = json.containsKey("testType") ? json["testType"] : "",
        testId = json.containsKey("testId") ? json["testId"] : "",
        userId = json.containsKey("userId") ? json["userId"] : "",
        createdAt = json["createdAt"],
        userAnswers = json.containsKey("userAnswers")
            ? Map<String, bool>.from(json["userAnswers"])
            : {},
        totalPoint = json.containsKey("totalPoint") ? json["totalPoint"] : 0,
        result = json.containsKey("result") ? json["result"] : "",
        userName = json["users"]["name"] ?? "-",
        userGender = json["users"]["gender"] ?? "-",
        userAge = userAgeCalculation(
            json["users"]["birthYear"], json["users"]["birthDay"]),
        userPhone = json["users"]["phone"] ?? "-",
        userSubdistrictId = json["users"]['subdistrictId'] ?? "",
        userContractCommunityId = json["users"]["contractCommunityId"] ?? "";

  // CognitionTestModel copyWith({
  //   String? userName,
  //   String? userGender,
  //   String? userAge,
  //   String? userPhone,
  // }) {
  //   return CognitionTestModel(
  //     testType: testType,
  //     testId: testId,
  //     userId: userId,
  //     createdAt: createdAt,
  //     userAnswers: userAnswers,
  //     totalPoint: totalPoint,
  //     result: result,
  //     userName: userName ?? this.userName,
  //     userGender: userGender ?? this.userGender,
  //     userAge: userAge ?? this.userAge,
  //     userPhone: userPhone ?? this.userPhone,
  //   );
  // }
}

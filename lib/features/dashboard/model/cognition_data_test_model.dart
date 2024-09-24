import 'package:onldocc_admin/utils.dart';

class CognitionDataTestModel {
  final String userId;
  final String userSubdistrictId;
  final String userContractCommunityId;
  final String userName;
  final String userAge;
  final String userPhone;
  final String userGender;
  final String userAgeGroup;
  final String testId;
  final String testType;
  final String result;

  CognitionDataTestModel({
    required this.userId,
    required this.userSubdistrictId,
    required this.userContractCommunityId,
    required this.userName,
    required this.userAge,
    required this.userPhone,
    required this.userGender,
    required this.userAgeGroup,
    required this.testId,
    required this.testType,
    required this.result,
  });

  CognitionDataTestModel.from(Map<String, dynamic> json)
      : userId = json["users"]["userId"] ?? "",
        userSubdistrictId = json["users"]["subdistrictId"] ?? "",
        userContractCommunityId = json["users"]["contractCommunityId"] ?? "",
        userName = json["users"]["name"] ?? "",
        userAge = (json["users"]["birthYear"] != null) &&
                (json["users"]["birthDay"] != null)
            ? userAgeCalculation(
                json["users"]["birthYear"], json["users"]["birthDay"])
            : "50",
        userPhone = json["users"]["phone"] ?? "",
        userGender = json["users"]["gender"] ?? "남성",
        userAgeGroup = (json["users"]["birthYear"] != null) &&
                (json["users"]["birthDay"] != null)
            ? userAgeGroupCalculation(
                json["users"]["birthYear"], json["users"]["birthDay"])
            : "50대",
        testId = json.containsKey("testId") ? json["testId"] : "",
        testType = json.containsKey("testType") ? json["testType"] : "",
        result = json.containsKey("result") ? json["result"] : "";
}

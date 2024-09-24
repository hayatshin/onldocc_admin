import 'package:onldocc_admin/utils.dart';

class StepDataModel {
  final String date;
  final int step;
  final String userId;
  final String userSubdistrictId;
  final String userContractCommunityId;
  final String userGender;
  final String userAgeGroup;

  StepDataModel({
    required this.date,
    required this.step,
    required this.userId,
    required this.userSubdistrictId,
    required this.userContractCommunityId,
    required this.userGender,
    required this.userAgeGroup,
  });

  StepDataModel.from(Map<String, dynamic> json)
      : date = json.containsKey("date") ? json["date"] : "",
        step = json.containsKey("step") ? json["step"] : "",
        userId = json["users"]["userId"] ?? "",
        userSubdistrictId = json["users"]["subdistrictId"] ?? "",
        userContractCommunityId = json["users"]["contractCommunityId"] ?? "",
        userGender = json["users"]["gender"] ?? "남성",
        userAgeGroup = (json["users"]["birthYear"] != null) &&
                (json["users"]["birthDay"] != null)
            ? userAgeGroupCalculation(
                json["users"]["birthYear"], json["users"]["birthDay"])
            : "50대";
}

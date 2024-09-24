import 'package:onldocc_admin/utils.dart';

class DashboardCountModel {
  final String id;
  final String userId;
  final String userSubdistrictId;
  final String userContractCommunityId;
  final String userGender;
  final String userAgeGroup;
  final int? diaryTodayMood;
  final bool? quizCorrect;

  DashboardCountModel({
    required this.id,
    required this.userId,
    required this.userSubdistrictId,
    required this.userContractCommunityId,
    required this.userGender,
    required this.userAgeGroup,
    this.diaryTodayMood,
    this.quizCorrect,
  });

  DashboardCountModel.from(Map<String, dynamic> json)
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
        userId = json["users"]["userId"] ?? "",
        userSubdistrictId = json["users"]["subdistrictId"] ?? "",
        userContractCommunityId = json["users"]["contractCommunityId"] ?? "",
        userGender = json["users"]["gender"] ?? "남성",
        userAgeGroup = (json["users"]["birthYear"] != null) &&
                (json["users"]["birthDay"] != null)
            ? userAgeGroupCalculation(
                json["users"]["birthYear"], json["users"]["birthDay"])
            : "50대",
        quizCorrect = json.containsKey("correct") ? json["correct"] : false;
}

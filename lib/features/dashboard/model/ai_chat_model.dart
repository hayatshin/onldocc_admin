import 'package:onldocc_admin/utils.dart';

class AiChatModel {
  final String roomId;
  final int chatTime;
  final String userId;
  final String userSubdistrictId;
  final String userContractCommunityId;
  final String userGender;
  final String userAgeGroup;

  AiChatModel({
    required this.roomId,
    required this.chatTime,
    required this.userId,
    required this.userSubdistrictId,
    required this.userContractCommunityId,
    required this.userGender,
    required this.userAgeGroup,
  });

  AiChatModel.from(Map<String, dynamic> json)
      : roomId = json.containsKey("roomId") ? json["roomId"] : "",
        chatTime = json.containsKey("chatTime") ? json["chatTime"] : 0,
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

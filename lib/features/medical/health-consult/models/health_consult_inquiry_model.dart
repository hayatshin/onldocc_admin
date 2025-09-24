import 'package:onldocc_admin/features/medical/health-consult/models/health_consult_response_model.dart';
import 'package:onldocc_admin/utils.dart';

class HealthConsultInquiryModel {
  final String healthConsultInquiryId;
  final String userId;
  final String? userAvatar;
  final String? userName;
  final String? userAge;
  final String? userGender;
  final String? userPhone;
  final String? userFcmToken;
  final String title;
  final String inquiry;
  final int createdAt;
  final bool public;
  final List<String> images;
  final HealthConsultResponseModel? response;
  final int? views;

  HealthConsultInquiryModel({
    required this.healthConsultInquiryId,
    required this.userId,
    this.userAvatar,
    this.userName,
    this.userAge,
    this.userGender,
    this.userPhone,
    this.userFcmToken,
    required this.title,
    required this.inquiry,
    required this.createdAt,
    required this.public,
    required this.images,
    this.response,
    this.views,
  });

  Map<String, dynamic> toJson() {
    return {
      "healthConsultInquiryId": healthConsultInquiryId,
      "userId": userId,
      "title": title,
      "inquiry": inquiry,
      "createdAt": createdAt,
      "public": public,
    };
  }

  HealthConsultInquiryModel.fromJson(Map<String, dynamic> json)
      : healthConsultInquiryId = json["healthConsultInquiryId"],
        userId = json["userId"],
        userAvatar = json["users"]["avatar"],
        userName = json["users"]["name"],
        userAge = userAgeCalculation(
            json["users"]["birthYear"], json["users"]["birthDay"]),
        userGender = json["users"]["gender"],
        userPhone = json["users"]["phone"],
        userFcmToken = json["users"]["fcmToken"],
        title = json["title"],
        inquiry = json["inquiry"],
        createdAt = json["createdAt"],
        public = json["public"],
        images = spreadDiaryImages(json["health_consult_inquiry_images"]),
        response =
            spreadHealthConsultResponses(json["health_consult_responses"]),
        views = (json["health_consult_views"]).length;
}

HealthConsultResponseModel? spreadHealthConsultResponses(List data) {
  if (data.isEmpty) return null;
  final model = HealthConsultResponseModel.fromJson(data[0]);
  return model;
}

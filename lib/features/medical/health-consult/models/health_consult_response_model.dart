class HealthConsultResponseModel {
  final String healthConsultResponseId;
  final String healthConsultInquiryId;
  final String doctorId;
  final String response;
  final int createdAt;

  HealthConsultResponseModel({
    required this.healthConsultResponseId,
    required this.doctorId,
    required this.response,
    required this.createdAt,
    required this.healthConsultInquiryId,
  });

  Map<String, dynamic> toJson() {
    return {
      "healthConsultResponseId": healthConsultResponseId,
      "healthConsultInquiryId": healthConsultInquiryId,
      "doctorId": doctorId,
      "response": response,
      "createdAt": createdAt,
    };
  }

  HealthConsultResponseModel.fromJson(Map<String, dynamic> json)
      : healthConsultResponseId = json["healthConsultResponseId"],
        healthConsultInquiryId = json["healthConsultInquiryId"],
        doctorId = json["doctorId"],
        response = json["response"],
        createdAt = json["createdAt"];
}

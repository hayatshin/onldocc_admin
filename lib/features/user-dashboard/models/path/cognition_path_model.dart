import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';

class DahsboardDetailPathModel {
  final String? userId;
  final String? userName;
  final String? quizType;
  final DateRange? periodType;

  DahsboardDetailPathModel({
    required this.userId,
    required this.userName,
    required this.quizType,
    required this.periodType,
  });

  DahsboardDetailPathModel.fromJson(Map<String, dynamic> json)
      : userId = json["userId"],
        userName = json["userName"],
        quizType = json["quizType"],
        periodType = (json["periodType"] as DateRange);
}

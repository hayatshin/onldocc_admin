import 'package:onldocc_admin/common/models/mood_model.dart';
import 'package:onldocc_admin/utils.dart';

class UserDashboardDiaryModel {
  final String date;
  final int? diaryTodayMood;
  final String? todayMoodDesc;

  final String? todayDiary;

  UserDashboardDiaryModel({
    required this.date,
    this.diaryTodayMood,
    this.todayMoodDesc,
    this.todayDiary,
  });

  UserDashboardDiaryModel.from(Map<String, dynamic> json)
      : date = secondsToStringLine(json["createdAt"]),
        diaryTodayMood = json.containsKey("todayMood") ? json["todayMood"] : 0,
        todayMoodDesc = moodeList[(json["todayMood"])].description,
        todayDiary = json["todayDiary"];

  @override
  String toString() {
    return '''
    UserDiaryData(date: $date, todayMood: $todayMoodDesc, todayDiary: $todayDiary)
    ''';
  }
}

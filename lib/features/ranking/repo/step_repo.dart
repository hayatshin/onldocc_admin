import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/utils.dart';

class StepRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<int> calculateStepScore(String userId, DateTime date) async {
    int dailyScore = 0;
    final dateString = convertTimettampToString(date);
    final query =
        await _db.collection("period_step_count").doc(dateString).get();

    if (query.exists) {
      final userExists = query.data()?.containsKey(userId);

      if (userExists!) {
        dynamic dailyStepString = query.get(userId);

        final int dailyStepInt = dailyStepString as int;

        dailyScore = dailyStepInt < 0
            ? 0
            : dailyStepInt > 10000
                ? 100
                : ((dailyStepInt / 1000).floor()) * 10;
      }
    }
    return dailyScore;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserAllDateStepData(
      String userId) async {
    final query = await _db.collection("user_step_cout").doc(userId).get();
    return query;
  }

  Future<List<Map<String, dynamic>>> getUserCertinDateStepData(
      String userId, DateTime startDate, DateTime endDate) async {
    List<DateTime> dateList = getBetweenDays(startDate, endDate);
    List<Map<String, dynamic>> stepList = [];

    await Future.forEach(dateList, (DateTime date) async {
      final dateString = convertTimettampToString(date);
      final query =
          await _db.collection("period_step_count").doc(dateString).get();
      final userExists = query.data()?.containsKey(userId);
      if (userExists!) {
        dynamic dailyStepString = query.get(userId);
        final int dailyStepInt = dailyStepString as int;
        final Map<String, dynamic> dailyStepMap = {
          "date": dateString,
          "dailyStep": dailyStepInt,
        };
        stepList.add(dailyStepMap);
      }
    });

    return stepList;
  }
}

final stepRepo = Provider((ref) => StepRepository());

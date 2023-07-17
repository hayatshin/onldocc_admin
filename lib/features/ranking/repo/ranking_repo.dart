import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onldocc_admin/utils.dart';

class RankingRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<int> calculateStepScore(String userId, DateTime date) async {
    int dailyScore = 0;
    final dateString =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final query = await _db.collection("user_step_count").doc(userId).get();

    if (query.exists) {
      final dateExists = query.data()?.containsKey(dateString);

      if (dateExists!) {
        dynamic diaryStepString = query.get(dateString);

        final int dailyStepInt = diaryStepString as int;

        dailyScore = dailyStepInt < 0
            ? 0
            : dailyStepInt > 10000
                ? 100
                : ((dailyStepInt / 1000).floor()) * 10;
      }
    }
    return dailyScore;
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> getDateStepScores(
      DateTime startDate, DateTime endDate) async {
    List<DateTime> dateList = getBetweenDays(startDate, endDate);
    List<DocumentSnapshot<Map<String, dynamic>>> list = [];
    for (DateTime date in dateList) {
      final dateString = convertTimettampToString(date);
      final query =
          await _db.collection("period_step_count").doc(dateString).get();
      list.add(query);
    }
    return list;
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getDateDiaryScore(
      DateTime startDate, DateTime endDate) async {
    final query = await _db
        .collection("diary")
        .where("timestamp", isGreaterThanOrEqualTo: startDate)
        .where("timestamp", isLessThanOrEqualTo: endDate)
        .get();
    return query.docs;
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getDateCommentScore(
      DateTime startDate, DateTime endDate) async {
    final query = await _db
        .collectionGroup("comments")
        .where("timestamp", isGreaterThanOrEqualTo: startDate)
        .where("timestamp", isLessThanOrEqualTo: endDate)
        .get();
    return query.docs;
  }

  Future<int> getUserStepScores(
      String userId, DateTime startDate, DateTime endDate) async {
    List<DateTime> betweenDates = getBetweenDays(startDate, endDate);
    int stepScores = 0;

    await Future.forEach(betweenDates, (DateTime date) async {
      final dailyScore = await calculateStepScore(userId, date);
      stepScores += dailyScore;
    });

    return stepScores;
  }

  Future<int> getUserDiaryScores(
      String userId, DateTime startDate, DateTime endDate) async {
    final query = await _db
        .collection("diary")
        .where("userId", isEqualTo: userId)
        .where("timestamp", isGreaterThanOrEqualTo: startDate)
        .where("timestamp", isLessThanOrEqualTo: endDate)
        .get();
    int docCount = query.docs.length;
    return docCount * 100;
  }

  Future<int> getUserCommentScores(
      String userId, DateTime startDate, DateTime endDate) async {
    final query = await _db
        .collectionGroup("comments")
        .where("userId", isEqualTo: userId)
        .where("timestamp", isGreaterThanOrEqualTo: startDate)
        .where("timestamp", isLessThanOrEqualTo: endDate)
        .get();
    int docCount = query.docs.length;
    return docCount * 20;
  }
}

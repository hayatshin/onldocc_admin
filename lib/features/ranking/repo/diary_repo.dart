import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      getUserCertainDateDiaryData(
          String userId, DateTime startDate, DateTime endDate) async {
    final query = await _db
        .collection("diary")
        .where("userId", isEqualTo: userId)
        .where("timestamp", isGreaterThanOrEqualTo: startDate)
        .where("timestamp", isLessThanOrEqualTo: endDate)
        .get();
    return query.docs;
  }
}

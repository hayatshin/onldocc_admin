import 'package:cloud_firestore/cloud_firestore.dart';

class CaRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      getUserCertainDateCaData(
          String userId, DateTime startDate, DateTime endDate) async {
    final query = await _db
        .collection("recognition")
        .where("userId", isEqualTo: userId)
        .where("timestamp", isGreaterThanOrEqualTo: startDate)
        .where("timestamp", isLessThanOrEqualTo: endDate)
        .get();
    return query.docs;
  }
}

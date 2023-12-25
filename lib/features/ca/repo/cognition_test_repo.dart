import 'package:cloud_firestore/cloud_firestore.dart';

class CognitionTestRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getTestData(
      String testType) async {
    final query = await _db
        .collection("cognition_test")
        .where("testType", isEqualTo: testType)
        .orderBy("timestamp", descending: true)
        .get();
    return query.docs;
  }
}

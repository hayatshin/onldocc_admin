import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TvRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getAllTvs() async {
    final tvRef = await _db.collection("youtube").get();
    return tvRef.docs;
  }

  Future<void> deleteTv(String documentId) async {
    await _db.collection("youtube").doc(documentId).delete();
  }

  Future<void> saveTv(Map<String, dynamic> tvJson, String documentId) async {
    await _db.collection("youtube").doc(documentId).set(tvJson);
  }
}

final tvRepo = Provider((ref) => TvRepository());

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuizRepository {
  // final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getUserCertainDateCaData(
      String userId, int startSeconds, int endSeconds) async {
    final query = await _supabase
        .from("quizzes")
        .select('*')
        .eq('userId', userId)
        .gte('createdAt', startSeconds)
        .lte('createdAt', endSeconds);

    return query;

    // final query = await _db
    //     .collection("recognition")
    //     .where("userId", isEqualTo: userId)
    //     .where("timestamp", isGreaterThanOrEqualTo: startDate)
    //     .where("timestamp", isLessThanOrEqualTo: endDate)
    //     .get();
    // return query.docs;
  }
}

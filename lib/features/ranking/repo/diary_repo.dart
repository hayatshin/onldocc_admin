// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DiaryRepository {
  // final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getUserCertainDateDiaryData(
      String userId, DateTime startDate, DateTime endDate) async {
    int startSeconds = convertStartDateTimeToSeconds(startDate);
    int endSeconds = convertEndDateTimeToSeconds(endDate);
    final doc = await _supabase
        .from("diaries")
        .select('*')
        .eq('userId', userId)
        .gte('createdAt', startSeconds)
        .lte('createdAt', endSeconds);
    return doc;

    // final query = await _db
    //     .collection("diary")
    //     .where("userId", isEqualTo: userId)
    //     .where("timestamp", isGreaterThanOrEqualTo: startDate)
    //     .where("timestamp", isLessThanOrEqualTo: endDate)
    //     .get();
    // return query.docs;
  }
}

final diaryRepo = Provider((ref) => DiaryRepository());

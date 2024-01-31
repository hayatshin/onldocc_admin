import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DiaryRepository {
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
  }
}

final diaryRepo = Provider((ref) => DiaryRepository());

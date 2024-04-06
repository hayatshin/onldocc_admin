import 'package:supabase_flutter/supabase_flutter.dart';

class QuizRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getUserCertainDateCaData(
      String userId, int startSeconds, int endSeconds) async {
    final query = await _supabase
        .from("quizzes_math")
        .select('*, users(*)')
        .eq('userId', userId)
        .gte('createdAt', startSeconds)
        .lte('createdAt', endSeconds);

    return query;
  }
}

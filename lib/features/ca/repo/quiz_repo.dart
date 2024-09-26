import 'package:supabase_flutter/supabase_flutter.dart';

class QuizRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getUserQuizMathData(
      String userId, int startSeconds, int endSeconds) async {
    final query = await _supabase
        .from("quizzes_math")
        .select('*, users(subdistrictId, contractCommunityId)')
        .eq('userId', userId)
        .gte('createdAt', startSeconds)
        .lte('createdAt', endSeconds)
        .order("createdAt", ascending: true);

    return query;
  }

  Future<List<Map<String, dynamic>>> getUserQuizMultipleChoicesData(
      String userId, int startSeconds, int endSeconds) async {
    final query = await _supabase
        .from("quizzes_multiple_choices")
        .select(
            '*, users(subdistrictId, contractCommunityId), quizzes_multiple_choices_db(quiz, quizAnswer)')
        .eq('userId', userId)
        .gte('createdAt', startSeconds)
        .lte('createdAt', endSeconds)
        .order("createdAt", ascending: true);
    return query;
  }
}

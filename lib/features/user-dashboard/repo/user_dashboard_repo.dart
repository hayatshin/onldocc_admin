import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserDashboardRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> userDiaryCount(
      int selectedStartSeconds, int selectedEndSeconds, String userId) async {
    final data = await _supabase
        .from("diaries")
        .select('todayMood, todayDiary, createdAt')
        .eq("userId", userId)
        .gte("createdAt", selectedStartSeconds)
        .lt("createdAt", selectedEndSeconds);

    return data;
  }

  Future<List<Map<String, dynamic>>> userCommentCount(
      int selectedStartSeconds, int selectedEndSeconds, String userId) async {
    final data = await _supabase
        .from("comments")
        .select('commentId')
        .eq("userId", userId)
        .gte("createdAt", selectedStartSeconds)
        .lt("createdAt", selectedEndSeconds);
    return data;
  }

  Future<List<Map<String, dynamic>>> userLikeCount(
      int selectedStartSeconds, int selectedEndSeconds, String userId) async {
    final data = await _supabase
        .from("likes")
        .select('likeId')
        .eq("userId", userId)
        .gte("createdAt", selectedStartSeconds)
        .lt("createdAt", selectedEndSeconds);
    return data;
  }

  Future<List<Map<String, dynamic>>> userQuizMath(
      int selectedStartSeconds, int selectedEndSeconds, String userId) async {
    final data = await _supabase
        .from("quizzes_math")
        .select('createdAt, quiz, quizAnswer, userAnswer, correct')
        .eq("userId", userId)
        .gte("createdAt", selectedStartSeconds)
        .lt("createdAt", selectedEndSeconds);
    return data;
  }

  Future<List<Map<String, dynamic>>> userQuizMultipleChoices(
      int selectedStartSeconds, int selectedEndSeconds, String userId) async {
    final data = await _supabase
        .from("quizzes_multiple_choices")
        .select(
            'createdAt, userAnswer, correct, quizzes_multiple_choices_db!inner(quiz, quizAnswer)')
        .eq("userId", userId)
        .gte("createdAt", selectedStartSeconds)
        .lt("createdAt", selectedEndSeconds);
    return data;
  }

  Future<List<Map<String, dynamic>>> userCognitionTest(
      int selectedStartSeconds, int selectedEndSeconds, String userId) async {
    final data = await _supabase
        .from("cognition_test")
        .select('createdAt, testType, result, userAnswers')
        .eq("userId", userId)
        .gte("createdAt", selectedStartSeconds)
        .lt("createdAt", selectedEndSeconds);
    return data;
  }

  Future<List<Map<String, dynamic>>> userAiChat(
      int selectedStartSeconds, int selectedEndSeconds, String userId) async {
    final data = await _supabase
        .from("chat_rooms")
        .select('roomId, chatTime')
        .eq("userId", userId)
        .gte("createdAt", selectedStartSeconds)
        .lt("createdAt", selectedEndSeconds);
    return data;
  }

  Future<List<Map<String, dynamic>>> userSteps(
      List<String> dateStrings, String userId) async {
    final data = await _supabase
        .from("steps")
        .select('date, step')
        .eq("userId", userId)
        .inFilter("date", dateStrings);
    return data;
  }
}

final userDashboardRepo = Provider((ref) => UserDashboardRepository());

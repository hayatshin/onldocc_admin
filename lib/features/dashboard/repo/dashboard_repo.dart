import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> userCount(
      int selectedStartSeconds, int selectedEndSeconds) async {
    final userSubdistrictId = selectContractRegion.value!.subdistrictId;
    if (userSubdistrictId != "") {
      // 지역
      final data = await _supabase
          .from("users")
          .select('*')
          .eq("users.subdistrictId", userSubdistrictId)
          .gte("createdAt", selectedStartSeconds)
          .lt("createdAt", selectedEndSeconds);
      return data;
    } else {
      // 마스터
      final data = await _supabase
          .from("users")
          .select('*')
          .gte("createdAt", selectedStartSeconds)
          .lt("createdAt", selectedEndSeconds);
      return data;
    }
  }

  Future<List<Map<String, dynamic>>> diaryCount(
      int selectedStartSeconds, int selectedEndSeconds) async {
    final userSubdistrictId = selectContractRegion.value!.subdistrictId;
    if (userSubdistrictId != "") {
      // 지역
      final data = await _supabase
          .from("diaries")
          .select(
              'diaryId, todayMood, users!inner(userId, subdistrictId, contractCommunityId, gender, birthYear, birthDay)')
          .eq("users.subdistrictId", userSubdistrictId)
          .gte("createdAt", selectedStartSeconds)
          .lt("createdAt", selectedEndSeconds);

      return data;
    } else {
      // 마스터
      final data = await _supabase
          .from("diaries")
          .select(
              'diaryId, todayMood, users!inner(userId, subdistrictId, contractCommunityId, gender, birthYear, birthDay)')
          .gte("createdAt", selectedStartSeconds)
          .lt("createdAt", selectedEndSeconds);
      return data;
    }
  }

  Future<List<Map<String, dynamic>>> commentCount(
      int selectedStartSeconds, int selectedEndSeconds) async {
    final userSubdistrictId = selectContractRegion.value!.subdistrictId;
    if (userSubdistrictId != "") {
      // 지역
      final data = await _supabase
          .from("comments")
          .select(
              'commentId, users!inner(userId, subdistrictId, contractCommunityId, gender, birthYear, birthDay)')
          .eq("users.subdistrictId", userSubdistrictId)
          .gte("createdAt", selectedStartSeconds)
          .lt("createdAt", selectedEndSeconds);
      return data;
    } else {
      // 마스터
      final data = await _supabase
          .from("comments")
          .select(
              'commentId, users!inner(userId, subdistrictId, contractCommunityId, gender, birthYear, birthDay)')
          .gte("createdAt", selectedStartSeconds)
          .lt("createdAt", selectedEndSeconds);
      return data;
    }
  }

  Future<List<Map<String, dynamic>>> likeCount(
      int selectedStartSeconds, int selectedEndSeconds) async {
    final userSubdistrictId = selectContractRegion.value!.subdistrictId;
    if (userSubdistrictId != "") {
      // 지역
      final data = await _supabase
          .from("likes")
          .select(
              'likeId, users!inner(userId, subdistrictId, contractCommunityId, gender, birthYear, birthDay)')
          .eq("users.subdistrictId", userSubdistrictId)
          .gte("createdAt", selectedStartSeconds)
          .lt("createdAt", selectedEndSeconds);
      return data;
    } else {
      // 마스터
      final data = await _supabase
          .from("likes")
          .select(
              'likeId, users!inner(userId, subdistrictId, contractCommunityId, gender, birthYear, birthDay)')
          .gte("createdAt", selectedStartSeconds)
          .lt("createdAt", selectedEndSeconds);
      return data;
    }
  }

  Future<List<Map<String, dynamic>>> quizMath(
      int selectedStartSeconds, int selectedEndSeconds) async {
    final userSubdistrictId = selectContractRegion.value!.subdistrictId;
    if (userSubdistrictId != "") {
      // 지역
      final data = await _supabase
          .from("quizzes_math")
          .select(
              'quizId, correct, users!inner(userId, subdistrictId, contractCommunityId, gender, birthYear, birthDay)')
          .eq("users.subdistrictId", userSubdistrictId)
          .gte("createdAt", selectedStartSeconds)
          .lt("createdAt", selectedEndSeconds);
      return data;
    } else {
      // 마스터
      final data = await _supabase
          .from("quizzes_math")
          .select(
              'quizId, correct, users!inner(userId, subdistrictId, contractCommunityId, gender, birthYear, birthDay)')
          .gte("createdAt", selectedStartSeconds)
          .lt("createdAt", selectedEndSeconds);
      return data;
    }
  }

  Future<List<Map<String, dynamic>>> quizMultipleChoices(
      int selectedStartSeconds, int selectedEndSeconds) async {
    final userSubdistrictId = selectContractRegion.value!.subdistrictId;
    if (userSubdistrictId != "") {
      // 지역
      final data = await _supabase
          .from("quizzes_multiple_choices")
          .select(
              'quizId, correct, users!inner(userId, subdistrictId, contractCommunityId, gender, birthYear, birthDay)')
          .eq("users.subdistrictId", userSubdistrictId)
          .gte("createdAt", selectedStartSeconds)
          .lt("createdAt", selectedEndSeconds);
      return data;
    } else {
      // 마스터
      final data = await _supabase
          .from("quizzes_multiple_choices")
          .select(
              'quizId, correct, users!inner(userId, subdistrictId, contractCommunityId, gender, birthYear, birthDay)')
          .gte("createdAt", selectedStartSeconds)
          .lt("createdAt", selectedEndSeconds);
      return data;
    }
  }

  Future<List<Map<String, dynamic>>> cognitionTest(
      int selectedStartSeconds, int selectedEndSeconds) async {
    final userSubdistrictId = selectContractRegion.value!.subdistrictId;
    if (userSubdistrictId != "") {
      // 지역
      final data = await _supabase
          .from("cognition_test")
          .select(
              'testId, testType, result, users!inner(userId, name, phone, subdistrictId, contractCommunityId, gender, birthYear, birthDay)')
          .eq("users.subdistrictId", userSubdistrictId)
          .gte("createdAt", selectedStartSeconds)
          .lt("createdAt", selectedEndSeconds);
      return data;
    } else {
      // 마스터
      final data = await _supabase
          .from("cognition_test")
          .select(
              'testId, testType, result, users!inner(userId, name, phone, subdistrictId, contractCommunityId, gender, birthYear, birthDay)')
          .gte("createdAt", selectedStartSeconds)
          .lt("createdAt", selectedEndSeconds);
      return data;
    }
  }

  Future<List<Map<String, dynamic>>> aiChat(
      int selectedStartSeconds, int selectedEndSeconds) async {
    final userSubdistrictId = selectContractRegion.value!.subdistrictId;
    if (userSubdistrictId != "") {
      // 지역
      final data = await _supabase
          .from("chat_rooms")
          .select(
              'roomId, chatTime, users!inner(userId, subdistrictId, contractCommunityId, gender, birthYear, birthDay)')
          .eq("users.subdistrictId", userSubdistrictId)
          .gte("createdAt", selectedStartSeconds)
          .lt("createdAt", selectedEndSeconds);
      return data;
    } else {
      // 마스터
      final data = await _supabase
          .from("chat_rooms")
          .select(
              'roomId, chatTime, users!inner(userId, subdistrictId, contractCommunityId, gender, birthYear, birthDay)')
          .gte("createdAt", selectedStartSeconds)
          .lt("createdAt", selectedEndSeconds);
      return data;
    }
  }

  Future<List<Map<String, dynamic>>> steps(List<String> dateStrings) async {
    final userSubdistrictId = selectContractRegion.value!.subdistrictId;
    if (userSubdistrictId != "") {
      // 지역
      final data = await _supabase
          .from("steps")
          .select(
              'date, step, users!inner(userId, subdistrictId, contractCommunityId, gender, birthYear, birthDay)')
          .eq("users.subdistrictId", userSubdistrictId)
          .inFilter("date", dateStrings);
      return data;
    } else {
      // 마스터
      final data = await _supabase
          .from("steps")
          .select(
              'date, step, users!inner(userId, subdistrictId, contractCommunityId, gender, birthYear, birthDay)')
          .inFilter("date", dateStrings);
      return data;
    }
  }

  Future<List<Map<String, dynamic>>> visitCount(
      int selectedStartSeconds, int selectedEndSeconds) async {
    final userSubdistrictId = selectContractRegion.value!.subdistrictId;
    if (userSubdistrictId != "") {
      // 지역
      final data = await _supabase
          .from("visit_logs")
          .select(
              '*, users!inner(userId, subdistrictId, contractCommunityId, gender, birthYear, birthDay)')
          .eq("users.subdistrictId", userSubdistrictId)
          .gte("visitedAt", selectedStartSeconds)
          .lt("visitedAt", selectedEndSeconds);
      return data;
    } else {
      // 마스터
      final data = await _supabase
          .from("visit_logs")
          .select(
              '*, users!inner(userId, subdistrictId, contractCommunityId, gender, birthYear, birthDay)')
          .gte("visitedAt", selectedStartSeconds)
          .lt("visitedAt", selectedEndSeconds);

      print("data: ${data.length}");
      return data;
    }
  }
}

final dashboardRepo = Provider((ref) => DashboardRepository());

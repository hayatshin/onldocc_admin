import 'dart:convert';

import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:onldocc_admin/constants/http.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RankingRepository {
  final _supabase = Supabase.instance.client;
  static final pointPFunctions = Uri.parse(
      "https://diejlcrtffmlsdyvcagq.supabase.co/functions/v1/point-p-functions-6");

  // supabase
  Future<List<dynamic>> getUserPoints(
      List<UserModel> userList, DateRange range) async {
    final startSeconds = convertStartDateTimeToSeconds(range.start);
    final endSeconds = convertEndDateTimeToSeconds(range.end);
    final userIds = userList.map((user) => user.userId).toList();
    Map<String, dynamic> requestBody = {
      'userIds': userIds,
      'userlist': userList,
      'startSeconds': startSeconds,
      'endSeconds': endSeconds,
    };

    String requestBodyJson = jsonEncode(requestBody);

    final response = await http.post(
      pointPFunctions,
      body: requestBodyJson,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data["data"];
    }
    return [];
  }

  Future<List<dynamic>> fetchUserDiary(
      String userId, DateRange dateRange) async {
    int startSecond = convertStartDateTimeToSeconds(dateRange.start);
    int endSecond = convertEndDateTimeToSeconds(dateRange.end);
    final data = _supabase
        .from("diaries")
        .select('createdAt, todayDiary')
        .gte("createdAt", startSecond)
        .lte("createdAt", endSecond)
        .eq("userId", userId)
        .order('createdAt', ascending: true);
    return data;
  }

  Future<List<dynamic>> fetchUserSteps(
      String userId, DateRange dateRange) async {
    List<DateTime> dateList = getBetweenDays(dateRange.start, dateRange.end);
    List<Map<String, dynamic>> stepList = [];

    await Future.forEach(dateList, (DateTime date) async {
      final dateString = convertTimettampToStringDate(date);

      final data = await _supabase
          .from("steps")
          .select('date, step')
          .eq('userId', userId)
          .eq('date', dateString);

      if (data.length == 1) {
        stepList.add(data[0]);
      }
    });

    return stepList;
  }

  Future<List<dynamic>> fetchUserComments(
      String userId, DateRange dateRange) async {
    int startSecond = convertStartDateTimeToSeconds(dateRange.start);
    int endSecond = convertEndDateTimeToSeconds(dateRange.end);
    final data = _supabase
        .from("comments")
        .select('createdAt, description')
        .gte("createdAt", startSecond)
        .lte("createdAt", endSecond)
        .eq("userId", userId)
        .order('createdAt', ascending: true);
    return data;
  }

  Future<List<dynamic>> fetchUserLikes(
      String userId, DateRange dateRange) async {
    int startSecond = convertStartDateTimeToSeconds(dateRange.start);
    int endSecond = convertEndDateTimeToSeconds(dateRange.end);
    final data = _supabase
        .from("likes")
        .select('createdAt')
        .gte("createdAt", startSecond)
        .lte("createdAt", endSecond)
        .eq("userId", userId)
        .order('createdAt', ascending: true);
    return data;
  }

  // Future<List<dynamic>> fetchUserInvitations(
  //     String userId, DateRange dateRange) async {
  //   int startSecond = convertStartDateTimeToSeconds(dateRange.start);
  //   int endSecond = convertEndDateTimeToSeconds(dateRange.end);
  //   final data = _supabase
  //       .from("receive_invitations")
  //       .select('createdAt')
  //       .gte("createdAt", startSecond)
  //       .lte("createdAt", endSecond)
  //       .eq("sendUserId", userId)
  //       .order('createdAt', ascending: true);
  //   return data;
  // }
}

final rankingRepo = Provider((ref) => RankingRepository());

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/constants/http.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class RankingRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _supabase = Supabase.instance.client;
  static final pointPFunctions = Uri.parse(
      "https://diejlcrtffmlsdyvcagq.supabase.co/functions/v1/point-p-functions");

  // supabase
  Future<List<dynamic>> getUserPoints(
      List<UserModel> userList, DateRange range) async {
    final startSeconds = convertStartDateTimeToSeconds(range.start);
    final endSeconds = convertEndDateTimeToSeconds(range.end);

    Map<String, dynamic> requestBody = {
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

  // firebase
  Future<int> calculateStepScore(String userId, DateTime date) async {
    int dailyScore = 0;
    final dateString = convertTimettampToStringDate(date);
    final query =
        await _db.collection("period_step_count").doc(dateString).get();

    if (query.exists) {
      final userExists = query.data()?.containsKey(userId);

      if (userExists!) {
        dynamic diaryStepString = query.get(userId);

        final int dailyStepInt = diaryStepString as int;

        dailyScore = dailyStepInt < 0
            ? 0
            : dailyStepInt > 10000
                ? 100
                : ((dailyStepInt / 1000).floor()) * 10;
      }
    }
    return dailyScore;
  }

  // all
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      getAllStepQuery() async {
    final query = await _db.collection("period_step_count").get();

    return query.docs;
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      getAllDiaryQuery() async {
    final query = await _db.collection("diary").get();

    return query.docs;
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      getAllCommentQuery() async {
    final query = await _db.collectionGroup("comments").get();

    return query.docs;
  }

  // date
  Future<List<DocumentSnapshot<Map<String, dynamic>>>> getDateStepQuery(
      DateTime startDate, DateTime endDate) async {
    List<DateTime> dateList = getBetweenDays(startDate, endDate);
    List<DocumentSnapshot<Map<String, dynamic>>> list = [];
    await Future.forEach(dateList, (DateTime date) async {
      final dateString = convertTimettampToStringDate(date);
      final query =
          await _db.collection("period_step_count").doc(dateString).get();
      list.add(query);
    });

    return list;
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getDateDiaryQuery(
      DateTime startDate, DateTime endDate) async {
    final query = await _db
        .collection("diary")
        .where("timestamp", isGreaterThanOrEqualTo: startDate)
        .where("timestamp", isLessThanOrEqualTo: endDate)
        .get();

    return query.docs;
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getDateCommentQuery(
      DateTime startDate, DateTime endDate) async {
    final query = await _db
        .collectionGroup("comments")
        .where("timestamp", isGreaterThanOrEqualTo: startDate)
        .where("timestamp", isLessThanOrEqualTo: endDate)
        .get();

    return query.docs;
  }

  // user & date
  Future<int> getUserDateStepScores(
      String userId, DateTime startDate, DateTime endDate) async {
    List<DateTime> betweenDates = getBetweenDays(startDate, endDate);

    int stepScores = 0;

    await Future.forEach(betweenDates, (DateTime date) async {
      final dailyScore = await calculateStepScore(userId, date);
      stepScores += dailyScore;
    });

    return stepScores;
  }

  Future<int> getUserDateDiaryScores(
      String userId, DateTime startDate, DateTime endDate) async {
    final query = await _db
        .collection("diary")
        .where("userId", isEqualTo: userId)
        .where("timestamp", isGreaterThanOrEqualTo: startDate)
        .where("timestamp", isLessThanOrEqualTo: endDate)
        .get();
    int docCount = query.docs.length;

    return docCount * 100;
  }

  Future<int> getUserDateCommentScores(
      String userId, DateTime startDate, DateTime endDate) async {
    final query = await _db
        .collectionGroup("comments")
        .where("userId", isEqualTo: userId)
        .where("timestamp", isGreaterThanOrEqualTo: startDate)
        .where("timestamp", isLessThanOrEqualTo: endDate)
        .get();
    int docCount = query.docs.length;

    return docCount * 20;
  }
}

final rankingRepo = Provider((ref) => RankingRepository());

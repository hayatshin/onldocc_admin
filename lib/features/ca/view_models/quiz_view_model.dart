import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/ca/models/quiz_model.dart';
import 'package:onldocc_admin/features/ca/repo/quiz_repo.dart';
import 'package:onldocc_admin/utils.dart';

class QuizViewModel extends AsyncNotifier<List<QuizModel>> {
  DateTime now = DateTime.now();
  WeekMonthDay weekMonthDay = getWeekMonthDay();
  late QuizRepository _quizRepository;

  @override
  FutureOr<List<QuizModel>> build() {
    _quizRepository = QuizRepository();
    return [];
  }

  Future<List<QuizModel>> getUserDateCaData(
      String userId, DateRange dateRange) async {
    int startSeconds = convertStartDateTimeToSeconds(dateRange.start);
    int endSeconds = convertEndDateTimeToSeconds(dateRange.end);

    final userQuizDataList = await _quizRepository.getUserCertainDateCaData(
        userId, startSeconds, endSeconds);

    return userQuizDataList.map((e) => QuizModel.fromJson(e)).toList();

    // List<QuizModel> caList = [];

    // late List<QueryDocumentSnapshot<Map<String, dynamic>>> caDocs;

    // switch (periodType) {
    //   case "이번주":
    //     caDocs = await _caRepository.getUserCertainDateCaData(userId,
    //         weekMonthDay.thisWeek.startDate, weekMonthDay.thisWeek.endDate);
    //     break;
    //   case "이번달":
    //     caDocs = await _caRepository.getUserCertainDateCaData(userId,
    //         weekMonthDay.thisMonth.startDate, weekMonthDay.thisMonth.endDate);

    //     break;
    //   case "지난달":
    //     caDocs = await _caRepository.getUserCertainDateCaData(userId,
    //         weekMonthDay.lastMonth.startDate, weekMonthDay.lastMonth.endDate);

    //     break;
    // }

    // for (DocumentSnapshot<Map<String, dynamic>> caDoc in caDocs) {
    //   Map<String, dynamic> caJson = caDoc.data()!;
    //   QuizModel caModel = QuizModel.fromJson(caJson);
    //   caList.add(caModel);
    // }

    // return caList;
  }
}

final caProvider = AsyncNotifierProvider<QuizViewModel, List<QuizModel>>(
  () => QuizViewModel(),
);

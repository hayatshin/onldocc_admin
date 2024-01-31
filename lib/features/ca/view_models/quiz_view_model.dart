import 'dart:async';

import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/ca/models/quiz_model.dart';
import 'package:onldocc_admin/features/ca/repo/quiz_repo.dart';
import 'package:onldocc_admin/utils.dart';

class QuizViewModel extends AsyncNotifier<List<QuizModel>> {
  DateTime now = DateTime.now();
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
  }
}

final caProvider = AsyncNotifierProvider<QuizViewModel, List<QuizModel>>(
  () => QuizViewModel(),
);

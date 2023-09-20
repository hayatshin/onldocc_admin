import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/ranking/models/step_model.dart';
import 'package:onldocc_admin/features/ranking/repo/step_repo.dart';
import 'package:onldocc_admin/utils.dart';

class StepViewModel extends AsyncNotifier<List<StepModel>> {
  DateTime now = DateTime.now();
  late StepRepository _stepRepository;
  WeekMonthDay weekMonthDay = getWeekMonthDay();

  @override
  FutureOr<List<StepModel>> build() {
    _stepRepository = StepRepository();

    return [];
  }

  Future<List<StepModel>> getUserDateStepData(
      String userId, String periodType) async {
    List<StepModel> stepList = [];
    late List<Map<String, dynamic>> userRef;

    if (periodType == "이번주") {
      userRef = await _stepRepository.getUserCertinDateStepData(userId,
          weekMonthDay.thisWeek.startDate, weekMonthDay.thisWeek.endDate);
    } else if (periodType == "이번달") {
      userRef = await _stepRepository.getUserCertinDateStepData(userId,
          weekMonthDay.thisMonth.startDate, weekMonthDay.thisMonth.endDate);
    } else if (periodType == "지난달") {
      userRef = await _stepRepository.getUserCertinDateStepData(userId,
          weekMonthDay.lastMonth.startDate, weekMonthDay.lastMonth.endDate);
    }

    for (var stepJson in userRef) {
      StepModel stepModel = StepModel.fromJson(stepJson);
      stepList.add(stepModel);
    }

    return stepList;
  }
}

final stepProvider = AsyncNotifierProvider<StepViewModel, List<StepModel>>(
  () => StepViewModel(),
);

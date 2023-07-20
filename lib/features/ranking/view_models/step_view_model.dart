import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/ranking/models/step_model.dart';
import 'package:onldocc_admin/features/ranking/repo/step_repo.dart';

class StepViewModel extends AsyncNotifier<List<StepModel>> {
  DateTime now = DateTime.now();
  late DateTime firstDateOfWeek;
  late DateTime firstDateOfMonth;
  late StepRepository _stepRepository;

  @override
  FutureOr<List<StepModel>> build() {
    _stepRepository = StepRepository();
    firstDateOfWeek = now.subtract(Duration(days: now.weekday - 1));
    firstDateOfWeek = DateTime(
        firstDateOfWeek.year, firstDateOfWeek.month, firstDateOfWeek.day, 0, 0);
    firstDateOfMonth = DateTime(now.year, now.month, 1);
    firstDateOfMonth = DateTime(firstDateOfMonth.year, firstDateOfMonth.month,
        firstDateOfMonth.day, 0, 0);
    return [];
  }

  Future<List<StepModel>> getUserAllStepData(String userId) async {
    List<StepModel> stepList = [];
    final userRef = await _stepRepository.getUserAllDateStepData(userId);
    final userDoc = userRef.data();

    userDoc?.forEach(
      (date, dailyStep) {
        final dailyStepInt = int.parse(dailyStep);
        final stepJson = {
          date: dailyStepInt,
        };
        StepModel? stepModel = StepModel.fromJson(stepJson);
        stepList.add(stepModel);
      },
    );
    return stepList;
  }

  Future<List<StepModel>> getUserDateStepData(
      String userId, String periodType) async {
    List<StepModel> stepList = [];
    late List<Map<String, dynamic>> userRef;

    if (periodType == "이번주") {
      userRef = await _stepRepository.getUserCertinDateStepData(
          userId, firstDateOfWeek, now);
    } else if (periodType == "이번달") {
      userRef = await _stepRepository.getUserCertinDateStepData(
          userId, firstDateOfMonth, now);
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

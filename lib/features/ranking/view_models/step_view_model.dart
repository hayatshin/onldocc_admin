import 'dart:async';

import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/ranking/models/step_model.dart';
import 'package:onldocc_admin/features/ranking/repo/step_repo.dart';

class StepViewModel extends AsyncNotifier<List<StepModel>> {
  DateTime now = DateTime.now();
  late StepRepository _stepRepository;

  @override
  FutureOr<List<StepModel>> build() {
    _stepRepository = StepRepository();

    return [];
  }

  Future<List<StepModel>> getUserDateStepData(
      String userId, DateRange dateRange) async {
    final stepList = await _stepRepository.getUserCertinDateStepData(
        userId, dateRange.start, dateRange.end);
    return stepList.map((step) => StepModel.fromJson(step)).toList();
  }
}

final stepProvider = AsyncNotifierProvider<StepViewModel, List<StepModel>>(
  () => StepViewModel(),
);

import 'dart:async';

import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/ranking/models/diary_model.dart';
import 'package:onldocc_admin/features/ranking/repo/diary_repo.dart';
import 'package:onldocc_admin/utils.dart';

class DiaryViewModel extends AsyncNotifier<List<DiaryModel>> {
  DateTime now = DateTime.now();
  late DiaryRepository _diaryRepo;

  @override
  FutureOr<List<DiaryModel>> build() {
    _diaryRepo = ref.read(diaryRepo);
    return [];
  }

  Future<List<DiaryModel>> getUserDateDiaryData(
      String userId, DateRange dateRange) async {
    final diaryDocs = await _diaryRepo.getUserCertainDateDiaryData(
        userId, dateRange.start, dateRange.end);
    return diaryDocs.map((doc) => DiaryModel.fromJson(doc)).toList();
  }
}

final diaryProvider = AsyncNotifierProvider<DiaryViewModel, List<DiaryModel>>(
  () => DiaryViewModel(),
);

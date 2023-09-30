import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/ranking/models/diary_model.dart';
import 'package:onldocc_admin/features/ranking/repo/diary_repo.dart';
import 'package:onldocc_admin/utils.dart';

class DiaryViewModel extends AsyncNotifier<List<DiaryModel>> {
  DateTime now = DateTime.now();
  late DiaryRepository _diaryRepo;
  WeekMonthDay weekMonthDay = getWeekMonthDay();

  @override
  FutureOr<List<DiaryModel>> build() {
    _diaryRepo = ref.read(diaryRepo);
    return [];
  }

  Future<List<DiaryModel>> getUserDateDiaryData(
      String userId, String periodType) async {
    List<DiaryModel> diaryList = [];
    late List<QueryDocumentSnapshot<Map<String, dynamic>>> diaryDocs;

    if (periodType == "이번주") {
      diaryDocs = await _diaryRepo.getUserCertainDateDiaryData(userId,
          weekMonthDay.thisWeek.startDate, weekMonthDay.thisWeek.endDate);
      for (DocumentSnapshot<Map<String, dynamic>> diaryDoc in diaryDocs) {
        Map<String, dynamic> diaryJson = diaryDoc.data()!;
        DiaryModel diaryModel = DiaryModel.fromJson(diaryJson);
        diaryList.add(diaryModel);
      }
    } else if (periodType == "이번달") {
      diaryDocs = await _diaryRepo.getUserCertainDateDiaryData(userId,
          weekMonthDay.thisMonth.startDate, weekMonthDay.thisMonth.endDate);
      for (DocumentSnapshot<Map<String, dynamic>> diaryDoc in diaryDocs) {
        Map<String, dynamic> diaryJson = diaryDoc.data()!;

        DiaryModel diaryModel = DiaryModel.fromJson(diaryJson);
        diaryList.add(diaryModel);
      }
    } else if (periodType == "지난달") {
      diaryDocs = await _diaryRepo.getUserCertainDateDiaryData(userId,
          weekMonthDay.lastMonth.startDate, weekMonthDay.lastMonth.endDate);
      for (DocumentSnapshot<Map<String, dynamic>> diaryDoc in diaryDocs) {
        Map<String, dynamic> diaryJson = diaryDoc.data()!;

        DiaryModel diaryModel = DiaryModel.fromJson(diaryJson);
        diaryList.add(diaryModel);
      }
    }

    return diaryList;
  }
}

final diaryProvider = AsyncNotifierProvider<DiaryViewModel, List<DiaryModel>>(
  () => DiaryViewModel(),
);

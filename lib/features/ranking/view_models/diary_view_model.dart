import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/ranking/models/diary_model.dart';
import 'package:onldocc_admin/features/ranking/repo/diary_repo.dart';

class DiaryViewModel extends AsyncNotifier<List<DiaryModel>> {
  DateTime now = DateTime.now();
  late DateTime firstDateOfWeek;
  late DateTime firstDateOfMonth;
  late DiaryRepository _diaryRepository;

  @override
  FutureOr<List<DiaryModel>> build() {
    _diaryRepository = DiaryRepository();
    firstDateOfWeek = now.subtract(Duration(days: now.weekday - 1));
    firstDateOfWeek = DateTime(
        firstDateOfWeek.year, firstDateOfWeek.month, firstDateOfWeek.day, 0, 0);
    firstDateOfMonth = DateTime(now.year, now.month, 1);
    firstDateOfMonth = DateTime(firstDateOfMonth.year, firstDateOfMonth.month,
        firstDateOfMonth.day, 0, 0);
    return [];
  }

  Future<List<DiaryModel>> getUserDateDiaryData(
      String userId, String periodType) async {
    List<DiaryModel> diaryList = [];
    late List<QueryDocumentSnapshot<Map<String, dynamic>>> diaryDocs;

    if (periodType == "이번주") {
      diaryDocs = await _diaryRepository.getUserCertainDateDiaryData(
          userId, firstDateOfWeek, now);
      for (DocumentSnapshot<Map<String, dynamic>> diaryDoc in diaryDocs) {
        Map<String, dynamic> diaryJson = diaryDoc.data()!;
        DiaryModel diaryModel = DiaryModel.fromJson(diaryJson);
        diaryList.add(diaryModel);
      }
    } else if (periodType == "이번달") {
      diaryDocs = await _diaryRepository.getUserCertainDateDiaryData(
          userId, firstDateOfMonth, now);

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

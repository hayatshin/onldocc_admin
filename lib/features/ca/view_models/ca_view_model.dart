import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/ca/models/ca_model.dart';
import 'package:onldocc_admin/features/ca/repo/ca_repo.dart';
import 'package:onldocc_admin/utils.dart';

class CaViewModel extends AsyncNotifier<List<CaModel>> {
  DateTime now = DateTime.now();
  WeekMonthDay weekMonthDay = getWeekMonthDay();
  late CaRepository _caRepository;

  @override
  FutureOr<List<CaModel>> build() {
    _caRepository = CaRepository();
    return [];
  }

  Future<List<CaModel>> getUserDateCaData(
      String userId, String periodType) async {
    List<CaModel> caList = [];
    late List<QueryDocumentSnapshot<Map<String, dynamic>>> caDocs;

    switch (periodType) {
      case "이번주":
        caDocs = await _caRepository.getUserCertainDateCaData(userId,
            weekMonthDay.thisWeek.startDate, weekMonthDay.thisWeek.endDate);
        break;
      case "이번달":
        caDocs = await _caRepository.getUserCertainDateCaData(userId,
            weekMonthDay.thisMonth.startDate, weekMonthDay.thisMonth.endDate);

        break;
      case "지난달":
        caDocs = await _caRepository.getUserCertainDateCaData(userId,
            weekMonthDay.lastMonth.startDate, weekMonthDay.lastMonth.endDate);

        break;
    }

    for (DocumentSnapshot<Map<String, dynamic>> caDoc in caDocs) {
      Map<String, dynamic> caJson = caDoc.data()!;
      CaModel caModel = CaModel.fromJson(caJson);
      caList.add(caModel);
    }

    return caList;
  }
}

final caProvider = AsyncNotifierProvider<CaViewModel, List<CaModel>>(
  () => CaViewModel(),
);

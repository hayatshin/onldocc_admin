import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/ca/models/ca_model.dart';
import 'package:onldocc_admin/features/ca/repo/ca_repo.dart';

class CaViewModel extends AsyncNotifier<List<CaModel>> {
  DateTime now = DateTime.now();
  late DateTime firstDateOfWeek;
  late DateTime firstDateOfMonth;
  late CaRepository _caRepository;

  @override
  FutureOr<List<CaModel>> build() {
    _caRepository = CaRepository();
    firstDateOfWeek = now.subtract(Duration(days: now.weekday - 1));
    firstDateOfWeek = DateTime(
        firstDateOfWeek.year, firstDateOfWeek.month, firstDateOfWeek.day, 0, 0);
    firstDateOfMonth = DateTime(now.year, now.month, 1);
    firstDateOfMonth = DateTime(firstDateOfMonth.year, firstDateOfMonth.month,
        firstDateOfMonth.day, 0, 0);
    return [];
  }

  Future<List<CaModel>> getUserDateCaData(
      String userId, String periodType) async {
    List<CaModel> caList = [];
    late List<QueryDocumentSnapshot<Map<String, dynamic>>> caDocs;

    if (periodType == "이번주") {
      caDocs = await _caRepository.getUserCertainDateCaData(
          userId, firstDateOfWeek, now);
      for (DocumentSnapshot<Map<String, dynamic>> caDoc in caDocs) {
        Map<String, dynamic> caJson = caDoc.data()!;
        CaModel caModel = CaModel.fromJson(caJson);
        caList.add(caModel);
      }
    } else if (periodType == "이번달") {
      caDocs = await _caRepository.getUserCertainDateCaData(
          userId, firstDateOfMonth, now);

      for (DocumentSnapshot<Map<String, dynamic>> caDoc in caDocs) {
        Map<String, dynamic> caJson = caDoc.data()!;

        CaModel caModel = CaModel.fromJson(caJson);

        caList.add(caModel);
      }
    }

    return caList;
  }
}

final caProvider = AsyncNotifierProvider<CaViewModel, List<CaModel>>(
  () => CaViewModel(),
);

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/ca/models/cognition_test_model.dart';
import 'package:onldocc_admin/features/ca/repo/cognition_test_repo.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';

const alzheimer_test = "alzheimer_test";
const depression_test = "depression_test";

class CognitionViewModel extends AsyncNotifier<void> {
  late CognitionTestRepository _cognitionTestRepo;

  @override
  FutureOr<void> build() async {
    _cognitionTestRepo = CognitionTestRepository();
  }

  Future<List<CognitionTestModel>> getCognitionTestData(String testType) async {
    AdminProfileModel? adminProfileModel = ref.read(adminProfileProvider).value;

    final list =
        await _cognitionTestRepo.getTestData(testType, adminProfileModel!);
    final modelList = list.map((e) => CognitionTestModel.fromJson(e)).toList();

    return modelList;
  }

  List<CognitionTestModel?> filterTableRows(List<CognitionTestModel?> testList,
      String searchType, String searchKeyword) {
    if (searchType == "name") {
      return testList
          .where((item) => item!.userName!.contains(searchKeyword))
          .toList();
    } else if (searchType == "phone") {
      return testList
          .where((item) => item!.userPhone!.contains(searchKeyword))
          .toList();
    }
    return testList;
  }
}

final cognitionTestProvider =
    AsyncNotifierProvider<CognitionViewModel, void>(() => CognitionViewModel());

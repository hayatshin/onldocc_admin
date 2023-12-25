import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/ca/models/cognition_test_model.dart';
import 'package:onldocc_admin/features/ca/repo/cognition_test_repo.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/features/users/view_models/user_view_model.dart';

const alzheimer_test = "alzheimer_test";
const depression_test = "depression_test";

class CognitionViewModel extends AsyncNotifier<void> {
  late CognitionTestRepository _cognitionTestRepo;

  @override
  FutureOr<void> build() async {
    _cognitionTestRepo = CognitionTestRepository();
  }

  Future<List<CognitionTestModel>> getAdminAlzheimerTestData() async {
    List<UserModel?> userList =
        await ref.watch(userProvider.notifier).getContractUserList();
    final userListNonNull =
        userList.where((element) => element != null).cast<UserModel>().toList();

    final alzDataList = await _cognitionTestRepo.getTestData(alzheimer_test);
    final alzheimerTestList =
        alzDataList.map((e) => CognitionTestModel.fromJson(e.data())).toList();

    List<CognitionTestModel> resultList = [];

    for (var test in alzheimerTestList) {
      for (final user in userListNonNull) {
        if (user.userId == test.userId) {
          final userInfo = test.copyWith(
            userName: user.name,
            userGender: user.gender,
            userAge: user.age,
            userPhone: user.phone,
          );
          resultList.add(userInfo);
        }
      }
    }
    return resultList;
  }

  Future<List<CognitionTestModel>> getAdminDepressionTestData() async {
    List<UserModel?> userList =
        await ref.watch(userProvider.notifier).getContractUserList();
    final userListNonNull =
        userList.where((element) => element != null).cast<UserModel>().toList();

    final depressionList =
        await _cognitionTestRepo.getTestData(depression_test);
    final depressionTestList = depressionList
        .map((e) => CognitionTestModel.fromJson(e.data()))
        .toList();

    List<CognitionTestModel> resultList = [];
    for (var test in depressionTestList) {
      for (final user in userListNonNull) {
        if (user.userId == test.userId) {
          final userInfo = test.copyWith(
            userName: user.name,
            userGender: user.gender,
            userAge: user.age,
            userPhone: user.phone,
          );
          resultList.add(userInfo);
        }
      }
    }
    return resultList;
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

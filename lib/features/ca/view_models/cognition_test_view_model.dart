import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/ca/models/cognition_test_model.dart';
import 'package:onldocc_admin/features/ca/repo/cognition_test_repo.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
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

  Future<List<CognitionTestModel>> getCognitionTestData(String testType) async {
    AdminProfileModel? adminProfileModel = ref.read(adminProfileProvider).value;

    final list =
        await _cognitionTestRepo.getTestData(testType, adminProfileModel!);
    final modelList = list.map((e) => CognitionTestModel.fromJson(e)).toList();

    return modelList;

    // List<UserModel?> userList =
    //     await ref.watch(userProvider.notifier).getContractUserList();
    // final userListNonNull =
    //     userList.where((element) => element != null).cast<UserModel>().toList();

    // final alzDataList = await _cognitionTestRepo.getTestData(alzheimer_test);
    // final alzheimerTestList =
    //     alzDataList.map((e) => CognitionTestModel.fromJson(e.data())).toList();

    // List<CognitionTestModel> resultList = [];

    // for (var test in alzheimerTestList) {
    //   // for (final user in userListNonNull) {
    //   //   if (user.userId == test.userId) {
    //   //     final userInfo = test.copyWith(
    //   //       userName: user.name,
    //   //       userGender: user.gender,
    //   //       userAge: user.userAge,
    //   //       userPhone: user.phone,
    //   //     );
    //   //     resultList.add(userInfo);
    //   //   }
    //   // }
    // }
    // return resultList;
  }

  // Future<List<CognitionTestModel>> getAdminDepressionTestData() async {
  //   AdminProfileModel? adminProfileModel = ref.read(adminProfileProvider).value;

  //   final depressionList = await _cognitionTestRepo.getTestData(
  //       depression_test, adminProfileModel!.subdistrictId);
  //   final depressionTestList =
  //       depressionList.map((e) => CognitionTestModel.fromJson(e)).toList();

  //   return depressionTestList;

  //   // List<CognitionTestModel> resultList = [];
  //   // for (var test in depressionTestList) {
  //   //   for (final user in userListNonNull) {
  //   //     // if (user.userId == test.userId) {
  //   //     //   final userInfo = test.copyWith(
  //   //     //     userName: user.name,
  //   //     //     userGender: user.gender,
  //   //     //     userAge: user.userAge,
  //   //     //     userPhone: user.phone,
  //   //     //   );
  //   //     //   resultList.add(userInfo);
  //   //     // }
  //   //   }
  //   // }
  //   // return resultList;
  // }

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

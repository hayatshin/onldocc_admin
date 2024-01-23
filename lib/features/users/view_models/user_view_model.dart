import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/models/contract_notifier.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/features/users/repo/user_repo.dart';

class UserViewModel extends AsyncNotifier<UserModel> {
  late UserRepository _userRepo;
  @override
  FutureOr<UserModel> build() {
    _userRepo = UserRepository();
    return UserModel.empty();
  }

  List<UserModel?> filterTableRows(
      List<UserModel?> userList, String searchType, String searchKeyword) {
    if (searchType == "name") {
      final newList =
          userList.where((item) => item!.name.contains(searchKeyword)).toList();
      List<UserModel?> sortList = List.from(newList);
      sortList.sort((a, b) => a!.fullRegion.compareTo(b!.fullRegion));
      return sortList;
    } else if (searchType == "phone") {
      final newList = userList
          .where((item) => item!.phone.contains(searchKeyword))
          .toList();
      List<UserModel?> sortList = List.from(newList);
      sortList.sort((a, b) => a!.fullRegion.compareTo(b!.fullRegion));
      return sortList;
    }
    return userList;
  }

  Future<UserModel?> getUserModel(String userId) async {
    Map<String, dynamic>? userJson =
        await ref.read(userRepo).getUserProfile(userId);
    final userModel = UserModel.fromJson(userJson!);

    return userModel;
  }

  List<UserModel?> indexUserModel(
      String order, List<UserModel?> updateScoreList) {
    int count = 1;
    List<UserModel?> list = [];

    if (order == "종합 점수") {
      for (int i = 0; i < updateScoreList.length - 1; i++) {
        if (updateScoreList[i + 1] != null) {
          UserModel indexUpdateUser = updateScoreList[i]!.copyWith(
            index: count,
          );

          list.add(indexUpdateUser);
          if (updateScoreList[i]!.totalScore !=
              updateScoreList[i + 1]!.totalScore) {
            count++;
          }
        }
      }
    } else if (order == "걸음수") {
      for (int i = 0; i < updateScoreList.length; i++) {
        if (updateScoreList[i + 1] != null) {
          UserModel indexUpdateUser = updateScoreList[i]!.copyWith(
            index: count,
          );
          list.add(indexUpdateUser);
          if (updateScoreList[i]!.stepScore !=
              updateScoreList[i + 1]!.stepScore) {
            count++;
          }
        }
      }
    } else if (order == "일기") {
      for (int i = 0; i < updateScoreList.length; i++) {
        if (updateScoreList[i + 1] != null) {
          UserModel indexUpdateUser = updateScoreList[i]!.copyWith(
            index: count,
          );
          list.add(indexUpdateUser);
          if (updateScoreList[i]!.diaryScore !=
              updateScoreList[i + 1]!.diaryScore) {
            count++;
          }
        }
      }
    } else if (order == "댓글") {
      for (int i = 0; i < updateScoreList.length; i++) {
        if (updateScoreList[i + 1] != null) {
          UserModel indexUpdateUser = updateScoreList[i]!.copyWith(
            index: count,
          );
          list.add(indexUpdateUser);
          if (updateScoreList[i]!.commentScore !=
              updateScoreList[i + 1]!.commentScore) {
            count++;
          }
        }
      }
    }
    return list;
  }

  Future<List<UserModel?>> getContractUserList() async {
    List<UserModel?> userDataList = [];
    // List<UserModel?> allUserList = await ref.read(userRepo).getAllUserData();
    AdminProfileModel? adminProfileModel = ref.read(adminProfileProvider).value;

    // if (adminProfileModel.contractType == "마스터") {
    //   if (contractNotifier.contractConfigModel.contractType != "지역" &&
    //       contractNotifier.contractConfigModel.contractType != "기관") {
    //     return allUserList.where((element) => element!.name != "탈퇴자").toList();
    //   } else {
    //     for (UserModel? user in allUserList) {
    //       if (contractNotifier.contractConfigModel.contractType == "지역" &&
    //           contractNotifier.contractConfigModel.contractName ==
    //               user!.fullRegion) {
    //         userDataList.add(user);
    //       } else if (contractNotifier.contractConfigModel.contractType ==
    //               "기관" &&
    //           contractNotifier.contractConfigModel.contractName ==
    //               user!.community) {
    //         userDataList.add(user);
    //       }
    //     }
    //   }
    // } else {
    //   for (UserModel? user in allUserList) {
    //     if (adminProfileModel.contractType == "지역" &&
    //         adminProfileModel.contractName == user!.fullRegion) {
    //       userDataList.add(user);
    //     } else if (adminProfileModel.contractType == "기관" &&
    //         adminProfileModel.contractName == user!.community) {
    //       userDataList.add(user);
    //     }
    //   }
    // }

    return userDataList;
  }

  Future<List<UserModel?>> initializeUserList() async {
    AdminProfileModel? adminProfile = ref.read(adminProfileProvider).value;
    final selectMaster = selectContractRegion.value.name == '마스터';
    final selectSubdistrictId = selectContractRegion.value.name == "마스터"
        ? adminProfile!.subdistrictId
        : selectContractRegion.value.subdistrictId;

    final userlist =
        await _userRepo.initializeUserList(selectMaster, selectSubdistrictId);
    final modelList = userlist.map((e) => UserModel.fromJson(e)).toList();
    return modelList.where((e) => e.name != "탈퇴자").toList();
  }
}

final userProvider = AsyncNotifierProvider<UserViewModel, UserModel>(
  () => UserViewModel(),
);

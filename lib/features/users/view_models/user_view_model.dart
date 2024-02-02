import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/features/users/repo/user_repo.dart';
import 'package:onldocc_admin/utils.dart';

class UserViewModel extends AsyncNotifier<List<UserModel?>> {
  late UserRepository _userRepo;
  @override
  FutureOr<List<UserModel?>> build() async {
    _userRepo = UserRepository();
    return await initializeUserList();
  }

  Future<void> saveAdminUser(String notiUserId) async {
    AdminProfileModel? adminProfileModel = ref.read(adminProfileProvider).value;

    final userJson = {
      "userId": notiUserId,
      "avatar": adminProfileModel!.image,
      "loginType": "어드민",
      "gender": "남성",
      "birthYear": "1960",
      "birthDay": "0101",
      "phone": adminProfileModel.phone,
      "name": adminProfileModel.name,
      "createdAt": getCurrentSeconds(),
      "subdistrictId": adminProfileModel.subdistrictId,
    };
    await _userRepo.saveAdminUser(userJson);
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

  Future<List<UserModel?>> initializeUserList() async {
    AdminProfileModel? adminProfile = ref.read(adminProfileProvider).value;
    final selectMaster = selectContractRegion.value.name == '마스터';
    final selectSubdistrictId = selectContractRegion.value.name == "마스터"
        ? adminProfile!.subdistrictId
        : selectContractRegion.value.subdistrictId;

    final userlist =
        await _userRepo.initializeUserList(selectMaster, selectSubdistrictId);
    final modelList = userlist.map((e) => UserModel.fromJson(e)).toList();
    final filterList = modelList.where((e) => e.name != "탈퇴자").toList();
    return filterList;
  }
}

final userProvider = AsyncNotifierProvider<UserViewModel, List<UserModel?>>(
  () => UserViewModel(),
);

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/models/contract_region_model.dart';
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
    return await initializeUserList(selectContractRegion.value.subdistrictId);
  }

  Future<void> saveAdminUser(
      String notiUserId, ContractRegionModel selectRegionModel) async {
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
      "subdistrictId": selectRegionModel.subdistrictId != ""
          ? selectRegionModel.subdistrictId
          : adminProfileModel.subdistrictId,
      "contractCommunityId": selectRegionModel.contractCommunityId != ""
          ? selectRegionModel.contractCommunityId
          : null,
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

  Future<List<UserModel?>> initializeUserList(String subdistrictId) async {
    final userlist = await _userRepo.initializeUserList(subdistrictId);
    final modelList = userlist.map((e) => UserModel.fromJson(e)).toList();
    final filterList = modelList.where((e) => e.name != "탈퇴자").toList();
    return filterList;
  }
}

final userProvider = AsyncNotifierProvider<UserViewModel, List<UserModel?>>(
  () => UserViewModel(),
);

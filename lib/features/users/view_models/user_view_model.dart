import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/features/users/repo/user_repo.dart';
import 'package:onldocc_admin/retry.dart';

class UserViewModel extends AsyncNotifier<List<UserModel?>> {
  final UserRepository _userRepo = UserRepository();
  @override
  FutureOr<List<UserModel?>> build() async {
    return await retry(() async =>
        await initializeUserList(selectContractRegion.value!.subdistrictId));
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

  Future<List<UserModel>> initializeUserList(String subdistrictId) async {
    final userlist = await _userRepo.initializeUserList(subdistrictId);

    final modelList = userlist.map((json) {
      try {
        final model = UserModel.fromJson(json);

        return model;
      } catch (e, stack) {
        // // ignore: avoid_print
        // print("에러 발생한 JSON: $json");
        // // ignore: avoid_print
        // print("에러 메시지: $e");
        // // ignore: avoid_print
        // print("스택: $stack");
      }
    }).toList();
    final nonNullModelList = modelList.whereType<UserModel>().toList();
    state = AsyncData(nonNullModelList);
    return nonNullModelList;
  }
}

final userProvider = AsyncNotifierProvider<UserViewModel, List<UserModel?>>(
  () => UserViewModel(),
);

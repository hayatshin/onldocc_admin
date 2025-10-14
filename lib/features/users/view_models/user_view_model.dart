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
    final raw = await _userRepo.initializeUserList(subdistrictId);

    bool isBlank(String? s) {
      final v = s?.trim();
      if (v == null || v.isEmpty) return true;
      // 서버에서 "null" 문자열이 들어오는 경우도 배제
      return v.toLowerCase() == '-';
    }

    bool hasAllRequired(UserModel m) {
      return !isBlank(m.gender) &&
          !isBlank(m.phone) &&
          !isBlank(m.birthYear) &&
          !isBlank(m.birthDay);
    }

    final models = <UserModel>[];
    int dropped = 0;

    for (final json in raw) {
      try {
        // 2) 파싱
        final m = UserModel.fromJson(json);

        // 3) 필수값 검증 — 하나라도 비었으면 제외
        if (hasAllRequired(m)) {
          models.add(m);
        } else {
          dropped++;
        }
      } catch (_) {
        dropped++;
        // 필요하면 콘솔로 어떤 레코드가 떨어졌는지 찍어보세요:
        // print('initializeUserList: drop due to parse error -> $json');
      }
    }

    // 필요시 통계 로그
    // ignore: avoid_print
    print('initializeUserList: kept=${models.length}, dropped=$dropped');

    state = AsyncData(models);
    return models;
  }
}

final userProvider = AsyncNotifierProvider<UserViewModel, List<UserModel?>>(
  () => UserViewModel(),
);

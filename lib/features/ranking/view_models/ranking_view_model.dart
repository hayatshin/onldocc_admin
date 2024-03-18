import 'dart:async';

import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/ranking/repo/ranking_repo.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/features/users/view_models/user_view_model.dart';

class RankingViewModel extends AsyncNotifier<List<UserModel>> {
  final RankingRepository _rankingRepo = RankingRepository();
  @override
  FutureOr<List<UserModel>> build() async {
    return [];
  }

  Future<List<UserModel>> getUserPoints(DateRange range) async {
    List<UserModel?> userDataList = await ref
        .read(userProvider.notifier)
        .initializeUserList(selectContractRegion.value.subdistrictId);

    List<UserModel> nonNullUserList =
        userDataList.where((e) => e != null).cast<UserModel>().toList();

    final points = await _rankingRepo.getUserPoints(nonNullUserList, range);
    final userpoints = points.map((e) => UserModel.fromJson(e)).toList();
    userpoints.sort((a, b) => b.totalScore!.compareTo(a.totalScore!));

    return indexRankingModel(userpoints);
  }

  List<UserModel> indexRankingModel(List<UserModel> userList) {
    int count = 1;
    List<UserModel> list = [];

    for (int i = 0; i < userList.length - 1; i++) {
      UserModel indexUpdateUser = userList[i].copyWith(
        index: count,
      );
      list.add(indexUpdateUser);
      if (userList.length > i + 1) {
        if (userList[i].totalScore != userList[i + 1].totalScore) {
          count++;
        }
      }
    }

    return list;
  }
}

final rankingProvider =
    AsyncNotifierProvider<RankingViewModel, List<UserModel>>(
  () => RankingViewModel(),
);

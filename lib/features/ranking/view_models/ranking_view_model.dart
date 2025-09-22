import 'dart:async';

import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/ranking/repo/ranking_repo.dart';
import 'package:onldocc_admin/features/ranking/view/ranking_user_dashboard_screen.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/features/users/view_models/user_view_model.dart';

class RankingViewModel extends AsyncNotifier<List<UserModel>> {
  final RankingRepository _rankingRepo = RankingRepository();
  @override
  FutureOr<List<UserModel>> build() async {
    return [];
  }

  Future<List<UserModel>> getUserPoints(DateRange range) async {
    try {
      List<UserModel?> userDataList = ref.read(userProvider).value ??
          await ref
              .read(userProvider.notifier)
              .initializeUserList(selectContractRegion.value!.subdistrictId);

      List<UserModel> nonNullUserList =
          userDataList.where((e) => e != null).cast<UserModel>().toList();

      final points = await _rankingRepo.getUserPoints(nonNullUserList, range);

      final userpoints = points.map((e) => UserModel.fromJson(e)).toList();

      userpoints.sort((a, b) => b.totalPoint!.compareTo(a.totalPoint!));

      return indexRankingModel(userpoints);
    } catch (e) {
      // ignore: avoid_print
      print("getUserPoints: $e");
      return [];
    }
  }

  List<UserModel> indexRankingModel(List<UserModel> userList) {
    int count = 1;
    int samePoint = 0;
    List<UserModel> list = [];

    for (int i = 0; i < userList.length - 1; i++) {
      UserModel indexUpdateUser = userList[i].copyWith(
        index: count,
      );
      list.add(indexUpdateUser);
      if (userList.length > i + 1) {
        if (userList[i].totalPoint != userList[i + 1].totalPoint) {
          count = count + 1 + samePoint;
        } else {
          samePoint++;
        }
      }
    }

    return list;
  }

  Future<List<RankingDataSet>> getRankingData(
      String rankingType, String userId, DateRange dateRange) async {
    try {
      List<RankingDataSet> list;
      switch (rankingType) {
        case "일기":
          int index = 1;
          final query =
              await ref.read(rankingRepo).fetchUserDiary(userId, dateRange);
          list = query
              .map((e) => RankingDataSet(
                  index: index++,
                  createdAt: e["createdAt"],
                  content: e["todayDiary"]))
              .toList();
          break;
        case "걸음수":
          int index = 1;
          final query =
              await ref.read(rankingRepo).fetchUserSteps(userId, dateRange);
          list = query
              .map((e) => RankingDataSet(
                  index: index++,
                  stepDate: e["date"],
                  content: "${e["step"]}보"))
              .toList();
          break;
        case "댓글":
          int index = 1;
          final query =
              await ref.read(rankingRepo).fetchUserComments(userId, dateRange);
          list = query
              .map((e) => RankingDataSet(
                  index: index++,
                  createdAt: e["createdAt"],
                  content: e["description"]))
              .toList();
          break;
        case "좋아요":
          int index = 1;
          final query =
              await ref.read(rankingRepo).fetchUserLikes(userId, dateRange);
          list = query
              .map((e) => RankingDataSet(
                  index: index++, createdAt: e["createdAt"], content: ""))
              .toList();
          break;
        // case "친구초대":
        //   int index = 1;
        //   final query = await ref
        //       .read(rankingRepo)
        //       .fetchUserInvitations(userId, dateRange);
        //   list = query
        //       .map((e) => RankingDataSet(
        //           index: index++, createdAt: e["createdAt"], content: ""))
        //       .toList();
        //   break;
        default:
          list = [];
          break;
      }
      return list;
    } catch (e) {
      // ignore: avoid_print
      print("getRankingData -> $e");
    }
    return [];
  }
}

final rankingProvider =
    AsyncNotifierProvider<RankingViewModel, List<UserModel>>(
  () => RankingViewModel(),
);

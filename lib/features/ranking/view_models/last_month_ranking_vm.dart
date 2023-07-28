import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/ranking/repo/ranking_repo.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/features/users/view_models/user_view_model.dart';

import '../../../common/view_models/contract_config_view_model.dart';
import '../../users/repo/user_repo.dart';

class LastMonthRankingViewModel extends AsyncNotifier<List<UserModel?>> {
  late RankingRepository _rankingRepository;
  DateTime now = DateTime.now();
  late DateTime lastMonth;
  late DateTime firstDateOfLastMonth;
  late DateTime lastDateOfLastMonth;

  late List<UserModel?> monthUserList;

  @override
  FutureOr<List<UserModel?>> build() async {
    _rankingRepository = RankingRepository();
    DateTime now = DateTime.now();

    lastMonth = DateTime(now.year, now.month - 1, now.day);
    firstDateOfLastMonth = DateTime(lastMonth.year, lastMonth.month, 1);
    lastDateOfLastMonth = DateTime(lastMonth.year, lastMonth.month + 1, 0);

    print("firstDateOfLastMonth -> $firstDateOfLastMonth");
    print("lastDateOfLastMonth -> $lastDateOfLastMonth");

    // firstDateOfMonth = DateTime(now.year, now.month, 1);
    // firstDateOfMonth = DateTime(firstDateOfMonth.year, firstDateOfMonth.month,
    //     firstDateOfMonth.day, 0, 0);

    ref.watch(contractConfigProvider).when(
          data: (data) async {
            final String getUserContractType = data.contractType;
            final String getUserContractName = data.contractName;
            if (getUserContractType == "지역") {
              final userDataList = await ref
                  .watch(userRepo)
                  .getRegionUserData(getUserContractName);
              final monthUserList =
                  await updateUserScore(userDataList, "종합 점수");
              state = AsyncValue.data(monthUserList);
            } else if (getUserContractType == "기관") {
              final userDataList = await ref
                  .watch(userRepo)
                  .getCommunityUserData(getUserContractName);
              final monthUserList =
                  await updateUserScore(userDataList, "종합 점수");
              state = AsyncValue.data(monthUserList);
            } else if (getUserContractType == "마스터" ||
                getUserContractType == "전체") {
              final userDataList = await ref.watch(userRepo).getAllUserData();
              final monthUserList =
                  await updateUserScore(userDataList, "종합 점수");
              state = AsyncValue.data(monthUserList);
            }
          },
          error: (error, stackTrace) => print(error),
          loading: () {},
        );

    state = const AsyncValue.data([]);
    return [];
  }

  Future<List<UserModel?>> updateUserScore(
      List<UserModel?> users, String sortOrder) async {
    List<UserModel?> updateScoreList = [];
    state = const AsyncValue.loading();

    if (state.value!.isEmpty) {
      await Future.forEach(
        users,
        (user) async {
          final scoreUser = await calculateUserScore(user);
          updateScoreList.add(scoreUser);
        },
      );

      updateScoreList.sort((a, b) => b!.totalScore!.compareTo(a!.totalScore!));
      final indexList = ref
          .read(userProvider.notifier)
          .indexUserModel(sortOrder, updateScoreList);

      state = AsyncValue.data(indexList);
      return indexList;
    } else {
      state = AsyncValue.data(state.value!);
      return state.value!;
    }
  }

  Future<UserModel?> calculateUserScore(UserModel? user) async {
    final String userId = user!.userId;
    List<int> results;

    List<Future<int>> futures = [
      _rankingRepository.getUserDateStepScores(
          userId, firstDateOfLastMonth, lastDateOfLastMonth),
      _rankingRepository.getUserDateDiaryScores(
          userId, firstDateOfLastMonth, lastDateOfLastMonth),
      _rankingRepository.getUserDateCommentScores(
          userId, firstDateOfLastMonth, lastDateOfLastMonth),
    ];
    results = await Future.wait(futures);

    int userTotalScore = results[0] + results[1] + results[2];

    final updatedUser = user.copyWith(
      totalScore: userTotalScore,
      stepScore: results[0],
      diaryScore: results[1],
      commentScore: results[2],
    );
    return updatedUser;
  }
}

final lastMonthRankingProvider =
    AsyncNotifierProvider<LastMonthRankingViewModel, List<UserModel?>>(
  () => LastMonthRankingViewModel(),
);

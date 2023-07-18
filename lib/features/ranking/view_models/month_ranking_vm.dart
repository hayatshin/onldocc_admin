import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/ranking/repo/ranking_repo.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/features/users/view_models/user_view_model.dart';

import '../../../common/view_models/contract_config_view_model.dart';
import '../../users/repo/user_repo.dart';

class MonthRankingViewModel extends AsyncNotifier<List<UserModel?>> {
  late RankingRepository _rankingRepository;
  DateTime now = DateTime.now();
  late DateTime firstDateOfMonth;
  late List<UserModel?> monthUserList;

  @override
  FutureOr<List<UserModel?>> build() async {
    _rankingRepository = RankingRepository();
    DateTime now = DateTime.now();

    firstDateOfMonth = DateTime(now.year, now.month, 1);
    firstDateOfMonth = DateTime(firstDateOfMonth.year, firstDateOfMonth.month,
        firstDateOfMonth.day, 0, 0);

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
      _rankingRepository.getUserDateStepScores(userId, firstDateOfMonth, now),
      _rankingRepository.getUserDateDiaryScores(userId, firstDateOfMonth, now),
      _rankingRepository.getUserDateCommentScores(
          userId, firstDateOfMonth, now),
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

final monthRankingProvider =
    AsyncNotifierProvider<MonthRankingViewModel, List<UserModel?>>(
  () => MonthRankingViewModel(),
);

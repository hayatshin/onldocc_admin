import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/view_models/contract_config_view_model.dart';
import 'package:onldocc_admin/features/login/repo/authentication_repo.dart';
import 'package:onldocc_admin/features/ranking/repo/ranking_repo.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';

class RankingViewModel extends AsyncNotifier<void> {
  late RankingRepository _rankingRepository;
  late List<DocumentSnapshot<Map<String, dynamic>>> _stepAllDataList;
  late List<QueryDocumentSnapshot<Map<String, dynamic>>> _diaryAllDataList;
  late List<QueryDocumentSnapshot<Map<String, dynamic>>> _commentAllDataList;
  late List<QueryDocumentSnapshot<Map<String, dynamic>>> _userDiaryDataList;
  late List<QueryDocumentSnapshot<Map<String, dynamic>>> _userCommentDataList;

  @override
  FutureOr<void> build() async {
    const AsyncValue.loading();
    _rankingRepository = RankingRepository();

    // state = AsyncValue.guard(() => calculateUserScore(user, startDate, endDate))
  }

  Future<List<UserModel?>> updateUserScore(
      List<UserModel?> users, DateTime startDate, DateTime endDate) async {
    List<UserModel?> scoreUserList = [];
    await Future.forEach(users.sublist(0, 5), (UserModel? item) async {
      final scoreUser = await calculateUserScore(item, startDate, endDate);
      scoreUserList.add(scoreUser);
    });
    return scoreUserList;
  }

  Future<UserModel?> calculateUserScore(
      UserModel? user, DateTime startDate, DateTime endDate) async {
    int userStepScore = 0;
    int userDiaryScore = 0;
    int userCommentScore = 0;
    int userTotalScore = 0;
    final String userId = user!.userId;

    // DateTime now = DateTime.now();
    // DateTime firstDateOfMonth = DateTime(now.year, now.month, 1);
    // DateTime firstDateOfWeek = now.subtract(Duration(days: now.weekday - 1));

    final List<Object> results = await Future.wait([
      _rankingRepository.getDateStepQuery(startDate, endDate),
      _rankingRepository.getDateDiaryQuery(startDate, endDate),
      _rankingRepository.getDateCommentQuery(startDate, endDate),
    ]);
    _stepAllDataList =
        results[0] as List<DocumentSnapshot<Map<String, dynamic>>>;
    _diaryAllDataList =
        results[1] as List<QueryDocumentSnapshot<Map<String, dynamic>>>;
    _commentAllDataList =
        results[2] as List<QueryDocumentSnapshot<Map<String, dynamic>>>;

    _userDiaryDataList =
        _diaryAllDataList.where((e) => e.get("userId") == userId).toList();
    _userCommentDataList =
        _commentAllDataList.where((e) => e.get("userId") == userId).toList();

    for (var _stepData in _stepAllDataList) {
      Map<String, dynamic>? stepQuery = _stepData.data();
      if (stepQuery!.containsKey(userId)) {
        final int stepInt = stepQuery[userId];
        userStepScore += calculateDiaryStepPoint(stepInt);
      }
    }

    for (var _diaryData in _userDiaryDataList) {
      userDiaryScore += 100;
    }

    for (var _commentData in _userCommentDataList) {
      userCommentScore += 20;
    }

    userTotalScore = userStepScore + userDiaryScore + userCommentScore;

    final updatedUser = user.copyWith(
      totalScore: userTotalScore,
      stepScore: userStepScore,
      diaryScore: userDiaryScore,
      commentScore: userCommentScore,
    );

    return updatedUser;
  }

  int calculateDiaryStepPoint(int dailyStepInt) {
    dailyStepInt < 0
        ? 0
        : dailyStepInt > 10000
            ? 100
            : ((dailyStepInt / 1000).floor()) * 10;
    return dailyStepInt;
  }
}

final rankingProvider = AsyncNotifierProvider<RankingViewModel, void>(
  () => RankingViewModel(),
);

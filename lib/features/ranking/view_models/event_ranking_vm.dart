import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/event/models/event_user_model.dart';
import 'package:onldocc_admin/features/ranking/repo/ranking_repo.dart';

class EventRankingViewModel extends AsyncNotifier<void> {
  late RankingRepository _rankingRepository;
  DateTime now = DateTime.now();

  @override
  FutureOr<void> build() {
    _rankingRepository = RankingRepository();
  }

  Future<EventUserModel?> calculateUserScore(
    EventUserModel user,
    DateTime startDate,
    DateTime endDate,
    int goalScore,
  ) async {
    final String userId = user.userId!;
    List<int> results;

    List<Future<int>> futures = [
      _rankingRepository.getUserDateStepScores(userId, startDate, endDate),
      _rankingRepository.getUserDateDiaryScores(userId, startDate, endDate),
      _rankingRepository.getUserDateCommentScores(userId, startDate, endDate),
    ];
    results = await Future.wait(futures);

    int userTotalScore = results[0] + results[1] + results[2];
    bool goalOrNot = userTotalScore >= goalScore;

    final updatedUser = user.copyWith(
      userPoint: userTotalScore,
      goalOrNot: goalOrNot,
    );
    return updatedUser;
  }
}

final eventRankingProvider = AsyncNotifierProvider<EventRankingViewModel, void>(
  () => EventRankingViewModel(),
);

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/event/repo/event_repo.dart';
import 'package:onldocc_admin/features/ranking/repo/ranking_repo.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/features/users/view_models/user_view_model.dart';

class RankingViewModel extends AsyncNotifier<void> {
  final RankingRepository _rankingRepo = RankingRepository();
  final EventRepository _eventRepository = EventRepository();
  @override
  FutureOr<void> build() async {}

  // supabase
  Future<List<UserModel>> getUserPoints(DateRange range) async {
    final userList = ref.read(userProvider).value ??
        await ref.read(userProvider.notifier).initializeUserList();

    List<UserModel> nonNullUserList =
        userList.where((e) => e != null).cast<UserModel>().toList();

    final points = await _rankingRepo.getUserPoints(nonNullUserList, range);
    final userpoints = points.map((e) => UserModel.fromJson(e)).toList();
    userpoints.sort((a, b) => b.totalScore!.compareTo(a.totalScore!));

    return indexRankingModel(userpoints);
  }

  // firebase
  List<UserModel> indexRankingModel(List<UserModel> userList) {
    int count = 1;
    List<UserModel> list = [];

    for (int i = 0; i < userList.length - 1; i++) {
      UserModel indexUpdateUser = userList[i].copyWith(
        index: count,
      );
      list.add(indexUpdateUser);
      if (userList[i].totalScore != userList[i + 1].totalScore) {
        count++;
      }
    }

    return list;
  }

  int updateUserStepPoint(
      List<DocumentSnapshot<Map<String, dynamic>>> stepDocs, String userId) {
    int userTotalScore = 0;
    for (DocumentSnapshot<Map<String, dynamic>> document in stepDocs) {
      if (document.exists && document.data()!.containsKey(userId)) {
        int dailyStepInt = document.get(userId) as int;

        int userDailyScore = dailyStepInt < 0
            ? 0
            : dailyStepInt > 10000
                ? 100
                : ((dailyStepInt / 1000).floor()) * 10;
        userTotalScore += userDailyScore;
      }
    }
    return userTotalScore;
  }

  int updateUserDiaryPoint(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> diaryDocs,
      String userId) {
    int count = 0;

    for (QueryDocumentSnapshot<Map<String, dynamic>> document in diaryDocs) {
      Map<String, dynamic> data = document.data();
      if (data["userId"] == userId) {
        count++;
      }
    }
    return count * 100;
  }

  int updateUserCommentPoint(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> commentDocs,
      String userId) {
    int count = 0;
    for (QueryDocumentSnapshot<Map<String, dynamic>> document in commentDocs) {
      Map<String, dynamic> data = document.data();
      if (data["userId"] == userId) {
        count++;
      }
    }
    return count * 20;
  }

  Future<List<UserModel>> updateUsersListScore(
      DateTime startDate, DateTime endDate) async {
    List<UserModel?> userList =
        await ref.watch(userProvider.notifier).getContractUserList();

    final stepDocs = await _rankingRepo.getDateStepQuery(startDate, endDate);
    final diaryDocs = await _rankingRepo.getDateDiaryQuery(startDate, endDate);
    final commentDocs =
        await _rankingRepo.getDateCommentQuery(startDate, endDate);

    List<UserModel> updateScoreList =
        await Future.wait(userList.map((user) async {
      int stepScore = updateUserStepPoint(stepDocs, user!.userId);
      int diaryScore = updateUserDiaryPoint(diaryDocs, user.userId);
      int commentScore = updateUserCommentPoint(commentDocs, user.userId);

      int totalScore = stepScore + diaryScore + commentScore;
      final scoreUser = user.copyWith(
        stepScore: stepScore,
        diaryScore: diaryScore,
        commentScore: commentScore,
        totalScore: totalScore,
      );
      return scoreUser;
    }).toList());

    updateScoreList.sort((a, b) => b.totalScore!.compareTo(a.totalScore!));
    List<UserModel> indexList = indexRankingModel(updateScoreList);

    return indexList;
  }
}

final rankingProvider = AsyncNotifierProvider<RankingViewModel, void>(
  () => RankingViewModel(),
);

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/user-dashboard/models/user_ai_chat_model.dart';
import 'package:onldocc_admin/features/user-dashboard/models/user_cognition_data_test_model.dart';
import 'package:onldocc_admin/features/user-dashboard/models/user_dashboard_count_model.dart';
import 'package:onldocc_admin/features/user-dashboard/models/user_dashboard_diary_model.dart';
import 'package:onldocc_admin/features/user-dashboard/models/user_dashboard_quiz_model.dart';
import 'package:onldocc_admin/features/user-dashboard/models/user_step_data_model.dart';
import 'package:onldocc_admin/features/user-dashboard/repo/user_dashboard_repo.dart';

class UserDashboardViewModel extends AsyncNotifier<void> {
  final _userDashboardRepo = UserDashboardRepository();
  @override
  FutureOr<void> build() {}

  Future<List<UserDashboardDiaryModel>> userDiaryCount(
      int selectedStartSeconds, int selectedEndSeconds, String userId) async {
    final data = await _userDashboardRepo.userDiaryCount(
        selectedStartSeconds, selectedEndSeconds, userId);
    final modelList =
        data.map((element) => UserDashboardDiaryModel.from(element)).toList();
    return modelList;
  }

  Future<List<UserDashboardCountModel>> userCommentCount(
      int selectedStartSeconds, int selectedEndSeconds, String userId) async {
    final data = await _userDashboardRepo.userCommentCount(
        selectedStartSeconds, selectedEndSeconds, userId);
    final modelList =
        data.map((element) => UserDashboardCountModel.from(element)).toList();
    return modelList;
  }

  Future<List<UserDashboardCountModel>> userLikeCount(
      int selectedStartSeconds, int selectedEndSeconds, String userId) async {
    final data = await _userDashboardRepo.userLikeCount(
        selectedStartSeconds, selectedEndSeconds, userId);
    final modelList =
        data.map((element) => UserDashboardCountModel.from(element)).toList();
    return modelList;
  }

  Future<List<UserDashboardQuizModel>> userQuizMath(
      int selectedStartSeconds, int selectedEndSeconds, String userId) async {
    final data = await _userDashboardRepo.userQuizMath(
        selectedStartSeconds, selectedEndSeconds, userId);
    final modelList = data
        .map((element) => UserDashboardQuizModel.fromMath(element))
        .toList();
    return modelList;
  }

  Future<List<UserDashboardQuizModel>> userQuizMultipleChoices(
      int selectedStartSeconds, int selectedEndSeconds, String userId) async {
    final data = await _userDashboardRepo.userQuizMultipleChoices(
        selectedStartSeconds, selectedEndSeconds, userId);
    final modelList = data
        .map((element) => UserDashboardQuizModel.fromMultipleChoices(element))
        .toList();
    return modelList;
  }

  Future<List<UserCognitionDataTestModel>> userCognitionTest(
      int selectedStartSeconds, int selectedEndSeconds, String userId) async {
    final data = await _userDashboardRepo.userCognitionTest(
        selectedStartSeconds, selectedEndSeconds, userId);
    final modelList = data
        .map((element) => UserCognitionDataTestModel.from(element))
        .toList();
    return modelList;
  }

  Future<List<UserAiChatModel>> userAiChat(
      int selectedStartSeconds, int selectedEndSeconds, String userId) async {
    final data = await _userDashboardRepo.userAiChat(
        selectedStartSeconds, selectedEndSeconds, userId);
    final modelList =
        data.map((element) => UserAiChatModel.from(element)).toList();
    return modelList;
  }

  Future<List<UserStepDataModel>> userSteps(
      List<String> dateStrings, String userId) async {
    final data = await _userDashboardRepo.userSteps(dateStrings, userId);
    final modelList =
        data.map((element) => UserStepDataModel.from(element)).toList();
    return modelList;
  }
}

final userDashboardProvider =
    AsyncNotifierProvider<UserDashboardViewModel, void>(
  () => UserDashboardViewModel(),
);

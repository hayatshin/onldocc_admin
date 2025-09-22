import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/dashboard/model/ai_chat_model.dart';
import 'package:onldocc_admin/features/dashboard/model/cognition_data_test_model.dart';
import 'package:onldocc_admin/features/dashboard/model/dashboard_count_model.dart';
import 'package:onldocc_admin/features/dashboard/model/step_data_model.dart';
import 'package:onldocc_admin/features/dashboard/repo/dashboard_repo.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';

class DashboardViewModel extends AsyncNotifier<void> {
  final _dashboardRepo = DashboardRepository();
  @override
  FutureOr<void> build() {}

  Future<List<DashboardCountModel>> visitCount(
      int selectedStartSeconds, int selectedEndSeconds) async {
    final data = await _dashboardRepo.visitCount(
        selectedStartSeconds, selectedEndSeconds);

    final modelList =
        data.map((element) => DashboardCountModel.from(element)).toList();
    if (selectContractRegion.value!.contractCommunityId == null ||
        selectContractRegion.value!.contractCommunityId == "") {
      // 전체보기
      return modelList;
    } else {
      // 기관 선택
      final filterList = modelList
          .where((e) =>
              e.userContractCommunityId ==
              selectContractRegion.value!.contractCommunityId)
          .toList();

      return filterList;
    }
  }

  Future<List<UserModel>> userCount(
      int selectedStartSeconds, int selectedEndSeconds) async {
    final data = await _dashboardRepo.userCount(
        selectedStartSeconds, selectedEndSeconds);
    final modelList =
        data.map((element) => UserModel.fromJson(element)).toList();

    if (selectContractRegion.value!.contractCommunityId == null) {
      // 전체보기
      return modelList;
    } else {
      // 기관 선택
      final filterList = modelList
          .where((e) =>
              e.contractCommunityId ==
              selectContractRegion.value!.contractCommunityId)
          .toList();

      return filterList;
    }
  }

  Future<List<DashboardCountModel>> diaryCount(
      int selectedStartSeconds, int selectedEndSeconds) async {
    final data = await _dashboardRepo.diaryCount(
        selectedStartSeconds, selectedEndSeconds);

    final modelList =
        data.map((element) => DashboardCountModel.from(element)).toList();

    if (selectContractRegion.value!.contractCommunityId == null ||
        selectContractRegion.value!.contractCommunityId == "") {
      // 전체보기
      return modelList;
    } else {
      // 기관 선택
      final filterList = modelList
          .where((e) =>
              e.userContractCommunityId ==
              selectContractRegion.value!.contractCommunityId)
          .toList();

      return filterList;
    }
  }

  Future<List<DashboardCountModel>> commentCount(
      int selectedStartSeconds, int selectedEndSeconds) async {
    final data = await _dashboardRepo.commentCount(
        selectedStartSeconds, selectedEndSeconds);
    final modelList =
        data.map((element) => DashboardCountModel.from(element)).toList();

    if (selectContractRegion.value!.contractCommunityId == null) {
      // 전체보기
      return modelList;
    } else {
      // 기관 선택
      final filterList = modelList
          .where((e) =>
              e.userContractCommunityId ==
              selectContractRegion.value!.contractCommunityId)
          .toList();

      return filterList;
    }
  }

  Future<List<DashboardCountModel>> likeCount(
      int selectedStartSeconds, int selectedEndSeconds) async {
    final data = await _dashboardRepo.likeCount(
        selectedStartSeconds, selectedEndSeconds);
    final modelList =
        data.map((element) => DashboardCountModel.from(element)).toList();

    if (selectContractRegion.value!.contractCommunityId == null) {
      // 전체보기
      return modelList;
    } else {
      // 기관 선택
      final filterList = modelList
          .where((e) =>
              e.userContractCommunityId ==
              selectContractRegion.value!.contractCommunityId)
          .toList();

      return filterList;
    }
  }

  Future<List<DashboardCountModel>> quizMath(
      int selectedStartSeconds, int selectedEndSeconds) async {
    final data =
        await _dashboardRepo.quizMath(selectedStartSeconds, selectedEndSeconds);
    final modelList =
        data.map((element) => DashboardCountModel.from(element)).toList();

    if (selectContractRegion.value!.contractCommunityId == null) {
      // 전체보기
      return modelList;
    } else {
      // 기관 선택
      final filterList = modelList
          .where((e) =>
              e.userContractCommunityId ==
              selectContractRegion.value!.contractCommunityId)
          .toList();

      return filterList;
    }
  }

  Future<List<DashboardCountModel>> quizMultipleChoices(
      int selectedStartSeconds, int selectedEndSeconds) async {
    final data = await _dashboardRepo.quizMultipleChoices(
        selectedStartSeconds, selectedEndSeconds);
    final modelList =
        data.map((element) => DashboardCountModel.from(element)).toList();

    if (selectContractRegion.value!.contractCommunityId == null) {
      // 전체보기
      return modelList;
    } else {
      // 기관 선택
      final filterList = modelList
          .where((e) =>
              e.userContractCommunityId ==
              selectContractRegion.value!.contractCommunityId)
          .toList();

      return filterList;
    }
  }

  Future<List<CognitionDataTestModel>> cognitionTest(
      int selectedStartSeconds, int selectedEndSeconds) async {
    final data = await _dashboardRepo.cognitionTest(
        selectedStartSeconds, selectedEndSeconds);
    final modelList =
        data.map((element) => CognitionDataTestModel.from(element)).toList();

    if (selectContractRegion.value!.contractCommunityId == null) {
      // 전체보기
      return modelList;
    } else {
      // 기관 선택
      final filterList = modelList
          .where((e) =>
              e.userContractCommunityId ==
              selectContractRegion.value!.contractCommunityId)
          .toList();

      return filterList;
    }
  }

  Future<List<AiChatModel>> aiChat(
      int selectedStartSeconds, int selectedEndSeconds) async {
    final data =
        await _dashboardRepo.aiChat(selectedStartSeconds, selectedEndSeconds);
    final modelList = data.map((element) => AiChatModel.from(element)).toList();

    if (selectContractRegion.value!.contractCommunityId == null) {
      // 전체보기
      return modelList;
    } else {
      // 기관 선택
      final filterList = modelList
          .where((e) =>
              e.userContractCommunityId ==
              selectContractRegion.value!.contractCommunityId)
          .toList();

      return filterList;
    }
  }

  Future<List<StepDataModel>> steps(List<String> dateStrings) async {
    final data = await _dashboardRepo.steps(dateStrings);
    final modelList =
        data.map((element) => StepDataModel.from(element)).toList();

    if (selectContractRegion.value!.contractCommunityId == null) {
      // 전체보기
      return modelList;
    } else {
      // 기관 선택
      final filterList = modelList
          .where((e) =>
              e.userContractCommunityId ==
              selectContractRegion.value!.contractCommunityId)
          .toList();

      return filterList;
    }
  }
}

final dashboardProvider = AsyncNotifierProvider<DashboardViewModel, void>(
  () => DashboardViewModel(),
);

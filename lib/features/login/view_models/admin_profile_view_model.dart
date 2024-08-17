import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/models/contract_region_model.dart';
import 'package:onldocc_admin/common/repo/contract_config_repo.dart';
import 'package:onldocc_admin/features/dashboard/view/dashboard_screen.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/repo/authentication_repo.dart';
import 'package:onldocc_admin/features/users/repo/user_repo.dart';
import 'package:onldocc_admin/features/users/view_models/user_view_model.dart';
import 'package:onldocc_admin/retry.dart';
import 'package:onldocc_admin/utils.dart';

class AdminProfileViewModel extends AsyncNotifier<AdminProfileModel> {
  final AuthenticationRepository _authRepository = AuthenticationRepository();
  final UserRepository _userRepo = UserRepository();

  final String emailFirebaseError = "auth/invalid-email";
  final String passwordFirebaseError = "auth/wrong-password";

  final String emailErrorMessage = "일치하는 이메일 주소가 없습니다.";
  final String passwordErrorMessage = "잘못된 비밀번호 입니다.";
  final String defaultErrorMessage = "로그인 과정에서 오류가 발생했습니다.";

  @override
  FutureOr<AdminProfileModel> build() async {
    state = const AsyncValue.loading();
    return await retry(getAdminProfile);
  }

  Future<AdminProfileModel> getAdminProfile() async {
    late AdminProfileModel adminProfileModel;

    Map<String, dynamic>? adminProfile =
        await _authRepository.getAdminProfile(_authRepository.user!.uid);
    adminProfileModel = AdminProfileModel.fromJson(adminProfile!);
    selectContractRegion.value = ContractRegionModel(
      name: adminProfileModel.name,
      contractRegionId: adminProfileModel.contractRegionId,
      subdistrictId: adminProfileModel.subdistrictId,
      image: adminProfileModel.image,
    );
    state = AsyncData(adminProfileModel);
    return adminProfileModel;
  }

  Future<AdminProfileModel?> login(
      String email, String password, BuildContext context) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () async {
        await _authRepository.signIn(email, password);
        Map<String, dynamic>? adminProfile =
            await _authRepository.getAdminProfile(_authRepository.user!.uid);
        final adminProfileModel = AdminProfileModel.fromJson(adminProfile!);
        await ref
            .read(userProvider.notifier)
            .initializeUserList(adminProfileModel.subdistrictId);

        selectContractRegion.value = ContractRegionModel(
          name: adminProfileModel.name,
          contractRegionId: adminProfileModel.contractRegionId,
          subdistrictId: adminProfileModel.subdistrictId,
          image: adminProfileModel.image,
        );
        return adminProfileModel;
      },
    );

    if (!state.hasError) {
      if (!context.mounted) return null;
      context.goNamed(DashboardScreen.routeName);
    } else {
      if (state.error.toString().contains(emailFirebaseError)) {
        if (!context.mounted) return null;

        showWarningSnackBar(context, emailErrorMessage);
      } else if (state.error.toString().contains(passwordFirebaseError)) {
        if (!context.mounted) return null;

        showWarningSnackBar(context, passwordErrorMessage);
      } else {
        // ignore: avoid_print
        print("로그인 에러 -> ${state.error.toString()}");
        if (!context.mounted) return null;
        showWarningSnackBar(context, defaultErrorMessage);
      }
    }
    return null;
  }

  Future<AdminProfileModel> logOut(BuildContext context) async {
    state = AsyncValue.data(AdminProfileModel.empty());
    state = await AsyncValue.guard(
      () async {
        context.go("/");
        await _authRepository.signOut();
        return AdminProfileModel.empty();
      },
    );
    return AdminProfileModel.empty();
  }

  Future<void> saveAdminUser(
      String notiUserId, ContractRegionModel selectRegionModel) async {
    AdminProfileModel? adminProfileModel = ref.read(adminProfileProvider).value;

    final name = notiUserId.contains("region")
        ? await ref
            .read(contractRepo)
            .convertSubdistrictIdToName(selectRegionModel.subdistrictId)
        : await ref.read(contractRepo).convertContractCommunityIdToName(
            selectRegionModel.contractCommunityId);

    final userJson = {
      "userId": notiUserId,
      "avatar": adminProfileModel!.image,
      "loginType": "어드민",
      "gender": "남성",
      "birthYear": "1960",
      "birthDay": "0101",
      "phone": adminProfileModel.phone,
      "name": name.split(' ').last,
      "createdAt": getCurrentSeconds(),
      "subdistrictId": selectRegionModel.subdistrictId != ""
          ? selectRegionModel.subdistrictId
          : adminProfileModel.subdistrictId,
      "contractCommunityId": selectRegionModel.contractCommunityId != ""
          ? selectRegionModel.contractCommunityId
          : null,
    };
    await _userRepo.saveAdminUser(userJson);
  }
}

final adminProfileProvider =
    AsyncNotifierProvider<AdminProfileViewModel, AdminProfileModel>(
  () => AdminProfileViewModel(),
);

final selectContractRegion = ValueNotifier<ContractRegionModel?>(null);

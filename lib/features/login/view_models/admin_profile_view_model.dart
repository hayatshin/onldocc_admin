import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/models/contract_region_model.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/repo/authentication_repo.dart';
import 'package:onldocc_admin/features/users/view/users_screen.dart';
import 'package:onldocc_admin/utils.dart';

class AdminProfileViewModel extends AsyncNotifier<AdminProfileModel?> {
  late final AuthenticationRepository _authRepository;
  final String emailFirebaseError = "auth/invalid-email";
  final String passwordFirebaseError = "auth/wrong-password";

  final String emailErrorMessage = "일치하는 이메일 주소가 없습니다.";
  final String passwordErrorMessage = "잘못된 비밀번호 입니다.";
  final String defaultErrorMessage = "로그인 과정에서 오류가 발생했습니다.";

  @override
  FutureOr<AdminProfileModel> build() async {
    _authRepository = ref.read(authRepo);
    state = const AsyncValue.loading();
    if (_authRepository.isLoggedIn) {
      final adminProfile =
          await _authRepository.getAdminProfile(_authRepository.user!.uid);
      if (adminProfile != null) {
        return AdminProfileModel.fromJson(adminProfile);
      }
    }
    return AdminProfileModel.empty();
  }

  Future<AdminProfileModel?> getAdminProfile() async {
    late AdminProfileModel adminProfileModel;

    Map<String, dynamic>? adminProfile =
        await _authRepository.getAdminProfile(_authRepository.user!.uid);
    if (adminProfile != null) {
      adminProfileModel = AdminProfileModel.fromJson(adminProfile);
      selectContractRegion.value = ContractRegionModel(
        name: adminProfileModel.name,
        contractRegionId: adminProfileModel.contractRegionId,
        subdistrictId: adminProfileModel.subdistrictId,
        image: adminProfileModel.image,
      );
      return adminProfileModel;
    }
    return null;
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
      context.goNamed(UsersScreen.routeName);
    } else {
      if (state.error.toString().contains(emailFirebaseError)) {
        if (!context.mounted) return null;

        showSnackBar(context, emailErrorMessage);
      } else if (state.error.toString().contains(passwordFirebaseError)) {
        if (!context.mounted) return null;

        showSnackBar(context, passwordErrorMessage);
      } else {
        // ignore: avoid_print
        print("로그인 에러 -> ${state.error.toString()}");
        if (!context.mounted) return null;
        showSnackBar(context, defaultErrorMessage);
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
}

final adminProfileProvider =
    AsyncNotifierProvider<AdminProfileViewModel, AdminProfileModel?>(
  () => AdminProfileViewModel(),
);

final selectContractRegion =
    ValueNotifier<ContractRegionModel>(ContractRegionModel.empty());

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/repo/authentication_repo.dart';

class ContractConfigViewModel extends AsyncNotifier<void> {
  final AuthenticationRepository _authRepository = AuthenticationRepository();

  @override
  FutureOr<void> build() async {}

  Future<AdminProfileModel> getMyAdminProfile() async {
    final userId = _authRepository.user!.uid;
    final adminData = await _authRepository.getAdminProfile(userId);
    final adminProfile = AdminProfileModel.fromJson(adminData!);
    return adminProfile;
  }
}

final contractConfigProvider =
    AsyncNotifierProvider<ContractConfigViewModel, void>(
  () => ContractConfigViewModel(),
);

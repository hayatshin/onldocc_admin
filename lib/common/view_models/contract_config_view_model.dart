import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/models/contract_region_model.dart';
import 'package:onldocc_admin/common/repo/contract_config_repo.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/repo/authentication_repo.dart';

class ContractConfigViewModel extends AsyncNotifier<void> {
  final AuthenticationRepository _authRepository = AuthenticationRepository();
  late ContractConfigRepository _contractConfigRepo;

  @override
  FutureOr<void> build() async {
    _contractConfigRepo = ContractConfigRepository();
  }

  Future<AdminProfileModel> getMyAdminProfile() async {
    final userId = _authRepository.user!.uid;
    final adminData = await _authRepository.getAdminProfile(userId);
    final adminProfile = AdminProfileModel.fromJson(adminData!);
    return adminProfile;
  }

  Future<List<ContractRegionModel>> getRegionItems() async {
    final regionlist = await _contractConfigRepo.getRegionItems();
    return regionlist!.map((e) => ContractRegionModel.fromJson(e)).toList();
  }
}

final contractConfigProvider =
    AsyncNotifierProvider<ContractConfigViewModel, void>(
  () => ContractConfigViewModel(),
);

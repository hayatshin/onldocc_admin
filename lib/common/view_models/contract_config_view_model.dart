import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/models/contract_config_model.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/repo/authentication_repo.dart';

class ContractConfigViewModel extends AsyncNotifier<ContractConfigModel> {
  late final AuthenticationRepository _authRepository;

  @override
  FutureOr<ContractConfigModel> build() async {
    _authRepository = ref.read(authRepo);

    final userId = _authRepository.user!.uid;
    final adminData = await _authRepository.getAdminProfile(userId);
    final adminProfile = AdminProfileModel.fromJson(adminData!);
    if (!adminProfile.master) {
      return ContractConfigModel(
          contractType: adminProfile.contractType,
          contractName: "${adminProfile.region} ${adminProfile.smallRegion}");
    }
    return ContractConfigModel(
      contractType: adminProfile.contractType,
      contractName: adminProfile.region,
    );
  }

  Future<void> setContractType(String value) async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(state.value!.copyWith(contractType: value));
  }

  Future<void> setContractName(String value) async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(state.value!.copyWith(contractName: value));
  }
}

final contractConfigProvider =
    AsyncNotifierProvider<ContractConfigViewModel, ContractConfigModel>(
  () => ContractConfigViewModel(),
);

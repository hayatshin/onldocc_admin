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
    final adminData =
        await _authRepository.getAdminProfile(_authRepository.user!.uid);
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

  void setContractType(String value) {
    final previousCommunityName = state.value!.contractName;
    final contractConfig = AsyncValue.data(
      ContractConfigModel(
          contractType: value, contractName: previousCommunityName),
    );
    state = contractConfig;
  }

  void setContractName(String value) {
    final previousCommunityType = state.value!.contractType;
    final contractConfig = AsyncValue.data(
      ContractConfigModel(
          contractType: previousCommunityType, contractName: value),
    );
    state = contractConfig;
  }
}

final contractConfigProvider =
    AsyncNotifierProvider<ContractConfigViewModel, ContractConfigModel>(
  () => ContractConfigViewModel(),
);

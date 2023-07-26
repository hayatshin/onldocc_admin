import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/models/contract_config_model.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/repo/authentication_repo.dart';

class ContractConfigViewModel extends AsyncNotifier<ContractConfigModel> {
  late final AuthenticationRepository _authRepository;

  @override
  FutureOr<ContractConfigModel> build() async {
    state = const AsyncValue.loading();

    _authRepository = ref.read(authRepo);
    late ContractConfigModel contractConfigModel;

    final userId = _authRepository.user!.uid;
    final adminData = await _authRepository.getAdminProfile(userId);
    final adminProfile = AdminProfileModel.fromJson(adminData!);
    if (!adminProfile.master) {
      String contractType = adminProfile.contractType;
      if (contractType == "지역") {
        // 지역
        contractConfigModel = ContractConfigModel(
            contractType: adminProfile.contractType,
            contractName: "${adminProfile.region} ${adminProfile.smallRegion}");
      } else if (contractType == "기관") {
        // 기관
        contractConfigModel = ContractConfigModel(
          contractType: adminProfile.contractType,
          contractName: adminProfile.region,
        );
      }
    } else {
      // 마스터
      contractConfigModel = ContractConfigModel(
        contractType: adminProfile.contractType,
        contractName: adminProfile.region,
      );
    }

    state = AsyncValue.data(contractConfigModel);
    return contractConfigModel;
  }

  Future<ContractConfigModel> updateContractConfigModel(
      AdminProfileModel adminProfile) async {
    state = const AsyncValue.loading();
    final contractType = adminProfile.contractType;
    late ContractConfigModel contractConfigModel;

    if (!adminProfile.master) {
      if (contractType == "지역") {
        // 지역
        contractConfigModel = ContractConfigModel(
            contractType: adminProfile.contractType,
            contractName: "${adminProfile.region} ${adminProfile.smallRegion}");
      } else if (contractType == "기관") {
        // 기관
        contractConfigModel = ContractConfigModel(
          contractType: adminProfile.contractType,
          contractName: adminProfile.region,
        );
      } else {
        // 마스터
        contractConfigModel = ContractConfigModel(
          contractType: adminProfile.contractType,
          contractName: adminProfile.region,
        );
      }
    }

    state = AsyncValue.data(contractConfigModel);
    return contractConfigModel;
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

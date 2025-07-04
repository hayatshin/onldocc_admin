import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/care/models/care_model.dart';
import 'package:onldocc_admin/features/care/repo/care_repo.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';

class CareViewModel extends AsyncNotifier<void> {
  final CareRepository _careRepo = CareRepository();
  @override
  FutureOr<void> build() {}

  Future<List<CareModel>> fetchPartners(
      AdminProfileModel adminProfileModel) async {
    final data = await _careRepo.fetchPartners(adminProfileModel);
    return data.map((element) => CareModel.fromJson(element)).toList();
  }
}

final careProvider =
    AsyncNotifierProvider<CareViewModel, void>(() => CareViewModel());

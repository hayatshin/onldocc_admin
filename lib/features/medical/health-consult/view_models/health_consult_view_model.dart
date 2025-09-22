import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/medical/health-consult/models/health_consult_inquiry_model.dart';
import 'package:onldocc_admin/features/medical/health-consult/models/health_consult_response_model.dart';
import 'package:onldocc_admin/features/medical/health-consult/repo/health_consult_repo.dart';

class HealthConsultViewModel extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<List<HealthConsultInquiryModel>> fetchAllHealthConsults() async {
    final data = await ref.read(healthConsultRepo).fetchAllHealthConsults();
    final models =
        data.map((e) => HealthConsultInquiryModel.fromJson(e)).toList();
    return models;
  }

  Future<void> insertHealthConsultResponse(
      HealthConsultResponseModel model) async {
    await ref
        .read(healthConsultRepo)
        .insertHealthConsultResponse(model.toJson());
  }
}

final healthConsultProvider =
    AsyncNotifierProvider<HealthConsultViewModel, void>(
        () => HealthConsultViewModel());

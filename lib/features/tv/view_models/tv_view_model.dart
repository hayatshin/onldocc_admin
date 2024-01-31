import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/tv/models/tv_model.dart';
import 'package:onldocc_admin/features/tv/repo/tv_repo.dart';

class TvViewModel extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() async {}

  Future<List<TvModel>> getUserTvs() async {
    AdminProfileModel? adminProfileModel = ref.read(adminProfileProvider).value;
    final tvList = await ref.read(tvRepo).getUserTvs(adminProfileModel!);
    return tvList.map((e) => TvModel.fromJson(e)).toList();
  }
}

final tvProvider = AsyncNotifierProvider<TvViewModel, void>(
  () => TvViewModel(),
);

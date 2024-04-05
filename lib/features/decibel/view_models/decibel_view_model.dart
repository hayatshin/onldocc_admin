import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/decibel/models/decibel_model.dart';
import 'package:onldocc_admin/features/decibel/repo/decibel_repo.dart';

class DecibelViewModel extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<List<DecibelModel>> fetchUserDecibels(String userSubdistrictId) async {
    final data =
        await ref.read(decibelRepo).fetchUserDecibels(userSubdistrictId);
    return data.map((e) => DecibelModel.fromJson(e)).toList();
  }
}

final decibelProvider = AsyncNotifierProvider<DecibelViewModel, void>(
  () => DecibelViewModel(),
);

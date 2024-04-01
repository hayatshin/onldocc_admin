import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/tv/models/tv_model.dart';
import 'package:onldocc_admin/features/tv/repo/tv_repo.dart';
import 'package:uuid/uuid.dart';

class TvViewModel extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() async {}

  Future<List<TvModel>> getUserTvs() async {
    AdminProfileModel? adminProfileModel = ref.read(adminProfileProvider).value;

    final tvList = await ref.read(tvRepo).getUserTvs(
        adminProfileModel!, selectContractRegion.value.contractRegionId!);
    return tvList.map((e) => TvModel.fromJson(e)).toList();
  }

  Future<void> addTv(TvModel model, Uint8List? videoFile) async {
    try {
      // ignore: avoid_print
      if (model.videoType == "youtube" ||
          (model.videoType == "file" && videoFile == null)) {
        await ref.read(tvRepo).addTv(model);
      } else {
        final link = await ref.read(tvRepo).uplaodTvToSupabase(videoFile!);

        final newModel = model.copyWith(
          videoId: const Uuid().v4(),
          link: link,
        );
        await ref.read(tvRepo).addTv(newModel);
      }
    } catch (e) {
      // ignore: avoid_print
      print("addTv: error -> $e");
    }
  }
}

final tvProvider = AsyncNotifierProvider<TvViewModel, void>(
  () => TvViewModel(),
);

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/invitation/models/invitation_model.dart';
import 'package:onldocc_admin/features/invitation/repo/invitation_repo.dart';

class InvitationViewModel extends AsyncNotifier<List<InvitationModel>> {
  @override
  FutureOr<List<InvitationModel>> build() {
    throw UnimplementedError();
  }

  Future<List<InvitationModel>> fetchInvitations(
      String userSubdistrictId) async {
    final data =
        await ref.read(invitationRepo).fetchInvitations(userSubdistrictId);
    final models =
        data.map((element) => InvitationModel.fromJson(element)).toList();

    models.sort((a, b) => b.sendCounts.compareTo(a.sendCounts));
    return indexRankingModel(models);
  }

  Future<List<ReceiveUser>> fetchUserInvitation(String userId) async {
    final iDatas = await ref.read(invitationRepo).fetchUserInvitation(userId);

    return iDatas.map((element) => ReceiveUser.fromJson(element)).toList();
  }
}

List<InvitationModel> indexRankingModel(List<InvitationModel> modelList) {
  int count = 1;
  List<InvitationModel> list = [];

  for (int i = 0; i < modelList.length; i++) {
    InvitationModel indexUpdateUser = modelList[i].copyWith(
      index: count,
    );
    list.add(indexUpdateUser);
    if (modelList.length > i + 1) {
      if (modelList[i].sendCounts != modelList[i + 1].sendCounts) {
        count++;
      }
    }
  }

  return list;
}

final invitationProvider =
    AsyncNotifierProvider<InvitationViewModel, List<InvitationModel>>(
  () => InvitationViewModel(),
);

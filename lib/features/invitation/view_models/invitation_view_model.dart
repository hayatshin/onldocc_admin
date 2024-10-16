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
    List<InvitationModel> sendUsers = [];
    final iDatas =
        await ref.read(invitationRepo).fetchInvitations(userSubdistrictId);

    for (final iData in iDatas) {
      bool hasSendUserId =
          sendUsers.any((sendUser) => sendUser.userId == iData["sendUserId"]);
      if (hasSendUserId) {
        final sendUserInstance = sendUsers
            .firstWhere((sendUser) => sendUser.userId == iData["sendUserId"]);
        sendUserInstance.receiveUsers = [
          ...sendUserInstance.receiveUsers,
          ReceiveUser.fromJson(iData["receiveUsers"], iData["createdAt"])
        ];
      } else {
        sendUsers.add(
          InvitationModel.fromJson(iData),
        );
      }
    }

    // final modelList = invitationData.map((e) {
    //   final map = Map<String, dynamic>.from(e);
    //   return InvitationModel.fromJson(map);
    // }).toList();
    sendUsers
        .sort((a, b) => b.receiveUsers.length.compareTo(a.receiveUsers.length));
    return indexRankingModel(sendUsers);
  }

  Future<List<ReceiveUser>> fetchUserInvitation(String userId) async {
    List<ReceiveUser> receivedUsers = [];

    final iDatas = await ref.read(invitationRepo).fetchUserInvitation(userId);
    for (final iData in iDatas) {
      receivedUsers
          .add(ReceiveUser.fromJson(iData["receiveUsers"], iData["createdAt"]));
    }

    return receivedUsers;
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
      if (modelList[i].receiveUsers.length !=
          modelList[i + 1].receiveUsers.length) {
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

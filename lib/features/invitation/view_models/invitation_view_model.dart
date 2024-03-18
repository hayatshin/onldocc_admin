import 'dart:async';

import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/invitation/models/invitation_model.dart';
import 'package:onldocc_admin/features/invitation/repo/invitation_repo.dart';

class InvitationViewModel extends AsyncNotifier<List<InvitationModel>> {
  @override
  FutureOr<List<InvitationModel>> build() {
    throw UnimplementedError();
  }

  Future<List<InvitationModel>> fetchInvitations(
      DateRange dateRange, String userSubdistrictId) async {
    final invitationData = await ref
        .read(invitationRepo)
        .fetchInvitations(dateRange.start, dateRange.end, userSubdistrictId);
    final modelList = invitationData.map((e) {
      final map = Map<String, dynamic>.from(e);
      return InvitationModel.fromJson(map);
    }).toList();
    modelList.sort((a, b) => b.invitationCount.compareTo(a.invitationCount));
    return indexRankingModel(modelList);
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
      if (modelList[i].invitationCount != modelList[i + 1].invitationCount) {
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

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/notice/repo/notice_repo.dart';
import 'package:onldocc_admin/features/ranking/models/diary_model.dart';
import 'package:onldocc_admin/features/users/repo/user_repo.dart';
import 'package:onldocc_admin/utils.dart';

class NoticeViewModel extends AsyncNotifier<void> {
  late AdminProfileModel? adminProfileModel;

  @override
  FutureOr<void> build() {
    adminProfileModel = ref.read(adminProfileProvider).value;
  }

  Future<List<DiaryModel>> fetchAllNotices() async {
    final notices = await ref
        .read(noticeRepo)
        .fetchAllNotices(selectContractRegion.value!.subdistrictId);
    return notices.map((e) => DiaryModel.fromJson(e)).toList();
  }

  Future<void> addFeedNotification(
    AdminProfileModel adminProfileModel,
    String todayDiary,
    List<dynamic> imageList,
    bool noticeTopFixed,
    int noticeFixedAt,
  ) async {
    final notiUserId = adminProfileModel.master
        ? "noti:injicare"
        : selectContractRegion.value!.contractCommunityId == "" ||
                selectContractRegion.value!.contractCommunityId == null
            ? "noti:region:${adminProfileModel.subdistrictId}"
            : "noti:community:${selectContractRegion.value!.contractCommunityId}";
    final diaryId = "${getCurrentSeconds()}_$notiUserId:true";

    DiaryModel feedNotiModel = DiaryModel(
      userId: notiUserId,
      diaryId: diaryId,
      createdAt: getCurrentSeconds(),
      secretType: "전체 공개",
      todayMood: 0,
      numLikes: 0,
      numComments: 0,
      todayDiary: todayDiary,
      notice: true,
      noticeTopFixed: noticeTopFixed,
      noticeFixedAt: noticeFixedAt,
    );

    final isUserExist = await ref.read(userRepo).checkUserExists(notiUserId);

    if (!isUserExist) {
      await ref
          .read(adminProfileProvider.notifier)
          .saveAdminUser(notiUserId, selectContractRegion.value!);
    }

    await ref.read(noticeRepo).addFeedNotification(feedNotiModel.toJson());

    if (imageList.isNotEmpty) {
      await ref.read(noticeRepo).uploadImageFileToStorage(diaryId, imageList);
    }
  }

  Future<void> editFeedNotification(
    String diaryId,
    String todayDiary,
    List<dynamic> imageList,
    bool noticeTopFixed,
    int noticeFixedAt,
  ) async {
    await ref.read(noticeRepo).editFeedNotificationTodayDiary(
        diaryId, todayDiary, noticeTopFixed, noticeFixedAt);
    await ref.read(noticeRepo).uploadImageFileToStorage(diaryId, imageList);
  }

  Future<void> changeAdminSecretDiary(
    String diaryId,
    bool currentSecret,
  ) async {
    try {
      final parts = diaryId.split(':');
      String newDiaryId =
          "${parts.sublist(0, parts.length - 1).join(":")}:${!currentSecret}";
      await ref
          .read(noticeRepo)
          .editFeedNotificationDiaryId(diaryId, newDiaryId);
    } catch (e) {
      // ignore: avoid_print
      print("changeAdminSecretDiary: $e");
    }
  }
}

final noticeProvider =
    AsyncNotifierProvider<NoticeViewModel, void>(() => NoticeViewModel());

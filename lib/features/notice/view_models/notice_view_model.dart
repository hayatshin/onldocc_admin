import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/notice/repo/notice_repo.dart';
import 'package:onldocc_admin/features/ranking/models/diary_model.dart';
import 'package:onldocc_admin/features/users/repo/user_repo.dart';
import 'package:onldocc_admin/features/users/view_models/user_view_model.dart';
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
        .fetchAllNotices(adminProfileModel!.subdistrictId);
    return notices.map((e) => DiaryModel.fromJson(e)).toList();
  }

  Future<void> addFeedNotification(
      String todayDiary, List<dynamic> imageList) async {
    AdminProfileModel? adminProfileModel = ref.read(adminProfileProvider).value;
    final notiUserId = "noti:${adminProfileModel!.subdistrictId}";
    final diaryId = "${getCurrentSeconds()}_$notiUserId";

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
    );

    final isUserExist = await ref.read(userRepo).checkUserExists(notiUserId);

    if (!isUserExist) {
      await ref.read(userProvider.notifier).saveAdminUser(notiUserId);
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
  ) async {
    await ref.read(noticeRepo).editFeedNotification(diaryId, todayDiary);
    await ref.read(noticeRepo).uploadImageFileToStorage(diaryId, imageList);
  }
}

final noticeProvider =
    AsyncNotifierProvider<NoticeViewModel, void>(() => NoticeViewModel());

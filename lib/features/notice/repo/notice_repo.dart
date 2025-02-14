import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onldocc_admin/features/notice/models/popup_model.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class NoticeRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchAllNotices(
      String subdistrictId) async {
    if (subdistrictId == "") {
      final notices = await _supabase
          .from("diaries")
          .select('*, users!inner(*), images(*)')
          .eq('userId', 'noti:injicare')
          .eq('notice', true)
          .order('createdAt', ascending: false);
      return notices;
    } else {
      final notices = await _supabase
          .from("diaries")
          .select('*, users!inner(*), images(*)')
          .eq('users.subdistrictId', subdistrictId)
          .eq('notice', true)
          .order('createdAt', ascending: false);
      return notices;
    }
  }

  Future<void> deleteDiaryImageStorage(
    String diaryId,
  ) async {
    try {
      final objects =
          await _supabase.storage.from("images").list(path: diaryId);

      if (objects.isNotEmpty) {
        final fileList = objects.mapIndexed((index, e) {
          // ignore: avoid_print
          final path = "$diaryId/${e.name}";
          return path;
        }).toList();

        await _supabase.storage.from("images").remove(fileList);
      }
    } catch (e) {
      // ignore: avoid_print
      print("deleteDiaryImageStorage -> $e");
    }
  }

  Future<String> uploadSingleImageToStorage(
      String diaryId, dynamic filePath) async {
    if (filePath.toString().startsWith("https://")) {
      return filePath;
    }
    final milliseconds = DateTime.now().millisecondsSinceEpoch;
    final imageType = filePath.toString().contains("mp4") ||
            filePath.toString().contains("mov") ||
            filePath.toString().contains("avi") ||
            filePath.toString().contains("mkv") ||
            filePath.toString().contains("3gp")
        ? "video"
        : 'image';
    final fileStoragePath = '$diaryId/$imageType-imageOrder-$milliseconds';

    XFile xFile = XFile.fromData(filePath);
    final imageBytes = await xFile.readAsBytes();

    await _supabase.storage
        .from("images")
        .uploadBinary(fileStoragePath, imageBytes,
            fileOptions: const FileOptions(
              upsert: true,
            ));

    final fileUrl =
        _supabase.storage.from("images").getPublicUrl(fileStoragePath);

    return fileUrl;
  }

  Future<List<String>> uploadImageFileToStorage(
      String diaryId, List<dynamic> images) async {
    try {
      await _supabase.from("images").delete().match({"diaryId": diaryId});

      List<String> urlList = [];
      await Future.wait(images.mapIndexed((index, filePath) async {
        final url = await uploadSingleImageToStorage(diaryId, filePath);
        await _supabase
            .from("images")
            .upsert({'diaryId': diaryId, 'image': url});

        urlList.add(url);
      }));
      return urlList;
    } catch (e) {
      // ignore: avoid_print
      print("uploadImageFileToStorage -> $e");
    }

    return [];
  }

  Future<void> addFeedNotification(Map<String, dynamic> diaryJson) async {
    await _supabase.from("diaries").upsert(diaryJson);
  }

  // 팝업
  Future<String> addPopupNotification(PopupModel popupModel) async {
    try {
      final data = await _supabase
          .from("subdistricts_popup")
          .upsert(popupModel.toJson())
          .select('popupId');
      return data[0]["popupId"];
    } catch (e) {
      // ignore: avoid_print
      print("[notice] addPopupNotification -> $e");
    }
    return "";
  }

  Future<String> uploadSinglePopupImageToStorage(
      String popupId, dynamic filePath) async {
    if (filePath.toString().startsWith("https://")) {
      return filePath;
    }
    final uuid = const Uuid().v4();
    final fileStoragePath = "$popupId/$uuid";

    XFile xFile = XFile.fromData(filePath);
    final imageBytes = await xFile.readAsBytes();

    await _supabase.storage
        .from("popups")
        .uploadBinary(fileStoragePath, imageBytes,
            fileOptions: const FileOptions(
              upsert: true,
            ));

    final fileUrl =
        _supabase.storage.from("popups").getPublicUrl(fileStoragePath);

    return fileUrl;
  }

  Future<List<String>> uploadPopupImagesToStorage(
      String popupId, List<dynamic> images) async {
    try {
      List<String> urlList = [];
      await Future.wait(images.mapIndexed((index, filePath) async {
        final url = await uploadSingleImageToStorage(popupId, filePath);
        await _supabase.from("subdistricts_popup_images").upsert({
          'popupId': popupId,
          'image': url,
          'createdAt': getCurrentSeconds()
        });

        urlList.add(url);
      }));
      return urlList;
    } catch (e) {
      // ignore: avoid_print
      print("uploadImageFileToStorage -> $e");
    }

    return [];
  }

  Future<PopupModel?> checkPopup(String diaryId) async {
    final data = await _supabase
        .from("subdistricts_popup")
        .select('*')
        .eq('diaryId', diaryId);
    return data.isNotEmpty ? PopupModel.fromJson(data[0]) : null;
  }

  Future<void> deletePopupImageStorage(
    String diaryId,
  ) async {
    try {
      final objects =
          await _supabase.storage.from("popups").list(path: diaryId);

      if (objects.isNotEmpty) {
        final fileList = objects.mapIndexed((index, e) {
          // ignore: avoid_print
          final path = "$diaryId/${e.name}";
          return path;
        }).toList();

        await _supabase.storage.from("popups").remove(fileList);
      }
    } catch (e) {
      // ignore: avoid_print
      print("deleteDiaryImageStorage -> $e");
    }
  }

  Future<void> editPopupAdminSecret(String popupId, bool currentState) async {
    try {
      if (currentState) {
        // 비밀 조치
        await _supabase.from("subdistricts_popup").update({
          "adminSecret": !currentState,
        }).match({"popupId": popupId});
      } else {
        // 공개 조치
        await _supabase.from("subdistricts_popup").update({
          "adminSecret": !currentState,
          "createdAt": getCurrentSeconds()
        }).match({"popupId": popupId});
      }
      await _supabase.from("subdistricts_popup").update({
        "adminSecret": !currentState,
        "createdAt": getCurrentSeconds()
      }).match({"popupId": popupId});
    } catch (e) {
      // ignore: avoid_print
      print("editPopupAdminSecret -> $e");
    }
  }

  // 수정
  Future<void> editFeedAdminSecret(
      String diaryId, String newDiaryId, bool currentState) async {
    try {
      if (currentState) {
        // 비공개 -> 공개
        await _supabase.from("diaries").update({
          "diaryId": newDiaryId,
          "createdAt": getCurrentSeconds()
        }).match({"diaryId": diaryId});
      } else {
        // 공개 -> 비공개
        await _supabase.from("diaries").update({
          "diaryId": newDiaryId,
        }).match({"diaryId": diaryId});
      }
    } catch (e) {
      // ignore: avoid_print
      print("editFeedNotificationDiaryId -> $e");
    }
  }

  Future<void> editFeedNotificationTodayDiary(
    String diaryId,
    String todayDiary,
    bool noticeTopFixed,
    int noticeFixedAt,
  ) async {
    await _supabase.from("images").delete().match({"diaryId": diaryId});
    await _supabase.from("diaries").update({
      "todayDiary": todayDiary,
      "noticeTopFixed": noticeTopFixed,
      "noticeFixedAt": noticeFixedAt,
    }).match({"diaryId": diaryId});
  }

  Future<void> deleteFeedNotification(String diaryId) async {
    await deleteDiaryImageStorage(diaryId);
    await _supabase.from("images").delete().match({"diaryId": diaryId});
    await _supabase.from("diaries").delete().match({"diaryId": diaryId});
  }
}

final noticeRepo = Provider((ref) => NoticeRepository());

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class NoticeRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchAllNotices(
      String subdistrictId) async {
    final notices = await _supabase
        .from("diaries")
        .select('*, users!inner(*), images(*)')
        .eq('users.subdistrictId', subdistrictId)
        .eq('notice', true)
        .order('createdAt', ascending: false);
    return notices;
  }

  Future<void> deleteDiaryImageStorage(
    String diaryId,
  ) async {
    final objects = await _supabase.storage.from("images").list(path: diaryId);

    if (objects.isNotEmpty) {
      final fileList = objects
          .mapIndexed((index, e) => "$diaryId/$index/${e.name}")
          .toList();
      await _supabase.storage.from("images").remove(fileList);
    }
  }

  Future<String> uploadSingleImageToStorage(
      String diaryId, dynamic image, int index) async {
    final uuid = const Uuid().v4();
    final fileStoragePath = '$diaryId/$index/$uuid';
    try {
      if (!image.toString().startsWith("https://")) {
        final objects =
            await _supabase.storage.from("images").list(path: diaryId);

        if (objects.isNotEmpty) {
          objects.forEachIndexed((windex, e) async {
            if (windex == index) {
              final fileList = ["$diaryId/$windex/${e.name}"];
              await _supabase.storage.from("images").remove(fileList);
            }
          });
        }

        XFile xFile = XFile.fromData(image);
        final imageBytes = await xFile.readAsBytes();

        await _supabase.storage.from("images").uploadBinary(
            fileStoragePath, imageBytes,
            fileOptions: const FileOptions(upsert: true));

        final fileUrl =
            _supabase.storage.from("images").getPublicUrl(fileStoragePath);
        // await _supabase
        //     .from("images")
        //     .insert({'diaryId': diaryId, 'image': fileUrl});
        return fileUrl;
      }
    } catch (e) {
      // ignore: avoid_print
      print("uploadSingleImageToStorage -> $e");
    }

    return image;
  }

  Future<List<String>> uploadImageFileToStorage(
      String diaryId, List<dynamic> images) async {
    try {
      List<String> urlList = [];
      await Future.wait(images.mapIndexed((index, image) async {
        final url = await uploadSingleImageToStorage(diaryId, image, index);

        await _supabase
            .from("images")
            .insert({'diaryId': diaryId, 'image': url});

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

  Future<void> editFeedNotification(String diaryId, String todayDiary) async {
    await _supabase.from("images").delete().match({"diaryId": diaryId});
    await _supabase
        .from("diaries")
        .update({"todayDiary": todayDiary}).match({"diaryId": diaryId});
  }

  Future<void> deleteFeedNotification(String diaryId) async {
    await _supabase.from("images").delete().match({"diaryId": diaryId});
    await deleteDiaryImageStorage(diaryId);
    await _supabase.from("diaries").delete().match({"diaryId": diaryId});
  }
}

final noticeRepo = Provider((ref) => NoticeRepository());

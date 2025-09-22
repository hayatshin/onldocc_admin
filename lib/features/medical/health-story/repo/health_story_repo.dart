import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:web/web.dart' as web;

class HealthStoryRepo {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchAllHealthStories() async {
    final docs = await _supabase
        .from("health_stories")
        .select('*, doctors(*)')
        .order('createdAt', ascending: false);
    return docs;
  }

  Future<void> insertHealthStory(Map<String, dynamic> json) async {
    await _supabase.from("health_stories").upsert(json);
  }

  Future<Uint8List?> getBlobData(String blobUrl) async {
    final response = await web.window.fetch(blobUrl.toJS).toDart;

    if (!response.ok) {
      // ignore: avoid_print
      print('Failed to fetch blob URL: ${response.statusText}');
      return null;
    }

    final blob = await response.blob().toDart;
    final reader = web.FileReader();
    final completer = Completer<Uint8List>();
    reader.onLoadEnd.listen((_) {
      try {
        final buffer = (reader.result as ByteBuffer);
        completer.complete(Uint8List.view(buffer));
      } catch (e) {
        completer.completeError('[image] Casting failed: $e');
      }
    });
    reader.readAsArrayBuffer(blob);

    return completer.future;
  }

  Future<String?> uploadSingleBlobToHealthStoryStorage(
      String healthStoryId, String blobUrl) async {
    final uuid = const Uuid().v4();
    final fileStoragePath = "$healthStoryId/$uuid";
    final image = await getBlobData(blobUrl);

    if (image != null) {
      await _supabase.storage.from("hstories").uploadBinary(
          fileStoragePath, image,
          fileOptions: const FileOptions(upsert: true));

      final fileUrl =
          _supabase.storage.from("hstories").getPublicUrl(fileStoragePath);

      return fileUrl;
    }
    return null;
  }

  Future<void> deleteHealthStoryImages(
    String healthStoryId,
  ) async {
    try {
      final objects =
          await _supabase.storage.from("hstories").list(path: healthStoryId);

      if (objects.isNotEmpty) {
        final fileList = objects.mapIndexed((index, e) {
          // ignore: avoid_print
          final path = "$healthStoryId/${e.name}";
          return path;
        }).toList();

        await _supabase.storage.from("hstories").remove(fileList);
      }
    } catch (e) {
      // ignore: avoid_print
      print("deleteHealthStoryImages -> $e");
    }
  }

  Future<void> deleteHealthStory(String healthStoryId) async {
    await deleteHealthStoryImages(healthStoryId);
    await _supabase
        .from("health_stories")
        .delete()
        .eq('healthStoryId', healthStoryId);
  }
}

final healthStoryRepo = Provider((ref) => HealthStoryRepo());

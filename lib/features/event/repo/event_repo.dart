import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:onldocc_admin/constants/http.dart';
import 'package:onldocc_admin/features/event/models/event_model.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class EventRepository {
  final _supabase = Supabase.instance.client;

  static final eventUserPointFunctions = Uri.parse(
      "https://diejlcrtffmlsdyvcagq.supabase.co/functions/v1/event-user-point-functions-2");
  static final eventUserCountFunctions = Uri.parse(
      "https://diejlcrtffmlsdyvcagq.supabase.co/functions/v1/event-user-count-functions-2");

  Future<Map<String, dynamic>> getEventUserPoint(
    String userId,
    int startSeconds,
    int endSeconds,
    int stepPoint,
    int invitationPoint,
    int diaryPoint,
    int commentPoint,
    int likePoint,
    int quizPoint,
    int targetScore,
  ) async {
    Map<String, dynamic> requestBody = {
      'userId': userId,
      'startSeconds': startSeconds,
      'endSeconds': endSeconds,
      'stepPoint': stepPoint,
      'invitationPoint': invitationPoint,
      'diaryPoint': diaryPoint,
      'commentPoint': commentPoint,
      'likePoint': likePoint,
      'quizPoint': quizPoint,
      'targetScore': targetScore,
    };
    String requestBodyJson = jsonEncode(requestBody);

    final response = await http.post(
      eventUserPointFunctions,
      body: requestBodyJson,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data["data"];
    }

    return {};
  }

  Future<Map<String, dynamic>> getEventUserCount(
    String userId,
    int startSeconds,
    int endSeconds,
    int invitationCount,
    int diaryCount,
    int commentCount,
    int quizCount,
    int likeCount,
  ) async {
    Map<String, dynamic> requestBody = {
      'userId': userId,
      'startSeconds': startSeconds,
      'endSeconds': endSeconds,
      'invitationCount': invitationCount,
      'diaryCount': diaryCount,
      'commentCount': commentCount,
      'likeCount': likeCount,
      'quizCount': quizCount,
    };
    String requestBodyJson = jsonEncode(requestBody);

    final response = await http.post(
      eventUserCountFunctions,
      body: requestBodyJson,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data["data"];
    }

    return {};
  }

  Future<List<Map<String, dynamic>>> getUserEvents(
      AdminProfileModel model, String contractRegionId) async {
    if (model.master && contractRegionId == "") {
      final allUsers = await _supabase
          .from("events")
          .select('*, contract_regions(*)')
          .eq('allUsers', true)
          .order(
            'createdAt',
            ascending: true,
          );
      return allUsers;
    } else {
      final contractRegions = await _supabase
          .from("events")
          .select('*, contract_regions(*)')
          .eq('allUsers', false)
          .eq('contractRegionId', contractRegionId)
          .order(
            'createdAt',
            ascending: true,
          );

      return contractRegions;
    }
  }

  Future<List<Map<String, dynamic>>> getEventPariticipants(
      String eventId) async {
    final data = await _supabase
        .from("event_participants")
        .select('*, users(*)')
        .eq('eventId', eventId)
        .order('gift', ascending: false)
        .order('createdAt', ascending: true);
    return data;
  }

  Future<String> uploadSingleImageToStorage(
      String eventId, dynamic image) async {
    if (!image.toString().startsWith("https://")) {
      // await deleteEventImageStorage(eventId);
      final uuid = const Uuid().v4();
      final fileStoragePath = "$eventId/$uuid";

      XFile xFile = XFile.fromData(image);
      final imageBytes = await xFile.readAsBytes();

      await _supabase.storage.from("events").uploadBinary(
          fileStoragePath, imageBytes,
          fileOptions: const FileOptions(upsert: true));

      final fileUrl =
          _supabase.storage.from("events").getPublicUrl(fileStoragePath);

      return fileUrl;
    }
    return image;
  }

  Future<void> addEvent(EventModel eventModel) async {
    try {
      await _supabase.from("events").insert(eventModel.toJson());
    } catch (e) {
      // ignore: avoid_print
      print("addEvent: $e");
    }
  }

  Future<void> editEvent(EventModel eventModel) async {
    try {
      await _supabase
          .from("events")
          .update(eventModel.editToJson())
          .eq("eventId", eventModel.eventId);
    } catch (e) {
      // ignore: avoid_print
      print("editEvent -> $e");
    }
  }

  Future<void> editEventAdminSecret(String eventId, bool currentSecret) async {
    try {
      await _supabase.from("events").update({
        'adminSecret': !currentSecret,
        'createdAt': getCurrentSeconds()
      }).eq("eventId", eventId);
    } catch (e) {
      // ignore: avoid_print
      print("editEvent -> $e");
    }
  }

  Future<void> deleteEvent(String eventId) async {
    await _supabase.from("events").delete().match({'eventId': eventId});
  }

  Future<void> deleteEventImageStorage(String eventId) async {
    final objects = await _supabase.storage.from("events").list(path: eventId);

    if (objects.isNotEmpty) {
      final fileList =
          objects.mapIndexed((index, e) => "$eventId/${e.name}").toList();
      await _supabase.storage.from("events").remove(fileList);
    }
  }
}

final eventRepo = Provider((ref) => EventRepository());

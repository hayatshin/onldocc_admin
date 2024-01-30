import 'dart:io';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onldocc_admin/features/event/models/event_model.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';

class EventRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _supabase = Supabase.instance.client;

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      getAllEvents() async {
    final query = await _db.collection("mission").get();
    return query.docs;
  }

// supabase
  Future<List<Map<String, dynamic>>> getUserEvents(
      AdminProfileModel adminProfile) async {
    if (adminProfile.master) {
      final data =
          await _supabase.from("events").select('*, contract_regions(*)').order(
                'createdAt',
                ascending: true,
              );
      return data;
    } else {
      final allUsers = await _supabase
          .from("events")
          .select('*, contract_regions(*)')
          .eq('allUsers', true)
          .order(
            'createdAt',
            ascending: true,
          );
      final contractRegions = await _supabase
          .from("events")
          .select('*, contract_regions(*)')
          .eq('allUsers', false)
          .eq('contractRegionId', adminProfile.contractRegionId)
          .order(
            'createdAt',
            ascending: true,
          );

      final combinedList = [...contractRegions, ...allUsers];
      return combinedList.sorted(
          (a, b) => (a["createdAt"] as int).compareTo(b["createdAt"] as int));
    }
  }

  Future<List<Map<String, dynamic>>> getEventPariticipants(
      String eventId) async {
    final data = await _supabase
        .from("event_participants")
        .select('*, users(*)')
        .eq('eventId', eventId);
    return data;
  }

  Future<String> uploadSingleImageToStorage(
      String eventId, dynamic image) async {
    if (!image.toString().startsWith("https://")) {
      await deleteEventImageStorage(eventId);
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
    await _supabase.from("events").insert(eventModel.toJson());
  }

  Future<void> editEvent(EventModel eventModel) async {
    await _supabase
        .from("events")
        .update(eventModel.editToJson())
        .match({"eventId": eventModel.eventId});
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

// firebase
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getRegionEvents(
      String fullRegion) async {
    final regionQueries = await _db
        .collection("mission")
        .where("contractName", isEqualTo: fullRegion)
        .get();

    final allUserQueries =
        await _db.collection("mission").where("allUser", isEqualTo: true).get();

    Set<QueryDocumentSnapshot<Map<String, dynamic>>> setRegion =
        Set.from(regionQueries.docs);
    Set<QueryDocumentSnapshot<Map<String, dynamic>>> setAllUser =
        Set.from(allUserQueries.docs);

    Set<QueryDocumentSnapshot<Map<String, dynamic>>> setQueries = {
      ...setRegion,
      ...setAllUser
    };

    List<QueryDocumentSnapshot<Map<String, dynamic>>> list =
        setQueries.toList();

    return list;
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getCommunityEvents(
      String community) async {
    final communityQueries = await _db
        .collection("mission")
        .where("contractName", isEqualTo: community)
        .get();

    final allUserQueries =
        await _db.collection("mission").where("allUser", isEqualTo: true).get();

    Set<QueryDocumentSnapshot<Map<String, dynamic>>> setCommunity =
        Set.from(communityQueries.docs);
    Set<QueryDocumentSnapshot<Map<String, dynamic>>> setAllUser =
        Set.from(allUserQueries.docs);

    Set<QueryDocumentSnapshot<Map<String, dynamic>>> setQueries = {
      ...setCommunity,
      ...setAllUser
    };

    List<QueryDocumentSnapshot<Map<String, dynamic>>> list =
        setQueries.toList();

    return list;
  }

  Future<void> saveEvent(
    Map<String, dynamic> eventJson,
  ) async {
    await _db.collection("mission").doc(eventJson["documentId"]).set(eventJson);
  }

  // Future<void> deleteEvent(String documentId) async {
  //   await _db.collection("mission").doc(documentId).delete();
  // }

  Future<String?> uploadEventImage(Uint8List file, String fileName) async {
    final fileRef = _storage.ref().child("events/$fileName");
    TaskSnapshot snapshot = await fileRef.putData(file);
    if (snapshot.state == TaskState.success) {
      String downloadURL = await fileRef.getDownloadURL();
      return downloadURL;
    }
    return null;
  }

  Future<List<String>> uploadFeedImage(List<Uint8List> fileList) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    List<String> imageArray = [];
    for (Uint8List file in fileList) {
      final fileRef = _storage.ref().child("feedNotifications/$fileName");
      TaskSnapshot snapshot = await fileRef.putData(file);
      if (snapshot.state == TaskState.success) {
        String downloadURL = await fileRef.getDownloadURL();
        imageArray.add(downloadURL);
      }
    }

    return imageArray;
  }

  Future<String?> getCommunityImage(String name) async {
    final ref = await _db.collection("community").doc(name).get();
    String image = ref.get("communityImage");
    return image;
  }

  Future<String?> getRegionImage(String name) async {
    final ref = await _db.collection("contract_region").doc(name).get();
    String image = ref.get("regionImage");
    return image;
  }

  Future<void> addNotification(
      String userId, String diaryId, Map<String, dynamic> diaryJson) async {
    await _db.collection("diary").doc(diaryId).set(diaryJson);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getCertainEventDocument(
      String eventId) async {
    final eventDoc = await _db.collection("mission").doc(eventId).get();
    return eventDoc;
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      getEventParticipants(String eventId) async {
    final participantsRef = await _db
        .collection("mission")
        .doc(eventId)
        .collection("participants")
        .get();

    return participantsRef.docs;
  }
}

final eventRepo = Provider((ref) => EventRepository());

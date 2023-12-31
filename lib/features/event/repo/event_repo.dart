import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      getAllEvents() async {
    final query = await _db.collection("mission").get();
    return query.docs;
  }

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

  Future<void> deleteEvent(String documentId) async {
    await _db.collection("mission").doc(documentId).delete();
  }

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

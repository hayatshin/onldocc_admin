import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:onldocc_admin/common/models/contract_config_model.dart';
import 'package:onldocc_admin/features/event/models/event_model.dart';
import 'package:onldocc_admin/features/event/models/event_user_model.dart';
import 'package:onldocc_admin/features/event/repo/event_repo.dart';
import 'package:onldocc_admin/features/ranking/view_models/event_ranking_vm.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/features/users/repo/user_repo.dart';

import '../../../common/view_models/contract_config_view_model.dart';

class EventViewModel extends AsyncNotifier<List<EventModel>> {
  late EventRepository _eventRepository;
  @override
  FutureOr<List<EventModel>> build() async {
    _eventRepository = EventRepository();
    ContractConfigModel? contractModel =
        ref.watch(contractConfigProvider).value;
    List<EventModel> eventModelList = await getEventModels(
        contractModel!.contractType, contractModel.contractName);

    return eventModelList;
  }

  Future<List<EventModel>> getEventModels(
      String contractType, String contractName) async {
    state = const AsyncValue.loading();

    List<EventModel> eventList = [];
    if (contractType == "지역") {
      final eventDocs = await _eventRepository.getRegionEvents(contractName);
      for (DocumentSnapshot<Map<String, dynamic>> eventDoc in eventDocs) {
        Map<String, dynamic> diaryJson = eventDoc.data()!;
        EventModel eventModel = EventModel.fromJson(diaryJson);
        eventList.add(eventModel);
      }
    } else if (contractType == "기관") {
      final eventDocs = await _eventRepository.getCommunityEvents(contractName);
      for (DocumentSnapshot<Map<String, dynamic>> eventDoc in eventDocs) {
        Map<String, dynamic> diaryJson = eventDoc.data()!;
        EventModel eventModel = EventModel.fromJson(diaryJson);
        eventList.add(eventModel);
      }
    } else if (contractType == "마스터" || contractType == "전체") {
      final eventDocs = await _eventRepository.getAllEvents();
      for (DocumentSnapshot<Map<String, dynamic>> eventDoc in eventDocs) {
        Map<String, dynamic> diaryJson = eventDoc.data()!;
        EventModel eventModel = EventModel.fromJson(diaryJson);
        eventList.add(eventModel);
      }
    }
    state = AsyncValue.data(eventList);

    return eventList;
  }

  Future<EventModel> getCertainEventModel(String eventId) async {
    DocumentSnapshot<Map<String, dynamic>> eventDoc =
        await _eventRepository.getCertainEventDocument(eventId);
    Map<String, dynamic>? eventMap = eventDoc.data();
    EventModel eventModel = EventModel.fromJson(eventMap!);
    return eventModel;
  }

  Future<EventUserModel?> calculatePoint(
      QueryDocumentSnapshot<Map<String, dynamic>> doc,
      int goalScore,
      String endDateString) async {
    String userId = doc.get("userId");

    Timestamp participatingTimestamp = doc.get("timestamp");

    DateTime participateDate = participatingTimestamp.toDate();

    UserModel? userModel = await ref.read(userRepo).getUserModel(userId);
    if (userModel != null) {
      EventUserModel? eventUserModel =
          EventUserModel.fromJson(userModel.toJson());

      final timestampEventUserModel = eventUserModel.copyWith(
        participateDate: participateDate,
      );

      DateTime endDateTime = endDateString.contains('.')
          ? DateFormat('yyyy.MM.dd').parse(endDateString)
          : DateTime.now();

      EventUserModel? scoreEventUserModel = await ref
          .read(eventRankingProvider.notifier)
          .calculateUserScore(
              timestampEventUserModel, participateDate, endDateTime, goalScore);

      return scoreEventUserModel;
    }
    return null;

    // participantsModelList.add(scoreEventUserModel!);
  }

  Future<List<EventUserModel>> getCertainEventParticipants(
      String eventId, int goalScore, String endDateString) async {
    List<EventUserModel> participantsModelList = [];

    List<QueryDocumentSnapshot<Map<String, dynamic>>> participantsDocs =
        await _eventRepository.getEventParticipants(eventId);

    await Future.forEach(participantsDocs,
        (QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
      EventUserModel? scoreEventUserModel =
          await calculatePoint(doc, goalScore, endDateString);
      if (scoreEventUserModel != null) {
        participantsModelList.add(scoreEventUserModel);
      }
    });

    return participantsModelList;
  }
}

final eventProvider = AsyncNotifierProvider<EventViewModel, List<EventModel>>(
  () => EventViewModel(),
);

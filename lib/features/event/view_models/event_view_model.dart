import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/repo/contract_config_repo.dart';
import 'package:onldocc_admin/constants/http.dart';
import 'package:onldocc_admin/features/event/models/event_model.dart';
import 'package:onldocc_admin/features/event/models/event_user_model.dart';
import 'package:onldocc_admin/features/event/models/participant_model.dart';
import 'package:onldocc_admin/features/event/repo/event_repo.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/ranking/models/diary_model.dart';
import 'package:onldocc_admin/features/ranking/repo/ranking_repo.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/features/users/repo/user_repo.dart';
import 'package:onldocc_admin/features/users/view_models/user_view_model.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:http/http.dart' as http;

import '../../../common/view_models/contract_config_view_model.dart';

class EventViewModel extends AsyncNotifier<List<EventModel>> {
  late EventRepository _eventRepository;
  late RankingRepository _rankingRepo;

  static final pointUpFunctions = Uri.parse(
      "https://diejlcrtffmlsdyvcagq.supabase.co/functions/v1/point-up-functions");

  @override
  FutureOr<List<EventModel>> build() async {
    _eventRepository = EventRepository();
    _rankingRepo = RankingRepository();
    AdminProfileModel data =
        await ref.read(contractConfigProvider.notifier).getMyAdminProfile();
    List<EventModel> eventModelList =
        await getEventModels(data.contractType, data.name);

    return eventModelList;
  }

  // supabase
  Future<List<EventModel>> getUserEvents() async {
    AdminProfileModel? adminProfileModel = ref.read(adminProfileProvider).value;
    final events = await _eventRepository.getUserEvents(adminProfileModel!);
    return events.map((e) => EventModel.fromJson(e)).toList();
  }

  Future<List<ParticipantModel>> getEventParticipants(
      EventModel eventModel) async {
    final participants =
        await _eventRepository.getEventPariticipants(eventModel.eventId);
    final modelList = await Future.wait(participants.map((e) async {
      final model = ParticipantModel.fromJson(e);
      final userRegion = await ref
          .read(contractRepo)
          .convertSubdistrictIdToName(model.subdistrictId);

      int startSeconds = convertStartDateStringToSeconds(eventModel.startDate);
      int endSeconds = convertEndDateStringToSeconds(eventModel.endDate);

      final pointData =
          await getEventUserScore(model.userId, startSeconds, endSeconds);

      final userPoint = pointData[0]["totalPoint"];
      final rModel = model.copyWith(
        smallRegion: userRegion,
        totalPoint: userPoint,
      );
      return rModel;
    }).toList());

    return modelList;
  }

  Future<List<dynamic>> getEventUserScore(
      String userId, int startSeconds, int endSeconds) async {
    Map<String, dynamic> requestBody = {
      'userId': userId,
      'startSeconds': startSeconds,
      'endSeconds': endSeconds,
    };
    String requestBodyJson = jsonEncode(requestBody);

    final response = await http.post(
      pointUpFunctions,
      body: requestBodyJson,
      headers: headers,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data["data"];
    }

    return [];
  }

  // firebase
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

  // re-code

  int updateUserStepPoint(
    List<DocumentSnapshot<Map<String, dynamic>>> stepDocs,
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    int userTotalScore = 0;
    List<DateTime> dateList = getBetweenDays(startDate, endDate);

    for (DateTime date in dateList) {
      final dateString = convertTimettampToStringDate(date);
      for (DocumentSnapshot<Map<String, dynamic>> document in stepDocs) {
        if (document.exists &&
            document.id == dateString &&
            document.data()!.containsKey(userId)) {
          int dailyStepInt = document.get(userId) as int;

          int userDailyScore = dailyStepInt < 0
              ? 0
              : dailyStepInt > 10000
                  ? 100
                  : ((dailyStepInt / 1000).floor()) * 10;
          userTotalScore += userDailyScore;
        }
      }
    }

    return userTotalScore;
  }

  int updateUserDiaryPoint(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> diaryDocs,
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    int count = 0;

    for (QueryDocumentSnapshot<Map<String, dynamic>> document in diaryDocs) {
      Map<String, dynamic> data = document.data();
      Timestamp timestamp = document.get("timestamp") as Timestamp;
      DateTime docDate = timestamp.toDate();

      if (docDate.isAfter(startDate) &&
          docDate.isBefore(endDate) &&
          data["userId"] == userId) {
        count++;
      }
    }
    return count * 100;
  }

  int updateUserCommentPoint(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> commentDocs,
      String userId,
      DateTime startDate,
      DateTime endDate) {
    int count = 0;
    for (QueryDocumentSnapshot<Map<String, dynamic>> document in commentDocs) {
      Map<String, dynamic> data = document.data();
      Timestamp timestamp = document.get("timestamp") as Timestamp;
      DateTime docDate = timestamp.toDate();

      if (docDate.isAfter(startDate) &&
          docDate.isBefore(endDate) &&
          data["userId"] == userId) {
        count++;
      }
    }
    return count * 20;
  }

  // Future<List<EventUserModel>> updateEventParticipantsList(
  //     String startDateString,
  //     String endDateString,
  //     String eventId,
  //     int goalScore) async {
  //   List<QueryDocumentSnapshot<Map<String, dynamic>>> participantsDocs =
  //       await _eventRepository.getEventParticipants(eventId);

  //   final stepDocs = await _rankingRepo.getAllStepQuery();
  //   final diaryDocs = await _rankingRepo.getAllDiaryQuery();
  //   final commentDocs = await _rankingRepo.getAllCommentQuery();

  //   List<EventUserModel> updateScoreList =
  //       await Future.wait(participantsDocs.map((doc) async {
  //     final userId = doc.get("userId");
  //     DateTime participateDate = (doc.get("timestamp") as Timestamp).toDate();

  //     DateTime startDate = startDateString.contains(".")
  //         ? dateStringToDateTimeDot(startDateString)
  //         : (doc["timestamp"] as Timestamp).toDate();

  //     DateTime endDate = endDateString.contains(".")
  //         ? dateStringToDateTimeDot(endDateString)
  //         : DateTime.now();

  //     int stepScore = updateUserStepPoint(stepDocs, userId, startDate, endDate);
  //     int diaryScore =
  //         updateUserDiaryPoint(diaryDocs, userId, startDate, endDate);
  //     int commentScore =
  //         updateUserCommentPoint(commentDocs, userId, startDate, endDate);

  //     int totalScore = stepScore + diaryScore + commentScore;

  //     bool goalOrNot = totalScore >= goalScore;

  //     // UserModel? userModel = await ref.read(userRepo).getUserModel(userId);

  //     // EventUserModel eventUserModel = userModel != null
  //     //     ? EventUserModel.fromJson(userModel.toJson())
  //     //     : EventUserModel.empty();

  //     eventUserModel.copyWith(
  //       participateDate: participateDate,
  //       userPoint: totalScore,
  //       goalOrNot: goalOrNot,
  //     );

  //     return eventUserModel;
  //   }).toList());

  //   return updateScoreList;
  // }
}

final eventProvider = AsyncNotifierProvider<EventViewModel, List<EventModel>>(
  () => EventViewModel(),
);

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/features/event/models/event_model.dart';
import 'package:onldocc_admin/features/event/models/participant_model.dart';
import 'package:onldocc_admin/features/event/repo/event_repo.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/utils.dart';

class EventViewModel extends AsyncNotifier<List<EventModel>> {
  late EventRepository _eventRepository;

  static final pointUpFunctions = Uri.parse(
      "https://diejlcrtffmlsdyvcagq.supabase.co/functions/v1/point-up-functions-1");
  static final pointEventFunctions = Uri.parse(
      "https://diejlcrtffmlsdyvcagq.supabase.co/functions/v1/point-event-functions-1");

  @override
  FutureOr<List<EventModel>> build() async {
    _eventRepository = EventRepository();
    return getUserEvents();
  }

  Future<List<EventModel>> getUserEvents() async {
    AdminProfileModel? adminProfileModel =
        ref.read(adminProfileProvider).value ??
            await ref.read(adminProfileProvider.notifier).getAdminProfile();

    final events = await _eventRepository.getUserEvents(
        adminProfileModel, selectContractRegion.value!.contractRegionId!);

    final list = events.map((e) => EventModel.fromJson(e)).toList();
    return list;
  }

  Future<List<ParticipantModel>> getEventParticipants(
      EventModel eventModel) async {
    List<dynamic> participants = [];
    if (eventModel.eventType == EventType.quiz.name) {
      participants =
          await _eventRepository.getQuizEventPariticipants(eventModel.eventId);
    } else if (eventModel.eventType == EventType.photo.name) {
      participants =
          await _eventRepository.getPhotoEventPariticipants(eventModel.eventId);
    } else {
      participants =
          await _eventRepository.getEventPariticipants(eventModel.eventId);
    }

    final modelList = await Future.wait(participants.map((e) async {
      final model = ParticipantModel.fromJson(e);

      // final userRegion = await ref
      //     .read(contractRepo)
      //     .convertSubdistrictIdToName(model.subdistrictId);

      int startSeconds = convertStartDateStringToSeconds(eventModel.startDate);
      int endSeconds = convertEndDateStringToSeconds(eventModel.endDate);

      int userStartSeconds =
          model.createdAt > startSeconds ? model.createdAt : startSeconds;

      if (eventModel.eventType == EventType.targetScore.name) {
        final data = await _eventRepository.getEventUserTargetScore(
          model.userId,
          userStartSeconds,
          endSeconds,
          eventModel.stepPoint!,
          eventModel.invitationPoint!,
          eventModel.diaryPoint!,
          eventModel.commentPoint!,
          eventModel.likePoint!,
          eventModel.quizPoint!,
          eventModel.targetScore!,
          eventModel.maxStepCount!,
        );

        final scorePointModel = model.copyWith(
          // smallRegion: userRegion,
          userStepPoint: data["userStepPoint"],
          userInvitationPoint: data["userInvitationPoint"],
          userDiaryPoint: data["userDiaryPoint"],
          userCommentPoint: data["userCommentPoint"],
          userLikePoint: data["userLikePoint"],
          userQuizPoint: data["userQuizPoint"],
          userTotalPoint: data["userTotalPoint"],
          userAchieveOrNot: data["userAchieveOrNot"],
        );
        return scorePointModel;
      } else if (eventModel.eventType == EventType.multipleScores.name) {
        final data = await _eventRepository.getEventUserMultipleScores(
          model.userId,
          userStartSeconds,
          endSeconds,
          eventModel.stepPoint!,
          eventModel.invitationPoint!,
          eventModel.diaryPoint!,
          eventModel.commentPoint!,
          eventModel.likePoint!,
          eventModel.quizPoint!,
          eventModel.targetScore!,
          eventModel.maxStepCount!,
          eventModel.maxCommentCount!,
          eventModel.maxLikeCount!,
          eventModel.maxInvitationCount!,
        );

        final scorePointModel = model.copyWith(
          // smallRegion: userRegion,
          userStepPoint: data["userStepPoint"],
          userInvitationPoint: data["userInvitationPoint"],
          userDiaryPoint: data["userDiaryPoint"],
          userCommentPoint: data["userCommentPoint"],
          userLikePoint: data["userLikePoint"],
          userQuizPoint: data["userQuizPoint"],
          userTotalPoint: data["userTotalPoint"],
          userAchieveOrNot: data["userAchieveOrNot"],
        );
        return scorePointModel;
      } else if (eventModel.eventType == EventType.count.name) {
        final data = await _eventRepository.getEventUserCount(
          model.userId,
          userStartSeconds,
          endSeconds,
          eventModel.invitationCount!,
          eventModel.diaryCount!,
          eventModel.commentCount!,
          eventModel.likeCount!,
          eventModel.quizCount!,
        );
        final scorePointModel = model.copyWith(
          // smallRegion: userRegion,
          userInvitationCount: data["userInvitationCount"],
          userDiaryCount: data["userDiaryCount"],
          userCommentCount: data["userCommentCount"],
          userLikeCount: data["userLikeCount"],
          userQuizCount: data["userQuizCount"],
          userAchieveOrNot: data["userAchieveOrNot"],
        );
        return scorePointModel;
      } else if (eventModel.eventType == EventType.quiz.name) {
        final scorePointModel = model.copyWith(
          // smallRegion: userRegion,
          userAchieveOrNot: model.quizAnswer == eventModel.quizAnswer,
        );
        return scorePointModel;
      } else if (eventModel.eventType == EventType.photo.name) {
        final scorePointModel = model.copyWith(
            // smallRegion: userRegion,
            );
        return scorePointModel;
      } else {
        return ParticipantModel.empty();
      }
    }).toList());

    // remove duplicate row
    List<ParticipantModel> exclusiveModels = modelList.toSet().toList();
    return exclusiveModels;
  }

  Future<EventModel> getCertainEvent(String eventId) async {
    try {
      final data = await ref.read(eventRepo).getCertainEvent(eventId);
      return EventModel.fromJson(data);
    } catch (e) {
      // ignore: avoid_print
      print("[router] getCertainEvent -> $e");
    }
    return EventModel.empty();
  }

  // Future<List<dynamic>> getEventUserScore(
  //   String userId,
  //   int startSeconds,
  //   int endSeconds,
  //   int stepPoint,
  //   int diaryPoint,
  //   int commentPoint,
  //   int likePoint,
  // ) async {
  //   Map<String, dynamic> requestBody = {
  //     'userId': userId,
  //     'startSeconds': startSeconds,
  //     'endSeconds': endSeconds,
  //     'stepPoint': stepPoint,
  //     'diaryPoint': diaryPoint,
  //     'commentPoint': commentPoint,
  //     'likePoint': likePoint,
  //   };
  //   String requestBodyJson = jsonEncode(requestBody);

  //   final response = await http.post(
  //     pointEventFunctions,
  //     body: requestBodyJson,
  //     headers: headers,
  //   );

  //   if (response.statusCode == 200) {
  //     Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
  //     return data["data"];
  //   }

  //   return [];
  // }
}

final eventProvider = AsyncNotifierProvider<EventViewModel, List<EventModel>>(
  () => EventViewModel(),
);

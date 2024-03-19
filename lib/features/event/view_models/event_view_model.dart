import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/repo/contract_config_repo.dart';
import 'package:onldocc_admin/features/event/models/event_model.dart';
import 'package:onldocc_admin/features/event/models/participant_model.dart';
import 'package:onldocc_admin/features/event/repo/event_repo.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/utils.dart';

class EventViewModel extends AsyncNotifier<List<EventModel>> {
  late EventRepository _eventRepository;

  static final pointUpFunctions = Uri.parse(
      "https://diejlcrtffmlsdyvcagq.supabase.co/functions/v1/point-up-functions");
  static final pointEventFunctions = Uri.parse(
      "https://diejlcrtffmlsdyvcagq.supabase.co/functions/v1/point-event-functions");

  @override
  FutureOr<List<EventModel>> build() async {
    _eventRepository = EventRepository();
    return getUserEvents();
  }

  Future<List<EventModel>> getUserEvents() async {
    AdminProfileModel? adminProfileModel = ref.read(adminProfileProvider).value;

    final events = await _eventRepository.getUserEvents(
        adminProfileModel!, selectContractRegion.value.contractRegionId!);

    final list = events.map((e) => EventModel.fromJson(e)).toList();
    return list;
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
      int userStartSeconds =
          model.createdAt > startSeconds ? model.createdAt : startSeconds;

      if (eventModel.eventType == "point") {
        final data = await _eventRepository.getEventUserPoint(
          model.userId,
          userStartSeconds,
          endSeconds,
          eventModel.stepPoint!,
          eventModel.invitationPoint!,
          eventModel.diaryPoint!,
          eventModel.commentPoint!,
          eventModel.likePoint!,
          eventModel.targetScore!,
        );
        final scorePointModel = model.copyWith(
          smallRegion: userRegion,
          userStepPoint: data["userStepPoint"],
          userInvitationPoint: data["userInvitationPoint"],
          userDiaryPoint: data["userDiaryPoint"],
          userCommentPoint: data["userCommentPoint"],
          userLikePoint: data["userLikePoint"],
          userTotalPoint: data["userTotalPoint"],
          userAchieveOrNot: data["userAchieveOrNot"],
        );
        return scorePointModel;
      } else {
        final data = await _eventRepository.getEventUserCount(
          model.userId,
          userStartSeconds,
          endSeconds,
          eventModel.invitationCount!,
          eventModel.diaryCount!,
          eventModel.commentCount!,
          eventModel.likeCount!,
        );
        final scorePointModel = model.copyWith(
          smallRegion: userRegion,
          userInvitationCount: data["userInvitationCount"],
          userDiaryCount: data["userDiaryCount"],
          userCommentCount: data["userCommentCount"],
          userLikeCount: data["userLikeCount"],
          userAchieveOrNot: data["userAchieveOrNot"],
        );
        return scorePointModel;
      }
    }).toList());

    return modelList;
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

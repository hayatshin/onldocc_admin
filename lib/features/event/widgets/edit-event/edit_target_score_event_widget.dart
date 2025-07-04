import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/event/models/event_model.dart';
import 'package:onldocc_admin/features/event/repo/event_repo.dart';
import 'package:onldocc_admin/features/event/view/event_screen.dart';
import 'package:onldocc_admin/features/users/view/users_screen.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';

class EditTargetScoreEventWidget extends ConsumerStatefulWidget {
  final BuildContext context;
  final Size size;
  final EventModel eventModel;
  final Function() refreshScreen;
  final TextEditingController goalScoreController;
  final ValueNotifier<bool> diaryField;
  final ValueNotifier<bool> quizField;
  final ValueNotifier<bool> commentField;
  final ValueNotifier<bool> likeField;
  final ValueNotifier<bool> invitationField;
  final ValueNotifier<bool> stepField;
  final ValueNotifier<bool> quizLimitField;
  final ValueNotifier<bool> commentLimitField;
  final ValueNotifier<bool> likeLimitField;
  final ValueNotifier<bool> invitationLimitField;
  final TextEditingController diaryPointController;
  final TextEditingController quizPointController;
  final TextEditingController commentPointController;
  final TextEditingController likePointController;
  final TextEditingController invitationPointController;
  final TextEditingController stepPointController;
  final TextEditingController commentMaxPointController;
  final TextEditingController likeMaxPointController;
  final TextEditingController invitationMaxPointController;
  final TextEditingController stepMaxPointController;

  const EditTargetScoreEventWidget({
    super.key,
    required this.context,
    required this.size,
    required this.eventModel,
    required this.refreshScreen,
    required this.goalScoreController,
    required this.diaryField,
    required this.quizField,
    required this.commentField,
    required this.likeField,
    required this.invitationField,
    required this.stepField,
    required this.quizLimitField,
    required this.commentLimitField,
    required this.likeLimitField,
    required this.invitationLimitField,
    required this.diaryPointController,
    required this.quizPointController,
    required this.commentPointController,
    required this.likePointController,
    required this.invitationPointController,
    required this.stepPointController,
    required this.commentMaxPointController,
    required this.likeMaxPointController,
    required this.invitationMaxPointController,
    required this.stepMaxPointController,
  });

  @override
  ConsumerState<EditTargetScoreEventWidget> createState() =>
      _EditPointEventWidgetState();
}

class _EditPointEventWidgetState
    extends ConsumerState<EditTargetScoreEventWidget> {
  OverlayEntry? overlayEntry;
  GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();

  bool tapEditEvent = false;

  @override
  void initState() {
    super.initState();

    setState(() {});
  }

  @override
  void dispose() {
    removeDeleteOverlay();
    super.dispose();
  }

  // Future<void> _submitEvent() async {
  //   setState(() {
  //     tapEditEvent = true;
  //   });

  //   // AdminProfileModel? adminProfileModel = ref.read(adminProfileProvider).value;
  //   final eventId = widget.eventModel.eventId;
  //   final eventImageUrl = await ref
  //       .read(eventRepo)
  //       .uploadSingleImageToStorage(eventId, _eventImage);
  //   final bannerImageUrl = await ref
  //       .read(eventRepo)
  //       .uploadSingleImageToStorage(eventId, _bannerImage);
  //   final eventModel = widget.eventModel.copyWith(
  //     eventId: eventId,
  //     title: _eventTitle,
  //     description: _eventDescription,
  //     eventImage: eventImageUrl,
  //     bannerImage: bannerImageUrl,
  //     allUsers: selectContractRegion.value!.subdistrictId != "" ? false : true,
  //     targetScore: int.parse(_eventGoalScore),
  //     achieversNumber: _eventPrizeWinners,
  //     startDate: convertTimettampToStringDot(_eventStartDate!),
  //     endDate: convertTimettampToStringDot(_eventEndDate!),
  //     stepPoint: _eventStepPoint,
  //     diaryPoint: _eventDiaryPoint,
  //     commentPoint: _eventCommentPoint,
  //     likePoint: _eventLikePoint,
  //     invitationPoint: _eventInvitationPoint,
  //     quizPoint: _eventQuizPoint,
  //     ageLimit: _eventAgeLimit,
  //     maxStepCount: _eventMaxStepCount,
  //     eventType: _eventType.name,
  //   );

  //   await ref.read(eventRepo).editEvent(eventModel);
  //   if (!mounted) return;
  //   resultBottomModal(context, "성공적으로 행사가 수정되었습니다.", widget.refreshScreen);
  // }

  Future<void> deleteEvent(String eventId) async {
    await ref.read(eventRepo).deleteEvent(eventId);
    await ref.read(eventRepo).deleteEventImageStorage(eventId);

    if (!mounted) return;
    resultBottomModal(context, "성공적으로 행사가 삭제되었습니다.", widget.refreshScreen);
  }

  // void updateStepPoint(int point) {
  //   setState(() {
  //     _eventStepPoint = point;
  //   });
  // }

  // void updateDiaryPoint(int point) {
  //   setState(() {
  //     _eventDiaryPoint = point;
  //   });
  // }

  // void updateCommentPoint(int point) {
  //   setState(() {
  //     _eventCommentPoint = point;
  //   });
  // }

  // void updateLikePoint(int point) {
  //   setState(() {
  //     _eventLikePoint = point;
  //   });
  // }

  // void updateInvitationPoint(int point) {
  //   setState(() {
  //     _eventInvitationPoint = point;
  //   });
  // }

  // void updateQuizPoint(int point) {
  //   setState(() {
  //     _eventQuizPoint = point;
  //   });
  // }

  // void updateMaxStepCount(int maxCount) {
  //   setState(() {
  //     _eventMaxStepCount = maxCount;
  //   });
  // }

  void removeDeleteOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  void showDeleteOverlay(
      BuildContext context, String eventId, String eventName) async {
    removeDeleteOverlay();

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.black54,
          child: Center(
            child: AlertDialog(
              title: SelectableText(
                eventName.length > 10
                    ? "${eventName.substring(0, 11)}.."
                    : eventName,
                style: const TextStyle(
                  fontSize: Sizes.size20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: Colors.white,
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SelectableText(
                    "정말로 삭제하시겠습니까?",
                    style: TextStyle(
                      fontSize: Sizes.size13,
                    ),
                  ),
                  SelectableText(
                    "삭제하면 다시 되돌릴 수 없습니다.",
                    style: TextStyle(
                      fontSize: Sizes.size13,
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: removeDeleteOverlay,
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all(Colors.pink.shade100),
                  ),
                  child: SelectableText(
                    "취소",
                    style: TextStyle(
                      fontSize: Sizes.size13,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => deleteEvent(eventId),
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all(Theme.of(context).primaryColor),
                  ),
                  child: const SelectableText(
                    "삭제",
                    style: TextStyle(
                      fontSize: Sizes.size13,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    Overlay.of(context, debugRequiredFor: widget).insert(overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: SelectableText(
                "2. 목표 점수를 설정해주세요.",
                style: headerTextStyle,
                textAlign: TextAlign.start,
              ),
            ),
            Expanded(
              flex: 4,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 100,
                    height: 40,
                    child: TextFormField(
                      // expands: true,
                      maxLines: 1,
                      // minLines: null,
                      controller: widget.goalScoreController,
                      textAlignVertical: TextAlignVertical.top,
                      style: contentTextStyle,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Palette().darkBlue.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            Sizes.size20,
                          ),
                        ),
                        errorStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            Sizes.size20,
                          ),
                          borderSide: BorderSide(
                            width: 1.5,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            Sizes.size20,
                          ),
                          borderSide: BorderSide(
                            width: 1.5,
                            color: Palette().darkBlue.withOpacity(0.7),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            Sizes.size20,
                          ),
                          borderSide: BorderSide(
                            width: 1.5,
                            color: Palette().darkBlue.withOpacity(0.7),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: Sizes.size20,
                          vertical: Sizes.size20,
                        ),
                      ),
                    ),
                  ),
                  Gaps.h10,
                  SelectableText(
                    "점",
                    style: contentTextStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
        Gaps.v52,
        SelectableText(
          "3. 점수 산출 방식을 설정해주세요.",
          style: headerTextStyle,
          textAlign: TextAlign.start,
        ),
        Gaps.v20,
        // PointFieldBox(
        //   diaryField: widget.diaryField,
        //   quizField: widget.quizField,
        //   commentField: widget.commentField,
        //   likeField: widget.likeField,
        //   invitationField: widget.invitationField,
        //   stepField: widget.stepField,
        //   quizLimitField: widget.quizLimitField,
        //   commentLimitField: widget.commentLimitField,
        //   likeLimitField: widget.likeLimitField,
        //   invitationLimitField: widget.invitationLimitField,
        // ),
      ],
    );
  }
}

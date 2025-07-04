import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/view_a/modal_screen.dart';
import 'package:onldocc_admin/common/widgets/modal_button.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/event/models/event_model.dart';
import 'package:onldocc_admin/features/event/models/quiz_event_model.dart';
import 'package:onldocc_admin/features/event/repo/event_repo.dart';
import 'package:onldocc_admin/features/event/view/event_screen.dart';
import 'package:onldocc_admin/features/event/widgets/upload-event/upload_count_widget.dart';
import 'package:onldocc_admin/features/event/widgets/upload-event/upload_multiple_scores_widget.dart';
import 'package:onldocc_admin/features/event/widgets/upload-event/upload_quiz_event_widget.dart';
import 'package:onldocc_admin/features/event/widgets/upload-event/upload_target_score_widget.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:uuid/uuid.dart';

class UploadEventWidget extends ConsumerStatefulWidget {
  final BuildContext pcontext;
  final Size size;
  final Function() refreshScreen;
  final bool edit;
  final EventModel? eventModel;
  const UploadEventWidget({
    super.key,
    required this.pcontext,
    required this.size,
    required this.refreshScreen,
    required this.edit,
    this.eventModel,
  });

  @override
  ConsumerState<UploadEventWidget> createState() => _UploadEventWidgetState();
}

class _UploadEventWidgetState extends ConsumerState<UploadEventWidget> {
  bool _enabledEventButton = false;
  // final TextEditingController _titleControllder = TextEditingController();
  // final TextEditingController _descriptionControllder = TextEditingController();
  // final TextEditingController _goalScoreController = TextEditingController();
  // final TextEditingController _prizewinnersControllder =
  //     TextEditingController();
  // final TextEditingController _ageLimitControllder = TextEditingController();

  // 행사 추가하기
  String _eventTitle = "";
  String _eventDescription = "";

  String _bannerImage = "";
  PlatformFile? _bannerImageFile;
  Uint8List? _bannerImageBytes;

  String _eventImage = "";
  PlatformFile? _eventImageFile;
  Uint8List? _eventImageBytes;

  DateTime? _eventStartDate;
  DateTime? _eventEndDate;

  int _eventPrizeWinners = 0;
  int _eventAgeLimit = 0;

  int _eventGoalScore = 0;

  EventType _eventType = eventList[0];

  int _eventStepPoint = 0;
  int _eventDiaryPoint = 0;
  int _eventCommentPoint = 0;
  int _eventLikePoint = 0;
  int _eventInvitationPoint = 0;
  int _eventQuizPoint = 0;

  int _eventDiaryCount = 0;
  int _eventCommentCount = 0;
  int _eventLikeCount = 0;
  int _eventInvitationCount = 0;
  int _eventQuizCount = 0;

  int _eventMaxStepCount = 7000;
  int _eventMaxCommentCount = 0;
  int _eventMaxLikeCount = 0;
  int _eventMaxInvitationCount = 0;

  String _eventInvitationType = "send";

  // String _eventQuizOne = "";
  // String _eventAnswerOne = "";

  String _eventQuiz = "";
  String _eventFirstChoice = "";
  String _eventSecondChoice = "";
  String _eventThirdChoice = "";
  String _eventFourthChoice = "";
  int _eventQuizAnswer = 0;

  bool tapUploadEvent = false;
  bool notFilledEventSetting = false;

  OverlayEntry? overlayEntry;
  GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();

  // final _diaryField = ValueNotifier<bool>(false);
  // final _quizField = ValueNotifier<bool>(false);
  // final _commentField = ValueNotifier<bool>(false);
  // final _likeField = ValueNotifier<bool>(false);
  // final _invitationField = ValueNotifier<bool>(false);
  // final _stepField = ValueNotifier<bool>(false);

  // final _quizLimitField = ValueNotifier<bool>(false);
  // final _commentLimitField = ValueNotifier<bool>(false);
  // final _likeLimitField = ValueNotifier<bool>(false);
  // final _invitationLimitField = ValueNotifier<bool>(false);

  // final TextEditingController _diaryController = TextEditingController();
  // final TextEditingController _quizController = TextEditingController();
  // final TextEditingController _commentController = TextEditingController();
  // final TextEditingController _likeController = TextEditingController();
  // final TextEditingController _invitationController = TextEditingController();
  // final TextEditingController _stepController = TextEditingController();

  // final TextEditingController _commentMaxController = TextEditingController();
  // final TextEditingController _likeMaxController = TextEditingController();
  // final TextEditingController _invitationMaxController =
  //     TextEditingController();
  // final TextEditingController _stepMaxController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // 점수
    _eventMaxStepCount = 7000;

    if (widget.edit && widget.eventModel != null) {
      _eventTitle = widget.eventModel!.title;
      _eventDescription = widget.eventModel!.description;
      _eventStartDate =
          convertStartDateStringToDateTime(widget.eventModel!.startDate);
      _eventEndDate =
          convertEndDateStringToDateTime(widget.eventModel!.endDate);
      _eventGoalScore = widget.eventModel!.targetScore!;
      _eventPrizeWinners = widget.eventModel!.achieversNumber;
      _eventAgeLimit = widget.eventModel!.ageLimit ?? 0;
      _bannerImage = widget.eventModel!.bannerImage;
      _eventImage = widget.eventModel!.eventImage;
      _eventType = eventList.firstWhere(
          (element) => element.eventCode == widget.eventModel!.eventType);

      _eventStepPoint = widget.eventModel!.stepPoint ?? 0;
      _eventDiaryPoint = widget.eventModel!.diaryPoint ?? 0;
      _eventCommentPoint = widget.eventModel!.commentPoint ?? 0;
      _eventLikePoint = widget.eventModel!.likePoint ?? 0;
      _eventInvitationPoint = widget.eventModel!.invitationPoint ?? 0;
      _eventQuizPoint = widget.eventModel!.quizPoint ?? 0;
      _eventDiaryCount = widget.eventModel!.diaryCount ?? 0;
      _eventCommentCount = widget.eventModel!.commentCount ?? 0;
      _eventLikeCount = widget.eventModel!.likeCount ?? 0;
      _eventInvitationCount = widget.eventModel!.invitationCount ?? 0;
      _eventQuizCount = widget.eventModel!.quizCount ?? 0;
      _eventMaxStepCount = widget.eventModel!.maxStepCount ?? 0;
      _eventMaxCommentCount = widget.eventModel!.maxCommentCount ?? 0;
      _eventMaxLikeCount = widget.eventModel!.maxLikeCount ?? 0;
      _eventMaxInvitationCount = widget.eventModel!.maxInvitationCount ?? 0;

      _eventQuiz = widget.eventModel!.quiz ?? "";
      _eventFirstChoice = widget.eventModel!.firstChoice ?? "";
      _eventSecondChoice = widget.eventModel!.secondChoice ?? "";
      _eventThirdChoice = widget.eventModel!.thirdChoice ?? "";
      _eventFourthChoice = widget.eventModel!.fourthChoice ?? "";
      _eventQuizAnswer = widget.eventModel!.quizAnswer ?? 0;

      _eventInvitationType = widget.eventModel!.invitationType;
    }
  }

  @override
  void dispose() {
    removeDeleteOverlay();
    super.dispose();
  }

  void selectStartPeriod(void Function(void Function()) setState) async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year, now.month, 1),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Palette().darkBlue,
              onSurface: Palette().darkGray,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _eventStartDate = picked;
      });
      checkEnabledEventButton();
    }
  }

  void selectEndPeriod(void Function(void Function()) setState) async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year, now.month, 1),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Palette().darkBlue,
              onSurface: Palette().darkGray,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _eventEndDate = picked;
      });
      checkEnabledEventButton();
    }
  }

  Future<void> pickEventImageFromGallery(
      void Function(void Function()) setState) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result == null) return;
      setState(() {
        _eventImage = "";
        _eventImageFile = result.files.first;
        _eventImageBytes = result.files.first.bytes!;
      });
      checkEnabledEventButton();
    } catch (e) {
      if (!mounted) return;
      showWarningSnackBar(context, "오류가 발생했습니다");
    }
  }

  Future<void> pickBannerImageFromGallery(
      void Function(void Function()) setState) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result == null) return;
      setState(() {
        _bannerImage = "";
        _bannerImageFile = result.files.first;
        _bannerImageBytes = result.files.first.bytes!;
      });
      checkEnabledEventButton();
    } catch (e) {
      if (!mounted) return;
      showWarningSnackBar(context, "오류가 발생했습니다");
    }
  }

  void checkEnabledEventButton() {
    bool enabledEventButton = _eventTitle.isNotEmpty &&
        _eventDescription.isNotEmpty &&
        _eventImageBytes != null &&
        _bannerImageBytes != null &&
        _eventStartDate != null &&
        _eventEndDate != null;
    if (enabledEventButton) {
      tapUploadEvent = false;
      _enabledEventButton = enabledEventButton;
    } else {
      _enabledEventButton = enabledEventButton;
    }
    setState(() {});
  }

  Future<void> _submitEvent() async {
    setState(() {
      tapUploadEvent = true;
      notFilledEventSetting = _eventType.eventCode == "quiz" &&
          (_eventQuiz == "" ||
              _eventFirstChoice == "" ||
              _eventSecondChoice == "" ||
              _eventThirdChoice == "" ||
              _eventFourthChoice == "" ||
              _eventQuizAnswer == 0);
    });

    if ((!widget.edit && !_enabledEventButton) || notFilledEventSetting) {
      return;
    }

    AdminProfileModel? adminProfileModel =
        ref.read(adminProfileProvider).value ??
            await ref.read(adminProfileProvider.notifier).getAdminProfile();
    final eventId =
        !widget.edit ? const Uuid().v4() : widget.eventModel!.eventId;

    final eventImageUrl = await ref
        .read(eventRepo)
        .uploadSingleImageToStorage(eventId, _eventImageBytes ?? _eventImage);
    final bannerImageUrl = await ref
        .read(eventRepo)
        .uploadSingleImageToStorage(eventId, _bannerImageBytes ?? _bannerImage);

    final eventModel = EventModel(
      eventId: eventId,
      title: _eventTitle,
      description: _eventDescription,
      eventImage: eventImageUrl,
      bannerImage: bannerImageUrl,
      allUsers: selectContractRegion.value!.subdistrictId != "" ? false : true,
      targetScore: _eventGoalScore,
      achieversNumber: _eventPrizeWinners,
      startDate: convertTimettampToStringDot(_eventStartDate!),
      endDate: convertTimettampToStringDot(_eventEndDate!),
      createdAt: getCurrentSeconds(),
      contractRegionId: adminProfileModel.contractRegionId != ""
          ? adminProfileModel.contractRegionId
          : null,
      contractCommunityId: selectContractRegion.value!.contractCommunityId != ""
          ? selectContractRegion.value!.contractCommunityId
          : null,
      stepPoint: _eventStepPoint,
      diaryPoint: _eventDiaryPoint,
      commentPoint: _eventCommentPoint,
      likePoint: _eventLikePoint,
      invitationPoint: _eventInvitationPoint,
      quizPoint: _eventQuizPoint,
      diaryCount: _eventDiaryCount,
      commentCount: _eventCommentCount,
      likeCount: _eventLikeCount,
      invitationCount: _eventInvitationCount,
      quizCount: _eventQuizCount,
      adminSecret: true,
      eventType: _eventType.eventCode,
      ageLimit: _eventAgeLimit,
      maxStepCount: _eventMaxStepCount,
      maxCommentCount: _eventMaxCommentCount,
      maxLikeCount: _eventMaxLikeCount,
      maxInvitationCount: _eventMaxInvitationCount,
      invitationType: _eventInvitationType,
    );

    !widget.edit
        ? await ref.read(eventRepo).addEvent(eventModel)
        : await ref.read(eventRepo).editEvent(eventModel);

    // 퀴즈: quiz_event_db
    if (_eventType.eventCode == "quiz") {
      final quizEventId =
          !widget.edit ? const Uuid().v4() : widget.eventModel!.quizEventId!;
      final quizEventModel = QuizEventModel(
        quizEventId: quizEventId,
        eventId: eventId,
        quiz: _eventQuiz,
        firstChoice: _eventFirstChoice,
        secondChoice: _eventSecondChoice,
        thirdChoice: _eventThirdChoice,
        fourthChoice: _eventFourthChoice,
        quizAnswer: _eventQuizAnswer,
      );
      !widget.edit
          ? await ref.read(eventRepo).addQuizEvent(quizEventModel)
          : await ref.read(eventRepo).editQuizEvent(quizEventModel);
    }

    if (!mounted) return;
    resultBottomModal(
        context,
        !widget.edit ? "성공적으로 행사가 올라갔습니다" : "성공적으로 행사가 수정되었습니다",
        widget.refreshScreen);
  }

  void updateGoalScore(int goalScore) {
    setState(() {
      _eventGoalScore = goalScore;
    });

    checkEnabledEventButton();
  }

  void updateStepPoint(int point) {
    setState(() {
      _eventStepPoint = point;
    });
  }

  void updateDiaryPoint(int point) {
    setState(() {
      _eventDiaryPoint = point;
    });
  }

  void updateCommentPoint(int point) {
    setState(() {
      _eventCommentPoint = point;
    });
  }

  void updateLikePoint(int point) {
    setState(() {
      _eventLikePoint = point;
    });
  }

  void updateInvitationPoint(int point) {
    setState(() {
      _eventInvitationPoint = point;
    });
  }

  void updateQuizPoint(int point) {
    setState(() {
      _eventQuizPoint = point;
    });
  }

  void updateDiaryCount(int count) {
    setState(() {
      _eventDiaryCount = count;
    });
  }

  void updateCommentCount(int count) {
    setState(() {
      _eventCommentCount = count;
    });
  }

  void updateLikeCount(int count) {
    setState(() {
      _eventLikeCount = count;
    });
  }

  void updateInvitationCount(int count) {
    setState(() {
      _eventInvitationCount = count;
    });
  }

  void updateQuizCount(int count) {
    setState(() {
      _eventQuizCount = count;
    });
  }

  void updateMaxStepCount(int maxCount) {
    setState(() {
      _eventMaxStepCount = maxCount;
    });
  }

  void updateMaxCommentCount(int maxCount) {
    setState(() {
      _eventMaxCommentCount = maxCount;
    });
  }

  void updateMaxLikeCount(int maxCount) {
    setState(() {
      _eventMaxLikeCount = maxCount;
    });
  }

  void updateMaxInvitationCount(int maxCount) {
    setState(() {
      _eventMaxInvitationCount = maxCount;
    });
  }

  void updateQuiz(String quiz) {
    setState(() {
      _eventQuiz = quiz;
    });
  }

  void updateFirstChoice(String value) {
    setState(() {
      _eventFirstChoice = value;
    });
  }

  void updateSecondChoice(String value) {
    setState(() {
      _eventSecondChoice = value;
    });
  }

  void updateThirdChoice(String value) {
    setState(() {
      _eventThirdChoice = value;
    });
  }

  void updateFourthChoice(String value) {
    setState(() {
      _eventFourthChoice = value;
    });
  }

  void updateQuizAnswer(int value) {
    setState(() {
      _eventQuizAnswer = value;
    });
  }

  void updateInvitationType(String value) {
    setState(() {
      _eventInvitationType = value;
    });
  }

  // 행사 삭제
  void removeDeleteOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  Future<void> deleteEvent(String eventId) async {
    await ref.read(eventRepo).deleteEvent(eventId);
    await ref.read(eventRepo).deleteEventImageStorage(eventId);

    if (!mounted) return;
    resultBottomModal(context, "성공적으로 행사가 삭제되었습니다.", widget.refreshScreen);
  }

  void showDeleteOverlay(String eventId, String eventName) async {
    removeDeleteOverlay();
    overlayEntry = OverlayEntry(builder: (context) {
      return deleteUserOverlay(
          eventName.length > 10 ? "${eventName.substring(0, 11)}.." : eventName,
          removeDeleteOverlay,
          () => deleteEvent(eventId));
    });

    Overlay.of(widget.pcontext, debugRequiredFor: widget).insert(overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return StatefulBuilder(builder: (context, setState) {
      return ModalScreen(
        size: size,
        modalTitle: !widget.edit ? "행사 올리기" : "행사 수정하기",
        modalButtonOneText: !widget.edit ? "확인" : "삭제하기",
        modalButtonOneFunction: !widget.edit
            ? _submitEvent
            : () => showDeleteOverlay(
                widget.eventModel!.eventId, widget.eventModel!.title),
        modalButtonTwoText: !widget.edit ? null : "수정하기",
        modalButtonTwoFunction: _submitEvent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: SizedBox(
                          width: widget.size.width * 0.12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SelectableText("행사 이름", style: headerTextStyle),
                              if (tapUploadEvent && _eventTitle.isEmpty)
                                const InsufficientField(text: "행사 이름을 입력해주세요")
                            ],
                          ),
                        ),
                      ),
                      Gaps.h32,
                      Expanded(
                        child: SizedBox(
                          child: TextFormField(
                            onChanged: (value) {
                              setState(
                                () {
                                  _eventTitle = value;
                                },
                              );
                            },
                            initialValue: _eventTitle,
                            textAlignVertical: TextAlignVertical.top,
                            style: contentTextStyle,
                            decoration: inputDecorationStyle(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Gaps.v52,
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: widget.size.width * 0.12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText(
                              "행사 설명",
                              style: headerTextStyle,
                              textAlign: TextAlign.start,
                            ),
                            if (tapUploadEvent && _eventDescription.isEmpty)
                              const InsufficientField(text: "행사 설명을 입력해주세요")
                          ],
                        ),
                      ),
                      Gaps.h32,
                      Expanded(
                        child: SizedBox(
                          height: 200,
                          child: TextFormField(
                            expands: true,
                            maxLines: null,
                            minLines: null,
                            onChanged: (value) {
                              setState(
                                () {
                                  _eventDescription = value;
                                },
                              );
                            },
                            initialValue: _eventDescription,
                            textAlignVertical: TextAlignVertical.top,
                            style: contentTextStyle,
                            decoration: inputDecorationStyle(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Gaps.v52,
                // 3단
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 300,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: widget.size.width * 0.12,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SelectableText(
                                          "배너 이미지",
                                          style: headerTextStyle,
                                          textAlign: TextAlign.start,
                                        ),
                                        Gaps.v5,
                                        SelectableText(
                                          "가로:세로 = 5:4 비율\n(ex. 1000px:800px)",
                                          style: headerInfoTextStyle,
                                          textAlign: TextAlign.start,
                                        ),
                                        if (tapUploadEvent &&
                                            (!widget.edit &&
                                                _bannerImageBytes == null))
                                          const InsufficientField(
                                              text: "배너 이미지를 추가해주세요")
                                      ],
                                    ),
                                  ),
                                  Gaps.h32,
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 150,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            Sizes.size20,
                                          ),
                                          border: Border.all(
                                              width: 1.5,
                                              color: Palette()
                                                  .darkGray
                                                  .withOpacity(0.5)),
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                        child: _bannerImage != ""
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Image.network(
                                                  _bannerImage,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : _bannerImageFile == null
                                                ? Icon(
                                                    Icons.image,
                                                    size: Sizes.size60,
                                                    color: Palette()
                                                        .darkBlue
                                                        .withOpacity(0.3),
                                                  )
                                                : ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    child: Image.memory(
                                                      _bannerImageBytes!,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                      ),
                                      Gaps.v20,
                                      ModalButton(
                                        modalText: "이미지 올리기",
                                        modalAction: () =>
                                            pickBannerImageFromGallery(
                                                setState),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Gaps.v52,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: widget.size.width * 0.12,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SelectableText(
                                        "시작일",
                                        style: headerTextStyle,
                                        textAlign: TextAlign.start,
                                      ),
                                      if (tapUploadEvent &&
                                          _eventStartDate == null)
                                        const InsufficientField(
                                            text: "시작일을 입력해주세요")
                                    ],
                                  ),
                                ),
                                Gaps.h32,
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: ModalButton(
                                          modalText: '날짜 선택하기',
                                          modalAction: () =>
                                              selectStartPeriod(setState)),
                                    ),
                                    Gaps.h20,
                                    if (_eventStartDate != null)
                                      SelectableText(
                                        "${_eventStartDate?.year}.${_eventStartDate?.month.toString().padLeft(2, '0')}.${_eventStartDate?.day.toString().padLeft(2, '0')}",
                                        style: contentTextStyle,
                                      ),
                                  ],
                                )
                              ],
                            ),
                            Gaps.v52,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: widget.size.width * 0.12,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SelectableText(
                                        "당첨자 수 제한",
                                        style: headerTextStyle,
                                        textAlign: TextAlign.start,
                                      ),
                                    ],
                                  ),
                                ),
                                Gaps.h32,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                          width: 100,
                                          height: 40,
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            // expands: true,
                                            maxLines: 1,
                                            // minLines: null,
                                            initialValue: "$_eventPrizeWinners",
                                            onChanged: (value) {
                                              if (value.isNotEmpty) {
                                                setState(() {
                                                  _eventPrizeWinners =
                                                      int.parse(value);
                                                });
                                              }
                                            },
                                            textAlignVertical:
                                                TextAlignVertical.top,
                                            style: contentTextStyle,
                                            decoration: inputDecorationStyle(),
                                          ),
                                        ),
                                        Gaps.h10,
                                        SelectableText(
                                          "명",
                                          style: contentTextStyle,
                                        ),
                                      ],
                                    ),
                                    Gaps.v16,
                                    SelectableText(
                                      "제한이 없을 경우 '0'을 기입해주세요.",
                                      style: headerInfoTextStyle,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // 3단 경계선
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                        ),
                        child: Container(
                          width: 0.5,
                          decoration: BoxDecoration(
                            color: Palette().lightGray,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 300,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: widget.size.width * 0.12,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SelectableText(
                                          "행사 이미지",
                                          style: headerTextStyle,
                                          textAlign: TextAlign.start,
                                        ),
                                        if (tapUploadEvent &&
                                            (!widget.edit &&
                                                _eventImageBytes == null))
                                          const InsufficientField(
                                              text: "행사 이미지를 추가해주세요")
                                      ],
                                    ),
                                  ),
                                  Gaps.h32,
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 150,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            Sizes.size20,
                                          ),
                                          border: Border.all(
                                            width: 1.5,
                                            color: Palette()
                                                .darkGray
                                                .withOpacity(0.5),
                                          ),
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                        child: _eventImage != ""
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Image.network(
                                                  _eventImage,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : _eventImageBytes == null
                                                ? Icon(
                                                    Icons.image,
                                                    size: Sizes.size60,
                                                    color: Palette()
                                                        .darkBlue
                                                        .withOpacity(0.3),
                                                  )
                                                : ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    child: Image.memory(
                                                      _eventImageBytes!,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                      ),
                                      Gaps.v20,
                                      ModalButton(
                                        modalText: "이미지 올리기",
                                        modalAction: () =>
                                            pickEventImageFromGallery(setState),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Gaps.v52,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: widget.size.width * 0.12,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SelectableText(
                                        "종료일",
                                        style: headerTextStyle,
                                        textAlign: TextAlign.start,
                                      ),
                                      if (tapUploadEvent &&
                                          _eventEndDate == null)
                                        const InsufficientField(
                                            text: "종료일을 입력해주세요")
                                    ],
                                  ),
                                ),
                                Gaps.h32,
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: ModalButton(
                                          modalText: '날짜 선택하기',
                                          modalAction: () =>
                                              selectEndPeriod(setState)),
                                    ),
                                    Gaps.h20,
                                    if (_eventEndDate != null)
                                      SelectableText(
                                        "${_eventEndDate?.year}.${_eventEndDate?.month.toString().padLeft(2, '0')}.${_eventEndDate?.day.toString().padLeft(2, '0')}",
                                        style: contentTextStyle,
                                      ),
                                  ],
                                )
                              ],
                            ),
                            Gaps.v52,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: widget.size.width * 0.12,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SelectableText(
                                        "연령 제한",
                                        style: headerTextStyle,
                                        textAlign: TextAlign.start,
                                      ),
                                    ],
                                  ),
                                ),
                                Gaps.h32,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                          width: 100,
                                          height: 40,
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,

                                            // expands: true,
                                            maxLines: 1,
                                            // minLines: null,
                                            onChanged: (value) {
                                              if (value.isNotEmpty) {
                                                setState(() {
                                                  _eventAgeLimit =
                                                      int.parse(value);
                                                });
                                              }
                                            },
                                            initialValue: "$_eventAgeLimit",
                                            textAlignVertical:
                                                TextAlignVertical.top,
                                            style: contentTextStyle,
                                            decoration: inputDecorationStyle(),
                                          ),
                                        ),
                                        Gaps.h10,
                                        SelectableText(
                                          "세 이상",
                                          style: contentTextStyle,
                                        ),
                                      ],
                                    ),
                                    Gaps.v16,
                                    SelectableText(
                                      "제한이 없을 경우 '0'을 기입해주세요.",
                                      style: headerInfoTextStyle,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Gaps.v60,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        color: Palette().darkBlue.withOpacity(0.3),
                      ),
                    ),
                    Gaps.v52,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SelectableText(
                          "행사 설정",
                          style: TextStyle(
                            color: Palette().darkBlue,
                            fontWeight: FontWeight.w700,
                            fontSize: Sizes.size14,
                          ),
                        ),
                        if (tapUploadEvent && notFilledEventSetting)
                          Row(
                            children: [
                              Gaps.h32,
                              SelectableText(
                                "행사 설정의 빈칸을 채워주세요",
                                style: headerTextStyle.copyWith(
                                  color: Colors.red,
                                ),
                                // overflow: TextOverflow.visible,
                                // softWrap: true,
                              )
                            ],
                          ),
                      ],
                    ),
                    Gaps.v52,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: SelectableText(
                            "1. 행사 유형을 설정해주세요.",
                            style: headerTextStyle,
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 300,
                                height: 40,
                                child: EventTypeDropdown(
                                  items: eventList
                                      .map((e) => e.eventTypeName)
                                      .toList(),
                                  value: _eventType.eventTypeName,
                                  onChangedFunction: (value) {
                                    final selectedEventType =
                                        eventList.firstWhere((element) =>
                                            element.eventTypeName == value);
                                    setState(
                                      () {
                                        _eventType = selectedEventType;
                                      },
                                    );
                                  },
                                ),
                              ),
                              Gaps.v16,
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Palette().darkBlue,
                                    size: 13,
                                  ),
                                  Gaps.h10,
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SelectableText(
                                        "${_eventType.eventTypeName}:",
                                        style: TextStyle(
                                          color: Palette().darkBlue,
                                          fontWeight: FontWeight.w700,
                                          fontSize: Sizes.size12,
                                        ),
                                      ),
                                      Gaps.v6,
                                      SelectableText(
                                        _eventType.eventTypeDescription,
                                        style: TextStyle(
                                          color: Palette().dashBlue,
                                          fontWeight: FontWeight.w300,
                                          fontSize: Sizes.size12,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Gaps.v52,
                    _eventType == eventList[0]
                        ? UploadTargetScoreWidget(
                            updateGoalScore: updateGoalScore,
                            updateDiaryPoint: updateDiaryPoint,
                            updateCommentPoint: updateCommentPoint,
                            updateLikePoint: updateLikePoint,
                            updateStepPoint: updateStepPoint,
                            updateInvitationPoint: updateInvitationPoint,
                            updateQuizPoint: updateQuizPoint,
                            updateMaxStepPoint: updateMaxStepCount,
                            updateMaxCommentPoint: updateMaxCommentCount,
                            updateMaxLikePoint: updateMaxLikeCount,
                            updateMaxInvitationPoint: updateMaxInvitationCount,
                            updateInvitationType: updateInvitationType,
                            edit: widget.edit,
                            eventModel: widget.eventModel,
                          )
                        : _eventType == eventList[1]
                            ? UploadMultipleScoresWidget(
                                updateDiaryPoint: updateDiaryPoint,
                                updateCommentPoint: updateCommentPoint,
                                updateLikePoint: updateLikePoint,
                                updateStepPoint: updateStepPoint,
                                updateInvitationPoint: updateInvitationPoint,
                                updateQuizPoint: updateQuizPoint,
                                updateMaxStepPoint: updateMaxStepCount,
                                updateMaxCommentPoint: updateMaxCommentCount,
                                updateMaxLikePoint: updateMaxLikeCount,
                                updateMaxInvitationPoint:
                                    updateMaxInvitationCount,
                                updateInvitationType: updateInvitationType,
                                edit: widget.edit,
                                eventModel: widget.eventModel,
                              )
                            : _eventType == eventList[2]
                                ? UploadCountWidget(
                                    updateDiaryCount: updateDiaryCount,
                                    updateCommentCount: updateCommentCount,
                                    updateLikeCount: updateLikeCount,
                                    updateInvitationCount:
                                        updateInvitationCount,
                                    updateQuizCount: updateQuizCount,
                                    updateMaxCommentCount:
                                        updateMaxCommentCount,
                                    updateMaxLikeCount: updateMaxLikeCount,
                                    updateMaxInvitationCount:
                                        updateMaxInvitationCount,
                                    updateInvitationType: updateInvitationType,
                                    edit: widget.edit,
                                    eventModel: widget.eventModel,
                                  )
                                : _eventType == eventList[3]
                                    ? UploadQuizEventWidget(
                                        updateQuiz: updateQuiz,
                                        updateFirstChoice: updateFirstChoice,
                                        updateSecondChoice: updateSecondChoice,
                                        updateThirdChoice: updateThirdChoice,
                                        updateFourthChoice: updateFourthChoice,
                                        updateQuizAnswer: updateQuizAnswer,
                                        submit: tapUploadEvent,
                                        edit: widget.edit,
                                        eventModel: widget.eventModel,
                                      )
                                    : _eventType == eventList[4]
                                        ? Container()
                                        : Container(),
                    Gaps.v40,
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class DefaultPointTile extends StatelessWidget {
  final double totalWidth;
  final Function(int) updateEventPoint;
  final String header;
  final int defaultPoint;
  const DefaultPointTile({
    super.key,
    required this.totalWidth,
    required this.updateEventPoint,
    required this.header,
    required this.defaultPoint,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: totalWidth * 0.1,
          child: SelectableText(
            "⚬ $header",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.start,
          ),
        ),
        Gaps.h32,
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: 100,
              child: TextFormField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                minLines: 1,
                onChanged: (value) {
                  final point = int.parse(value);
                  updateEventPoint(point);
                },
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(
                  fontSize: Sizes.size14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                decoration: inputDecorationStyle(),
              ),
            ),
            Gaps.h10,
            SelectableText(
              "점",
              style: TextStyle(
                fontSize: Sizes.size14,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w300,
              ),
            ),
            if (header == "걸음수")
              const Row(
                children: [
                  Gaps.h10,
                  SelectableText(
                    "/ 1000보 당",
                    style: TextStyle(
                      fontSize: Sizes.size13,
                      fontWeight: FontWeight.w400,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class CommentTextWidget extends StatelessWidget {
  final String text;
  const CommentTextWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      text,
      style: TextStyle(
        fontSize: Sizes.size12,
        fontWeight: FontWeight.w300,
        color: Colors.grey.shade600,
      ),
    );
  }
}

class InsufficientField extends StatelessWidget {
  final String text;
  const InsufficientField({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Gaps.v20,
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: SelectableText(
                text,
                style: headerTextStyle.copyWith(
                  color: Colors.red,
                ),
                // overflow: TextOverflow.visible,
                // softWrap: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class EventTypeDropdown extends StatelessWidget {
  final List<String> items;
  final String value;
  final Function(String?) onChangedFunction;
  const EventTypeDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.onChangedFunction,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 40,
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 12,
                  color: Palette().normalGray,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          value: value,
          onChanged: (value) => onChangedFunction(value),
          buttonStyleData: ButtonStyleData(
            padding: const EdgeInsets.only(left: 14, right: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              border: Border.all(
                color: Palette().darkBlue,
                width: 0.5,
              ),
            ),
          ),
          iconStyleData: IconStyleData(
            icon: const Icon(
              Icons.expand_more_rounded,
            ),
            iconSize: 14,
            iconEnabledColor: Palette().darkBlue,
            iconDisabledColor: Palette().darkBlue,
          ),
          dropdownStyleData: DropdownStyleData(
            elevation: 2,
            width: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(10),
              thumbVisibility: WidgetStateProperty.all(true),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 25,
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
            ),
          ),
        ),
      ),
    );
  }
}

class ChildTileModel {
  final int index;
  final String tileText;
  final Color tileColor;

  ChildTileModel({
    required this.index,
    required this.tileText,
    required this.tileColor,
  });
}

class EventType {
  final String eventTypeName;
  final String eventTypeDescription;
  final String eventCode;

  EventType({
    required this.eventTypeName,
    required this.eventTypeDescription,
    required this.eventCode,
  });
}

final eventList = [
  EventType(
    eventTypeName: "목표 달성 행사",
    eventTypeDescription: "행사 기간 동안 지정한 목표 점수를 사용자가 달성하는 행사입니다.",
    eventCode: "targetScore",
  ),
  EventType(
    eventTypeName: "고득점 점수 행사",
    eventTypeDescription: "행사 기간 내에 고득점 점수를 취득한 사용자들에게 선물을 주는 행사입니다.",
    eventCode: "multipleScores",
  ),
  EventType(
    eventTypeName: "횟수 달성 행사",
    eventTypeDescription: "행사 기간 동안 각 활동들의 설정된 횟수를 사용자가 달성하는 행사입니다.",
    eventCode: "count",
  ),
  EventType(
    eventTypeName: "객관식 퀴즈 행사",
    eventTypeDescription: "객관식 퀴즈 문제를 내면 행사 기간동안 사용자들이 객관식 문제를 푸는 행사입니다.",
    eventCode: "quiz",
  ),
  EventType(
    eventTypeName: "사진전 행사",
    eventTypeDescription: "행사 기간 동안 참여자들이 사진을 출품하는 행사입니다.",
    eventCode: "photo",
  ),
];

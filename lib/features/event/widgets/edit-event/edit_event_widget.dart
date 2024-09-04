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
import 'package:onldocc_admin/features/event/repo/event_repo.dart';
import 'package:onldocc_admin/features/event/view/event_screen.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:uuid/uuid.dart';

class EditEventWidget extends ConsumerStatefulWidget {
  final BuildContext context;
  final Size size;
  final Function() refreshScreen;
  final EventModel eventModel;
  const EditEventWidget({
    super.key,
    required this.context,
    required this.size,
    required this.refreshScreen,
    required this.eventModel,
  });

  @override
  ConsumerState<EditEventWidget> createState() => _EditEventWidgetState();
}

class _EditEventWidgetState extends ConsumerState<EditEventWidget> {
  bool _enabledEventButton = false;
  final TextEditingController _titleControllder = TextEditingController();
  final TextEditingController _descriptionControllder = TextEditingController();
  final TextEditingController _goalScoreController = TextEditingController();
  final TextEditingController _prizewinnersControllder =
      TextEditingController();
  final TextEditingController _ageLimitControllder = TextEditingController();

  // 행사 추가하기
  String _eventTitle = "";
  String _eventDescription = "";

  dynamic _bannerImage;
  PlatformFile? _bannerImageFile;
  Uint8List? _bannerImageBytes;

  dynamic _eventImage;
  PlatformFile? _eventImageFile;
  Uint8List? _eventImageBytes;

  DateTime? _eventStartDate;
  DateTime? _eventEndDate;

  int _eventPrizeWinners = 0;
  int _eventGoalScore = 0;

  EventType _eventType = eventList[0];

  int _eventAgeLimit = 0;

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

  int _eventMaxStepCount = 10000;
  int _eventMaxCommentCount = 0;
  int _eventMaxLikeCount = 0;
  int _eventMaxInvitationCount = 0;

  bool tapUploadEvent = false;

  final _diaryField = ValueNotifier<bool>(false);
  final _quizField = ValueNotifier<bool>(false);
  final _commentField = ValueNotifier<bool>(false);
  final _likeField = ValueNotifier<bool>(false);
  final _invitationField = ValueNotifier<bool>(false);
  final _stepField = ValueNotifier<bool>(false);

  final _quizLimitField = ValueNotifier<bool>(false);
  final _commentLimitField = ValueNotifier<bool>(false);
  final _likeLimitField = ValueNotifier<bool>(false);
  final _invitationLimitField = ValueNotifier<bool>(false);

  // final _quizLimitValue = ValueNotifier<int>(0);
  // final _commentLimitValue = ValueNotifier<int>(0);
  // final _likeLimitValue = ValueNotifier<int>(0);
  // final _invitationLimitValue = ValueNotifier<int>(0);
  // final _stepLimitValue = ValueNotifier<int>(0);

  final TextEditingController _diaryPointController = TextEditingController();
  final TextEditingController _quizPointController = TextEditingController();
  final TextEditingController _commentPointController = TextEditingController();
  final TextEditingController _likePointController = TextEditingController();
  final TextEditingController _invitationPointController =
      TextEditingController();
  final TextEditingController _stepPointController = TextEditingController();

  final TextEditingController _quizMaxPointController = TextEditingController();
  final TextEditingController _commentMaxPointController =
      TextEditingController();
  final TextEditingController _likeMaxPointController = TextEditingController();
  final TextEditingController _invitationMaxPointController =
      TextEditingController();
  final TextEditingController _stepMaxPointController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _initializeEvent();
  }

  @override
  void dispose() {
    _titleControllder.dispose();
    _descriptionControllder.dispose();
    _goalScoreController.dispose();
    _prizewinnersControllder.dispose();
    _ageLimitControllder.dispose();
    super.dispose();
  }

  Future<void> _initializeEvent() async {
    _eventTitle = widget.eventModel.title;
    _eventDescription = widget.eventModel.description;
    _eventStartDate =
        convertStartDateStringToDateTime(widget.eventModel.startDate);
    _eventEndDate = convertEndDateStringToDateTime(widget.eventModel.endDate);
    _eventGoalScore = widget.eventModel.targetScore!;
    _eventPrizeWinners = widget.eventModel.achieversNumber;
    _eventAgeLimit = widget.eventModel.ageLimit ?? 0;
    _bannerImage = widget.eventModel.bannerImage;
    _eventImage = widget.eventModel.eventImage;
    _eventType = eventList.firstWhere(
        (element) => element.eventCode == widget.eventModel.eventType);

    setState(() {});

    _titleControllder.text = widget.eventModel.title;
    _descriptionControllder.text = widget.eventModel.description;
    _goalScoreController.text = widget.eventModel.targetScore.toString();
    _prizewinnersControllder.text =
        widget.eventModel.achieversNumber.toString();
    _ageLimitControllder.text = widget.eventModel.ageLimit.toString();

    _diaryField.value = widget.eventModel.diaryPoint != 0;
    _quizField.value = widget.eventModel.quizPoint != 0;
    _commentField.value = widget.eventModel.commentPoint != 0;
    _likeField.value = widget.eventModel.likePoint != 0;
    _invitationField.value = widget.eventModel.invitationPoint != 0;
    _stepField.value = widget.eventModel.stepPoint != 0;

    _diaryPointController.text = widget.eventModel.diaryPoint!.toString();
    _quizPointController.text = widget.eventModel.quizPoint!.toString();
    _commentPointController.text = widget.eventModel.commentPoint!.toString();
    _likePointController.text = widget.eventModel.likePoint!.toString();
    _invitationPointController.text =
        widget.eventModel.invitationPoint!.toString();
    _stepPointController.text = widget.eventModel.stepPoint!.toString();

    // _quizMaxPointController.text = widget.eventModel.max!.toString();
    _commentPointController.text =
        widget.eventModel.maxCommentCount!.toString();
    _likePointController.text = widget.eventModel.likePoint!.toString();
    _invitationPointController.text =
        widget.eventModel.invitationPoint!.toString();
    _stepPointController.text = widget.eventModel.stepPoint!.toString();
  }

  void selectStartPeriod(void Function(void Function()) setState) async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year, now.month, 1),
      lastDate: DateTime(2030),
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
        _eventImageFile = result.files.first;
        _eventImageBytes = _eventImageFile!.bytes!;
      });
      checkEnabledEventButton();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("오류가 발생했습니다."),
        ),
      );
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
        _bannerImageFile = result.files.first;
        _bannerImageBytes = _bannerImageFile!.bytes!;
      });
      checkEnabledEventButton();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("오류가 발생했습니다."),
        ),
      );
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
    });

    if (!_enabledEventButton) return;

    AdminProfileModel? adminProfileModel = ref.read(adminProfileProvider).value;
    final eventId = const Uuid().v4();
    final eventImageUrl = await ref
        .read(eventRepo)
        .uploadSingleImageToStorage(eventId, _eventImageBytes);
    final bannerImageUrl = await ref
        .read(eventRepo)
        .uploadSingleImageToStorage(eventId, _bannerImageBytes);

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
      contractRegionId: adminProfileModel!.contractRegionId != ""
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
    );

    await ref.read(eventRepo).addEvent(eventModel);
    if (!mounted) return;
    resultBottomModal(context, "성공적으로 행사가 올라갔습니다.", widget.refreshScreen);
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return StatefulBuilder(builder: (context, setState) {
      return ModalScreen(
        size: size,
        modalTitle: "행사 수정하기",
        modalButtonOneText: "삭제하기",
        modalButtonOneFunction: () {},
        modalButtonTwoText: "수정하기",
        modalButtonTwoFunction: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Gaps.v20,
            Column(
              children: [
                Gaps.v52,
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
                              Text("행사 이름", style: headerTextStyle),
                            ],
                          ),
                        ),
                      ),
                      Gaps.h32,
                      Expanded(
                        child: SizedBox(
                          // height: 200,
                          child: TextFormField(
                            expands: true,
                            maxLines: null,
                            minLines: null,
                            controller: _titleControllder,
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
                            Text(
                              "행사 설명",
                              style: headerTextStyle,
                              textAlign: TextAlign.start,
                            ),
                            if (tapUploadEvent && _eventDescription.isEmpty)
                              const InsufficientField(text: "행사 설명을 입력해주세요.")
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
                            controller: _descriptionControllder,
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
                                        Text(
                                          "배너 이미지",
                                          style: headerTextStyle,
                                          textAlign: TextAlign.start,
                                        ),
                                        if (tapUploadEvent &&
                                            _bannerImageBytes == null)
                                          const InsufficientField(
                                              text: "배너 이미지를 추가해주세요.")
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
                                        height: 150,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            Sizes.size20,
                                          ),
                                          border: Border.all(
                                              width: 1.5,
                                              color: Palette()
                                                  .normalGray
                                                  .withOpacity(0.2)),
                                          color: Palette()
                                              .lightGray
                                              .withOpacity(0.1),
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                        child: _bannerImage != ""
                                            ? _bannerImage is Uint8List
                                                ? Image.memory(
                                                    _bannerImage,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.network(
                                                    _bannerImage,
                                                    fit: BoxFit.cover,
                                                  )
                                            : Icon(
                                                Icons.image,
                                                size: Sizes.size80,
                                                color: Colors.grey.shade200,
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
                                      Text(
                                        "시작일",
                                        style: headerTextStyle,
                                        textAlign: TextAlign.start,
                                      ),
                                      if (tapUploadEvent &&
                                          _eventStartDate == null)
                                        const InsufficientField(
                                            text: "시작일을 입력해주세요.")
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
                                      Text(
                                        "${_eventStartDate?.year}.${_eventStartDate?.month.toString().padLeft(2, '0')}.${_eventStartDate?.day.toString().padLeft(2, '0')}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade800,
                                          fontSize: Sizes.size14,
                                        ),
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
                                      Text(
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
                                            // expands: true,
                                            maxLines: 1,
                                            // minLines: null,
                                            controller:
                                                _prizewinnersControllder,
                                            textAlignVertical:
                                                TextAlignVertical.top,
                                            style: contentTextStyle,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              filled: true,
                                              fillColor: Palette()
                                                  .darkBlue
                                                  .withOpacity(0.1),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  Sizes.size20,
                                                ),
                                              ),
                                              errorStyle: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  Sizes.size20,
                                                ),
                                                borderSide: BorderSide(
                                                  width: 1.5,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  Sizes.size20,
                                                ),
                                                borderSide: BorderSide(
                                                  width: 1.5,
                                                  color: Palette()
                                                      .darkBlue
                                                      .withOpacity(0.7),
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  Sizes.size20,
                                                ),
                                                borderSide: BorderSide(
                                                  width: 1.5,
                                                  color: Palette()
                                                      .darkBlue
                                                      .withOpacity(0.7),
                                                ),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: Sizes.size20,
                                                vertical: Sizes.size20,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Gaps.h10,
                                        Text(
                                          "명",
                                          style: contentTextStyle,
                                        ),
                                      ],
                                    ),
                                    Gaps.v16,
                                    const CommentTextWidget(
                                      text: "제한이 없을 경우 '0'을 기입해주세요.",
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
                                        Text(
                                          "행사 이미지",
                                          style: headerTextStyle,
                                          textAlign: TextAlign.start,
                                        ),
                                        if (tapUploadEvent &&
                                            _eventImageBytes == null)
                                          const InsufficientField(
                                              text: "행사 이미지를 추가해주세요.")
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
                                                  .normalGray
                                                  .withOpacity(0.2)),
                                          color: Palette()
                                              .lightGray
                                              .withOpacity(0.1),
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                        child: _eventImage != ""
                                            ? _eventImage is Uint8List
                                                ? Image.memory(
                                                    _eventImage,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.network(
                                                    _eventImage,
                                                    fit: BoxFit.cover,
                                                  )
                                            : Icon(
                                                Icons.image,
                                                size: Sizes.size80,
                                                color: Colors.grey.shade200,
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
                                      Text(
                                        "종료일",
                                        style: headerTextStyle,
                                        textAlign: TextAlign.start,
                                      ),
                                      if (tapUploadEvent &&
                                          _eventEndDate == null)
                                        const InsufficientField(
                                            text: "종료일을 입력해주세요.")
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
                                      Text(
                                        "${_eventEndDate?.year}.${_eventEndDate?.month.toString().padLeft(2, '0')}.${_eventEndDate?.day.toString().padLeft(2, '0')}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade800,
                                          fontSize: Sizes.size14,
                                        ),
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
                                      Text(
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
                                            // expands: true,
                                            maxLines: 1,
                                            // minLines: null,
                                            controller: _ageLimitControllder,
                                            textAlignVertical:
                                                TextAlignVertical.top,
                                            style: contentTextStyle,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              filled: true,
                                              fillColor: Palette()
                                                  .darkBlue
                                                  .withOpacity(0.1),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  Sizes.size20,
                                                ),
                                              ),
                                              errorStyle: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  Sizes.size20,
                                                ),
                                                borderSide: BorderSide(
                                                  width: 1.5,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  Sizes.size20,
                                                ),
                                                borderSide: BorderSide(
                                                  width: 1.5,
                                                  color: Palette()
                                                      .darkBlue
                                                      .withOpacity(0.7),
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  Sizes.size20,
                                                ),
                                                borderSide: BorderSide(
                                                  width: 1.5,
                                                  color: Palette()
                                                      .darkBlue
                                                      .withOpacity(0.7),
                                                ),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: Sizes.size20,
                                                vertical: Sizes.size20,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Gaps.h10,
                                        Text(
                                          "세 이상",
                                          style: contentTextStyle,
                                        ),
                                      ],
                                    ),
                                    Gaps.v16,
                                    const CommentTextWidget(
                                      text: "제한이 없을 경우 '0'을 기입해주세요.",
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
                    Text(
                      "행사 설정",
                      style: TextStyle(
                        color: Palette().darkBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: Sizes.size14,
                      ),
                    ),
                    Gaps.v52,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
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
                                      Text(
                                        "${_eventType.eventTypeName}:",
                                        style: TextStyle(
                                          color: Palette().darkBlue,
                                          fontWeight: FontWeight.w700,
                                          fontSize: Sizes.size12,
                                        ),
                                      ),
                                      Gaps.v6,
                                      Text(
                                        _eventType.eventTypeDescription,
                                        style: TextStyle(
                                          color: Palette().darkBlue,
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
                    // _eventType == eventList[0]
                    //     ? EditTargetScoreEventWidget(
                    //         context: context,
                    //         size: size,
                    //         eventModel: widget.eventModel,
                    //         refreshScreen: widget.refreshScreen,
                    //         goalScoreController: _goalScoreController,
                    //         diaryField: _diaryField,
                    //         quizField: _quizField,
                    //         commentField: _commentField,
                    //         likeField: _likeField,
                    //         invitationField: _invitationField,
                    //         stepField: _stepField,
                    //         quizLimitField: _quizLimitField,
                    //         commentLimitField: _commentLimitField,
                    //         likeLimitField: _likeLimitField,
                    //         invitationLimitField: _invitationLimitField,
                    //         diaryPointController: _diaryPointController,
                    //         quizPointController: _quizPointController,
                    //         commentPointController: _commentPointController,
                    //         likePointController: _likePointController,
                    //         invitationPointController:
                    //             _invitationPointController,
                    //         stepPointController: _stepPointController,
                    //         commentMaxPointController:
                    //             _commentMaxPointController,
                    //         likeMaxPointController: _likeMaxPointController,
                    //         invitationMaxPointController:
                    //             _invitationMaxPointController,
                    //         stepMaxPointController: _stepMaxPointController,
                    //       )
                    //     : _eventType == eventList[1]
                    //         ? UploadMultipleScoresWidget(
                    //             updateGoalScore: updateGoalScore,
                    //             updateDiaryPoint: updateDiaryPoint,
                    //             updateCommentPoint: updateCommentPoint,
                    //             updateLikePoint: updateLikePoint,
                    //             updateStepPoint: updateStepPoint,
                    //             updateInvitationPoint: updateInvitationPoint,
                    //             updateQuizPoint: updateQuizPoint,
                    //             updateMaxStepCount: updateMaxStepCount,
                    //             updateMaxCommentCount: updateMaxCommentCount,
                    //             updateMaxLikeCount: updateMaxLikeCount,
                    //             updateInvitationCount: updateMaxInvitationCount,
                    //           )
                    //         : UploadCountWidget(
                    //             updateDiaryCount: updateDiaryCount,
                    //             updateCommentCount: updateCommentCount,
                    //             updateLikeCount: updateLikeCount,
                    //             updateInvitationCount: updateInvitationCount,
                    //             updateQuizCount: updateQuizCount,
                    //           ),
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
          child: Text(
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
                decoration: InputDecoration(
                  isDense: true,
                  hintText: "$defaultPoint",
                  hintStyle: TextStyle(
                    fontSize: Sizes.size14,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w300,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      Sizes.size3,
                    ),
                  ),
                  errorStyle: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      Sizes.size3,
                    ),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      Sizes.size3,
                    ),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      Sizes.size3,
                    ),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: Sizes.size10,
                    vertical: Sizes.size10,
                  ),
                ),
              ),
            ),
            Gaps.h10,
            Text(
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
                  Text(
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
    return Text(
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
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: Sizes.size12,
                ),
                overflow: TextOverflow.visible,
                softWrap: true,
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
];

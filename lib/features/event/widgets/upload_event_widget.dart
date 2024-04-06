import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/widgets/bottom_modal_button.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/event/models/event_model.dart';
import 'package:onldocc_admin/features/event/repo/event_repo.dart';
import 'package:onldocc_admin/features/event/widgets/upload_count_widget.dart';
import 'package:onldocc_admin/features/event/widgets/upload_point_widget.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:uuid/uuid.dart';

class UploadEventWidget extends ConsumerStatefulWidget {
  final BuildContext context;
  final double totalWidth;
  final double totalHeight;
  final Function() refreshScreen;
  const UploadEventWidget({
    super.key,
    required this.context,
    required this.totalWidth,
    required this.totalHeight,
    required this.refreshScreen,
  });

  @override
  ConsumerState<UploadEventWidget> createState() => _UploadEventWidgetState();
}

class _UploadEventWidgetState extends ConsumerState<UploadEventWidget> {
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

  PlatformFile? _eventImageFile;
  Uint8List? _eventImageBytes;

  PlatformFile? _bannerImageFile;
  Uint8List? _bannerImageBytes;

  DateTime? _eventStartDate;
  DateTime? _eventEndDate;

  int _eventPrizeWinners = 0;
  int _eventGoalScore = 0;
  String _eventType = "point";
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

  bool tapUploadEvent = false;

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
      FilePickerResult? result = await FilePickerWeb.platform.pickFiles(
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
      FilePickerResult? result = await FilePickerWeb.platform.pickFiles(
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
    setState(() {
      _enabledEventButton = _eventTitle.isNotEmpty &&
          _eventDescription.isNotEmpty &&
          _eventImageBytes != null &&
          _bannerImageBytes != null &&
          _bannerImageBytes != null &&
          _eventStartDate != null &&
          _eventEndDate != null;
    });
  }

  Future<void> _submitEvent() async {
    setState(() {
      tapUploadEvent = true;
    });

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
      allUsers: selectContractRegion.value.subdistrictId != "" ? false : true,
      targetScore: _eventGoalScore,
      achieversNumber: _eventPrizeWinners,
      startDate: convertTimettampToStringDot(_eventStartDate!),
      endDate: convertTimettampToStringDot(_eventEndDate!),
      createdAt: getCurrentSeconds(),
      contractRegionId: adminProfileModel!.contractRegionId != ""
          ? adminProfileModel.contractRegionId
          : null,
      contractCommunityId: selectContractRegion.value.contractCommunityId != ""
          ? selectContractRegion.value.contractCommunityId
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
      eventType: _eventType,
      ageLimit: _eventAgeLimit,
    );

    await ref.read(eventRepo).addEvent(eventModel);
    if (!mounted) return;
    resultBottomModal(context, "성공적으로 행사가 올라갔습니다.", widget.refreshScreen);
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

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return Container(
        width: widget.totalWidth,
        height: widget.totalHeight * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Sizes.size10),
            topRight: Radius.circular(Sizes.size10),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            top: Sizes.size40,
            left: Sizes.size40,
            right: Sizes.size40,
            bottom: Sizes.size60,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 200,
                    height: 40,
                    child: BottomModalButton(
                      text: "행사 추가하기",
                      submitFunction: _submitEvent,
                      hoverBottomButton: _enabledEventButton,
                      loading: tapUploadEvent,
                    ),
                  ),
                ],
              ),
              Gaps.v52,
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
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
                                width: widget.totalWidth * 0.1,
                                child: const Text(
                                  "행사 타이틀",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            Gaps.h32,
                            SizedBox(
                              width: widget.totalWidth * 0.6,
                              child: TextFormField(
                                maxLength: 50,
                                onChanged: (value) {
                                  setState(() {
                                    _eventTitle = value;
                                  });
                                  checkEnabledEventButton();
                                },
                                controller: _titleControllder,
                                textAlignVertical: TextAlignVertical.center,
                                style: const TextStyle(
                                  fontSize: Sizes.size14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  hintText: "",
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
                                    horizontal: Sizes.size20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gaps.v40,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: widget.totalWidth * 0.1,
                                child: const Text(
                                  "배너 이미지",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Gaps.h32,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          Sizes.size5,
                                        ),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        )),
                                    child: _bannerImageFile == null
                                        ? Icon(
                                            Icons.image,
                                            size: Sizes.size80,
                                            color: Colors.grey.shade200,
                                          )
                                        : Image.memory(
                                            _bannerImageBytes!,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  Gaps.v20,
                                  SizedBox(
                                    child: Align(
                                      alignment: Alignment.bottomLeft,
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            pickBannerImageFromGallery(
                                                setState),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey.shade200,
                                          surfaceTintColor:
                                              Colors.pink.shade200,
                                        ),
                                        child: Text(
                                          '이미지 올리기',
                                          style: TextStyle(
                                            color: Colors.grey.shade800,
                                            fontSize: Sizes.size12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                          Gaps.h60,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: widget.totalWidth * 0.1,
                                child: const Text(
                                  "행사 이미지",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Gaps.h32,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 150,
                                    height: 200,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          Sizes.size5,
                                        ),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        )),
                                    child: _eventImageFile == null
                                        ? Icon(
                                            Icons.image,
                                            size: Sizes.size80,
                                            color: Colors.grey.shade200,
                                          )
                                        : Image.memory(
                                            _eventImageBytes!,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  Gaps.v20,
                                  SizedBox(
                                    child: Align(
                                      alignment: Alignment.bottomLeft,
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            pickEventImageFromGallery(setState),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey.shade200,
                                          surfaceTintColor:
                                              Colors.pink.shade200,
                                        ),
                                        child: Text(
                                          '이미지 올리기',
                                          style: TextStyle(
                                            color: Colors.grey.shade800,
                                            fontSize: Sizes.size12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Gaps.v52,
                      IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              width: widget.totalWidth * 0.1,
                              child: const Text(
                                "행사 설명",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Gaps.h32,
                            SizedBox(
                              width: widget.totalWidth * 0.6,
                              height: 200,
                              child: TextFormField(
                                expands: true,
                                maxLines: null,
                                minLines: null,
                                onChanged: (value) {
                                  setState(() {
                                    _eventDescription = value;
                                  });
                                  checkEnabledEventButton();
                                },
                                controller: _descriptionControllder,
                                textAlignVertical: TextAlignVertical.top,
                                style: const TextStyle(
                                  fontSize: Sizes.size14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: "",
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
                                    horizontal: Sizes.size20,
                                    vertical: Sizes.size20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gaps.v52,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: widget.totalWidth * 0.1,
                                  child: const Text(
                                    "시작일",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                Gaps.h32,
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        selectStartPeriod(setState),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey.shade200,
                                      surfaceTintColor: Colors.pink.shade200,
                                    ),
                                    child: Text(
                                      '날짜 선택하기',
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: Sizes.size12,
                                      ),
                                    ),
                                  ),
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
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: widget.totalWidth * 0.1,
                                  child: const Text(
                                    "종료일",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                Gaps.h32,
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: ElevatedButton(
                                    onPressed: () => selectEndPeriod(setState),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey.shade200,
                                      surfaceTintColor: Colors.pink.shade200,
                                    ),
                                    child: Text(
                                      '날짜 선택하기',
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: Sizes.size12,
                                      ),
                                    ),
                                  ),
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
                            ),
                          ),
                        ],
                      ),
                      Gaps.v60,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: widget.totalWidth * 0.1,
                            child: const Text(
                              "당첨자 수 제한",
                              style: TextStyle(
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
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  minLines: 1,
                                  onChanged: (value) {
                                    setState(() {
                                      _eventPrizeWinners = int.parse(value);
                                    });
                                  },
                                  controller: _prizewinnersControllder,
                                  textAlignVertical: TextAlignVertical.top,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: Sizes.size14,
                                    color: Colors.black87,
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: "",
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
                                "명",
                                style: TextStyle(
                                  fontSize: Sizes.size14,
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Gaps.h40,
                              const CommentTextWidget(
                                text: "제한이 없을 경우 '0'을 기입해주세요.",
                              ),
                            ],
                          ),
                        ],
                      ),
                      Gaps.v60,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: widget.totalWidth * 0.1,
                            child: const Text(
                              "연령 제한",
                              style: TextStyle(
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
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  minLines: 1,
                                  onChanged: (value) {
                                    setState(() {
                                      _eventAgeLimit = int.parse(value);
                                    });
                                  },
                                  controller: _ageLimitControllder,
                                  textAlignVertical: TextAlignVertical.top,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: Sizes.size14,
                                    color: Colors.black87,
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: "",
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
                                "세",
                                style: TextStyle(
                                  fontSize: Sizes.size14,
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Gaps.h40,
                              const CommentTextWidget(
                                text: "제한이 없을 경우 '0'을 기입해주세요.",
                              ),
                            ],
                          ),
                        ],
                      ),
                      Gaps.v80,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 1,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          Gaps.v40,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                "🥇🥈",
                                style: TextStyle(
                                  fontSize: Sizes.size14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Gaps.h10,
                              Text(
                                "인지케어 행사 설정",
                                style: TextStyle(
                                  fontSize: Sizes.size14,
                                  fontWeight: FontWeight.w600,
                                  background: Paint()
                                    ..color =
                                        Colors.pinkAccent.withOpacity(0.2),
                                ),
                              ),
                            ],
                          ),
                          Gaps.v52,
                          Row(
                            children: [
                              Text(
                                "행사 유형 설정",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    background: Paint()
                                      ..color =
                                          Colors.yellowAccent.withOpacity(0.2)),
                                textAlign: TextAlign.start,
                              ),
                              Gaps.h80,
                              SizedBox(
                                width: 100,
                                child: CustomDropdown(
                                  onChanged: (value) {
                                    final type =
                                        value == "점수" ? "point" : "count";
                                    setState(() {
                                      _eventType = type;
                                    });
                                  },
                                  decoration: const CustomDropdownDecoration(
                                    listItemStyle: TextStyle(
                                      fontSize: Sizes.size12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  items: const ["점수", "횟수"],
                                  initialItem: "점수",
                                  // controller: contractCommunityController,
                                  excludeSelected: false,
                                ),
                              ),
                            ],
                          ),
                          Gaps.v40,
                          _eventType == "point"
                              ? UploadPointWidget(
                                  updateGoalScore: updateGoalScore,
                                  updateDiaryPoint: updateDiaryPoint,
                                  updateCommentPoint: updateCommentPoint,
                                  updateLikePoint: updateLikePoint,
                                  updateStepPoint: updateStepPoint,
                                  updateInvitationPoint: updateInvitationPoint,
                                  updateQuizPoint: updateQuizPoint,
                                )
                              : UploadCountWidget(
                                  updateDiaryCount: updateDiaryCount,
                                  updateCommentCount: updateCommentCount,
                                  updateLikeCount: updateLikeCount,
                                  updateInvitationCount: updateInvitationCount,
                                  updateQuizCount: updateQuizCount),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

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

  // 행사 추가하기
  String _eventTitle = "";
  String _eventDescription = "";

  PlatformFile? _eventImageFile;
  Uint8List? _eventImageBytes;

  DateTime? _eventStartDate;
  DateTime? _eventEndDate;

  String _eventPrizeWinners = "";
  String _eventGoalScore = "";

  int _eventStepPoint = 0;
  int _eventDiaryPoint = 100;
  int _eventCommentPoint = 0;
  int _eventLikePoint = 0;

  final List<PlatformFile> _feedImageFile = [];
  final List<Uint8List> _feedImageArray = [];

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

  Future<void> pickImageFromGallery(
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

  Future<void> pickMultipleImagesFromGallery(
      void Function(void Function()) setState) async {
    try {
      FilePickerResult? result = await FilePickerWeb.platform.pickFiles(
        type: FileType.image,
      );
      if (result == null) return;
      // _feedImageFile = result.files;
      for (PlatformFile file in _feedImageFile) {
        _feedImageArray.add(file.bytes!);
      }
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  void checkEnabledEventButton() {
    setState(() {
      _enabledEventButton = _eventTitle.isNotEmpty &&
          _eventDescription.isNotEmpty &&
          _eventImageBytes != null &&
          _eventPrizeWinners.isNotEmpty &&
          _eventGoalScore.isNotEmpty &&
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
    final evnetImageUrl = await ref
        .read(eventRepo)
        .uploadSingleImageToStorage(eventId, _eventImageBytes);

    final eventModel = EventModel(
      eventId: eventId,
      title: _eventTitle,
      description: _eventDescription,
      eventImage: evnetImageUrl,
      allUsers: selectContractRegion.value.subdistrictId != "" ? false : true,
      targetScore: int.parse(_eventGoalScore),
      achieversNumber: int.parse(_eventPrizeWinners),
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
    super.dispose();
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
                          Container(
                            width: 200,
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
                          Gaps.h52,
                          SizedBox(
                            height: 200,
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: ElevatedButton(
                                onPressed: () => pickImageFromGallery(setState),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade200,
                                  surfaceTintColor: Colors.pink.shade200,
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
                                maxLength: 200,
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
                                      _eventPrizeWinners = value;
                                    });
                                    checkEnabledEventButton();
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
                      Gaps.v32,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: widget.totalWidth * 0.1,
                            child: const Text(
                              "목표 점수 설정",
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
                                      _eventGoalScore = value;
                                    });
                                    checkEnabledEventButton();
                                  },
                                  controller: _goalScoreController,
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
                              )
                            ],
                          ),
                        ],
                      ),
                      Gaps.v40,
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      Gaps.v40,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                            "행사 점수 계산 설정",
                            style: TextStyle(
                              fontSize: Sizes.size14,
                              fontWeight: FontWeight.w600,
                              background: Paint()
                                ..color = Colors.pinkAccent.withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                      Gaps.v20,
                      const Text(
                        "- 설정을 안 하면 현재 화면에 보여지는 기본 값으로 행사의 점수 계산이 설정됩니다.",
                        style: TextStyle(
                          fontSize: Sizes.size13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Gaps.v52,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DefaultPointTile(
                            totalWidth: widget.totalWidth,
                            updateEventPoint: updateDiaryPoint,
                            header: "일기",
                            defaultPoint: 100,
                          ),
                          DefaultPointTile(
                            totalWidth: widget.totalWidth,
                            updateEventPoint: updateCommentPoint,
                            header: "댓글",
                            defaultPoint: 0,
                          ),
                          DefaultPointTile(
                            totalWidth: widget.totalWidth,
                            updateEventPoint: updateLikePoint,
                            header: "좋아요",
                            defaultPoint: 0,
                          ),
                        ],
                      ),
                      Gaps.v32,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          DefaultPointTile(
                            totalWidth: widget.totalWidth,
                            updateEventPoint: updateStepPoint,
                            header: "걸음수",
                            defaultPoint: 0,
                          ),
                          Gaps.h32,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "※ 걸음수는 신체 활동 권한 설정을 허용하지 않은 사용자들이 많아 사용을 권장하지 않습니다.",
                                style: TextStyle(
                                  fontSize: Sizes.size12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Gaps.v5,
                              const CommentTextWidget(
                                text: "- 일일 최대 만보까지 점수 계산에 포함됩니다.",
                              ),
                            ],
                          ),
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

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/widgets/bottom_modal_button.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/event/models/event_model.dart';
import 'package:onldocc_admin/features/event/repo/event_repo.dart';
import 'package:onldocc_admin/features/event/view/event_screen.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/utils.dart';

class EditCountEventWidget extends ConsumerStatefulWidget {
  final BuildContext context;
  final Size size;
  final EventModel eventModel;
  final Function() refreshScreen;
  const EditCountEventWidget({
    super.key,
    required this.context,
    required this.size,
    required this.eventModel,
    required this.refreshScreen,
  });

  @override
  ConsumerState<EditCountEventWidget> createState() =>
      _EditCountEventWidgetState();
}

class _EditCountEventWidgetState extends ConsumerState<EditCountEventWidget> {
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
  dynamic _eventImage;

  PlatformFile? _bannerImageFile;
  dynamic _bannerImage;

  DateTime? _eventStartDate;
  DateTime? _eventEndDate;

  int _eventPrizeWinners = 0;
  int _eventAgeLimit = 0;

  String _eventGoalScore = "";

  final List<String> _eventList = ["목표 점수 달성", "다득점 점수", "횟수 달성"];
  EventType _eventType = EventType.targetScore;

  int _eventDiaryCount = 0;
  int _eventCommentCount = 0;
  int _eventLikeCount = 0;
  int _eventInvitationCount = 0;
  int _eventQuizCount = 0;

  OverlayEntry? overlayEntry;
  GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();

  bool tapEditEvent = false;

  void selectStartPeriod(void Function(void Function()) setState) async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _eventStartDate,
      firstDate: DateTime(now.year),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _eventStartDate = picked;
      });
    }
  }

  void selectEndPeriod(void Function(void Function()) setState) async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _eventEndDate,
      firstDate: DateTime(now.year),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _eventEndDate = picked;
      });
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
        _eventImage = _eventImageFile!.bytes!;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: SelectableText("오류가 발생했습니다."),
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
        _bannerImage = _bannerImageFile!.bytes!;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: SelectableText("오류가 발생했습니다."),
        ),
      );
    }
  }

  Future<void> _submitEvent() async {
    setState(() {
      tapEditEvent = true;
    });

    // AdminProfileModel? adminProfileModel = ref.read(adminProfileProvider).value;
    final eventId = widget.eventModel.eventId;
    final eventImageUrl = await ref
        .read(eventRepo)
        .uploadSingleImageToStorage(eventId, _eventImage);
    final bannerImageUrl = await ref
        .read(eventRepo)
        .uploadSingleImageToStorage(eventId, _bannerImage);
    final eventModel = widget.eventModel.copyWith(
      eventId: eventId,
      title: _eventTitle,
      description: _eventDescription,
      eventImage: eventImageUrl,
      bannerImage: bannerImageUrl,
      allUsers: selectContractRegion.value!.subdistrictId != "" ? false : true,
      targetScore: int.parse(_eventGoalScore),
      achieversNumber: _eventPrizeWinners,
      startDate: convertTimettampToStringDot(_eventStartDate!),
      endDate: convertTimettampToStringDot(_eventEndDate!),
      diaryCount: _eventDiaryCount,
      commentCount: _eventCommentCount,
      likeCount: _eventLikeCount,
      invitationCount: _eventInvitationCount,
      quizCount: _eventQuizCount,
      ageLimit: _eventAgeLimit,
      eventType: _eventType.name,
    );

    await ref.read(eventRepo).editEvent(eventModel);
    if (!mounted) return;
    resultBottomModal(context, "성공적으로 행사가 수정되었습니다.", widget.refreshScreen);
  }

  Future<void> deleteEvent(String eventId) async {
    await ref.read(eventRepo).deleteEvent(eventId);
    await ref.read(eventRepo).deleteEventImageStorage(eventId);

    if (!mounted) return;
    resultBottomModal(context, "성공적으로 행사가 삭제되었습니다.", widget.refreshScreen);
  }

  @override
  void initState() {
    super.initState();

    _eventTitle = widget.eventModel.title;
    _eventDescription = widget.eventModel.description;
    _eventStartDate =
        convertStartDateStringToDateTime(widget.eventModel.startDate);
    _eventEndDate = convertEndDateStringToDateTime(widget.eventModel.endDate);
    _eventGoalScore = widget.eventModel.targetScore.toString();
    _eventPrizeWinners = widget.eventModel.achieversNumber;
    _eventAgeLimit = widget.eventModel.ageLimit ?? 0;
    _eventImage = widget.eventModel.eventImage;
    _eventInvitationCount = widget.eventModel.invitationCount!;
    _eventDiaryCount = widget.eventModel.diaryCount!;
    _eventCommentCount = widget.eventModel.commentCount!;
    _eventLikeCount = widget.eventModel.likeCount!;
    _eventQuizCount = widget.eventModel.quizCount!;
    _bannerImage = widget.eventModel.bannerImage;
    _eventType = stringToEventType(widget.eventModel.eventType);

    setState(() {});

    _titleControllder.text = widget.eventModel.title;
    _descriptionControllder.text = widget.eventModel.description;
    _goalScoreController.text = widget.eventModel.targetScore.toString();
    _prizewinnersControllder.text =
        widget.eventModel.achieversNumber.toString();
    _ageLimitControllder.text = widget.eventModel.ageLimit.toString();
  }

  @override
  void dispose() {
    removeDeleteOverlay();

    _titleControllder.dispose();
    _descriptionControllder.dispose();
    _goalScoreController.dispose();
    _prizewinnersControllder.dispose();
    _ageLimitControllder.dispose();
    super.dispose();
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
    return StatefulBuilder(builder: (context, setState) {
      return Container(
        width: widget.size.width,
        height: widget.size.height * 0.8,
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
                  BottomModalButton(
                    text: "행사 삭제하기",
                    submitFunction: () => showDeleteOverlay(context,
                        widget.eventModel.eventId, widget.eventModel.title),
                    hoverBottomButton: true,
                    loading: false,
                  ),
                  Gaps.h20,
                  BottomModalButton(
                    text: "행사 수정하기",
                    submitFunction: _submitEvent,
                    hoverBottomButton: true,
                    loading: tapEditEvent,
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
                                width: widget.size.width * 0.12,
                                child: const SelectableText(
                                  "행사 타이틀",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            Gaps.h32,
                            SizedBox(
                              width: widget.size.width * 0.6,
                              child: TextFormField(
                                maxLength: 50,
                                onChanged: (value) {
                                  setState(() {
                                    _eventTitle = value;
                                  });
                                },
                                controller: _titleControllder,
                                textAlignVertical: TextAlignVertical.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: Sizes.size14,
                                  color: Colors.black87,
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
                                width: widget.size.width * 0.12,
                                child: const SelectableText(
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
                                            )),
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
                                        child: SelectableText(
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
                                width: widget.size.width * 0.12,
                                child: const SelectableText(
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
                                        child: SelectableText(
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
                              width: widget.size.width * 0.12,
                              child: const SelectableText(
                                "행사 설명",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Gaps.h32,
                            SizedBox(
                              width: widget.size.width * 0.6,
                              height: 200,
                              child: TextFormField(
                                expands: true,
                                maxLines: null,
                                minLines: null,
                                onChanged: (value) {
                                  setState(() {
                                    _eventDescription = value;
                                  });
                                },
                                controller: _descriptionControllder,
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
                                  width: widget.size.width * 0.12,
                                  child: const SelectableText(
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
                                    child: SelectableText(
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
                                  SelectableText(
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
                                  width: widget.size.width * 0.12,
                                  child: const SelectableText(
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
                                    child: SelectableText(
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
                                  SelectableText(
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
                            width: widget.size.width * 0.12,
                            child: const SelectableText(
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
                              SelectableText(
                                "명",
                                style: TextStyle(
                                  fontSize: Sizes.size14,
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Gaps.h40,
                              SelectableText(
                                "제한이 없을 경우 '0'을 기입해주세요.",
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
                      Gaps.v60,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: widget.size.width * 0.12,
                            child: const SelectableText(
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
                              SelectableText(
                                "세 이상",
                                style: TextStyle(
                                  fontSize: Sizes.size14,
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Gaps.h40,
                              SelectableText(
                                "제한이 없을 경우 '0'을 기입해주세요.",
                                style: headerInfoTextStyle,
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
                              const SelectableText(
                                "🥇🥈",
                                style: TextStyle(
                                  fontSize: Sizes.size14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Gaps.h10,
                              SelectableText(
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
                              SizedBox(
                                width: widget.size.width * 0.12,
                                child: SelectableText(
                                  "행사 유형 설정",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      background: Paint()
                                        ..color = Colors.yellowAccent
                                            .withOpacity(0.2)),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Gaps.h80,
                              Gaps.h80,
                              SizedBox(
                                width: 300,
                                child: CustomDropdown(
                                  onChanged: (value) {
                                    final type = value == "목표 점수 달성"
                                        ? EventType.targetScore
                                        : value == "다득점 점수"
                                            ? EventType.multipleScores
                                            : EventType.count;
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
                                  items: _eventList,
                                  initialItem: _eventList[
                                      EventType.values.indexOf(_eventType)],
                                  // controller: contractCommunityController,
                                  excludeSelected: false,
                                ),
                              ),
                            ],
                          ),
                          Gaps.v80,
                          const Column(
                            children: [
                              // Row(
                              //   mainAxisAlignment:
                              //       MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     Expanded(
                              //       flex: 2,
                              //       child: DefaultCountTile(
                              //         totalWidth: size.width,
                              //         updateEventPoint: updateDiaryCount,
                              //         header: "일기",
                              //         defaultPoint: _eventDiaryCount,
                              //         editOrNot: true,
                              //       ),
                              //     ),
                              //     const Expanded(
                              //       flex: 3,
                              //       child: Column(
                              //         crossAxisAlignment:
                              //             CrossAxisAlignment.start,
                              //         children: [
                              //           MaxPointTextWidget(
                              //             text: "( 일일 최대:     1회 )",
                              //           ),
                              //         ],
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              // Gaps.v32,
                              // Row(
                              //   children: [
                              //     Expanded(
                              //       flex: 2,
                              //       child: DefaultPointTile(
                              //         totalWidth: size.width,
                              //         updateEventPoint: updateQuizCount,
                              //         header: "문제 풀기",
                              //         defaultPoint: _eventQuizCount,
                              //         editOrNot: true,
                              //       ),
                              //     ),
                              //     const Expanded(
                              //       flex: 3,
                              //       child: Column(
                              //         crossAxisAlignment:
                              //             CrossAxisAlignment.start,
                              //         children: [
                              //           MaxPointTextWidget(
                              //             text: "( 일일 최대:     1회 )",
                              //           ),
                              //         ],
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              // Gaps.v32,
                              // Row(
                              //   children: [
                              //     Expanded(
                              //       flex: 1,
                              //       child: DefaultCountTile(
                              //         totalWidth: size.width,
                              //         updateEventPoint: updateCommentCount,
                              //         header: "댓글",
                              //         defaultPoint: _eventCommentCount,
                              //         editOrNot: true,
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              // Gaps.v32,
                              // Row(
                              //   children: [
                              //     Expanded(
                              //       flex: 1,
                              //       child: DefaultCountTile(
                              //         totalWidth: size.width,
                              //         updateEventPoint: updateLikeCount,
                              //         header: "좋아요",
                              //         defaultPoint: _eventLikeCount,
                              //         editOrNot: true,
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              // Gaps.v32,
                              // Row(
                              //   children: [
                              //     Expanded(
                              //       flex: 2,
                              //       child: DefaultCountTile(
                              //         totalWidth: size.width,
                              //         updateEventPoint: updateInvitationCount,
                              //         header: "친구 초대",
                              //         defaultPoint: _eventInvitationCount,
                              //         editOrNot: true,
                              //       ),
                              //     ),
                              //   ],
                              // ),
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

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
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/utils.dart';

class EditPointEventWidget extends ConsumerStatefulWidget {
  final BuildContext context;
  final double totalWidth;
  final double totalHeight;
  final EventModel eventModel;
  final Function() refreshScreen;
  const EditPointEventWidget({
    super.key,
    required this.context,
    required this.totalWidth,
    required this.totalHeight,
    required this.eventModel,
    required this.refreshScreen,
  });

  @override
  ConsumerState<EditPointEventWidget> createState() =>
      _EditPointEventWidgetState();
}

class _EditPointEventWidgetState extends ConsumerState<EditPointEventWidget> {
  final TextEditingController _titleControllder = TextEditingController();
  final TextEditingController _descriptionControllder = TextEditingController();
  final TextEditingController _goalScoreController = TextEditingController();
  final TextEditingController _prizewinnersControllder =
      TextEditingController();

  // 행사 추가하기
  String _eventTitle = "";
  String _eventDescription = "";

  PlatformFile? _eventImageFile;
  dynamic _eventImage;

  PlatformFile? _bannerImageFile;
  dynamic _bannerImage;

  DateTime? _eventStartDate;
  DateTime? _eventEndDate;

  String _eventPrizeWinners = "";
  String _eventGoalScore = "";

  int _eventStepPoint = 0;
  int _eventDiaryPoint = 0;
  int _eventCommentPoint = 0;
  int _eventLikePoint = 0;
  int _eventInvitationPoint = 0;

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
      FilePickerResult? result = await FilePickerWeb.platform.pickFiles(
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
        _bannerImage = _bannerImageFile!.bytes!;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("오류가 발생했습니다."),
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
      allUsers: selectContractRegion.value.subdistrictId != "" ? false : true,
      targetScore: int.parse(_eventGoalScore),
      achieversNumber: int.parse(_eventPrizeWinners),
      startDate: convertTimettampToStringDot(_eventStartDate!),
      endDate: convertTimettampToStringDot(_eventEndDate!),
      stepPoint: _eventStepPoint,
      diaryPoint: _eventDiaryPoint,
      commentPoint: _eventCommentPoint,
      likePoint: _eventLikePoint,
      invitationPoint: _eventInvitationPoint,
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
    _eventPrizeWinners = widget.eventModel.achieversNumber.toString();
    _eventImage = widget.eventModel.eventImage;
    _eventStepPoint = widget.eventModel.stepPoint!;
    _eventDiaryPoint = widget.eventModel.diaryPoint!;
    _eventCommentPoint = widget.eventModel.commentPoint!;
    _eventLikePoint = widget.eventModel.likePoint!;
    _bannerImage = widget.eventModel.bannerImage;

    setState(() {});

    _titleControllder.text = widget.eventModel.title;
    _descriptionControllder.text = widget.eventModel.description;
    _goalScoreController.text = widget.eventModel.targetScore.toString();
    _prizewinnersControllder.text =
        widget.eventModel.achieversNumber.toString();
  }

  @override
  void dispose() {
    removeDeleteOverlay();

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

  void updateInvitationPoint(int point) {
    setState(() {
      _eventInvitationPoint = point;
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
              title: Text(
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
                  Text(
                    "정말로 삭제하시겠습니까?",
                    style: TextStyle(
                      fontSize: Sizes.size13,
                    ),
                  ),
                  Text(
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
                        MaterialStateProperty.all(Colors.pink.shade100),
                  ),
                  child: Text(
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
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).primaryColor),
                  ),
                  child: const Text(
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
        width: widget.totalWidth,
        height: widget.totalHeight * 0.8,
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
                                maxLength: 200,
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
                                  text: "제한이 없을 경우 '0'을 기입해주세요.")
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
                            ],
                          ),
                          Gaps.v80,
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: size.width * 0.1,
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
                                        width: 150,
                                        child: TextFormField(
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          minLines: 1,
                                          onChanged: (value) {
                                            setState(() {
                                              _eventGoalScore = value;
                                            });
                                          },
                                          controller: _goalScoreController,
                                          textAlignVertical:
                                              TextAlignVertical.top,
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
                                              borderRadius:
                                                  BorderRadius.circular(
                                                Sizes.size3,
                                              ),
                                            ),
                                            errorStyle: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                Sizes.size3,
                                              ),
                                              borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                Sizes.size3,
                                              ),
                                              borderSide: BorderSide(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                Sizes.size3,
                                              ),
                                              borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
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
                              Gaps.v52,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  DefaultPointTile(
                                    totalWidth: size.width,
                                    updateEventPoint: updateDiaryPoint,
                                    header: "일기",
                                    defaultPoint: _eventDiaryPoint,
                                    editOrNot: true,
                                  ),
                                  DefaultPointTile(
                                    totalWidth: size.width,
                                    updateEventPoint: updateCommentPoint,
                                    header: "댓글",
                                    defaultPoint: _eventCommentPoint,
                                    editOrNot: true,
                                  ),
                                  DefaultPointTile(
                                    totalWidth: size.width,
                                    updateEventPoint: updateLikePoint,
                                    header: "좋아요",
                                    defaultPoint: _eventLikePoint,
                                    editOrNot: true,
                                  ),
                                ],
                              ),
                              Gaps.v32,
                              DefaultPointTile(
                                totalWidth: size.width,
                                updateEventPoint: updateInvitationPoint,
                                header: "친구 초대",
                                defaultPoint: _eventInvitationPoint,
                                editOrNot: true,
                              ),
                              Gaps.v32,
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  DefaultPointTile(
                                    totalWidth: size.width,
                                    updateEventPoint: updateStepPoint,
                                    header: "걸음수",
                                    defaultPoint: _eventStepPoint,
                                    editOrNot: true,
                                  ),
                                  Gaps.h32,
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                          )
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

class DefaultCountTile extends StatefulWidget {
  final double totalWidth;
  final Function(int) updateEventPoint;
  final String header;
  final int defaultPoint;
  final bool editOrNot;

  const DefaultCountTile({
    super.key,
    required this.totalWidth,
    required this.updateEventPoint,
    required this.header,
    required this.defaultPoint,
    required this.editOrNot,
  });

  @override
  State<DefaultCountTile> createState() => _DefaultCountTileState();
}

class _DefaultCountTileState extends State<DefaultCountTile> {
  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.editOrNot) {
      textController.text = "${widget.defaultPoint}";
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: widget.totalWidth * 0.1,
          child: Text(
            "❍   ${widget.header}",
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
                controller: textController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                minLines: 1,
                onChanged: (value) {
                  final point = int.parse(value);
                  widget.updateEventPoint(point);
                },
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(
                  fontSize: Sizes.size14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  hintText: "${widget.defaultPoint}",
                  hintStyle: TextStyle(
                    fontSize: Sizes.size14,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w300,
                  ),
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
              "회",
              style: TextStyle(
                fontSize: Sizes.size14,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DefaultPointTile extends StatefulWidget {
  final double totalWidth;
  final Function(int) updateEventPoint;
  final String header;
  final int defaultPoint;
  final bool editOrNot;
  const DefaultPointTile({
    super.key,
    required this.totalWidth,
    required this.updateEventPoint,
    required this.header,
    required this.defaultPoint,
    required this.editOrNot,
  });

  @override
  State<DefaultPointTile> createState() => _DefaultPointTileState();
}

class _DefaultPointTileState extends State<DefaultPointTile> {
  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.editOrNot) {
      textController.text = "${widget.defaultPoint}";
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: widget.totalWidth * 0.1,
          child: Text(
            "❍   ${widget.header}",
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
                controller: textController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                minLines: 1,
                onChanged: (value) {
                  final point = int.parse(value);
                  widget.updateEventPoint(point);
                },
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(
                  fontSize: Sizes.size14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  hintText: "${widget.defaultPoint}",
                  hintStyle: TextStyle(
                    fontSize: Sizes.size14,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w300,
                  ),
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
            widget.header == "걸음수"
                ? Row(
                    children: [
                      Gaps.h10,
                      Text(
                        "/ 1,000보 당",
                        style: TextStyle(
                          fontSize: Sizes.size13,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Gaps.h10,
                      Text(
                        "/ 1회",
                        style: TextStyle(
                          fontSize: Sizes.size13,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade400,
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

import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/view_a/modal_screen.dart';
import 'package:onldocc_admin/common/widgets/modal_button.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/notice/repo/notice_repo.dart';
import 'package:onldocc_admin/features/notice/view_models/notice_view_model.dart';
import 'package:onldocc_admin/features/ranking/models/diary_model.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';

class EditNotificationWidget extends ConsumerStatefulWidget {
  final BuildContext context;
  final Size size;
  final DiaryModel diaryModel;
  final Function() refreshScreen;
  const EditNotificationWidget({
    super.key,
    required this.context,
    required this.size,
    required this.diaryModel,
    required this.refreshScreen,
  });

  @override
  ConsumerState<EditNotificationWidget> createState() =>
      _EditNotificationWidgetState();
}

class _EditNotificationWidgetState
    extends ConsumerState<EditNotificationWidget> {
  final TextStyle _headerTextStyle = TextStyle(
    fontSize: Sizes.size12,
    fontWeight: FontWeight.w600,
    color: Palette().darkGray,
  );

  final TextStyle _contentTextStyle = TextStyle(
    fontSize: Sizes.size14,
    fontWeight: FontWeight.w500,
    color: Palette().darkGray,
  );

  String _feedDescription = "";
  bool _noticeTopFixed = false;
  DateTime _noticeFixedAt = DateTime.now();

  final List<dynamic> _feedImageArray = [];

  final TextEditingController _descriptionControllder = TextEditingController();

  OverlayEntry? overlayEntry;
  GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();

  bool tapEditNotification = false;

  Future<void> pickMultipleImagesFromGallery(
      void Function(void Function()) setState) async {
    try {
      FilePickerResult? result = await FilePickerWeb.platform.pickFiles(
        type: FileType.image,
      );
      if (result == null) return;
      final feedImageFile = result.files;
      for (PlatformFile file in feedImageFile) {
        _feedImageArray.add(file.bytes);
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

  Future<void> _deleteFeedNotification() async {
    try {
      await ref
          .read(noticeRepo)
          .deleteFeedNotification(widget.diaryModel.diaryId);
      if (!mounted) return;
      resultBottomModal(context, "성공적으로 공지가 삭제되었습니다.", widget.refreshScreen);
    } catch (e) {
      // ignore: avoid_print
      print("_deleteFeedNotification -> $e");
    }
  }

  Future<void> _editFeedNotification() async {
    try {
      setState(() {
        tapEditNotification = true;
      });
      await ref.read(noticeProvider.notifier).editFeedNotification(
            widget.diaryModel.diaryId,
            _feedDescription,
            _feedImageArray,
            _noticeTopFixed,
            convertEndDateTimeToSeconds(_noticeFixedAt),
          );
      if (!mounted) return;
      resultBottomModal(context, "성공적으로 공지가 수정되었습니다.", widget.refreshScreen);
    } catch (e) {
      // ignore: avoid_print
      print("_editFeedNotification -> $e");
    }
  }

  void showDeleteOverlay(BuildContext context, String notiDesc) async {
    removeDeleteOverlay();

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.black54,
          child: Center(
            child: AlertDialog(
              title: Text(
                notiDesc.length > 10
                    ? "${notiDesc.substring(0, 11)}.."
                    : notiDesc,
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
                  onPressed: () => _deleteFeedNotification(),
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

  void removeDeleteOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  @override
  void initState() {
    super.initState();
    _descriptionControllder.text = widget.diaryModel.todayDiary;
    _noticeTopFixed = widget.diaryModel.noticeTopFixed ?? false;
    _noticeFixedAt = widget.diaryModel.noticeFixedAt != null
        ? secondsToDatetime(widget.diaryModel.noticeFixedAt!)
        : DateTime.now();

    _descriptionControllder.addListener(() {
      setState(() {
        _feedDescription = _descriptionControllder.text;
      });
    });

    setState(() {
      _feedDescription = widget.diaryModel.todayDiary;
      _feedImageArray.addAll(widget.diaryModel.images!);
    });
  }

  @override
  void dispose() {
    _descriptionControllder.dispose();
    removeDeleteOverlay();
    super.dispose();
  }

  void selectNoticeFixedAt(void Function(void Function()) setState) async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year, now.month, 1),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _noticeFixedAt = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return ModalScreen(
          size: widget.size,
          modalTitle: "공지 수정하기",
          modalButtonOneText: "삭제하기",
          modalButtonOneFunction: () {},
          modalButtonTwoText: "수정하기",
          modalButtonTwoFunction: () {},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Gaps.v20,
              Row(
                children: [
                  SizedBox(
                    width: widget.size.width * 0.12,
                    height: 50,
                    child: Text(
                      "📌\n지역 보기\n상단 고정",
                      style: _headerTextStyle,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Gaps.h32,
                  Transform.scale(
                    scale: 1.3,
                    child: Checkbox(
                      value: _noticeTopFixed,
                      activeColor: Palette().darkGreen,
                      overlayColor: MaterialStateProperty.all(
                          Palette().normalGreen.withOpacity(0.1)),
                      onChanged: (value) {
                        setState(
                          () {
                            _noticeTopFixed = !_noticeTopFixed;
                          },
                        );
                      },
                    ),
                  ),
                  Gaps.h52,
                  if (_noticeTopFixed)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ModalButton(
                          modalText: "고정 기한 선택하기",
                          modalAction: () => selectNoticeFixedAt(setState),
                        ),
                        Gaps.h20,
                        Column(
                          children: [
                            Text(
                              "${_noticeFixedAt.year}.${_noticeFixedAt.month.toString().padLeft(2, '0')}.${_noticeFixedAt.day.toString().padLeft(2, '0')}",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Palette().normalGray,
                                fontSize: Sizes.size13,
                              ),
                            ),
                            Gaps.v2,
                          ],
                        ),
                      ],
                    )
                ],
              ),
              Gaps.v52,
              Row(
                children: [
                  SizedBox(
                    width: widget.size.width * 0.12,
                    height: 200,
                    child: Text(
                      "공지 내용",
                      style: _headerTextStyle,
                      textAlign: TextAlign.start,
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
                        style: _contentTextStyle,
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Palette().lightGreen.withOpacity(0.1),
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
                              color: Palette().normalGreen.withOpacity(0.7),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              Sizes.size20,
                            ),
                            borderSide: BorderSide(
                              width: 1.5,
                              color: Palette().darkGreen.withOpacity(0.7),
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
              Gaps.v52,
              SizedBox(
                height: 200,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: widget.size.width * 0.12,
                      child: Text(
                        "이미지\n(선택)",
                        style: _headerTextStyle,
                        textAlign: TextAlign.start,
                      ),
                    ),
                    Gaps.h32,
                    ModalButton(
                      modalText: "이미지 올리기",
                      modalAction: () =>
                          pickMultipleImagesFromGallery(setState),
                    ),
                    Gaps.h32,
                    Expanded(
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _feedImageArray.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              SizedBox(
                                width: 200,
                                height: 200,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    Sizes.size5,
                                  ),
                                  child: Image.memory(
                                    _feedImageArray[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _feedImageArray.removeAt(index);
                                      });
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: Colors.grey.shade100,
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Gaps.h10;
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

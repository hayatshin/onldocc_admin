import 'dart:typed_data';

import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/widgets/bottom_modal_button.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/notice/repo/notice_repo.dart';
import 'package:onldocc_admin/features/notice/view_models/notice_view_model.dart';
import 'package:onldocc_admin/features/ranking/models/diary_model.dart';
import 'package:onldocc_admin/utils.dart';

class EditNotificationWidget extends ConsumerStatefulWidget {
  final BuildContext context;
  final double totalWidth;
  final double totalHeight;
  final DiaryModel diaryModel;
  final Function() refreshScreen;
  const EditNotificationWidget({
    super.key,
    required this.context,
    required this.totalWidth,
    required this.totalHeight,
    required this.diaryModel,
    required this.refreshScreen,
  });

  @override
  ConsumerState<EditNotificationWidget> createState() =>
      _EditNotificationWidgetState();
}

class _EditNotificationWidgetState
    extends ConsumerState<EditNotificationWidget> {
  String _feedDescription = "";

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
          widget.diaryModel.diaryId, _feedDescription, _feedImageArray);
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

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          height: widget.totalHeight * 0.8,
          width: widget.totalWidth,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Sizes.size10),
              topRight: Radius.circular(Sizes.size10),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(
              Sizes.size40,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    BottomModalButton(
                      text: "공지 삭제하기",
                      submitFunction: () => showDeleteOverlay(
                          context, widget.diaryModel.todayDiary),
                      hoverBottomButton: true,
                      loading: false,
                    ),
                    Gaps.h20,
                    BottomModalButton(
                      text: "공지 수정하기",
                      submitFunction: _editFeedNotification,
                      hoverBottomButton: true,
                      loading: tapEditNotification,
                    ),
                  ],
                ),
                Gaps.v52,
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: widget.totalWidth * 0.1,
                              height: 200,
                              child: const Text(
                                "공지 내용",
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
                        Gaps.v52,
                        SizedBox(
                          height: 200,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: widget.totalWidth * 0.1,
                                child: const Text(
                                  "이미지 (선택)",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Gaps.h32,
                              SizedBox(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      pickMultipleImagesFromGallery(setState),
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
                                            child: _feedImageArray[index]
                                                    is Uint8List
                                                ? Image.memory(
                                                    _feedImageArray[index],
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.network(
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
                                                  _feedImageArray
                                                      .removeAt(index);
                                                });
                                              },
                                              child: CircleAvatar(
                                                backgroundColor:
                                                    Colors.grey.shade100,
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
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

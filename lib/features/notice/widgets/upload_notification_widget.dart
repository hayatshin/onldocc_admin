import 'dart:typed_data';

import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/widgets/bottom_modal_button.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/notice/view_models/notice_view_model.dart';
import 'package:onldocc_admin/utils.dart';

class UploadNotificationWidget extends ConsumerStatefulWidget {
  final BuildContext context;
  final double totalWidth;
  final double totalHeight;
  final Function() refreshScreen;
  const UploadNotificationWidget({
    super.key,
    required this.context,
    required this.totalWidth,
    required this.totalHeight,
    required this.refreshScreen,
  });

  @override
  ConsumerState<UploadNotificationWidget> createState() =>
      _UploadFeedWidgetState();
}

class _UploadFeedWidgetState extends ConsumerState<UploadNotificationWidget> {
  String _feedDescription = "";
  bool _noticeTopFixed = false;
  DateTime _noticeFixedAt = DateTime.now();

  List<PlatformFile> _feedImageFile = [];
  final List<Uint8List> _feedImageArray = [];

  final TextEditingController _descriptionControllder = TextEditingController();
  bool uploadHoverBottmoButton = false;
  bool tapUploadNotification = false;

  Future<void> pickMultipleImagesFromGallery(
      void Function(void Function()) setState) async {
    try {
      FilePickerResult? result = await FilePickerWeb.platform.pickFiles(
        type: FileType.image,
      );
      if (result == null) return;
      _feedImageFile = result.files;
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

  Future<void> _submitFeedNotification() async {
    setState(() {
      tapUploadNotification = true;
    });

    AdminProfileModel? adminProfileModel = ref.read(adminProfileProvider).value;

    await ref.read(noticeProvider.notifier).addFeedNotification(
          adminProfileModel!,
          _feedDescription,
          _feedImageArray,
          _noticeTopFixed,
          convertEndDateTimeToSeconds(_noticeFixedAt),
        );
    if (!mounted) return;

    resultBottomModal(context, "성공적으로 공지가 올라갔습니다.", widget.refreshScreen);
  }

  @override
  void initState() {
    super.initState();

    _descriptionControllder.addListener(() {
      setState(() {
        uploadHoverBottmoButton = _descriptionControllder.text.isNotEmpty;
        _feedDescription = _descriptionControllder.text;
      });
    });
  }

  @override
  void dispose() {
    _descriptionControllder.dispose();
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
                      text: "피드 공지 올리기",
                      submitFunction: _submitFeedNotification,
                      hoverBottomButton: uploadHoverBottmoButton,
                      loading: tapUploadNotification,
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
                              width: widget.totalWidth * 0.12,
                              height: 50,
                              child: const Text(
                                "지역 보기\n상단 고정 여부",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Gaps.h32,
                            Checkbox(
                              value: _noticeTopFixed,
                              onChanged: (value) {
                                setState(
                                  () {
                                    _noticeTopFixed = !_noticeTopFixed;
                                  },
                                );
                              },
                            ),
                            Gaps.h52,
                            if (_noticeTopFixed)
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () =>
                                        selectNoticeFixedAt(setState),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey.shade200,
                                      surfaceTintColor: Colors.pink.shade200,
                                    ),
                                    child: Text(
                                      '고정 날짜 기한 선택하기',
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: Sizes.size12,
                                      ),
                                    ),
                                  ),
                                  Gaps.h20,
                                  Text(
                                    "${_noticeFixedAt.year}.${_noticeFixedAt.month.toString().padLeft(2, '0')}.${_noticeFixedAt.day.toString().padLeft(2, '0')}",
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
                          children: [
                            SizedBox(
                              width: widget.totalWidth * 0.12,
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
                                width: widget.totalWidth * 0.12,
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

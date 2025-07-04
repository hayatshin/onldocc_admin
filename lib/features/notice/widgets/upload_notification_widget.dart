import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:onldocc_admin/common/view_a/modal_screen.dart';
import 'package:onldocc_admin/common/widgets/modal_button.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/event/view/event_screen.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/notice/models/popup_model.dart';
import 'package:onldocc_admin/features/notice/repo/notice_repo.dart';
import 'package:onldocc_admin/features/notice/view_models/notice_view_model.dart';
import 'package:onldocc_admin/features/ranking/models/diary_model.dart';
import 'package:onldocc_admin/injicare_color.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';

class UploadNotificationWidget extends ConsumerStatefulWidget {
  final BuildContext pcontext;
  final Function() refreshScreen;
  final bool edit;
  final DiaryModel? notificationModel;
  const UploadNotificationWidget({
    super.key,
    required this.pcontext,
    required this.refreshScreen,
    required this.edit,
    this.notificationModel,
  });

  @override
  ConsumerState<UploadNotificationWidget> createState() =>
      _UploadFeedWidgetState();
}

class _UploadFeedWidgetState extends ConsumerState<UploadNotificationWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _feedDescription = "";
  bool _noticeTopFixed = false;
  DateTime _noticeFixedAt = DateTime.now();
  bool _noticePopup = false;
  DateTime _noticePopupFixedAt = DateTime.now();

  bool _noticeTopFixedInfo = false;
  bool _noticePopupInfo = false;

  List<PlatformFile> _feedImageFile = [];
  final List<dynamic> _feedImageArray = [];

  final TextEditingController _descriptionControllder = TextEditingController();
  bool uploadHoverBottmoButton = false;
  bool tapUploadNotification = false;

  OverlayEntry? overlayEntry;
  GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();

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

  @override
  void initState() {
    super.initState();

    if (widget.edit && widget.notificationModel != null) {
      // 수정할 경우
      _descriptionControllder.text = widget.notificationModel!.todayDiary;
      _noticeTopFixed = widget.notificationModel!.noticeTopFixed ?? false;
      _noticeFixedAt = widget.notificationModel!.noticeFixedAt != null
          ? secondsToDatetime(widget.notificationModel!.noticeFixedAt!)
          : DateTime.now();

      setState(() {
        _feedDescription = widget.notificationModel!.todayDiary;
        _feedImageArray.addAll(widget.notificationModel!.images!);
      });

      // 팝업 체크
      _checkPopup(widget.notificationModel!);
    }

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
    _removeDeleteOverlay();
    super.dispose();
  }

  void _checkPopup(DiaryModel diaryModel) async {
    final popup = await ref.read(noticeRepo).checkPopup(diaryModel.diaryId);
    if (popup != null) {
      setState(() {
        _noticePopup = true;
        _noticeFixedAt = secondsToDatetime(popup.noticeFixedAt);
      });
    }
  }

  Future<void> pickMultipleImagesFromGallery(
      void Function(void Function()) setState) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
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
          content: SelectableText(e.toString()),
        ),
      );
    }
  }

  Future<void> _submitFeedNotification() async {
    setState(() {
      tapUploadNotification = true;
    });

    if (_formKey.currentState != null) {
      if (_formKey.currentState!.validate()) {
        AdminProfileModel? adminProfileModel =
            ref.read(adminProfileProvider).value ??
                await ref.read(adminProfileProvider.notifier).getAdminProfile();

        final diaryId =
            await ref.read(noticeProvider.notifier).addFeedNotification(
                  adminProfileModel,
                  _feedDescription,
                  _feedImageArray,
                  _noticeTopFixed,
                  convertEndDateTimeToSeconds(_noticeFixedAt),
                );

        // 팝업 공지
        if (_noticePopup) {
          String popupId = "";
          if (adminProfileModel.master) {
            final popupModel = PopupModel(
              subdistrictId: null,
              noticeFixedAt: convertEndDateTimeToSeconds(_noticePopupFixedAt),
              description: _feedDescription,
              createdAt: getCurrentSeconds(),
              diaryId: diaryId,
              adminSecret: true,
              master: true,
            );
            popupId =
                await ref.read(noticeRepo).addPopupNotification(popupModel);
          } else {
            final popupModel = PopupModel(
              subdistrictId: adminProfileModel.subdistrictId,
              noticeFixedAt: convertEndDateTimeToSeconds(_noticePopupFixedAt),
              description: _feedDescription,
              createdAt: getCurrentSeconds(),
              diaryId: diaryId,
              adminSecret: true,
              master: false,
            );
            popupId =
                await ref.read(noticeRepo).addPopupNotification(popupModel);
          }

          // 팝업 이미지
          if (_feedImageArray.isNotEmpty) {
            await ref
                .read(noticeRepo)
                .uploadPopupImagesToStorage(popupId, _feedImageArray);
          }
        }

        if (!mounted) return;
        resultBottomModal(context, "성공적으로 공지가 올라갔습니다.", widget.refreshScreen);
      }
    }
  }

  void selectNoticeFixedAt() async {
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

  void selectPopupFixedAt() async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year, now.month, 1),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _noticePopupFixedAt = picked;
      });
    }
  }

  Future<void> _deleteFeedNotification() async {
    try {
      await ref
          .read(noticeRepo)
          .deleteFeedNotification(widget.notificationModel!.diaryId);
      if (!mounted) return;
      resultBottomModal(context, "성공적으로 공지가 삭제되었습니다", widget.refreshScreen);
    } catch (e) {
      // ignore: avoid_print
      print("_deleteFeedNotification -> $e");
    }
  }

  Future<void> _editFeedNotification() async {
    try {
      await ref.read(noticeProvider.notifier).editFeedNotification(
            widget.notificationModel!.diaryId,
            _feedDescription,
            _feedImageArray,
            _noticeTopFixed,
            convertEndDateTimeToSeconds(_noticeFixedAt),
          );
      if (!mounted) return;
      resultBottomModal(context, "성공적으로 공지가 수정되었습니다", widget.refreshScreen);
    } catch (e) {
      // ignore: avoid_print
      print("_editFeedNotification -> $e");
    }
  }

  // 행사 삭제
  void _removeDeleteOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  void showDeleteOverlay(String description) async {
    _removeDeleteOverlay();
    overlayEntry = OverlayEntry(builder: (context) {
      return deleteTitleOverlay(
          description, _removeDeleteOverlay, _deleteFeedNotification);
    });

    Overlay.of(widget.pcontext, debugRequiredFor: widget).insert(overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return StatefulBuilder(
      builder: (context, setState) {
        return ModalScreen(
          size: size,
          widthPercentage: 0.5,
          modalTitle: !widget.edit ? "공지 올리기" : "공지 수정하기",
          modalButtonOneText: !widget.edit ? "확인" : "삭제하기",
          modalButtonOneFunction: !widget.edit
              ? _submitFeedNotification
              : () => showDeleteOverlay(
                    widget.notificationModel!.todayDiary,
                  ),
          modalButtonTwoText: !widget.edit ? null : "수정하기",
          modalButtonTwoFunction: _editFeedNotification,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: size.width * 0.12,
                          height: 50,
                          child: SelectableText(
                            "지역 보기\n상단 고정하기",
                            style: _headerTextStyle,
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Gaps.h32,
                        Transform.scale(
                          scale: 1.3,
                          child: Checkbox(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: BorderSide(
                                width: 0.5,
                                color: Palette().darkGray,
                              ),
                            ),
                            value: _noticeTopFixed,
                            activeColor: Palette().darkBlue,
                            overlayColor: WidgetStateProperty.all(
                                Palette().darkBlue.withOpacity(0.1)),
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
                                modalAction: selectNoticeFixedAt,
                              ),
                              Gaps.h20,
                              Column(
                                children: [
                                  SelectableText(
                                    "${_noticeFixedAt.year}.${_noticeFixedAt.month.toString().padLeft(2, '0')}.${_noticeFixedAt.day.toString().padLeft(2, '0')}",
                                    style: _contentTextStyle,
                                  ),
                                  Gaps.v2,
                                ],
                              ),
                            ],
                          )
                      ],
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          setState(
                            () {
                              _noticeTopFixedInfo = !_noticeTopFixedInfo;
                            },
                          );
                        },
                        child: Row(
                          children: [
                            ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                InjicareColor().gray50,
                                BlendMode.srcIn,
                              ),
                              child: SvgPicture.asset(
                                "assets/svg/info.svg",
                                width: 15,
                              ),
                            ),
                            Gaps.h5,
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: 0.5,
                                    color: Palette().normalGray,
                                  ),
                                ),
                              ),
                              child: Text(
                                "지역보기 상단 고정하기가 무엇인가요?",
                                style: headerInfoTextStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (_noticeTopFixedInfo)
                  Column(
                    children: [
                      Gaps.v20,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: size.width * 0.12,
                          ),
                          Gaps.h32,
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.asset(
                              "assets/notice/notice.png",
                              width: 100,
                            ),
                          ),
                          Gaps.h16,
                          Text(
                            "지역 내 사용자의 [보기] 메뉴에서 [지역 보기] 탭을 누르면 공지글이 고정 기한동안 최상단에 고정됩니다",
                            style: headerInfoTextStyle,
                          )
                        ],
                      ),
                    ],
                  ),
                Gaps.v20,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: size.width * 0.12,
                          height: 50,
                          child: SelectableText(
                            "팝업 공지\n올리기",
                            style: _headerTextStyle,
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Gaps.h32,
                        Transform.scale(
                          scale: 1.3,
                          child: Checkbox(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: BorderSide(
                                width: 0.5,
                                color: Palette().darkGray,
                              ),
                            ),
                            value: _noticePopup,
                            activeColor: Palette().darkBlue,
                            overlayColor: WidgetStateProperty.all(
                                Palette().darkBlue.withOpacity(0.1)),
                            onChanged: (value) {
                              setState(
                                () {
                                  _noticePopup = !_noticePopup;
                                },
                              );
                            },
                          ),
                        ),
                        Gaps.h52,
                        if (_noticePopup)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ModalButton(
                                modalText: "팝업 기한 선택하기",
                                modalAction: selectPopupFixedAt,
                              ),
                              Gaps.h20,
                              Column(
                                children: [
                                  SelectableText(
                                    "${_noticePopupFixedAt.year}.${_noticePopupFixedAt.month.toString().padLeft(2, '0')}.${_noticePopupFixedAt.day.toString().padLeft(2, '0')}",
                                    style: _contentTextStyle,
                                  ),
                                  Gaps.v2,
                                ],
                              ),
                            ],
                          )
                      ],
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _noticePopupInfo = !_noticePopupInfo;
                          });
                        },
                        child: Row(
                          children: [
                            ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                InjicareColor().gray50,
                                BlendMode.srcIn,
                              ),
                              child: SvgPicture.asset(
                                "assets/svg/info.svg",
                                width: 15,
                              ),
                            ),
                            Gaps.h5,
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: 0.5,
                                    color: Palette().normalGray,
                                  ),
                                ),
                              ),
                              child: Text(
                                "팝업 공지 올리기가 무엇인가요?",
                                style: headerInfoTextStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (_noticePopupInfo)
                  Column(
                    children: [
                      Gaps.v20,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: size.width * 0.12,
                          ),
                          Gaps.h32,
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.asset(
                              "assets/notice/popup1.png",
                              width: 100,
                            ),
                          ),
                          Gaps.h5,
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.asset(
                              "assets/notice/popup2.png",
                              width: 100,
                            ),
                          ),
                          Gaps.h16,
                          SelectableText(
                            "지역 내 사용자가 앱의 처음 진입할 때 팝업 기한동안 공지글을 팝업창으로 볼 수 있습니다",
                            style: headerInfoTextStyle,
                          )
                        ],
                      ),
                    ],
                  ),
                Gaps.v52,
                Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      SizedBox(
                        width: size.width * 0.12,
                        height: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText(
                              "공지 내용",
                              style: _headerTextStyle,
                              textAlign: TextAlign.start,
                            ),
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
                            validator: (value) {
                              if (value != null && value.isEmpty) {
                                return "공지 내용을 입력해주세요";
                              }
                              return null;
                            },
                            controller: _descriptionControllder,
                            textAlignVertical: TextAlignVertical.top,
                            style: _contentTextStyle,
                            decoration: inputDecorationStyle(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Gaps.v52,
                SizedBox(
                  height: 200,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: size.width * 0.12,
                        child: SelectableText(
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
                                      Sizes.size20,
                                    ),
                                    child: _feedImageArray[index].runtimeType ==
                                            Uint8List
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
          ),
        );
      },
    );
  }
}

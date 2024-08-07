import 'dart:typed_data';

import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:onldocc_admin/common/view_a/modal_screen.dart';
import 'package:onldocc_admin/common/widgets/modal_button.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/notice/view_models/notice_view_model.dart';
import 'package:onldocc_admin/injicare_color.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';

class UploadNotificationWidget extends ConsumerStatefulWidget {
  final BuildContext context;
  final Function() refreshScreen;
  const UploadNotificationWidget({
    super.key,
    required this.context,
    required this.refreshScreen,
  });

  @override
  ConsumerState<UploadNotificationWidget> createState() =>
      _UploadFeedWidgetState();
}

class _UploadFeedWidgetState extends ConsumerState<UploadNotificationWidget> {
  final GlobalKey _key = GlobalKey();
  Offset _offset = Offset.zero;

  String _feedDescription = "";
  bool _noticeTopFixed = false;
  DateTime _noticeFixedAt = DateTime.now();
  bool _popUp = false;
  bool _popUpHover = false;

  List<PlatformFile> _feedImageFile = [];
  final List<Uint8List> _feedImageArray = [];

  final TextEditingController _descriptionControllder = TextEditingController();
  bool uploadHoverBottmoButton = false;
  bool tapUploadNotification = false;

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
    _findPosition();
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

  void _findPosition() {
    final RenderBox renderbox =
        _key.currentContext!.findRenderObject() as RenderBox;
    final position = renderbox.localToGlobal(Offset.zero);

    setState(() {
      _offset = position;
    });
    print("offset: $_offset");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return StatefulBuilder(
      builder: (context, setState) {
        return ModalScreen(
          size: size,
          modalTitle: "공지 올리기",
          modalButtonOneText: "확인",
          modalButtonOneFunction: () {},
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Gaps.v20,
                  Row(
                    children: [
                      SizedBox(
                        width: size.width * 0.12,
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
                          overlayColor: WidgetStateProperty.all(
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
                  Gaps.v20,
                  Row(
                    children: [
                      SizedBox(
                        width: size.width * 0.12,
                        height: 50,
                        child: Text(
                          "📌\n팝업 공지\n올리기",
                          style: _headerTextStyle,
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Gaps.h32,
                      Transform.scale(
                        scale: 1.3,
                        child: Checkbox(
                          value: _popUp,
                          activeColor: Palette().darkGreen,
                          overlayColor: WidgetStateProperty.all(
                              Palette().normalGreen.withOpacity(0.1)),
                          onChanged: (value) {
                            setState(
                              () {
                                _popUp = !_popUp;
                              },
                            );
                          },
                        ),
                      ),
                      Gaps.h52,
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        onEnter: (_) {
                          setState(() {
                            _popUpHover = true;
                          });
                        },
                        onExit: (_) {
                          setState(() {
                            _popUpHover = false;
                          });
                        },
                        child: ColorFiltered(
                          key: _key,
                          colorFilter: ColorFilter.mode(
                            InjicareColor().gray40,
                            BlendMode.srcIn,
                          ),
                          child: SvgPicture.asset(
                            "assets/svg/info.svg",
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gaps.v52,
                  Row(
                    children: [
                      SizedBox(
                        width: size.width * 0.12,
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
                          width: size.width * 0.12,
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
              if (_popUpHover)
                Positioned(
                  left: 300,
                  top: 100,
                  child: Container(
                    width: 500,
                    height: 100,
                    color: Colors.amber,
                  ),
                )
            ],
          ),
        );
      },
    );
  }
}

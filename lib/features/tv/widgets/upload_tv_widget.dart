import 'dart:typed_data';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/view_a/modal_screen.dart';
import 'package:onldocc_admin/common/widgets/modal_button.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/event/widgets/upload-event/upload_event_widget.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/tv/models/tv_model.dart';
import 'package:onldocc_admin/features/tv/repo/tv_repo.dart';
import 'package:onldocc_admin/features/tv/view_models/tv_view_model.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:uuid/uuid.dart';

class UploadTvWidget extends ConsumerStatefulWidget {
  final BuildContext pcontext;
  final bool edit;
  final TvModel? tvModel;
  final Function() refreshScreen;

  const UploadTvWidget({
    super.key,
    required this.pcontext,
    required this.edit,
    this.tvModel,
    required this.refreshScreen,
  });

  @override
  ConsumerState<UploadTvWidget> createState() => _UploadTvWidgetState();
}

class _UploadTvWidgetState extends ConsumerState<UploadTvWidget> {
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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _enabledUploadVideoButton = false;

  final TextEditingController _titleControllder = TextEditingController();
  final TextEditingController _linkControllder = TextEditingController();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();
  OverlayEntry? overlayEntry;

  String _title = "";
  String _link = "";
  String _tvType = "유투브";
  PlatformFile? _tvVideoFile;
  Uint8List? _tvVideoBytes;
  String? _tvTitle;

  String? _thumbnailUrl;
  PlatformFile? _thumbnailFile;
  Uint8List? _thumbnailBytes;

  bool tapUploadTv = false;

  @override
  void initState() {
    super.initState();

    _linkControllder.addListener(() {
      if (_tvType == "유투브" && _linkControllder.text.isNotEmpty) {
        getYoutubeThumbnail(_linkControllder.text);
      }
    });

    if (widget.edit && widget.tvModel != null) {
      _titleControllder.text = widget.tvModel!.title;
      _linkControllder.text = widget.tvModel!.link;
      _thumbnailUrl = widget.tvModel!.thumbnail;
      _tvType = widget.tvModel!.videoType == "youtube" ? "유투브" : "파일";
    }
  }

  @override
  void dispose() {
    _titleControllder.dispose();
    _linkControllder.dispose();
    _removeDeleteOverlay();
    super.dispose();
  }

  Future<void> pickVideoFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
      );
      if (result == null) return;
      setState(() {
        _tvVideoFile = result.files.first;
        _tvVideoBytes = _tvVideoFile!.bytes!;
        _tvTitle = _tvVideoFile!.name;

        _enabledUploadVideoButton = _title.isNotEmpty && _tvVideoFile != null;
      });
    } catch (e) {
      if (!mounted) return;
      showWarningSnackBar(context, "오류가 발생했습니다");
    }
  }

  void pickThumbnailFromGallery() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result == null) return;
      setState(() {
        _thumbnailFile = result.files.first;
        _thumbnailBytes = _thumbnailFile!.bytes!;
      });
    } catch (e) {
      if (!mounted) return;
      showWarningSnackBar(context, "오류가 발생했습니다");
    }
  }

  String getYoutubeId(String link) {
    String documentId = "";
    if (link.contains("youtu.be")) {
      final parts = link.split("youtu.be/");
      documentId = parts[1].split('?').first;
    } else if (link.contains("youtube.com")) {
      final parts = link.split("watch?v=");
      documentId = parts[1];
    }
    return documentId;
  }

  void getYoutubeThumbnail(String link) {
    final videoId = getYoutubeId(link);
    String thumbnail = "";
    if (link.contains("youtu.be")) {
      thumbnail = "http://i3.ytimg.com/vi/$videoId/hqdefault.jpg";
    } else if (link.contains("youtube.com")) {
      thumbnail = "https://img.youtube.com/vi/$videoId/mqdefault.jpg";
    }

    setState(() {
      _thumbnailUrl = thumbnail;
    });
  }

  void _submitTv() async {
    if (_tvType == "파일" && _tvVideoBytes == null) {
      showWarningSnackBar(context, "영상 파일을 선택해주세요");
    } else {
      setState(() {
        tapUploadTv = true;
      });

      if (_formKey.currentState != null) {
        final validate = _formKey.currentState!.validate();
        final thumbnailValidate =
            _thumbnailBytes != null || _thumbnailUrl != null;

        if (validate && thumbnailValidate) {
          AdminProfileModel? adminProfileModel =
              ref.read(adminProfileProvider).value;
          final videoId = !widget.edit
              ? _tvType == "유투브"
                  ? getYoutubeId(_link)
                  : const Uuid().v4()
              : widget.tvModel!.videoId;
          final thumbnailUrl = _thumbnailBytes != null
              ? await ref
                  .read(tvRepo)
                  .uploadSingleImageToStorage(videoId, _thumbnailBytes)
              : _thumbnailUrl!;

          final tvModel = TvModel(
            thumbnail: thumbnailUrl,
            title: _title,
            link: _link,
            allUsers:
                selectContractRegion.value!.subdistrictId != "" ? false : true,
            videoId: videoId,
            createdAt: getCurrentSeconds(),
            videoType: _tvType == "유투브" ? "youtube" : "file",
            contractRegionId: adminProfileModel!.contractRegionId != ""
                ? adminProfileModel.contractRegionId
                : null,
            contractCommunityId:
                selectContractRegion.value!.contractCommunityId != ""
                    ? selectContractRegion.value!.contractCommunityId
                    : null,
          );

          await ref.read(tvProvider.notifier).addTv(tvModel, _tvVideoBytes);
          if (!mounted) return;
          resultBottomModal(context, "성공적으로 영상이 올라갔습니다.", widget.refreshScreen);
        }
      }
    }
  }

  // 행사 삭제

  void _editTv() async {
    await ref.read(tvRepo).editTv(widget.tvModel!.videoId, _title);
    if (!mounted) return;
    resultBottomModal(
      context,
      "성공적으로 영상이 수정되었습니다.",
      widget.refreshScreen,
    );
  }

  void _deleteTv() async {
    await ref.read(tvRepo).deleteTv(widget.tvModel!.videoId);
    if (!mounted) return;
    resultBottomModal(context, "성공적으로 영상을 삭제하였습니다.", widget.refreshScreen);
  }

  void _removeDeleteOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  void _showDeleteOverlay() async {
    _removeDeleteOverlay();
    final description = widget.tvModel!.title;
    overlayEntry = OverlayEntry(builder: (context) {
      return deleteTitleOverlay(description, _removeDeleteOverlay, _deleteTv);
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
          modalTitle: !widget.edit ? "영상 올리기" : "영상 수정하기",
          modalButtonOneText: !widget.edit ? "확인" : "삭제하기",
          modalButtonOneFunction: !widget.edit ? _submitTv : _showDeleteOverlay,
          modalButtonTwoText: !widget.edit ? null : "수정하기",
          modalButtonTwoFunction: _editTv,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: size.width * 0.12,
                      child: SelectableText(
                        "영상 제목",
                        style: _headerTextStyle,
                        textAlign: TextAlign.start,
                      ),
                    ),
                    Gaps.h32,
                    Expanded(
                      child: TextFormField(
                        maxLength: 50,
                        validator: (value) {
                          if (value != null && value.isEmpty) {
                            return "영상 제목을 적어주세요";
                          }
                          return null;
                        },
                        controller: _titleControllder,
                        onChanged: (value) {
                          setState(
                            () {
                              _title = value;

                              _enabledUploadVideoButton = (_title.isNotEmpty &&
                                      _link.isNotEmpty) ||
                                  (_title.isNotEmpty && _tvVideoFile != null);
                            },
                          );
                        },
                        textAlignVertical: TextAlignVertical.center,
                        style: _contentTextStyle,
                        decoration: inputDecorationStyle(),
                      ),
                    )
                  ],
                ),
                Gaps.v52,
                Container(
                  height: 0.5,
                  decoration: BoxDecoration(
                    color: Palette().lightGray,
                  ),
                ),
                Gaps.v52,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: size.width * 0.12,
                      child: SelectableText(
                        "영상 타입",
                        style: _headerTextStyle,
                      ),
                    ),
                    Gaps.h32,
                    SizedBox(
                      width: 300,
                      height: 40,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          items: ["유투브", "파일"].map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: SelectableText(
                                item,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Palette().normalGray,
                                ),
                                // overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          value: _tvType,
                          onChanged: (value) => {
                            setState(() {
                              _tvType = value!;
                            })
                          },
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
                    ),
                  ],
                ),
                Gaps.v40,
                if (_tvType == "유투브")
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: size.width * 0.12,
                        child: SelectableText(
                          "영상 링크",
                          style: _headerTextStyle,
                        ),
                      ),
                      Gaps.h32,
                      SizedBox(
                        width: size.width * 0.4,
                        child: TextFormField(
                          controller: _linkControllder,
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return "영상 링크를 적어주세요";
                            } else if (!(value
                                    .toString()
                                    .contains("youtu.be/") ||
                                value.toString().contains("youtube.com"))) {
                              return "유투브 영상을 올려주세요.";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(
                              () {
                                _link = value;

                                _enabledUploadVideoButton =
                                    _title.isNotEmpty && _link.isNotEmpty;
                              },
                            );
                          },
                          textAlignVertical: TextAlignVertical.center,
                          style: _contentTextStyle,
                          decoration: inputDecorationStyle(),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: size.width * 0.12,
                        child: SelectableText(
                          "영상 파일",
                          style: _headerTextStyle,
                        ),
                      ),
                      Gaps.h32,
                      Row(
                        children: [
                          ModalButton(
                              modalText: '영상 선택하기', modalAction: pickVideoFile),
                          Gaps.h32,
                          if (_tvVideoFile != null)
                            SelectableText(
                              _tvTitle!,
                              style: _contentTextStyle.copyWith(
                                color: Palette().darkBlue,
                              ),
                            )
                        ],
                      ),
                    ],
                  ),
                Gaps.v40,
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: size.width * 0.12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(
                            "썸네일 이미지",
                            style: _headerTextStyle,
                            textAlign: TextAlign.start,
                          ),
                          if (tapUploadTv &&
                              (_thumbnailBytes == null &&
                                  _thumbnailUrl == null))
                            const InsufficientField(text: "영상 썸네일을 설정해주세요")
                        ],
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
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              width: 1.5,
                              color: Palette().darkGray.withOpacity(0.5),
                            ),
                            color: Colors.white.withOpacity(0.3),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: _thumbnailBytes != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Image.memory(
                                    _thumbnailBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : _thumbnailUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: Image.network(
                                        _thumbnailUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(
                                            Icons.image,
                                            size: Sizes.size60,
                                            color: Palette()
                                                .darkBlue
                                                .withOpacity(0.3),
                                          );
                                        },
                                      ),
                                    )
                                  : Icon(
                                      Icons.image,
                                      size: Sizes.size60,
                                      color:
                                          Palette().darkBlue.withOpacity(0.3),
                                    ),
                        ),
                        Gaps.v20,
                        ModalButton(
                          modalText: !widget.edit ? "썸네일 올리기" : "썸네일 수정하기",
                          modalAction: pickThumbnailFromGallery,
                        ),

                        // if (tapUploadTv &&
                        //     (_thumbnailBytes == null || _thumbnailUrl == null))
                      ],
                    ),
                  ],
                ),
                Gaps.v52,
              ],
            ),
          ),
        );
      },
    );
  }
}

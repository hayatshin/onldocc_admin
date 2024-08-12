import 'dart:typed_data';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/view_a/modal_screen.dart';
import 'package:onldocc_admin/common/widgets/modal_button.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/tv/models/tv_model.dart';
import 'package:onldocc_admin/features/tv/repo/tv_repo.dart';
import 'package:onldocc_admin/features/tv/view_models/tv_view_model.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:uuid/uuid.dart';

class UploadTvWidget extends ConsumerStatefulWidget {
  final BuildContext context;
  final bool edit;
  final TvModel? tvModel;
  final Function() refreshScreen;

  const UploadTvWidget({
    super.key,
    required this.context,
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

  PlatformFile? _thumbnailFile;
  Uint8List? _thumbnailBytes;

  bool tapUploadTv = false;

  @override
  void initState() {
    super.initState();

    if (widget.edit && widget.tvModel != null) {
      _titleControllder.text = widget.tvModel!.title;
      _linkControllder.text = widget.tvModel!.link;
      _tvType = widget.tvModel!.videoType == "youtube" ? "유투브" : "파일";
    }
  }

  @override
  void dispose() {
    _titleControllder.dispose();
    _linkControllder.dispose();
    super.dispose();
  }

  Future<void> pickVideoFile() async {
    try {
      FilePickerResult? result = await FilePickerWeb.platform.pickFiles(
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
      FilePickerResult? result = await FilePickerWeb.platform.pickFiles(
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

  void _submitTv() async {
    if (_formKey.currentState != null) {
      if (_formKey.currentState!.validate()) {
        setState(() {
          tapUploadTv = true;
        });

        AdminProfileModel? adminProfileModel =
            ref.read(adminProfileProvider).value;
        final videoId =
            !widget.edit ? const Uuid().v4() : widget.tvModel!.videoId;
        final thumbnailUrl = await ref
            .read(tvRepo)
            .uploadSingleImageToStorage(videoId, _thumbnailBytes);

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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return StatefulBuilder(
      builder: (context, setState) {
        return ModalScreen(
          size: size,
          modalTitle: "영상 올리기",
          modalButtonOneText: "확인",
          modalButtonOneFunction: _submitTv,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: size.width * 0.12,
                      child: Text(
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
                            return "영상 제목을 적어주세요.";
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: size.width * 0.12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "썸네일 이미지",
                            style: _headerTextStyle,
                            textAlign: TextAlign.start,
                          ),
                          // if (tapUploadEvent &&
                          //     _thumbnailBytes == null)
                          //   const InsufficientField(
                          //       text: "행사 이미지를 추가해주세요.")
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
                              : !widget.edit
                                  ? Icon(
                                      Icons.image,
                                      size: Sizes.size60,
                                      color:
                                          Palette().darkBlue.withOpacity(0.3),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(18),
                                      child: Image.network(
                                        widget.tvModel!.thumbnail,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                        ),
                        Gaps.v20,
                        ModalButton(
                          modalText: !widget.edit ? "썸네일 올리기" : "썸네일 수정하기",
                          modalAction: pickThumbnailFromGallery,
                        ),
                      ],
                    ),
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
                      child: Text(
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
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Palette().normalGray,
                                ),
                                overflow: TextOverflow.ellipsis,
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
                        child: Text(
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
                              return "영상 링크를 적어주세요.";
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
                        child: Text(
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
                            Text(
                              _tvTitle!,
                              style: _contentTextStyle.copyWith(
                                color: Palette().darkBlue,
                              ),
                            )
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

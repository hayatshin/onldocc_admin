import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/widgets/bottom_modal_button.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/tv/models/tv_model.dart';
import 'package:onldocc_admin/features/tv/repo/tv_repo.dart';
import 'package:onldocc_admin/utils.dart';

class UploadTvWidget extends ConsumerStatefulWidget {
  final BuildContext context;
  final double totalWidth;
  final double totalHeight;
  final Function() refreshScreen;

  const UploadTvWidget({
    super.key,
    required this.context,
    required this.totalWidth,
    required this.totalHeight,
    required this.refreshScreen,
  });

  @override
  ConsumerState<UploadTvWidget> createState() => _UploadTvWidgetState();
}

class _UploadTvWidgetState extends ConsumerState<UploadTvWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _enabledUploadVideoButton = false;

  final TextEditingController _titleControllder = TextEditingController();
  final TextEditingController _linkControllder = TextEditingController();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();
  OverlayEntry? overlayEntry;

  String _title = "";
  String _link = "";

  bool tapUploadTv = false;

  void _submitTv() async {
    setState(() {
      tapUploadTv = true;
    });

    AdminProfileModel? adminProfileModel = ref.read(adminProfileProvider).value;
    final videoId = getVideoId(_link);
    final thumbnail = getVideoThumbnail(videoId, _link);

    final tvModel = TvModel(
      thumbnail: thumbnail,
      title: _title,
      link: _link,
      allUsers: selectContractRegion.value.subdistrictId != "" ? false : true,
      videoId: videoId,
      createdAt: getCurrentSeconds(),
      contractRegionId: adminProfileModel!.contractRegionId != ""
          ? adminProfileModel.contractRegionId
          : null,
      contractCommunityId: selectContractRegion.value.contractCommunityId != ""
          ? selectContractRegion.value.contractCommunityId
          : null,
    );

    await ref.read(tvRepo).addTv(tvModel);
    if (!mounted) return;
    resultBottomModal(context, "성공적으로 영상이 올라갔습니다.", widget.refreshScreen);
  }

  @override
  void dispose() {
    _titleControllder.dispose();
    _linkControllder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
            width: widget.totalWidth,
            height: widget.totalHeight * 0.6,
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        BottomModalButton(
                          text: "영상 올리기",
                          submitFunction: _submitTv,
                          hoverBottomButton: _enabledUploadVideoButton,
                          loading: tapUploadTv,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: widget.totalWidth * 0.1,
                                  child: const Text(
                                    "영상 제목",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                Gaps.h32,
                                SizedBox(
                                  width: widget.totalWidth * 0.6,
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

                                          _enabledUploadVideoButton =
                                              _title.isNotEmpty &&
                                                  _link.isNotEmpty;
                                        },
                                      );
                                    },
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: Sizes.size20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Gaps.v32,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: widget.totalWidth * 0.1,
                                  child: const Text(
                                    "영상 링크",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                Gaps.h32,
                                SizedBox(
                                  width: widget.totalWidth * 0.6,
                                  child: TextFormField(
                                    controller: _linkControllder,
                                    validator: (value) {
                                      if (value != null && value.isEmpty) {
                                        return "영상 링크를 적어주세요.";
                                      } else if (!(value
                                              .toString()
                                              .contains("youtu.be/") ||
                                          value
                                              .toString()
                                              .contains("youtube.com"))) {
                                        return "유투브 영상을 올려주세요.";
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      setState(
                                        () {
                                          _link = value;

                                          _enabledUploadVideoButton =
                                              _title.isNotEmpty &&
                                                  _link.isNotEmpty;
                                        },
                                      );
                                    },
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: Sizes.size20,
                                      ),
                                    ),
                                  ),
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
            ));
      },
    );
  }
}

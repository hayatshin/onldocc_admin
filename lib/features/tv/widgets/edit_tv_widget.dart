import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/widgets/bottom_modal_button.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/tv/models/tv_model.dart';
import 'package:onldocc_admin/features/tv/repo/tv_repo.dart';
import 'package:onldocc_admin/utils.dart';

class EditTvWidget extends ConsumerStatefulWidget {
  final BuildContext context;
  final double totalWidth;
  final double totalHeight;
  final TvModel tvModel;
  final Function() refreshScreen;

  const EditTvWidget({
    super.key,
    required this.context,
    required this.totalWidth,
    required this.totalHeight,
    required this.tvModel,
    required this.refreshScreen,
  });

  @override
  ConsumerState<EditTvWidget> createState() => _EditTvWidgetState();
}

class _EditTvWidgetState extends ConsumerState<EditTvWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleControllder = TextEditingController();
  final TextEditingController _linkControllder = TextEditingController();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();
  OverlayEntry? overlayEntry;

  String _title = "";
  bool tapEditTv = false;

  Future<void> deleteTv(String documentId) async {
    removeDeleteOverlay();
  }

  void removeDeleteOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  void showDeleteOverlay(
      BuildContext context, String videoId, String tvTitle) async {
    removeDeleteOverlay();

    // assert(overlayEntry == null);

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.black54,
          child: Center(
            child: AlertDialog(
              title: SelectableText(
                tvTitle.length > 10 ? "${tvTitle.substring(0, 11)}.." : tvTitle,
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
                  onPressed: () async {
                    await ref.read(tvRepo).deleteTv(videoId);
                    if (!context.mounted) return;
                    resultBottomModal(
                        context, "성공적으로 영상을 삭제하였습니다.", widget.refreshScreen);
                  },
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

  void _editTv() async {
    setState(() {
      tapEditTv = true;
    });
    await ref.read(tvRepo).editTv(widget.tvModel.videoId, _title);
    if (!mounted) return;
    resultBottomModal(
      context,
      "성공적으로 영상이 수정되었습니다.",
      widget.refreshScreen,
    );
  }

  @override
  void initState() {
    super.initState();
    _title = widget.tvModel.title;
    setState(() {});

    _titleControllder.text = widget.tvModel.title;
    _linkControllder.text = widget.tvModel.link;
  }

  @override
  void dispose() {
    removeDeleteOverlay();
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
                          text: "영상 삭제하기",
                          submitFunction: () => showDeleteOverlay(
                            context,
                            widget.tvModel.videoId,
                            widget.tvModel.title,
                          ),
                          hoverBottomButton: true,
                          loading: false,
                        ),
                        Gaps.h40,
                        BottomModalButton(
                          text: "영상 수정하기",
                          submitFunction: _editTv,
                          hoverBottomButton: true,
                          loading: tapEditTv,
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
                                  width: widget.totalWidth * 0.12,
                                  child: const SelectableText(
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
                                        return "영상 제목을 적어주세요";
                                      }
                                      return null;
                                    },
                                    controller: _titleControllder,
                                    onChanged: (value) {
                                      setState(
                                        () {
                                          _title = value;
                                        },
                                      );
                                    },
                                    textAlignVertical: TextAlignVertical.center,
                                    style: const TextStyle(
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
                                  width: widget.totalWidth * 0.12,
                                  child: const SelectableText(
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
                                  child: SelectableText(
                                    widget.tvModel.videoType == "youtube"
                                        ? widget.tvModel.link
                                        : "파일 형식의 영상",
                                    style: const TextStyle(
                                      fontSize: Sizes.size14,
                                      color: Colors.black87,
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

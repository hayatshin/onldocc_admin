import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/view/error_screen.dart';
import 'package:onldocc_admin/features/tv/repo/tv_repo.dart';
import 'package:onldocc_admin/features/tv/view_models/tv_view_model.dart';
import 'package:onldocc_admin/utils.dart';

import '../../../common/view/search_below.dart';
import '../../../constants/gaps.dart';
import '../../../constants/sizes.dart';

class TvScreen extends ConsumerStatefulWidget {
  static const routeURL = "/tv";
  static const routeName = "tv";

  const TvScreen({
    super.key,
  });

  @override
  ConsumerState<TvScreen> createState() => _TvScreenState();
}

class _TvScreenState extends ConsumerState<TvScreen> {
  int searchHeight = 35;
  bool _uploadVideoHover = false;

  bool _enabledUploadVideoButton = false;

  final TextEditingController _titleControllder = TextEditingController();
  final TextEditingController _linkControllder = TextEditingController();

  String _title = "";
  String _link = "";

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();
  OverlayEntry? overlayEntry;

  void _onSubmitTap() async {
    if (_formKey.currentState != null) {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();

        await ref.read(tvProvider.notifier).saveTvwithJson(_title, _link);
        await ref.read(tvProvider.notifier).getCertainTvList();
        context.pop();
        showSnackBar(context, "영상이 추가되었습니다.");
      }
    }
  }

  Future<void> deleteTv(String documentId) async {
    await ref.read(tvRepo).deleteTv(documentId);
    await ref.read(tvProvider.notifier).getCertainTvList();
    removeDeleteOverlay();
  }

  void removeDeleteOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  void showDeleteOverlay(
      BuildContext context, String documentId, String tvTitle) async {
    removeDeleteOverlay();

    // assert(overlayEntry == null);

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.black54,
          child: Center(
            child: AlertDialog(
              title: Text(
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
                  onPressed: () => deleteTv(documentId),
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

  void uploadVideoTap(
      BuildContext context, double totalWidth, double totalHeight) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        minWidth: totalWidth,
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
                width: totalWidth,
                height: totalHeight * 0.6,
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
                            SizedBox(
                              width: 200,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: _enabledUploadVideoButton
                                    ? _onSubmitTap
                                    : null,
                                style: ButtonStyle(
                                  side: MaterialStateProperty.resolveWith<
                                      BorderSide>(
                                    (states) {
                                      return BorderSide(
                                        color: _enabledUploadVideoButton
                                            ? Theme.of(context).primaryColor
                                            : Colors.grey.shade800,
                                        width: 1,
                                      );
                                    },
                                  ),
                                  backgroundColor: MaterialStateProperty.all(
                                    Colors.white,
                                  ),
                                  surfaceTintColor: MaterialStateProperty.all(
                                    _enabledUploadVideoButton
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey.shade800,
                                  ),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        Sizes.size10,
                                      ),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "영상 올리기",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _enabledUploadVideoButton
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey.shade800,
                                  ),
                                ),
                              ),
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
                                      width: totalWidth * 0.1,
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
                                      width: totalWidth * 0.6,
                                      child: TextFormField(
                                        maxLength: 50,
                                        onFieldSubmitted: (value) =>
                                            _onSubmitTap(),
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
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        style: const TextStyle(
                                          fontSize: Sizes.size12,
                                          color: Colors.black87,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "",
                                          hintStyle: TextStyle(
                                            fontSize: Sizes.size12,
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
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              Sizes.size3,
                                            ),
                                            borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor,
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
                                              color: Theme.of(context)
                                                  .primaryColor,
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
                                      width: totalWidth * 0.1,
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
                                      width: totalWidth * 0.7,
                                      child: TextFormField(
                                        controller: _linkControllder,
                                        onFieldSubmitted: (value) =>
                                            _onSubmitTap(),
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
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        style: const TextStyle(
                                          fontSize: Sizes.size12,
                                          color: Colors.black87,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "",
                                          hintStyle: TextStyle(
                                            fontSize: Sizes.size12,
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
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              Sizes.size3,
                                            ),
                                            borderSide: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor,
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
                                              color: Theme.of(context)
                                                  .primaryColor,
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
      },
    );
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
    final size = MediaQuery.of(context).size;
    return ref.watch(tvProvider).when(
          loading: () => CircularProgressIndicator.adaptive(
            backgroundColor: Theme.of(context).primaryColor,
          ),
          error: (error, stackTrace) {
            print(error);
            return const ErrorScreen();
          },
          data: (data) {
            final tvlist = data;
            final size = MediaQuery.of(context).size;

            return Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade200,
                      ),
                    ),
                  ),
                  child: SizedBox(
                    height: searchHeight + Sizes.size40,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: Sizes.size10,
                        horizontal: Sizes.size32,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            onHover: (event) {
                              setState(() {
                                _uploadVideoHover = true;
                              });
                            },
                            onExit: (event) {
                              setState(() {
                                _uploadVideoHover = false;
                              });
                            },
                            child: GestureDetector(
                              onTap: () => uploadVideoTap(
                                context,
                                size.width - 270,
                                size.height,
                              ),
                              child: Container(
                                width: 150,
                                height: searchHeight.toDouble(),
                                decoration: BoxDecoration(
                                  color: _uploadVideoHover
                                      ? Colors.grey.shade200
                                      : Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.shade800,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    Sizes.size10,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "영상 올리기",
                                    style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontSize: Sizes.size14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SearchBelow(
                  size: size,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: Sizes.size40,
                          horizontal: Sizes.size20,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              Sizes.size10,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: Sizes.size16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          "#",
                                          style: TextStyle(
                                            // color: Colors.white,
                                            fontSize: Sizes.size12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          "썸네일",
                                          style: TextStyle(
                                            fontSize: Sizes.size12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          "제목",
                                          style: TextStyle(
                                            fontSize: Sizes.size12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          "삭제",
                                          style: TextStyle(
                                            fontSize: Sizes.size12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                color: Colors.grey.shade200,
                              ),
                              Gaps.v16,
                              SingleChildScrollView(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: tvlist.length,
                                  itemBuilder: (context, index) {
                                    return Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Padding(
                                            padding: const EdgeInsets.all(
                                              Sizes.size3,
                                            ),
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                (index + 1).toString(),
                                                softWrap: true,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  // color: Colors.white,
                                                  fontSize: Sizes.size12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Padding(
                                            padding: const EdgeInsets.all(
                                              Sizes.size3,
                                            ),
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: SizedBox(
                                                width: 150,
                                                height: 100,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    Sizes.size5,
                                                  ),
                                                  child: Image.network(
                                                    tvlist[index].thumbnail,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Padding(
                                            padding: const EdgeInsets.all(
                                              Sizes.size3,
                                            ),
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                tvlist[index].title,
                                                softWrap: true,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  // color: Colors.white,
                                                  fontSize: Sizes.size12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        tvlist[index].allUser != true
                                            ? Expanded(
                                                flex: 2,
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: MouseRegion(
                                                    cursor: SystemMouseCursors
                                                        .click,
                                                    child: GestureDetector(
                                                      onTap: () =>
                                                          showDeleteOverlay(
                                                        context,
                                                        tvlist[index]
                                                            .documentId,
                                                        tvlist[index].title,
                                                      ),
                                                      child: const Icon(
                                                        Icons.delete,
                                                        size: Sizes.size16,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Expanded(
                                                flex: 2,
                                                child: Container(),
                                              ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              Gaps.v16,
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
  }
}

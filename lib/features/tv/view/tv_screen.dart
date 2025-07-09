import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/notice/views/notice_screen.dart';
import 'package:onldocc_admin/features/tv/models/tv_model.dart';
import 'package:onldocc_admin/features/tv/repo/tv_repo.dart';
import 'package:onldocc_admin/features/tv/view_models/tv_view_model.dart';
import 'package:onldocc_admin/features/tv/widgets/upload_tv_widget.dart';
import 'package:onldocc_admin/features/users/view/users_screen.dart';
import 'package:onldocc_admin/injicare_color.dart';
import 'package:onldocc_admin/injicare_font.dart';
import 'package:onldocc_admin/utils.dart';

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
  final double _tabHeight = 150;

  static const int _itemsPerPage = 5;
  int _currentPage = 0;
  int _pageIndication = 0;
  int _totalListLength = 0;
  int _endPage = 0;

  List<TvModel> _initialList = [];
  List<TvModel> _tvList = [];

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();
  OverlayEntry? overlayEntry;
  bool loadingFinished = false;

  @override
  void initState() {
    super.initState();
    if (selectContractRegion.value != null) {
      getUserTvs();
    }

    selectContractRegion.addListener(() async {
      if (mounted) {
        setState(() {
          loadingFinished = false;
        });

        await getUserTvs();
      }
    });
  }

  @override
  void dispose() {
    _removeDeleteOverlay();

    super.dispose();
  }

  void _removeDeleteOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  void uploadVideoTap(BuildContext context) {
    showRightModal(
        context,
        UploadTvWidget(
          pcontext: context,
          edit: false,
          refreshScreen: getUserTvs,
        ));
  }

  void editVideoTap(BuildContext context, TvModel tvModel) {
    showRightModal(
        context,
        UploadTvWidget(
          pcontext: context,
          edit: true,
          tvModel: tvModel,
          refreshScreen: getUserTvs,
        ));
  }

  Future<void> getUserTvs() async {
    final tvList = await ref.read(tvProvider.notifier).getUserTvs();
    int endPage = tvList.length ~/ _itemsPerPage + 1;

    if (selectContractRegion.value!.subdistrictId == "") {
      if (mounted) {
        setState(() {
          loadingFinished = true;
          _totalListLength = tvList.length;
          _initialList = tvList;
          _endPage = endPage;
        });
        _updateUserlistPerPage();
      }
    } else {
      if (selectContractRegion.value!.contractCommunityId != "" &&
          selectContractRegion.value!.contractCommunityId != null) {
        final filterList = tvList
            .where((e) =>
                e.contractCommunityId ==
                selectContractRegion.value!.contractCommunityId)
            .toList();
        int endPage = filterList.length ~/ _itemsPerPage + 1;

        if (mounted) {
          setState(() {
            loadingFinished = true;
            _totalListLength = filterList.length;
            _initialList = filterList;
            _endPage = endPage;
          });
          _updateUserlistPerPage();
        }
      } else {
        final filterList = tvList
            .where((e) =>
                e.contractCommunityId == null || e.contractCommunityId == "")
            .toList();

        if (mounted) {
          setState(() {
            loadingFinished = true;
            _totalListLength = filterList.length;
            _initialList = filterList;
            _endPage = endPage;
          });
          _updateUserlistPerPage();
        }
      }
    }
  }

  void _updateUserlistPerPage() {
    int startPage = _currentPage * _itemsPerPage;
    int endPage = startPage + _itemsPerPage > _initialList.length
        ? _initialList.length
        : startPage + _itemsPerPage;

    setState(() {
      _tvList = _initialList.sublist(startPage, endPage);
    });
  }

  void _previousPage() {
    if (_pageIndication == 0) return;

    setState(() {
      _pageIndication--;
      _currentPage = _pageIndication * 5;
    });
    _updateUserlistPerPage();
  }

  void _nextPage() {
    int endIndication = _endPage ~/ 5;
    if (_pageIndication >= endIndication) return;
    setState(() {
      _pageIndication++;
      _currentPage = _pageIndication * 5;
    });
    _updateUserlistPerPage();
  }

  void _changePage(int s) {
    setState(() {
      _currentPage = s - 1;
    });
    _updateUserlistPerPage();
  }

  void _deleteTv(TvModel tvModel) async {
    await ref.read(tvRepo).deleteTv(tvModel.videoId);
    _removeDeleteOverlay();
    if (!mounted) return;
    showCompletingSnackBar(context, "성공적으로 영상을 삭제하였습니다.");
    setState(() {
      _tvList.removeWhere((user) => user.videoId == tvModel.videoId);
    });
  }

  void _showDeleteOverlay(TvModel tvModel) async {
    _removeDeleteOverlay();

    final description = tvModel.title;

    overlayEntry = OverlayEntry(builder: (context) {
      return deleteTitleOverlay(
          description, _removeDeleteOverlay, () => _deleteTv(tvModel));
    });

    Overlay.of(context, debugRequiredFor: widget).insert(overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      menu: menuList[7],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderWithButton(
              buttonAction: () => uploadVideoTap(context),
              buttonText: "공지 올리기",
              listCount: _totalListLength,
            ),
            SizedBox(
              height: 50,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                          color: const Color(0xFFE9EDF9),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                          ),
                          border: Border.all(
                            width: 1,
                            color: const Color(0xFFF3F6FD),
                          )),
                      child: Center(
                        child: Text(
                          "#",
                          style: contentTextStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                          color: const Color(0xFFE9EDF9),
                          border: Border.all(
                            width: 1,
                            color: const Color(0xFFF3F6FD),
                          )),
                      child: Center(
                        child: Text(
                          "썸네일",
                          style: contentTextStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                          color: const Color(0xFFE9EDF9),
                          border: Border.all(
                            width: 1,
                            color: const Color(0xFFF3F6FD),
                          )),
                      child: Center(
                        child: Text(
                          "제목",
                          style: contentTextStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9EDF9),
                        border: Border.all(
                          width: 1,
                          color: const Color(0xFFF3F6FD),
                        ),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "",
                          style: contentTextStyle,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_tvList.isNotEmpty)
              for (int i = 0; i < _tvList.length; i++)
                Column(
                  children: [
                    SizedBox(
                      height: _tabHeight,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              "${_currentPage * _itemsPerPage + 1 + i}",
                              style: contentTextStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  width: 150,
                                  height: 100,
                                  child: Image.network(
                                    _tvList[i].thumbnail,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: SelectableText(
                              _tvList[i].title,
                              style: contentTextStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () =>
                                            editVideoTap(context, _tvList[i]),
                                        child: const EditButton(),
                                      ),
                                    ),
                                  ],
                                ),
                                Gaps.v3,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () =>
                                            _showDeleteOverlay(_tvList[i]),
                                        child: const DeleteButton(),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: InjicareColor().gray30,
                          ),
                        )
                      ],
                    )
                  ],
                ),
            Gaps.v40,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: _previousPage,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                          _pageIndication == 0
                              ? InjicareColor().gray50
                              : InjicareColor().gray100,
                          BlendMode.srcIn),
                      child: SvgPicture.asset(
                        "assets/svg/chevron-left.svg",
                      ),
                    ),
                  ),
                ),
                Gaps.h10,
                for (int s = (_pageIndication * 5 + 1);
                    s <
                        (s >= _endPage + 1
                            ? _endPage + 1
                            : (_pageIndication * 5 + 1) + 5);
                    s++)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Gaps.h10,
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => _changePage(s),
                          child: Text(
                            "$s",
                            style: InjicareFont().body07.copyWith(
                                color: _currentPage + 1 == s
                                    ? InjicareColor().gray100
                                    : InjicareColor().gray60,
                                fontWeight: _currentPage + 1 == s
                                    ? FontWeight.w900
                                    : FontWeight.w400),
                          ),
                        ),
                      ),
                      Gaps.h10,
                    ],
                  ),
                Gaps.h10,
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: _nextPage,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                          _pageIndication + 5 > _endPage
                              ? InjicareColor().gray50
                              : InjicareColor().gray100,
                          BlendMode.srcIn),
                      child: SvgPicture.asset(
                        "assets/svg/chevron-right.svg",
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     ReportButton(
            //       iconExists: false,
            //       buttonText: "영상 올리기",
            //       buttonColor: Palette().darkPurple,
            //       action: () => uploadVideoTap(
            //         context,
            //         size.width,
            //         size.height,
            //       ),
            //     ),
            //   ],
            // ),
            // SizedBox(
            //   height: 50,
            //   child: Row(
            //     children: [
            //       Expanded(
            //         flex: 1,
            //         child: Align(
            //           alignment: Alignment.center,
            //           child: SelectableText(
            //             "#",
            //             style: _headerTextStyle,
            //           ),
            //         ),
            //       ),
            //       Expanded(
            //         flex: 2,
            //         child: Align(
            //           alignment: Alignment.center,
            //           child: SelectableText(
            //             "썸네일",
            //             style: _headerTextStyle,
            //           ),
            //         ),
            //       ),
            //       Expanded(
            //         flex: 3,
            //         child: Align(
            //           alignment: Alignment.center,
            //           child: SelectableText(
            //             "제목",
            //             style: _headerTextStyle,
            //           ),
            //         ),
            //       ),
            //       Expanded(
            //         flex: 1,
            //         child: Align(
            //           alignment: Alignment.center,
            //           child: SelectableText(
            //             "수정",
            //             style: _headerTextStyle,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // Column(
            //   children: [
            //     Gaps.v16,
            //     Expanded(
            //       child: ListView.builder(
            //         shrinkWrap: true,
            //         itemCount: _tvList.length,
            //         itemBuilder: (context, index) {
            //           return Row(
            //             children: [
            //               Expanded(
            //                 flex: 1,
            //                 child: Padding(
            //                   padding: const EdgeInsets.all(
            //                     Sizes.size3,
            //                   ),
            //                   child: Align(
            //                     alignment: Alignment.center,
            //                     child: SelectableText(
            //                       (index + 1).toString(),
            //                       // softWrap: true,
            //                       // overflow: TextOverflow.ellipsis,
            //                       style: _contentTextStyle,
            //                     ),
            //                   ),
            //                 ),
            //               ),
            //               Expanded(
            //                 flex: 2,
            //                 child: Padding(
            //                   padding: const EdgeInsets.all(
            //                     Sizes.size3,
            //                   ),
            //                   child: Align(
            //                     alignment: Alignment.center,
            //                     child: ClipRRect(
            //                       borderRadius: BorderRadius.circular(
            //                         Sizes.size5,
            //                       ),
            //                       child: SizedBox(
            //                         width: 150,
            //                         height: 100,
            //                         child: Image.network(
            //                           _tvList[index].thumbnail,
            //                           fit: BoxFit.cover,
            //                         ),
            //                       ),
            //                     ),
            //                   ),
            //                 ),
            //               ),
            //               Expanded(
            //                 flex: 3,
            //                 child: Padding(
            //                   padding: const EdgeInsets.all(
            //                     Sizes.size3,
            //                   ),
            //                   child: Align(
            //                     alignment: Alignment.center,
            //                     child: SelectableText(
            //                       _tvList[index].title,
            //                       // softWrap: true,
            //                       // overflow: TextOverflow.ellipsis,
            //                       style: _contentTextStyle,
            //                     ),
            //                   ),
            //                 ),
            //               ),
            //               Expanded(
            //                 flex: 1,
            //                 child: Align(
            //                   alignment: Alignment.center,
            //                   child: MouseRegion(
            //                     cursor: SystemMouseCursors.click,
            //                     child: GestureDetector(
            //                       onTap: () => editVideoTap(
            //                         context,
            //                         size.width,
            //                         size.height,
            //                         _tvList[index],
            //                       ),
            //                       child: FaIcon(
            //                         FontAwesomeIcons.pen,
            //                         size: 14,
            //                         color: Palette().darkGray,
            //                       ),
            //                     ),
            //                   ),
            //                 ),
            //               ),
            //             ],
            //           );
            //         },
            //       ),
            //     ),
            //     Gaps.v16,
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}

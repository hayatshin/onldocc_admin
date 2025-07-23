import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:onldocc_admin/common/view/search_csv.dart';
import 'package:onldocc_admin/common/view/skeleton_loading_screen.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/notice/models/popup_model.dart';
import 'package:onldocc_admin/features/notice/repo/notice_repo.dart';
import 'package:onldocc_admin/features/notice/view_models/notice_view_model.dart';
import 'package:onldocc_admin/features/notice/widgets/upload_notification_widget.dart';
import 'package:onldocc_admin/features/ranking/models/diary_model.dart';
import 'package:onldocc_admin/features/users/view/users_screen.dart';
import 'package:onldocc_admin/injicare_color.dart';
import 'package:onldocc_admin/injicare_font.dart';
import 'package:onldocc_admin/router.dart';
import 'package:onldocc_admin/utils.dart';

class NoticeScreen extends ConsumerStatefulWidget {
  static const routeURL = "/notice";
  static const routeName = "notice";
  const NoticeScreen({super.key});

  @override
  ConsumerState<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends ConsumerState<NoticeScreen> {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();
  OverlayEntry? overlayEntry;

  List<DiaryModel> _initialList = [];
  List<DiaryModel> _noticeList = [];
  bool loadingFinished = false;
  final double _tabHeight = 75;

  static const int _itemsPerPage = 10;
  int _currentPage = 0;
  int _pageIndication = 0;
  int _totalListLength = 0;
  int _endPage = 0;

  void removeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  void uploadNotification(
      BuildContext context, double totalWidth, double totalHeight) {
    showRightModal(
        context,
        UploadNotificationWidget(
          pcontext: rootNavigatorKey.currentContext ?? context,
          refreshScreen: refreshScreen,
          edit: false,
        ));
  }

  void editNotification(
    BuildContext context,
    Size size,
    DiaryModel diaryModel,
  ) {
    showRightModal(
        context,
        UploadNotificationWidget(
          pcontext: context,
          refreshScreen: refreshScreen,
          edit: true,
          notificationModel: diaryModel,
        ));
  }

  void refreshScreen() {
    fetchAllNoticies();
  }

  @override
  void initState() {
    super.initState();
    if (selectContractRegion.value != null) {
      fetchAllNoticies();
    }

    selectContractRegion.addListener(() async {
      if (mounted) {
        await fetchAllNoticies();
      }
    });
  }

  @override
  void dispose() {
    removeDeleteOverlay();

    super.dispose();
  }

  Future<void> fetchAllNoticies() async {
    final noticeList =
        await ref.read(noticeProvider.notifier).fetchAllNotices();
    int endPage = noticeList.length ~/ _itemsPerPage + 1;

    if (selectContractRegion.value!.subdistrictId == "") {
      // 마스터
      if (mounted) {
        setState(() {
          loadingFinished = true;
          _totalListLength = noticeList.length;
          _initialList = noticeList;
          _endPage = endPage;
        });
        _updateUserlistPerPage();
      }
    } else {
      // 지역 기관
      if (selectContractRegion.value!.contractCommunityId != "" &&
          selectContractRegion.value!.contractCommunityId != null) {
        final filterList = noticeList
            .where((e) =>
                e.userContractCommunityId ==
                selectContractRegion.value!.contractCommunityId)
            .toList();
        int endPage = filterList.length ~/ _itemsPerPage + 1;

        if (mounted) {
          setState(() {
            loadingFinished = true;
            _totalListLength = noticeList.length;
            _initialList = noticeList;
            _endPage = endPage;
          });
          _updateUserlistPerPage();
        }
      } else {
        // 지역 전체
        final filterList = noticeList
            .where((e) =>
                e.userContractCommunityId == null ||
                e.userContractCommunityId == "")
            .toList();
        int endPage = filterList.length ~/ _itemsPerPage + 1;

        if (mounted) {
          setState(() {
            loadingFinished = true;
            _totalListLength = filterList.length;
            _initialList = noticeList;
            _endPage = endPage;
          });
          _updateUserlistPerPage();
        }
      }
    }

    setState(() {
      _currentPage = 0;
      _pageIndication = 0;
    });
  }

  void _editAdminSecret(String diaryId) async {
    bool currentState = diaryId.split(":").last == "true";
    // 피드
    final newDiaryId = await ref
        .read(noticeProvider.notifier)
        .editFeedAdminSecret(diaryId, currentState);

    // 팝업
    PopupModel? popup = await ref.read(noticeRepo).checkPopup(newDiaryId);
    if (popup != null) {
      await ref
          .read(noticeRepo)
          .editPopupAdminSecret(popup.popupId!, currentState);
    }

    // 새로고침
    await fetchAllNoticies();
  }

  void _updateUserlistPerPage() {
    int startPage = _currentPage * _itemsPerPage;
    int endPage = startPage + _itemsPerPage > _initialList.length
        ? _initialList.length
        : startPage + _itemsPerPage;

    setState(() {
      _noticeList = _initialList.sublist(startPage, endPage);
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

  Future<void> _deleteFeedNotification(DiaryModel model) async {
    try {
      await ref.read(noticeRepo).deleteFeedNotification(model.diaryId);
      if (!mounted) return;
      removeDeleteOverlay();
      showTopCompletingSnackBar(context, "성공적으로 영상을 삭제하였습니다.");
      setState(() {
        _noticeList.removeWhere((user) => user.diaryId == model.diaryId);
      });
    } catch (e) {
      // ignore: avoid_print
      print("_deleteFeedNotification -> $e");
    }
  }

  void showDeleteOverlay(BuildContext context, DiaryModel model) async {
    removeDeleteOverlay();

    overlayEntry = OverlayEntry(builder: (context) {
      return deleteTitleOverlay(model.todayDiary, removeDeleteOverlay,
          () => _deleteFeedNotification(model));
    });
    Overlay.of(context, debugRequiredFor: widget, rootOverlay: true)
        .insert(overlayEntry!);
  }

  void removeDeleteOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return DefaultScreen(
      menu: menuList[3],
      child: !loadingFinished
          ? const SkeletonLoadingScreen()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderWithButton(
                    buttonAction: () =>
                        uploadNotification(context, size.width, size.height),
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
                                "번호",
                                style: contentTextStyle,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Container(
                            decoration: BoxDecoration(
                                color: const Color(0xFFE9EDF9),
                                border: Border.all(
                                  width: 1,
                                  color: const Color(0xFFF3F6FD),
                                )),
                            child: Center(
                              child: Text(
                                "공지",
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
                                )),
                            child: Center(
                              child: Text(
                                "이미지",
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
                                )),
                            child: Center(
                              child: Text(
                                "작성일",
                                style: contentTextStyle,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
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
                                )),
                            child: Center(
                              child: Text(
                                "공개 여부",
                                style: contentTextStyle,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                                color: const Color(0xFFE9EDF9),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(16),
                                ),
                                border: Border.all(
                                  width: 2,
                                  color: const Color(0xFFF3F6FD),
                                )),
                            child: Container(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_noticeList.isNotEmpty)
                    for (int i = 0; i < _noticeList.length; i++)
                      Column(
                        children: [
                          SizedBox(
                            height: _tabHeight,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: SelectableText(
                                    "${_currentPage * _itemsPerPage + 1 + i}",
                                    style: contentTextStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 7,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: Text(
                                      _noticeList[i]
                                          .todayDiary
                                          .trim()
                                          .replaceAll("\n", " "),
                                      style: contentTextStyle,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: _noticeList[i].images!.isNotEmpty
                                      ? Center(
                                          child: Image.network(
                                            _noticeList[i].images![0],
                                            fit: BoxFit.cover,
                                            height: 35,
                                          ),
                                        )
                                      : Container(),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: SelectableText(
                                    secondsToStringLine(
                                        _noticeList[i].createdAt),
                                    style: contentTextStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () => _editAdminSecret(
                                          _noticeList[i].diaryId),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _noticeList[i]
                                                      .diaryId
                                                      .split(":")
                                                      .last !=
                                                  "true"
                                              ? const PublicButton()
                                              : const PrivateButton(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: () => editNotification(
                                                  context,
                                                  size,
                                                  _noticeList[i]),
                                              child: const EditButton(),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Gaps.v3,
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: () => showDeleteOverlay(
                                                  context, _noticeList[i]),
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
                  )
                ],
              ),
            ),
    );
  }
}

class DeleteButton extends StatelessWidget {
  const DeleteButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: InjicareColor().gray20,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 7,
          vertical: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorFiltered(
              colorFilter:
                  ColorFilter.mode(InjicareColor().primary50, BlendMode.srcIn),
              child: SvgPicture.asset(
                "assets/svg/delete-icon.svg",
                width: 14,
              ),
            ),
            Gaps.h2,
            Text(
              "삭제하기",
              style: InjicareFont()
                  .label02
                  .copyWith(color: InjicareColor().primary50),
            )
          ],
        ),
      ),
    );
  }
}

class EditButton extends StatelessWidget {
  const EditButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: InjicareColor().secondary20,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 7,
          vertical: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                  InjicareColor().secondary50, BlendMode.srcIn),
              child: SvgPicture.asset(
                "assets/svg/edit-icon.svg",
                width: 14,
              ),
            ),
            Gaps.h2,
            Text(
              "수정하기",
              style: InjicareFont()
                  .label02
                  .copyWith(color: InjicareColor().secondary50),
            )
          ],
        ),
      ),
    );
  }
}

class PrivateButton extends StatelessWidget {
  const PrivateButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      decoration: BoxDecoration(
        color: InjicareColor().gray20,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "비공개",
              style: InjicareFont()
                  .label02
                  .copyWith(color: InjicareColor().gray90),
            )
          ],
        ),
      ),
    );
  }
}

class PublicButton extends StatelessWidget {
  const PublicButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      decoration: BoxDecoration(
        color: InjicareColor().secondary50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "공개",
              style: InjicareFont().label02.copyWith(color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}

class HeaderWithButton extends StatelessWidget {
  final Function() buttonAction;
  final String buttonText;
  final int listCount;
  final String svgName;
  const HeaderWithButton({
    super.key,
    required this.buttonAction,
    required this.buttonText,
    required this.listCount,
    this.svgName = "plus",
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gaps.v10,
        Row(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: buttonAction,
                child: Container(
                  height: searchHeight,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: InjicareColor().secondary50,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      children: [
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(
                              InjicareColor().secondary50, BlendMode.srcIn),
                          child: SvgPicture.asset(
                            "assets/svg/$svgName.svg",
                            width: 15,
                          ),
                        ),
                        Gaps.h10,
                        Text(
                          buttonText,
                          style: InjicareFont().body03.copyWith(
                                color: InjicareColor().secondary50,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Gaps.v20,
        Text(
          "총 ${numberFormat(listCount)}개",
          style: InjicareFont().label03.copyWith(
                color: InjicareColor().gray70,
              ),
        ),
        Gaps.v10,
      ],
    );
  }
}

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/common/widgets/loading_widget.dart';
import 'package:onldocc_admin/common/widgets/report_button.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/notice/models/popup_model.dart';
import 'package:onldocc_admin/features/notice/repo/notice_repo.dart';
import 'package:onldocc_admin/features/notice/view_models/notice_view_model.dart';
import 'package:onldocc_admin/features/notice/widgets/upload_notification_widget.dart';
import 'package:onldocc_admin/features/ranking/models/diary_model.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';

import '../../../constants/sizes.dart';

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

  List<DiaryModel> _noticeList = [];
  bool loadingFinished = false;

  final TextStyle _headerTextStyle = TextStyle(
    fontSize: Sizes.size12,
    fontWeight: FontWeight.w600,
    color: Palette().darkGray,
  );

  final TextStyle _contentTextStyle = TextStyle(
    fontSize: Sizes.size11,
    fontWeight: FontWeight.w500,
    color: Palette().darkGray,
  );

  void uploadNotification(
      BuildContext context, double totalWidth, double totalHeight) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        minWidth: totalWidth,
      ),
      builder: (context) {
        return UploadNotificationWidget(
          pcontext: context,
          refreshScreen: refreshScreen,
          edit: false,
        );
      },
    );
  }

  void editNotification(
    BuildContext context,
    Size size,
    DiaryModel diaryModel,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        minWidth: size.width,
      ),
      builder: (context) {
        return UploadNotificationWidget(
          pcontext: context,
          refreshScreen: refreshScreen,
          edit: true,
          notificationModel: diaryModel,
        ); // return EditNotificationWidget(
        //   context: context,
        //   size: size,
        //   diaryModel: diaryModel,
        //   refreshScreen: refreshScreen,
        // );
      },
    );
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
    super.dispose();
  }

  Future<void> fetchAllNoticies() async {
    final noticeList =
        await ref.read(noticeProvider.notifier).fetchAllNotices();

    if (selectContractRegion.value!.subdistrictId == "") {
      // 마스터
      if (mounted) {
        setState(() {
          loadingFinished = true;
          _noticeList = noticeList;
        });
      }
    } else {
      // 지역 기관
      if (selectContractRegion.value!.contractCommunityId != "" &&
          selectContractRegion.value!.contractCommunityId != null) {
        final filterDataList = noticeList
            .where((e) =>
                e.userContractCommunityId ==
                selectContractRegion.value!.contractCommunityId)
            .toList();
        if (mounted) {
          setState(() {
            loadingFinished = true;
            _noticeList = filterDataList;
          });
        }
      } else {
        // 지역 전체
        final filterDataList = noticeList
            .where((e) =>
                e.userContractCommunityId == null ||
                e.userContractCommunityId == "")
            .toList();
        if (mounted) {
          setState(() {
            loadingFinished = true;
            _noticeList = filterDataList;
          });
        }
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) => DefaultScreen(
            menu: menuList[3],
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: loadingFinished
                  ? Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ReportButton(
                              iconExists: false,
                              buttonText: "공지 올리기",
                              buttonColor: Palette().darkPurple,
                              action: () => uploadNotification(
                                  context, size.width, size.height),
                            ),
                          ],
                        ),
                        Gaps.v40,
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                Sizes.size10,
                              ),
                            ),
                            child: DataTable2(
                              isVerticalScrollBarVisible: false,
                              isHorizontalScrollBarVisible: false,
                              dataRowHeight: 80,
                              lmRatio: 3,
                              dividerThickness: 0.1,
                              horizontalMargin: 5,
                              headingRowDecoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Palette().lightGray,
                                    width: 0.1,
                                  ),
                                ),
                              ),
                              columns: [
                                DataColumn2(
                                  fixedWidth: 80,
                                  label: Center(
                                    child: SelectableText(
                                      "#",
                                      style: _headerTextStyle,
                                    ),
                                  ),
                                ),
                                DataColumn2(
                                  size: ColumnSize.L,
                                  label: Center(
                                    child: SelectableText(
                                      "공지",
                                      style: _headerTextStyle,
                                    ),
                                  ),
                                ),
                                DataColumn2(
                                  label: Center(
                                    child: SelectableText(
                                      "이미지",
                                      style: _headerTextStyle,
                                    ),
                                  ),
                                ),
                                DataColumn2(
                                  label: Center(
                                    child: SelectableText(
                                      "작성일",
                                      style: _headerTextStyle,
                                    ),
                                  ),
                                ),
                                DataColumn2(
                                  label: Center(
                                    child: SelectableText(
                                      "공개 여부",
                                      style: _headerTextStyle,
                                    ),
                                  ),
                                ),
                                DataColumn2(
                                  fixedWidth: 100,
                                  label: Center(
                                    child: SelectableText(
                                      "수정",
                                      style: _headerTextStyle,
                                    ),
                                  ),
                                ),
                              ],
                              rows: [
                                for (var i = 0; i < _noticeList.length; i++)
                                  DataRow2(
                                    cells: [
                                      DataCell(
                                        Center(
                                          child: SelectableText(
                                            "${i + 1}",
                                            style: _contentTextStyle,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SelectableText(
                                          _noticeList[i]
                                              .todayDiary
                                              .trim()
                                              .replaceAll("\n\n", "\n"),
                                          style: _contentTextStyle,
                                          maxLines: 2,
                                        ),
                                      ),
                                      DataCell(
                                        _noticeList[i].images!.isEmpty
                                            ? Center(
                                                child: SelectableText(
                                                  "",
                                                  style: _contentTextStyle,
                                                ),
                                              )
                                            : Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      Sizes.size10,
                                                    ),
                                                    clipBehavior: Clip.hardEdge,
                                                    child: Image.network(
                                                      _noticeList[i].images![0],
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: SelectableText(
                                            secondsToStringLine(
                                                _noticeList[i].createdAt),
                                            style: _contentTextStyle,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: () => _editAdminSecret(
                                                  _noticeList[i].diaryId),
                                              child: _noticeList[i]
                                                          .diaryId
                                                          .split(":")
                                                          .last ==
                                                      "true"
                                                  ? Text(
                                                      "비공개",
                                                      style: _contentTextStyle
                                                          .copyWith(
                                                        color:
                                                            Palette().darkBlue,
                                                      ),
                                                    )
                                                  : Container(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Palette().darkBlue,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 8,
                                                          vertical: 2,
                                                        ),
                                                        child: Text(
                                                          "공개",
                                                          style:
                                                              _contentTextStyle
                                                                  .copyWith(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: () => editNotification(
                                                  context,
                                                  size,
                                                  _noticeList[i]),
                                              child: Icon(
                                                Icons.create,
                                                size: Sizes.size16,
                                                color: Palette().darkGray,
                                              ),
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
                    )
                  : loadingWidget(context),
            ),
          ),
        )
      ],
    );
  }
}

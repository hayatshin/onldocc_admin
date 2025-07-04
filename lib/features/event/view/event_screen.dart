import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/view/skeleton_loading_screen.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/features/event/models/event_model.dart';
import 'package:onldocc_admin/features/event/view_models/event_view_model.dart';
import 'package:onldocc_admin/features/event/widgets/upload-event/upload_event_widget.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/notice/views/notice_screen.dart';
import 'package:onldocc_admin/palette.dart';

import '../../../constants/sizes.dart';

class EventScreen extends ConsumerStatefulWidget {
  static const routeURL = "/event";
  static const routeName = "event";
  const EventScreen({super.key});

  @override
  ConsumerState<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends ConsumerState<EventScreen> {
  List<EventModel> _initialList = [];
  List<EventModel> _eventList = [];
  bool loadingFinished = false;

  Map<String, dynamic> addedEventData = {};

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final double _tabHeight = 75;

  static const int _itemsPerPage = 10;
  int _currentPage = 0;
  int _pageIndication = 0;
  int _totalListLength = 0;
  int _endPage = 0;

  @override
  void initState() {
    super.initState();
    if (selectContractRegion.value != null) {
      getUserEvents();
    }

    selectContractRegion.addListener(() async {
      if (mounted) {
        await getUserEvents();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void refreshScreen() {
    getUserEvents();
  }

  void addEventTap(BuildContext context, Size size) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      constraints: BoxConstraints(
        minWidth: size.width,
      ),
      builder: (context) {
        return UploadEventWidget(
          pcontext: context,
          size: size,
          refreshScreen: refreshScreen,
          edit: false,
        );
      },
    );
  }

  void editEventTap(BuildContext context, Size size, EventModel eventModel) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      constraints: BoxConstraints(
        minWidth: size.width,
      ),
      builder: (context) {
        return UploadEventWidget(
          pcontext: context,
          size: size,
          refreshScreen: refreshScreen,
          edit: true,
          eventModel: eventModel,
        );
        // return EditEventWidget(
        //   context: context,
        //   size: size,
        //   refreshScreen: refreshScreen,
        //   eventModel: eventModel,
        // );
      },
    );
  }

  Future<void> getUserEvents() async {
    List<EventModel> eventList =
        await ref.read(eventProvider.notifier).getUserEvents();
    int startPage = _currentPage * _itemsPerPage + 1;
    int endPage = eventList.length ~/ _itemsPerPage + 1;

    if (selectContractRegion.value!.subdistrictId == "") {
      if (mounted) {
        setState(() {
          loadingFinished = true;
          _totalListLength = eventList.length;
          _initialList = eventList;
          _endPage = endPage;
        });
        _updateUserlistPerPage();
      }
    } else {
      if (selectContractRegion.value!.contractCommunityId != "" &&
          selectContractRegion.value!.contractCommunityId != null) {
        final filterList = eventList
            .where((e) =>
                e.contractCommunityId ==
                selectContractRegion.value!.contractCommunityId)
            .toList();
        int endPageItems = startPage + _itemsPerPage > filterList.length
            ? filterList.length
            : startPage + _itemsPerPage;
        if (mounted) {
          setState(() {
            loadingFinished = true;
            _eventList = filterList.sublist(startPage, endPageItems);
            _totalListLength = filterList.length;
            _endPage = endPage;
          });
        }
      } else {
        final filterList = eventList
            .where((e) =>
                e.contractCommunityId == null || e.contractCommunityId == "")
            .toList();
        int endPageItems = startPage + _itemsPerPage > filterList.length
            ? filterList.length
            : startPage + _itemsPerPage;
        if (mounted) {
          setState(() {
            loadingFinished = true;
            _eventList = filterList.sublist(startPage, endPageItems);
            _totalListLength = filterList.length;
            _endPage = endPage;
          });
        }
      }
    }
  }

  void goDetailEvent(EventModel eventModel) {
    context.go("/event/${eventModel.eventType}/${eventModel.eventId}",
        extra: eventModel);
  }

  void _updateUserlistPerPage() {
    int startPage = _currentPage * _itemsPerPage;
    int endPage = startPage + _itemsPerPage > _initialList.length
        ? _initialList.length
        : startPage + _itemsPerPage;

    setState(() {
      _eventList = _initialList.sublist(startPage, endPage);
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return DefaultScreen(
      menu: menuList[4],
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: !loadingFinished
            ? const SkeletonLoadingScreen()
            : SingleChildScrollView(
                child: Column(
                  children: [
                    HeaderWithButton(
                      buttonAction: () => addEventTap(context, size),
                      buttonText: "행사 올리기",
                      listCount: 0,
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
                    // if (_eventList.isNotEmpty)
                    //   for (int i = 0; i < _eventList.length; i++)
                    //     Column(
                    //       children: [
                    //         SizedBox(
                    //           height: _tabHeight,
                    //           child: Row(
                    //             children: [
                    //               Expanded(
                    //                 flex: 1,
                    //                 child: SelectableText(
                    //                   "${_currentPage * _itemsPerPage + 1 + i}",
                    //                   style: contentTextStyle,
                    //                   textAlign: TextAlign.center,
                    //                 ),
                    //               ),
                    //               Expanded(
                    //                 flex: 7,
                    //                 child: Padding(
                    //                   padding: const EdgeInsets.symmetric(
                    //                       horizontal: 5),
                    //                   child: Text(
                    //                     _noticeList[i]
                    //                         .todayDiary
                    //                         .trim()
                    //                         .replaceAll("\n", " "),
                    //                     style: contentTextStyle,
                    //                     textAlign: TextAlign.center,
                    //                     maxLines: 1,
                    //                     overflow: TextOverflow.ellipsis,
                    //                   ),
                    //                 ),
                    //               ),
                    //               Expanded(
                    //                 flex: 1,
                    //                 child: _noticeList[i].images!.isNotEmpty
                    //                     ? Center(
                    //                         child: Image.network(
                    //                           _noticeList[i].images![0],
                    //                           fit: BoxFit.cover,
                    //                           height: 35,
                    //                         ),
                    //                       )
                    //                     : Container(),
                    //               ),
                    //               Expanded(
                    //                 flex: 1,
                    //                 child: SelectableText(
                    //                   secondsToStringLine(
                    //                       _noticeList[i].createdAt),
                    //                   style: contentTextStyle,
                    //                   textAlign: TextAlign.center,
                    //                 ),
                    //               ),
                    //               Expanded(
                    //                 flex: 1,
                    //                 child: MouseRegion(
                    //                   cursor: SystemMouseCursors.click,
                    //                   child: GestureDetector(
                    //                     onTap: () => _editAdminSecret(
                    //                         _noticeList[i].diaryId),
                    //                     child: Row(
                    //                       mainAxisAlignment:
                    //                           MainAxisAlignment.center,
                    //                       children: [
                    //                         MouseRegion(
                    //                           cursor: SystemMouseCursors.click,
                    //                           child: _noticeList[i]
                    //                                       .diaryId
                    //                                       .split(":")
                    //                                       .last !=
                    //                                   "true"
                    //                               ? Container(
                    //                                   width: 50,
                    //                                   decoration: BoxDecoration(
                    //                                     color: InjicareColor()
                    //                                         .secondary50,
                    //                                     borderRadius:
                    //                                         BorderRadius
                    //                                             .circular(6),
                    //                                   ),
                    //                                   child: Padding(
                    //                                     padding:
                    //                                         const EdgeInsets
                    //                                             .symmetric(
                    //                                       vertical: 5,
                    //                                     ),
                    //                                     child: Row(
                    //                                       mainAxisAlignment:
                    //                                           MainAxisAlignment
                    //                                               .center,
                    //                                       mainAxisSize:
                    //                                           MainAxisSize.min,
                    //                                       children: [
                    //                                         Text(
                    //                                           "공개",
                    //                                           style: InjicareFont()
                    //                                               .label02
                    //                                               .copyWith(
                    //                                                   color: Colors
                    //                                                       .white),
                    //                                         )
                    //                                       ],
                    //                                     ),
                    //                                   ),
                    //                                 )
                    //                               : Container(
                    //                                   width: 50,
                    //                                   decoration: BoxDecoration(
                    //                                     color: InjicareColor()
                    //                                         .gray20,
                    //                                     borderRadius:
                    //                                         BorderRadius
                    //                                             .circular(6),
                    //                                   ),
                    //                                   child: Padding(
                    //                                     padding:
                    //                                         const EdgeInsets
                    //                                             .symmetric(
                    //                                       vertical: 5,
                    //                                     ),
                    //                                     child: Row(
                    //                                       mainAxisAlignment:
                    //                                           MainAxisAlignment
                    //                                               .center,
                    //                                       mainAxisSize:
                    //                                           MainAxisSize.min,
                    //                                       children: [
                    //                                         Text(
                    //                                           "비공개",
                    //                                           style: InjicareFont()
                    //                                               .label02
                    //                                               .copyWith(
                    //                                                   color: InjicareColor()
                    //                                                       .gray90),
                    //                                         )
                    //                                       ],
                    //                                     ),
                    //                                   ),
                    //                                 ),
                    //                         ),
                    //                       ],
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ),
                    //               Expanded(
                    //                 flex: 1,
                    //                 child: Column(
                    //                   mainAxisAlignment:
                    //                       MainAxisAlignment.center,
                    //                   children: [
                    //                     Row(
                    //                       mainAxisAlignment:
                    //                           MainAxisAlignment.center,
                    //                       children: [
                    //                         MouseRegion(
                    //                           cursor: SystemMouseCursors.click,
                    //                           child: GestureDetector(
                    //                             onTap: () => editNotification(
                    //                                 context,
                    //                                 size,
                    //                                 _noticeList[i]),
                    //                             child: Container(
                    //                               decoration: BoxDecoration(
                    //                                 color: InjicareColor()
                    //                                     .secondary20,
                    //                                 borderRadius:
                    //                                     BorderRadius.circular(
                    //                                         6),
                    //                               ),
                    //                               child: Padding(
                    //                                 padding: const EdgeInsets
                    //                                     .symmetric(
                    //                                   horizontal: 7,
                    //                                   vertical: 5,
                    //                                 ),
                    //                                 child: Row(
                    //                                   mainAxisAlignment:
                    //                                       MainAxisAlignment
                    //                                           .center,
                    //                                   mainAxisSize:
                    //                                       MainAxisSize.min,
                    //                                   children: [
                    //                                     ColorFiltered(
                    //                                       colorFilter:
                    //                                           ColorFilter.mode(
                    //                                               InjicareColor()
                    //                                                   .secondary50,
                    //                                               BlendMode
                    //                                                   .srcIn),
                    //                                       child:
                    //                                           SvgPicture.asset(
                    //                                         "assets/svg/edit-icon.svg",
                    //                                         width: 14,
                    //                                       ),
                    //                                     ),
                    //                                     Gaps.h2,
                    //                                     Text(
                    //                                       "수정하기",
                    //                                       style: InjicareFont()
                    //                                           .label02
                    //                                           .copyWith(
                    //                                               color: InjicareColor()
                    //                                                   .secondary50),
                    //                                     )
                    //                                   ],
                    //                                 ),
                    //                               ),
                    //                             ),
                    //                           ),
                    //                         ),
                    //                       ],
                    //                     ),
                    //                     Gaps.v3,
                    //                     Row(
                    //                       mainAxisAlignment:
                    //                           MainAxisAlignment.center,
                    //                       children: [
                    //                         MouseRegion(
                    //                           cursor: SystemMouseCursors.click,
                    //                           child: GestureDetector(
                    //                             onTap: () => showDeleteOverlay(
                    //                                 context, _noticeList[i]),
                    //                             child: Container(
                    //                               decoration: BoxDecoration(
                    //                                 color:
                    //                                     InjicareColor().gray20,
                    //                                 borderRadius:
                    //                                     BorderRadius.circular(
                    //                                         6),
                    //                               ),
                    //                               child: Padding(
                    //                                 padding: const EdgeInsets
                    //                                     .symmetric(
                    //                                   horizontal: 7,
                    //                                   vertical: 5,
                    //                                 ),
                    //                                 child: Row(
                    //                                   mainAxisAlignment:
                    //                                       MainAxisAlignment
                    //                                           .center,
                    //                                   mainAxisSize:
                    //                                       MainAxisSize.min,
                    //                                   children: [
                    //                                     ColorFiltered(
                    //                                       colorFilter:
                    //                                           ColorFilter.mode(
                    //                                               InjicareColor()
                    //                                                   .primary50,
                    //                                               BlendMode
                    //                                                   .srcIn),
                    //                                       child:
                    //                                           SvgPicture.asset(
                    //                                         "assets/svg/delete-icon.svg",
                    //                                         width: 14,
                    //                                       ),
                    //                                     ),
                    //                                     Gaps.h2,
                    //                                     Text(
                    //                                       "삭제하기",
                    //                                       style: InjicareFont()
                    //                                           .label02
                    //                                           .copyWith(
                    //                                               color: InjicareColor()
                    //                                                   .primary50),
                    //                                     )
                    //                                   ],
                    //                                 ),
                    //                               ),
                    //                             ),
                    //                           ),
                    //                         ),
                    //                       ],
                    //                     ),
                    //                   ],
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //         Row(
                    //           children: [
                    //             Expanded(
                    //               child: Container(
                    //                 height: 1,
                    //                 color: InjicareColor().gray30,
                    //               ),
                    //             )
                    //           ],
                    //         )
                    //       ],
                    //     ),
                    // Gaps.v40,
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     MouseRegion(
                    //       cursor: SystemMouseCursors.click,
                    //       child: GestureDetector(
                    //         onTap: _previousPage,
                    //         child: ColorFiltered(
                    //           colorFilter: ColorFilter.mode(
                    //               _pageIndication == 0
                    //                   ? InjicareColor().gray50
                    //                   : InjicareColor().gray100,
                    //               BlendMode.srcIn),
                    //           child: SvgPicture.asset(
                    //             "assets/svg/chevron-left.svg",
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //     Gaps.h10,
                    //     for (int s = (_pageIndication * 5 + 1);
                    //         s <
                    //             (s >= _endPage + 1
                    //                 ? _endPage + 1
                    //                 : (_pageIndication * 5 + 1) + 5);
                    //         s++)
                    //       Row(
                    //         mainAxisSize: MainAxisSize.min,
                    //         children: [
                    //           Gaps.h10,
                    //           MouseRegion(
                    //             cursor: SystemMouseCursors.click,
                    //             child: GestureDetector(
                    //               onTap: () => _changePage(s),
                    //               child: Text(
                    //                 "$s",
                    //                 style: InjicareFont().body07.copyWith(
                    //                     color: _currentPage + 1 == s
                    //                         ? InjicareColor().gray100
                    //                         : InjicareColor().gray60,
                    //                     fontWeight: _currentPage + 1 == s
                    //                         ? FontWeight.w900
                    //                         : FontWeight.w400),
                    //               ),
                    //             ),
                    //           ),
                    //           Gaps.h10,
                    //         ],
                    //       ),
                    //     Gaps.h10,
                    //     MouseRegion(
                    //       cursor: SystemMouseCursors.click,
                    //       child: GestureDetector(
                    //         onTap: _nextPage,
                    //         child: ColorFiltered(
                    //           colorFilter: ColorFilter.mode(
                    //               _pageIndication + 5 > _endPage
                    //                   ? InjicareColor().gray50
                    //                   : InjicareColor().gray100,
                    //               BlendMode.srcIn),
                    //           child: SvgPicture.asset(
                    //             "assets/svg/chevron-right.svg",
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // )
                    // Expanded(
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       color: Colors.white,
                    //       borderRadius: BorderRadius.circular(
                    //         Sizes.size10,
                    //       ),
                    //     ),
                    //     child: DataTable2(
                    //       isVerticalScrollBarVisible: false,
                    //       isHorizontalScrollBarVisible: false,
                    //       dataRowHeight: 80,
                    //       lmRatio: 2,
                    //       dividerThickness: 0.1,
                    //       horizontalMargin: 5,
                    //       headingRowDecoration: BoxDecoration(
                    //         border: Border(
                    //           bottom: BorderSide(
                    //             color: Palette().lightGray,
                    //             width: 0.1,
                    //           ),
                    //         ),
                    //       ),
                    //       columns: [
                    //         DataColumn2(
                    //           fixedWidth: 70,
                    //           label: Center(
                    //             child: SelectableText(
                    //               "#",
                    //               style: headerTextStyle,
                    //             ),
                    //           ),
                    //         ),
                    //         DataColumn2(
                    //           size: ColumnSize.L,
                    //           label: Center(
                    //             child: SelectableText(
                    //               "행사",
                    //               style: headerTextStyle,
                    //             ),
                    //           ),
                    //         ),
                    //         DataColumn2(
                    //           label: Center(
                    //             child: SelectableText(
                    //               "주최 기관",
                    //               style: headerTextStyle,
                    //             ),
                    //           ),
                    //         ),
                    //         DataColumn2(
                    //           // size: ColumnSize.L,
                    //           label: Center(
                    //             child: SelectableText(
                    //               "시작일",
                    //               style: headerTextStyle,
                    //             ),
                    //           ),
                    //         ),
                    //         DataColumn2(
                    //           // size: ColumnSize.L,
                    //           label: Center(
                    //             child: SelectableText(
                    //               "종료일",
                    //               style: headerTextStyle,
                    //             ),
                    //           ),
                    //         ),
                    //         DataColumn2(
                    //           fixedWidth: 100,
                    //           label: Center(
                    //             child: SelectableText(
                    //               "상태",
                    //               style: headerTextStyle,
                    //             ),
                    //           ),
                    //         ),
                    //         DataColumn2(
                    //           label: Center(
                    //             child: SelectableText(
                    //               "공개 여부",
                    //               style: headerTextStyle,
                    //             ),
                    //           ),
                    //         ),
                    //         DataColumn2(
                    //           fixedWidth: 80,
                    //           label: Center(
                    //             child: SelectableText(
                    //               "수정",
                    //               style: headerTextStyle,
                    //             ),
                    //           ),
                    //         ),
                    //         DataColumn2(
                    //           fixedWidth: 80,
                    //           label: Center(
                    //             child: SelectableText(
                    //               "선택",
                    //               style: headerTextStyle,
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //       rows: [
                    //         for (var i = 0; i < _eventList.length; i++)
                    //           DataRow2(
                    //             cells: [
                    //               DataCell(
                    //                 Center(
                    //                   child: SelectableText(
                    //                     "${i + 1}",
                    //                     style: contentTextStyle,
                    //                   ),
                    //                 ),
                    //               ),
                    //               DataCell(
                    //                 SelectableText(
                    //                   _eventList[i].title,
                    //                   style: contentTextStyle,
                    //                   maxLines: 1,
                    //                   // overflow: TextOverflow.ellipsis,
                    //                 ),
                    //               ),
                    //               DataCell(
                    //                 Center(
                    //                   child: SelectableText(
                    //                     _eventList[i]
                    //                         .orgName
                    //                         .toString()
                    //                         .split(" ")
                    //                         .last,
                    //                     style: contentTextStyle,
                    //                     maxLines: 1,
                    //                     // overflow: TextOverflow.ellipsis,
                    //                   ),
                    //                 ),
                    //               ),
                    //               DataCell(
                    //                 Center(
                    //                   child: SelectableText(
                    //                     _eventList[i].startDate,
                    //                     style: contentTextStyle,
                    //                     maxLines: 1,
                    //                   ),
                    //                 ),
                    //               ),
                    //               DataCell(
                    //                 Center(
                    //                   child: SelectableText(
                    //                     _eventList[i].endDate,
                    //                     style: contentTextStyle,
                    //                     maxLines: 1,
                    //                   ),
                    //                 ),
                    //               ),
                    //               DataCell(
                    //                 Center(
                    //                   child: SelectableText(
                    //                     _eventList[i].state ?? "-",
                    //                     style: contentTextStyle,
                    //                     maxLines: 1,
                    //                   ),
                    //                 ),
                    //               ),
                    //               DataCell(
                    //                 Center(
                    //                   child: MouseRegion(
                    //                     cursor: SystemMouseCursors.click,
                    //                     child: GestureDetector(
                    //                       onTap: () async {
                    //                         await ref
                    //                             .read(eventRepo)
                    //                             .editEventAdminSecret(
                    //                                 _eventList[i].eventId,
                    //                                 _eventList[i].adminSecret);
                    //                         await getUserEvents();
                    //                       },
                    //                       child: _eventList[i].adminSecret
                    //                           ? Text(
                    //                               "비공개",
                    //                               style:
                    //                                   contentTextStyle.copyWith(
                    //                                 color: Palette().darkBlue,
                    //                               ),
                    //                             )
                    //                           : Container(
                    //                               decoration: BoxDecoration(
                    //                                 color: Palette().darkBlue,
                    //                                 borderRadius:
                    //                                     BorderRadius.circular(5),
                    //                               ),
                    //                               child: Padding(
                    //                                 padding: const EdgeInsets
                    //                                     .symmetric(
                    //                                   horizontal: 8,
                    //                                   vertical: 2,
                    //                                 ),
                    //                                 child: Text(
                    //                                   "공개",
                    //                                   style: contentTextStyle
                    //                                       .copyWith(
                    //                                     color: Colors.white,
                    //                                   ),
                    //                                 ),
                    //                               ),
                    //                             ),
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ),
                    //               DataCell(
                    //                 Center(
                    //                   child: MouseRegion(
                    //                     cursor: SystemMouseCursors.click,
                    //                     child: GestureDetector(
                    //                       onTap: () => editEventTap(
                    //                           context, size, _eventList[i]),
                    //                       child: Icon(
                    //                         Icons.create,
                    //                         size: Sizes.size16,
                    //                         color: Palette().darkGray,
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ),
                    //               DataCell(
                    //                 Center(
                    //                   child: MouseRegion(
                    //                     cursor: SystemMouseCursors.click,
                    //                     child: GestureDetector(
                    //                       onTap: () =>
                    //                           goDetailEvent(_eventList[i]),
                    //                       child: Icon(
                    //                         Icons.arrow_forward_ios,
                    //                         size: Sizes.size16,
                    //                         color: Palette().darkGray,
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
      ),
    );
  }
}

const double fieldHeight = 45;

final TextStyle headerTextStyle = TextStyle(
  fontSize: Sizes.size12,
  fontWeight: FontWeight.w600,
  color: Palette().darkGray,
);

final TextStyle headerInfoTextStyle = TextStyle(
  fontSize: Sizes.size11,
  fontWeight: FontWeight.w300,
  color: Palette().normalGray,
);

final TextStyle contentTextStyle = TextStyle(
  fontSize: Sizes.size14,
  fontWeight: FontWeight.w500,
  color: Palette().darkGray,
);

final TextStyle fieldHeaderTextStyle = TextStyle(
  fontSize: Sizes.size13,
  fontWeight: FontWeight.w700,
  color: Palette().darkBlue,
);

final TextStyle fieldLimitTextStyle = TextStyle(
  fontSize: Sizes.size12,
  fontWeight: FontWeight.w600,
  color: Palette().normalGray,
);
const TextStyle fieldLimitChangeTextStyle = TextStyle(
  fontSize: Sizes.size12,
  fontWeight: FontWeight.w600,
  color: Color(0xFFFF2D78),
);
final TextStyle fieldContentTextStyle = TextStyle(
  fontSize: Sizes.size12,
  fontWeight: FontWeight.w400,
  color: Palette().darkGray,
);

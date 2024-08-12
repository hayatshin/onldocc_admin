import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/common/widgets/loading_widget.dart';
import 'package:onldocc_admin/common/widgets/report_button.dart';
import 'package:onldocc_admin/features/event/models/event_model.dart';
import 'package:onldocc_admin/features/event/repo/event_repo.dart';
import 'package:onldocc_admin/features/event/view_models/event_view_model.dart';
import 'package:onldocc_admin/features/event/widgets/upload-event/upload_event_widget.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/palette.dart';

import '../../../constants/gaps.dart';
import '../../../constants/sizes.dart';

class EventScreen extends ConsumerStatefulWidget {
  static const routeURL = "/event";
  static const routeName = "event";
  const EventScreen({super.key});

  @override
  ConsumerState<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends ConsumerState<EventScreen> {
  List<EventModel> _eventList = [];
  bool loadingFinished = false;

  Map<String, dynamic> addedEventData = {};

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
    List<EventModel> dbeventList =
        await ref.read(eventProvider.notifier).getUserEvents();

    if (selectContractRegion.value!.subdistrictId == "") {
      if (mounted) {
        setState(() {
          loadingFinished = true;
          _eventList = dbeventList;
        });
      }
    } else {
      if (selectContractRegion.value!.contractCommunityId != "" &&
          selectContractRegion.value!.contractCommunityId != null) {
        final filterDataList = dbeventList
            .where((e) =>
                e.contractCommunityId ==
                selectContractRegion.value!.contractCommunityId)
            .toList();
        if (mounted) {
          setState(() {
            loadingFinished = true;
            _eventList = filterDataList;
          });
        }
      } else {
        final filterDataList = dbeventList
            .where((e) =>
                e.contractCommunityId == null || e.contractCommunityId == "")
            .toList();
        if (mounted) {
          setState(() {
            loadingFinished = true;
            _eventList = filterDataList;
          });
        }
      }
    }
  }

  void goDetailEvent(EventModel eventModel) {
    context.go("/event/${eventModel.eventId}", extra: eventModel);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) => DefaultScreen(
            menu: menuList[4],
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
                              buttonText: "행사 올리기",
                              buttonColor: Palette().darkPurple,
                              action: () => addEventTap(context, size),
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
                              lmRatio: 2,
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
                                    child: Text(
                                      "#",
                                      style: headerTextStyle,
                                    ),
                                  ),
                                ),
                                DataColumn2(
                                  size: ColumnSize.L,
                                  label: Center(
                                    child: Text(
                                      "행사",
                                      style: headerTextStyle,
                                    ),
                                  ),
                                ),
                                DataColumn2(
                                  label: Center(
                                    child: Text(
                                      "주최 기관",
                                      style: headerTextStyle,
                                    ),
                                  ),
                                ),
                                DataColumn2(
                                  size: ColumnSize.L,
                                  label: Center(
                                    child: Text(
                                      "시작일",
                                      style: headerTextStyle,
                                    ),
                                  ),
                                ),
                                DataColumn2(
                                  size: ColumnSize.L,
                                  label: Center(
                                    child: Text(
                                      "종료일",
                                      style: headerTextStyle,
                                    ),
                                  ),
                                ),
                                DataColumn2(
                                  fixedWidth: 100,
                                  label: Center(
                                    child: Text(
                                      "상태",
                                      style: headerTextStyle,
                                    ),
                                  ),
                                ),
                                DataColumn2(
                                  label: Center(
                                    child: Text(
                                      "공개 여부",
                                      style: headerTextStyle,
                                    ),
                                  ),
                                ),
                                DataColumn2(
                                  fixedWidth: 80,
                                  label: Center(
                                    child: Text(
                                      "수정",
                                      style: headerTextStyle,
                                    ),
                                  ),
                                ),
                                DataColumn2(
                                  fixedWidth: 80,
                                  label: Center(
                                    child: Text(
                                      "선택",
                                      style: headerTextStyle,
                                    ),
                                  ),
                                ),
                              ],
                              rows: [
                                for (var i = 0; i < _eventList.length; i++)
                                  DataRow2(
                                    cells: [
                                      DataCell(
                                        Center(
                                          child: Text(
                                            "${i + 1}",
                                            style: contentTextStyle,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          _eventList[i].title,
                                          style: contentTextStyle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: Text(
                                            _eventList[i]
                                                .orgName
                                                .toString()
                                                .split(" ")
                                                .last,
                                            style: contentTextStyle,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: Text(
                                            _eventList[i].startDate,
                                            style: contentTextStyle,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: Text(
                                            _eventList[i].endDate,
                                            style: contentTextStyle,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: Text(
                                            _eventList[i].state ?? "-",
                                            style: contentTextStyle,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: () async {
                                                await ref
                                                    .read(eventRepo)
                                                    .editEventAdminSecret(
                                                        _eventList[i].eventId,
                                                        _eventList[i]
                                                            .adminSecret);
                                                await getUserEvents();
                                              },
                                              child: _eventList[i].adminSecret
                                                  ? Text(
                                                      "비공개",
                                                      style: contentTextStyle
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
                                                              contentTextStyle
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
                                              onTap: () => editEventTap(
                                                  context, size, _eventList[i]),
                                              child: Icon(
                                                Icons.create,
                                                size: Sizes.size16,
                                                color: Palette().darkGray,
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
                                              onTap: () =>
                                                  goDetailEvent(_eventList[i]),
                                              child: Icon(
                                                Icons.arrow_forward_ios,
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

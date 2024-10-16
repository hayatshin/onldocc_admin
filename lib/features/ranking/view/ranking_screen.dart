import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/models/path_extra.dart';
import 'package:onldocc_admin/common/view/search_csv.dart';
import 'package:onldocc_admin/common/view/skeleton_loading_screen.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/common/widgets/period_button.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/ranking/view_models/ranking_view_model.dart';
import 'package:onldocc_admin/features/users/view_models/user_view_model.dart';
import 'package:onldocc_admin/injicare_font.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../users/models/user_model.dart';

class RankingScreen extends ConsumerStatefulWidget {
  static const routeURL = "/ranking";
  static const routeName = "ranking";
  const RankingScreen({super.key});

  @override
  ConsumerState<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends ConsumerState<RankingScreen> {
  List<UserModel?> _userDataList = [];
  List<UserModel?> _initialPointList = [];

  final List<String> _userListHeader = [
    "#",
    "이름",
    "핸드폰 번호",
    "종합",
    "걸음수",
    "일기",
    "댓글",
  ];

  bool _loadingFinished = false;
  int _sortColumnIndex = 2;

  String sortOder = "totalPoint";

  final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();
  OverlayEntry? overlayEntry;

  final _scrollController = ScrollController();
  bool _filtered = false;
  int _pageCount = 0;
  final int _offset = 20;
  int _rowCount = 0;

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

  DateRange? _selectedDateRange = DateRange(
    getThisWeekMonday(),
    DateTime.now(),
  );

  @override
  void initState() {
    super.initState();

    if (selectContractRegion.value != null) {
      _getScoreList(_selectedDateRange);
    }

    selectContractRegion.addListener(() async {
      if (mounted) {
        setState(() {
          _loadingFinished = false;
        });
        await ref
            .read(userProvider.notifier)
            .initializeUserList(selectContractRegion.value!.subdistrictId);
        await _getScoreList(_selectedDateRange);
      }
    });

    _scrollController.addListener(_onDetectScroll);
  }

  @override
  void dispose() {
    _removePeriodCalender();
    _scrollController.removeListener(_onDetectScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onDetectScroll() {
    if (_filtered) return;
    if (_scrollController.position.atEdge) {
      bool isTop = _scrollController.position.pixels == 0;
      _pageCount += _offset;

      if (!isTop) {
        setState(() {
          _rowCount = (_pageCount + _offset) > _userDataList.length
              ? _userDataList.length
              : _pageCount + _offset;
        });
      }
    }
  }

  Future<void> _getScoreList(DateRange? range) async {
    final userDataList =
        await ref.read(rankingProvider.notifier).getUserPoints(range!);
    int rowCount =
        userDataList.length > 20 ? _pageCount + _offset : userDataList.length;

    if (selectContractRegion.value!.contractCommunityId == null) {
      // 전체보기
      if (mounted) {
        setState(() {
          _loadingFinished = true;
          _filtered = false;
          _userDataList = userDataList;
          _initialPointList = userDataList;
          _rowCount = rowCount;
        });
      }
    } else {
      final filterList = userDataList
          .where((e) =>
              e.contractCommunityId ==
              selectContractRegion.value!.contractCommunityId)
          .toList();
      if (mounted) {
        setState(() {
          _loadingFinished = true;
          _userDataList = filterList;
          _filtered = false;
          _rowCount = filterList.length;
        });
      }
    }

    // if (selectContractRegion.value!.subdistrictId == "") {
    //   if (mounted) {
    //     setState(() {
    //       _loadingFinished = true;
    //       _filtered = false;
    //       _userDataList = userDataList;
    //       _initialPointList = userDataList;
    //       _rowCount = rowCount;
    //     });
    //   }
    // } else {
    //   if (selectContractRegion.value!.contractCommunityId != "" &&
    //       selectContractRegion.value!.contractCommunityId != null) {
    //     final filterDataList = userDataList
    //         .where((e) =>
    //             e.contractCommunityId ==
    //             selectContractRegion.value!.contractCommunityId)
    //         .toList();
    //     if (mounted) {
    //       setState(() {
    //         _loadingFinished = true;
    //         _filtered = false;
    //         _userDataList = filterDataList;
    //         _initialPointList = userDataList;
    //         _rowCount = rowCount;
    //       });
    //     }
    //   } else {
    //     if (mounted) {
    //       setState(() {
    //         _loadingFinished = true;
    //         _filtered = false;
    //         _userDataList = userDataList;
    //         _initialPointList = userDataList;
    //         _rowCount = rowCount;
    //       });
    //     }
    //   }
    // }
  }

  void _removePeriodCalender() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  void _showPeriodCalender() {
    overlayEntry = OverlayEntry(
      builder: (context) {
        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.light(
              primary: Palette().darkBlue,
            ),
          ),
          child: Positioned.fill(
            child: Material(
              color: Colors.black38,
              child: Center(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: SfDateRangePicker(
                    backgroundColor: Colors.white,
                    headerHeight: 50,
                    confirmText: "확인",
                    cancelText: "취소",
                    onCancel: () {
                      _removePeriodCalender();
                    },
                    onSubmit: (dateRange) async {
                      if (dateRange is PickerDateRange) {
                        setState(() {
                          _selectedDateRange = DateRange(dateRange.startDate!,
                              dateRange.endDate ?? dateRange.startDate!);
                          _loadingFinished = false;
                        });
                        _removePeriodCalender();
                        await _getScoreList(_selectedDateRange);
                      }
                    },
                    showActionButtons: true,
                    viewSpacing: 10,
                    selectionColor: Palette().darkBlue,
                    selectionTextStyle: InjicareFont().body07,
                    rangeTextStyle: InjicareFont().body07,
                    rangeSelectionColor: Palette().lightBlue,
                    startRangeSelectionColor: Palette().darkBlue,
                    endRangeSelectionColor: Palette().darkBlue,
                    headerStyle: DateRangePickerHeaderStyle(
                      backgroundColor: Palette().darkBlue,
                      textStyle: InjicareFont().body01.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    monthCellStyle: DateRangePickerMonthCellStyle(
                      textStyle: InjicareFont().body07,
                      leadingDatesTextStyle: InjicareFont().body07,
                      trailingDatesTextStyle: InjicareFont().body07,
                    ),
                    monthViewSettings: const DateRangePickerMonthViewSettings(),
                    selectionMode: DateRangePickerSelectionMode.range,
                    initialSelectedRange: PickerDateRange(
                      _selectedDateRange!.start,
                      _selectedDateRange!.end,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context, debugRequiredFor: widget).insert(overlayEntry!);
  }

  Future<void> _filterUserDataList(
      String? searchBy, String searchKeyword) async {
    List<UserModel> filterList = [];
    if (searchBy == "이름") {
      filterList = _initialPointList
          .where((element) => element!.name.contains(searchKeyword))
          .cast<UserModel>()
          .toList();
    } else {
      filterList = _initialPointList
          .where((element) => element!.phone.contains(searchKeyword))
          .cast<UserModel>()
          .toList();
    }

    setState(() {
      _filtered = true;
      _rowCount = filterList.length;
      _userDataList = filterList;
    });
  }

  // excel
  List<String> exportToList(UserModel userModel) {
    return [
      userModel.index.toString(),
      userModel.name.toString(),
      userModel.phone.toString(),
      userModel.totalPoint.toString(),
      userModel.stepPoint.toString(),
      userModel.diaryPoint.toString(),
      userModel.commentPoint.toString(),
      // userModel.invitationPoint.toString(),
    ];
  }

  List<List<String>> exportToFullList(List<UserModel?> userDataList) {
    List<List<String>> list = [];

    list.add(_userListHeader);

    for (var item in userDataList) {
      final itemList = exportToList(item!);
      list.add(itemList);
    }
    return list;
  }

  void generateExcel() {
    final csvData = exportToFullList(_userDataList);
    final String fileName = "인지케어 점수관리 ${todayToStringDot()}.xlsx";
    exportExcel(csvData, fileName);
  }

  void goUserRankingDashboard({
    required String userId,
    required String userName,
    required DateRange dateRange,
  }) {
    final startSeconds = convertStartDateTimeToSeconds(dateRange.start);
    final endSeconds = convertEndDateTimeToSeconds(dateRange.end);

    Map<String, String> extraJson = {
      "userId": userId,
      "userName": userName,
      "dateRange": encodeDateRange(dateRange),
    };
    context.go("/ranking/$userId?start=$startSeconds&end=$endSeconds",
        extra: DatePathExtra.fromJson(extraJson));
  }

  Future<void> updateOrderStandard(String value, int columnIndex) async {
    List<UserModel?> copiedUserDataList = [..._userDataList];
    int count = 1;

    List<UserModel> list = [];
    switch (value) {
      case "totalPoint":
        copiedUserDataList
            .sort((a, b) => b!.totalPoint!.compareTo(a!.totalPoint!));

        for (int i = 0; i < copiedUserDataList.length - 1; i++) {
          UserModel indexUpdateUser = copiedUserDataList[i]!.copyWith(
            index: count,
          );
          list.add(indexUpdateUser);

          if (copiedUserDataList[i]!.totalPoint !=
              copiedUserDataList[i + 1]!.totalPoint) {
            count++;
          }
        }

        break;
      case "stepPoint":
        copiedUserDataList
            .sort((a, b) => b!.stepPoint!.compareTo(a!.stepPoint!));

        for (int i = 0; i < copiedUserDataList.length - 1; i++) {
          UserModel indexUpdateUser = copiedUserDataList[i]!.copyWith(
            index: count,
          );
          list.add(indexUpdateUser);

          if (copiedUserDataList[i]!.stepPoint !=
              copiedUserDataList[i + 1]!.stepPoint) {
            count++;
          }
        }
        break;
      case "diaryPoint":
        copiedUserDataList
            .sort((a, b) => b!.diaryPoint!.compareTo(a!.diaryPoint!));

        for (int i = 0; i < copiedUserDataList.length - 1; i++) {
          UserModel indexUpdateUser = copiedUserDataList[i]!.copyWith(
            index: count,
          );
          list.add(indexUpdateUser);

          if (copiedUserDataList[i]!.diaryPoint !=
              copiedUserDataList[i + 1]!.diaryPoint) {
            count++;
          }
        }
        break;
      case "commentPoint":
        copiedUserDataList
            .sort((a, b) => b!.commentPoint!.compareTo(a!.commentPoint!));

        for (int i = 0; i < copiedUserDataList.length - 1; i++) {
          UserModel indexUpdateUser = copiedUserDataList[i]!.copyWith(
            index: count,
          );
          list.add(indexUpdateUser);

          if (copiedUserDataList[i]!.commentPoint !=
              copiedUserDataList[i + 1]!.commentPoint) {
            count++;
          }
        }
        break;
      case "likePoint":
        copiedUserDataList
            .sort((a, b) => b!.likePoint!.compareTo(a!.likePoint!));

        for (int i = 0; i < copiedUserDataList.length - 1; i++) {
          UserModel indexUpdateUser = copiedUserDataList[i]!.copyWith(
            index: count,
          );
          list.add(indexUpdateUser);

          if (copiedUserDataList[i]!.likePoint !=
              copiedUserDataList[i + 1]!.likePoint) {
            count++;
          }
        }
        break;
      // case "invitationPoint":
      //   copiedUserDataList
      //       .sort((a, b) => b!.invitationPoint!.compareTo(a!.invitationPoint!));

      //   for (int i = 0; i < copiedUserDataList.length - 1; i++) {
      //     UserModel indexUpdateUser = copiedUserDataList[i]!.copyWith(
      //       index: count,
      //     );
      //     list.add(indexUpdateUser);

      //     if (copiedUserDataList[i]!.invitationPoint !=
      //         copiedUserDataList[i + 1]!.invitationPoint) {
      //       count++;
      //     }
      //   }
      //   break;
    }
    setState(() {
      _sortColumnIndex = columnIndex;
      _userDataList = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) => DefaultScreen(
            menu: menuList[2],
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: Column(
                children: [
                  SearchCsv(
                    filterUserList: _filterUserDataList,
                    resetInitialList: () => _getScoreList(_selectedDateRange),
                    generateCsv: generateExcel,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: _showPeriodCalender,
                          child: PeriodButton(
                            startDate: _selectedDateRange!.start,
                            endDate: _selectedDateRange!.end,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "점수 계산 방법",
                            style: TextStyle(
                              fontSize: Sizes.size12,
                              color: Palette().normalGray,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Gaps.v5,
                          Text(
                            "걸음수: 1,000보당 10점 (하루 최대 7천보)",
                            style: TextStyle(
                              fontSize: Sizes.size11,
                              color: Palette().normalGray,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Gaps.v5,
                          Text(
                            "일기: 100점 / 댓글: 20점 / 좋아요: 10점",
                            style: TextStyle(
                              fontSize: Sizes.size11,
                              color: Palette().normalGray,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          // Gaps.v5,
                          // Text(
                          //   "내 초대로 가입한 친구 1명: 100점",
                          //   style: TextStyle(
                          //     fontSize: Sizes.size11,
                          //     color: Palette().normalGray,
                          //     fontWeight: FontWeight.w300,
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                  Gaps.v40,
                  !_loadingFinished
                      ? const SkeletonLoadingScreen()
                      : Expanded(
                          child: DataTable2(
                            scrollController: _scrollController,
                            isVerticalScrollBarVisible: false,
                            smRatio: 0.8,
                            lmRatio: 1.2,
                            dividerThickness: 0.1,
                            sortColumnIndex: _sortColumnIndex,
                            sortArrowIcon: Icons.arrow_downward_rounded,
                            horizontalMargin: 0,
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
                                fixedWidth: 50,
                                label: Text(
                                  "#",
                                  style: _headerTextStyle,
                                ),
                              ),
                              DataColumn2(
                                // size: ColumnSize.L,
                                label: Text(
                                  "이름",
                                  style: _headerTextStyle,
                                ),
                              ),
                              DataColumn2(
                                // size: ColumnSize.L,
                                label: Text(
                                  "핸드폰 번호",
                                  style: _headerTextStyle,
                                ),
                              ),
                              DataColumn2(
                                size: ColumnSize.S,
                                tooltip: "클릭하면 '종합 점수'를 기준으로 정렬됩니다.",
                                onSort: (columnIndex, sortAscending) {
                                  updateOrderStandard(
                                      "totalPoint", columnIndex);
                                },
                                label: Text(
                                  "종합",
                                  style: _headerTextStyle,
                                ),
                              ),
                              DataColumn2(
                                size: ColumnSize.S,
                                tooltip: "클릭하면 '걸음수'를 기준으로 정렬됩니다.",
                                onSort: (columnIndex, sortAscending) {
                                  updateOrderStandard("stepPoint", columnIndex);
                                },
                                label: Text(
                                  "걸음수",
                                  style: _headerTextStyle,
                                ),
                              ),
                              DataColumn2(
                                size: ColumnSize.S,
                                tooltip: "클릭하면 '일기'를 기준으로 정렬됩니다",
                                onSort: (columnIndex, sortAscending) {
                                  updateOrderStandard(
                                      "diaryPoint", columnIndex);
                                },
                                label: Text(
                                  "일기",
                                  style: _headerTextStyle,
                                ),
                              ),
                              DataColumn2(
                                size: ColumnSize.S,
                                tooltip: "클릭하면 '댓글'을 기준으로 정렬됩니다",
                                onSort: (columnIndex, sortAscending) {
                                  updateOrderStandard(
                                      "commentPoint", columnIndex);
                                },
                                label: Text(
                                  "댓글",
                                  style: _headerTextStyle,
                                ),
                              ),
                              DataColumn2(
                                size: ColumnSize.S,
                                tooltip: "클릭하면 '좋아요'를 기준으로 정렬됩니다",
                                onSort: (columnIndex, sortAscending) {
                                  updateOrderStandard("likePoint", columnIndex);
                                },
                                label: Text(
                                  "좋아요",
                                  style: _headerTextStyle,
                                ),
                              ),
                              // DataColumn2(
                              //   size: ColumnSize.S,
                              //   tooltip: "클릭하면 '친구초대'를 기준으로 정렬됩니다",
                              //   onSort: (columnIndex, sortAscending) {
                              //     updateOrderStandard(
                              //         "invitationPoint", columnIndex);
                              //   },
                              //   label: Text(
                              //     "친구초대",
                              //     style: _headerTextStyle,
                              //   ),
                              // ),
                              DataColumn2(
                                fixedWidth: 100,
                                onSort: (columnIndex, sortAscending) {
                                  setState(() {
                                    _sortColumnIndex = columnIndex;
                                  });
                                },
                                label: Text(
                                  "활동\n자세히 보기",
                                  style: _headerTextStyle,
                                  textAlign: TextAlign.end,
                                ),
                              ),
                            ],
                            rows: [
                              if (_userDataList.isNotEmpty)
                                for (var i = 0; i < _rowCount; i++)
                                  DataRow2(
                                    cells: [
                                      DataCell(
                                        Text(
                                          (i + 1).toString(),
                                          style: _contentTextStyle,
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          _userDataList[i]!.name.length > 10
                                              ? "${_userDataList[i]!.name.substring(0, 10)}.."
                                              : _userDataList[i]!.name,
                                          style: _contentTextStyle,
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          _userDataList[i]!.phone,
                                          style: _contentTextStyle,
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          "${_userDataList[i]!.totalPoint}",
                                          style: _contentTextStyle,
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          "${_userDataList[i]!.stepPoint}",
                                          style: _contentTextStyle,
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          "${_userDataList[i]!.diaryPoint}",
                                          style: _contentTextStyle,
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          "${_userDataList[i]!.commentPoint}",
                                          style: _contentTextStyle,
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          "${_userDataList[i]!.likePoint}",
                                          style: _contentTextStyle,
                                        ),
                                      ),
                                      // DataCell(
                                      //   Text(
                                      //     "${_userDataList[i]!.invitationPoint}",
                                      //     style: _contentTextStyle,
                                      //   ),
                                      // ),
                                      DataCell(
                                        Center(
                                          child: MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: () =>
                                                  goUserRankingDashboard(
                                                userId:
                                                    _userDataList[i]!.userId,
                                                userName:
                                                    _userDataList[i]!.name,
                                                dateRange: _selectedDateRange ??
                                                    DateRange(
                                                      getThisWeekMonday(),
                                                      DateTime.now(),
                                                    ),
                                              ),
                                              child: FaIcon(
                                                FontAwesomeIcons.arrowRight,
                                                color: Palette().darkGray,
                                                size: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

DateTime getThisWeekStartDate() {
  DateTime now = DateTime.now();
  int currentDayOfWeek = now.weekday;
  DateTime startOfWeek = now.subtract(Duration(days: currentDayOfWeek - 1));
  return startOfWeek;
}

DateTime getThisWeekEndDate() {
  DateTime now = DateTime.now();
  int currentDayOfWeek = now.weekday;
  DateTime startOfWeek = now.subtract(Duration(days: currentDayOfWeek - 1));
  DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
  return endOfWeek;
}

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/common/widgets/loading_widget.dart';
import 'package:onldocc_admin/common/widgets/period_button.dart';
import 'package:onldocc_admin/common/widgets/report_button.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/dashboard/view/dashboard_screen.dart';
import 'package:onldocc_admin/features/ranking/view_models/ranking_view_model.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/features/users/view_models/user_view_model.dart';
import 'package:onldocc_admin/injicare_font.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class RankingUserDashboardScreen extends ConsumerStatefulWidget {
  final String? userId;
  final String? userName;
  final String? dateRange;
  const RankingUserDashboardScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.dateRange,
  });

  @override
  ConsumerState<RankingUserDashboardScreen> createState() =>
      _RankingUserDashboardScreenState();
}

class _RankingUserDashboardScreenState
    extends ConsumerState<RankingUserDashboardScreen> {
  UserModel? _userModel;
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

  final List<String> _listHeader = [
    "#",
    "날짜",
    "내용",
  ];
  DateRange _selectedDateRange = DateRange(
    getThisWeekMonday(),
    DateTime.now(),
  );

  bool _loadingFinished = false;
  final _rankingTypes = ["일기", "걸음수", "댓글", "좋아요"];
  String _selectedRanking = "일기";

  List<RankingDataSet> _rankings = [];

  final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();
  OverlayEntry? overlayEntry;

  @override
  void initState() {
    super.initState();

    _selectedDateRange = widget.dateRange != null
        ? decodeDateRange(widget.dateRange!)
        : DateRange(
            getThisWeekMonday(),
            DateTime.now(),
          );

    _initializeUser();
    _initializeRankingData();
  }

  @override
  void dispose() {
    _removePeriodCalender();
    super.dispose();
  }

  void _initializeUser() async {
    final userModel =
        await ref.read(userProvider.notifier).getUserModel(widget.userId!);
    setState(() {
      _userModel = userModel;
    });
  }

  // 데이터 목록
  void _initializeRankingData() async {
    final rankings = await ref
        .read(rankingProvider.notifier)
        .getRankingData(_selectedRanking, widget.userId!, _selectedDateRange);
    setState(() {
      _rankings = rankings;
      _loadingFinished = true;
    });
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
                        _initializeRankingData();
                        // await _getScoreList(_selectedDateRange);
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
                      _selectedDateRange.start,
                      _selectedDateRange.end,
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

  // excel
  List<String> exportToList(RankingDataSet ranking) {
    return [
      ranking.index.toString(),
      _selectedRanking == "걸음수"
          ? ranking.stepDate ?? ""
          : ranking.createdAt != null
              ? secondsToStringLine(ranking.createdAt!)
              : "",
      ranking.content.toString(),
    ];
  }

  List<List<String>> exportToFullList() {
    List<List<String>> list = [];

    list.add(_listHeader);

    for (var item in _rankings) {
      final itemList = exportToList(item);
      list.add(itemList);
    }
    return list;
  }

  void generateExcel() {
    final csvData = exportToFullList();
    final String fileName =
        "인지케어 점수 활동보기: ${_userModel != null ? _userModel!.name : ""} $_selectedRanking ${todayToStringDot()}.xlsx";
    exportExcel(csvData, fileName);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return !_loadingFinished
        ? loadingWidget(context)
        : Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (context) => DefaultScreen(
                  menu: Menu(
                    index: 1,
                    name: "회원별 데이터: ${_userModel!.name}",
                    routeName: "user-dashboard",
                    child: Container(),
                    backButton: true,
                    colorButton: Palette().darkBlue,
                  ),
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Gaps.v20,
                        Row(
                          children: [
                            Text(
                              "점수 항목:",
                              style: TextStyle(
                                fontSize: Sizes.size14,
                                color: Palette().darkPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Gaps.h10,
                            PeriodDropdownMenu(
                              items: _rankingTypes.map((String item) {
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
                              value: _selectedRanking,
                              onChangedFunction: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedRanking = value;
                                  });
                                  _initializeRankingData();
                                }
                              },
                            ),
                          ],
                        ),
                        Gaps.v16,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: _showPeriodCalender,
                                        child: PeriodButton(
                                          startDate: _selectedDateRange.start,
                                          endDate: _selectedDateRange.end,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            ReportButton(
                              iconExists: true,
                              buttonText: "리포트 출력하기",
                              buttonColor: Palette().darkPurple,
                              action: generateExcel,
                            )
                          ],
                        ),
                        Gaps.v52,
                        // header
                        Expanded(
                          child: DataTable2(
                            smRatio: 0.4,
                            lmRatio: 3.0,
                            isVerticalScrollBarVisible: false,
                            dividerThickness: 0.1,
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
                                size: ColumnSize.S,
                                label: Text(
                                  "#",
                                  style: _headerTextStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              DataColumn2(
                                size: ColumnSize.M,
                                label: Text(
                                  "날짜",
                                  style: _headerTextStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              DataColumn2(
                                size: ColumnSize.L,
                                label: Text(
                                  "내용",
                                  style: _headerTextStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                            rows: [
                              for (int i = 0; i < _rankings.length; i++)
                                DataRow2(
                                  cells: [
                                    DataCell(
                                      Text(
                                        "${_rankings[i].index}",
                                        style: _contentTextStyle,
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        _selectedRanking == "걸음수"
                                            ? _rankings[i].stepDate ?? ""
                                            : _rankings[i].createdAt != null
                                                ? secondsToStringDateComment(
                                                    _rankings[i].createdAt!)
                                                : "",
                                        style: _contentTextStyle,
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        _rankings[i].content,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.start,
                                        style: _contentTextStyle.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        Gaps.v40,
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
  }
}

class RankingDataSet {
  final int index;
  final int? createdAt;
  final String? stepDate;
  final String content;

  RankingDataSet({
    required this.index,
    this.createdAt,
    this.stepDate,
    required this.content,
  });
}

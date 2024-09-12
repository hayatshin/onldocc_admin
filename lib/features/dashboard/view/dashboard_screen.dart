import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/common/widgets/period_button.dart';
import 'package:onldocc_admin/common/widgets/report_button.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/event/view/event_screen.dart';
import 'package:onldocc_admin/injicare_font.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  static const routeURL = "/dashboard";
  static const routeName = "dashboard";
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();
  OverlayEntry? overlayEntry;

  bool _loadingFinished = false;

  DateRange _selectedDateRange = DateRange(
    getThisWeekMonday(),
    DateTime.now(),
  );

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

  GlobalKey diaryColumnKey = GlobalKey();
  double? diaryWidgetHeight = 300;
  GlobalKey aiColumnKey = GlobalKey();
  double? aiWidgetHeight = 300;
  final List<ChartData> moodData = [
    ChartData('David', 25),
    ChartData('Steve', 38),
    ChartData('Jack', 34),
    ChartData('Others', 52)
  ];
  final List<ChartData> stepData = [
    ChartData("2010", 35),
    ChartData("2011", 28),
    ChartData("2012", 34),
    ChartData("2013", 32),
    ChartData("2014", 40)
  ];

  get data => null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _diaryCalculateHeight();
      _aiCalculateHeight();
    });
  }

  @override
  void dispose() {
    _removePeriodCalender();
    super.dispose();
  }

  void _diaryCalculateHeight() {
    final BuildContext? columnContext = diaryColumnKey.currentContext;
    if (columnContext != null) {
      RenderBox renderBox =
          diaryColumnKey.currentContext!.findRenderObject() as RenderBox;
      setState(() => diaryWidgetHeight = renderBox.size.height);
    } else {
      Future.delayed(
          const Duration(milliseconds: 200), () => _diaryCalculateHeight());
    }
  }

  void _aiCalculateHeight() {
    final BuildContext? columnContext = aiColumnKey.currentContext;
    if (columnContext != null) {
      RenderBox renderBox =
          aiColumnKey.currentContext!.findRenderObject() as RenderBox;
      setState(() => aiWidgetHeight = renderBox.size.height);
    } else {
      Future.delayed(
          const Duration(milliseconds: 200), () => _aiCalculateHeight());
    }
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
                          _selectedDateRange = DateRange(
                              dateRange.startDate!, dateRange.endDate!);
                          _loadingFinished = false;
                        });
                        _removePeriodCalender();
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
                    selectionMode: DateRangePickerSelectionMode.extendableRange,
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

  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) => DefaultScreen(
            menu: menuList[0],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    ReportButton(
                      iconExists: true,
                      buttonText: "리포트 출력하기",
                      buttonColor: Palette().darkPurple,
                      action: () {},
                    )
                  ],
                ),
                // 가입자 수 헤더
                const DashType(type: "회원 가입자 수 데이터"),
                IntrinsicHeight(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Palette().darkPurple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Gaps.h40,
                                HeaderBox(
                                  headerText: "누적 회원가입 수",
                                  headerColor: Palette().dashPink,
                                  contentData: "820 명",
                                ),
                              ],
                            ),
                          ),
                          HeightDivider(
                            borderColor: Palette().darkGray,
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Gaps.h40,
                                HeaderBox(
                                  headerText: "기간 내 회원가입 수",
                                  headerColor: Palette().dashYellow,
                                  contentData: "820 명",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // 가입자 수 표
                const SizedBox(
                  height: 60,
                ),
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 누적 가입자 수 표
                      Expanded(
                        child: Column(
                          children: [
                            DashboardTable(
                              tableTitle: "성별 누적 회원가입자 수",
                              titleColor: Palette().dashPink,
                              list: [
                                TableModel(
                                    tableHeader: "남성", tableContent: "40명"),
                                TableModel(
                                    tableHeader: "여성", tableContent: "40명"),
                              ],
                            ),
                            Gaps.v10,
                            DashboardTable(
                              tableTitle: "연령별 누적 회원가입자 수",
                              titleColor: Palette().dashPink,
                              list: [
                                TableModel(
                                    tableHeader: "40대 미만", tableContent: "40명"),
                                TableModel(
                                    tableHeader: "40대", tableContent: "40명"),
                                TableModel(
                                    tableHeader: "50대", tableContent: "40명"),
                                TableModel(
                                    tableHeader: "60대", tableContent: "40명"),
                                TableModel(
                                    tableHeader: "70대", tableContent: "40명"),
                                TableModel(
                                    tableHeader: "80대", tableContent: "40명"),
                                TableModel(
                                    tableHeader: "90대 이상", tableContent: "40명"),
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 250,
                                  height: 250,
                                  child: SfCircularChart(
                                    legend: const Legend(isVisible: true),
                                    series: <PieSeries<ChartData, String>>[
                                      PieSeries(
                                        explode: true,
                                        explodeIndex: 0,
                                        dataSource: moodData,
                                        xValueMapper: (datum, index) => datum.x,
                                        yValueMapper: (datum, index) => datum.y,
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 250,
                                  height: 250,
                                  child: SfCircularChart(
                                    legend: const Legend(isVisible: true),
                                    series: <PieSeries<ChartData, String>>[
                                      PieSeries(
                                        explode: true,
                                        explodeIndex: 0,
                                        dataSource: moodData,
                                        xValueMapper: (datum, index) => datum.x,
                                        yValueMapper: (datum, index) => datum.y,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      HeightDivider(
                        borderColor: Palette().lightGray,
                      ),
                      // 기간별 가입자 수 표
                      Expanded(
                        child: Column(
                          children: [
                            Column(
                              children: [
                                DashboardTable(
                                  tableTitle: "성별 기간 내 회원가입자 수",
                                  titleColor: Palette().dashYellow,
                                  list: [
                                    TableModel(
                                        tableHeader: "남성", tableContent: "40명"),
                                    TableModel(
                                        tableHeader: "여성", tableContent: "40명"),
                                  ],
                                ),
                                Gaps.v10,
                                DashboardTable(
                                  tableTitle: "연령별 기간 내 회원가입자 수",
                                  titleColor: Palette().dashYellow,
                                  list: [
                                    TableModel(
                                        tableHeader: "40대 미만",
                                        tableContent: "40명"),
                                    TableModel(
                                        tableHeader: "40대",
                                        tableContent: "40명"),
                                    TableModel(
                                        tableHeader: "50대",
                                        tableContent: "40명"),
                                    TableModel(
                                        tableHeader: "60대",
                                        tableContent: "40명"),
                                    TableModel(
                                        tableHeader: "70대",
                                        tableContent: "40명"),
                                    TableModel(
                                        tableHeader: "80대",
                                        tableContent: "40명"),
                                    TableModel(
                                        tableHeader: "90대 이상",
                                        tableContent: "40명"),
                                  ],
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 250,
                                      height: 250,
                                      child: SfCircularChart(
                                        legend: const Legend(isVisible: true),
                                        series: <PieSeries<ChartData, String>>[
                                          PieSeries(
                                            explode: true,
                                            explodeIndex: 0,
                                            dataSource: moodData,
                                            xValueMapper: (datum, index) =>
                                                datum.x,
                                            yValueMapper: (datum, index) =>
                                                datum.y,
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 250,
                                      height: 250,
                                      child: SfCircularChart(
                                        legend: const Legend(isVisible: true),
                                        series: <PieSeries<ChartData, String>>[
                                          PieSeries(
                                            explode: true,
                                            explodeIndex: 0,
                                            dataSource: moodData,
                                            xValueMapper: (datum, index) =>
                                                datum.x,
                                            yValueMapper: (datum, index) =>
                                                datum.y,
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // 일기 데이터
                const DashType(type: "일기 데이터"),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          key: diaryColumnKey,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            WhiteBox(
                              boxTitle: "",
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  SubHeaderBox(
                                    subHeader: "일기 작성 횟수",
                                    subHeaderColor: Palette().dashPink,
                                    contentData: "18 회",
                                  ),
                                  const GrayDivider(
                                    height: 60,
                                  ),
                                  SubHeaderBox(
                                    subHeader: "일기 작성자 수",
                                    subHeaderColor: Palette().dashPink,
                                    contentData: "20 명",
                                  ),
                                  const GrayDivider(
                                    height: 60,
                                  ),
                                  SubHeaderBox(
                                    subHeader: "댓글 횟수",
                                    subHeaderColor: Palette().dashBlue,
                                    contentData: "39 회",
                                  ),
                                  const GrayDivider(
                                    height: 60,
                                  ),
                                  SubHeaderBox(
                                    subHeader: "좋아요 횟수",
                                    subHeaderColor: Palette().dashGreen,
                                    contentData: "112 회",
                                  ),
                                ],
                              ),
                            ),
                            Gaps.v16,
                            WhiteBox(
                              boxTitle: "마음 분포도",
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 250,
                                    height: 250,
                                    child: SfCircularChart(
                                      legend: const Legend(isVisible: true),
                                      series: <PieSeries<ChartData, String>>[
                                        PieSeries(
                                          explode: true,
                                          explodeIndex: 0,
                                          dataSource: moodData,
                                          xValueMapper: (datum, index) =>
                                              datum.x,
                                          yValueMapper: (datum, index) =>
                                              datum.y,
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Gaps.v24,
                            WhiteBox(
                              boxTitle: "문제 풀기 [수학 문제]",
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  right: 80,
                                  left: 30,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // 수학
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        "20 회",
                                        style: TextStyle(
                                          fontSize: Sizes.size16,
                                          fontWeight: FontWeight.w800,
                                          color: Palette().darkGray,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                "맞음",
                                                style: TextStyle(
                                                  color: Palette().normalGray,
                                                  fontSize: Sizes.size12,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                              Gaps.v10,
                                              Text(
                                                "19 회",
                                                style: TextStyle(
                                                  color: Palette().darkGray,
                                                  fontSize: Sizes.size16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const GrayDivider(
                                            height: 60,
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                "틀림",
                                                style: TextStyle(
                                                  color: Palette().normalGray,
                                                  fontSize: Sizes.size12,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                              Gaps.v10,
                                              Text(
                                                "1 회",
                                                style: TextStyle(
                                                  color: Palette().darkGray,
                                                  fontSize: Sizes.size16,
                                                  fontWeight: FontWeight.w500,
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
                            ),
                            Gaps.v24,
                            CognitionQuizTable(
                                tableTitle: "성별 수학 문제 데이터",
                                titleColor: Palette().dashBlue,
                                tableHeaderOne: "총 문제풀기 횟수",
                                tableHeaderTwo: "틀린 횟수",
                                tableHeaderThree: "빈도",
                                list: [
                                  CognitionQuizTableModel(
                                    tableContentZero: "남성",
                                    tableContentOne: "124 회",
                                    tableContentTwo: "7 회",
                                    tableContentThree: "5.65",
                                  ),
                                  CognitionQuizTableModel(
                                    tableContentZero: "여성",
                                    tableContentOne: "124 회",
                                    tableContentTwo: "7 회",
                                    tableContentThree: "5.65",
                                  ),
                                ]),
                            Gaps.v10,
                            CognitionQuizTable(
                                tableTitle: "연령별 수학 문제 데이터",
                                titleColor: Palette().dashBlue,
                                tableHeaderOne: "총 문제풀기 횟수",
                                tableHeaderTwo: "틀린 횟수",
                                tableHeaderThree: "빈도",
                                list: [
                                  CognitionQuizTableModel(
                                    tableContentZero: "40대 미만",
                                    tableContentOne: "124 회",
                                    tableContentTwo: "7 회",
                                    tableContentThree: "5.65",
                                  ),
                                  CognitionQuizTableModel(
                                    tableContentZero: "40대",
                                    tableContentOne: "124 회",
                                    tableContentTwo: "7 회",
                                    tableContentThree: "5.65",
                                  ),
                                  CognitionQuizTableModel(
                                    tableContentZero: "50대",
                                    tableContentOne: "124 회",
                                    tableContentTwo: "7 회",
                                    tableContentThree: "5.65",
                                  ),
                                  CognitionQuizTableModel(
                                    tableContentZero: "60대",
                                    tableContentOne: "124 회",
                                    tableContentTwo: "7 회",
                                    tableContentThree: "5.65",
                                  ),
                                  CognitionQuizTableModel(
                                    tableContentZero: "70대",
                                    tableContentOne: "124 회",
                                    tableContentTwo: "7 회",
                                    tableContentThree: "5.65",
                                  ),
                                  CognitionQuizTableModel(
                                    tableContentZero: "80대",
                                    tableContentOne: "124 회",
                                    tableContentTwo: "7 회",
                                    tableContentThree: "5.65",
                                  ),
                                  CognitionQuizTableModel(
                                    tableContentZero: "90대 이상",
                                    tableContentOne: "124 회",
                                    tableContentTwo: "7 회",
                                    tableContentThree: "5.65",
                                  ),
                                ]),
                          ],
                        ),
                      ),
                      HeightDivider(
                        borderColor: Palette().lightGray,
                      ),
                      // 일기 표 데이터
                      Expanded(
                        child: Column(
                          children: [
                            Column(
                              children: [
                                DashboardTable(
                                  tableTitle: "성별 일기 작성 횟수",
                                  titleColor: Palette().dashPink,
                                  list: [
                                    TableModel(
                                        tableHeader: "남성", tableContent: "40명"),
                                    TableModel(
                                        tableHeader: "여성", tableContent: "40명"),
                                  ],
                                ),
                                Gaps.v10,
                                DashboardTable(
                                  tableTitle: "기간별 일기 작성 횟수",
                                  titleColor: Palette().dashPink,
                                  list: [
                                    TableModel(
                                        tableHeader: "40대 미만",
                                        tableContent: "40명"),
                                    TableModel(
                                        tableHeader: "40대",
                                        tableContent: "40명"),
                                    TableModel(
                                        tableHeader: "50대",
                                        tableContent: "40명"),
                                    TableModel(
                                        tableHeader: "60대",
                                        tableContent: "40명"),
                                    TableModel(
                                        tableHeader: "70대",
                                        tableContent: "40명"),
                                    TableModel(
                                        tableHeader: "80대",
                                        tableContent: "40명"),
                                    TableModel(
                                        tableHeader: "90대 이상",
                                        tableContent: "40명"),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(),
                            WhiteBox(
                              boxTitle: "문제 풀기 [객관식 문제]",
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  right: 80,
                                  left: 30,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // 수학
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        "20 회",
                                        style: TextStyle(
                                          fontSize: Sizes.size16,
                                          fontWeight: FontWeight.w800,
                                          color: Palette().darkGray,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                "맞음",
                                                style: TextStyle(
                                                  color: Palette().normalGray,
                                                  fontSize: Sizes.size12,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                              Gaps.v10,
                                              Text(
                                                "19 회",
                                                style: TextStyle(
                                                  color: Palette().darkGray,
                                                  fontSize: Sizes.size16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const GrayDivider(
                                            height: 60,
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                "틀림",
                                                style: TextStyle(
                                                  color: Palette().normalGray,
                                                  fontSize: Sizes.size12,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                              Gaps.v10,
                                              Text(
                                                "1 회",
                                                style: TextStyle(
                                                  color: Palette().darkGray,
                                                  fontSize: Sizes.size16,
                                                  fontWeight: FontWeight.w500,
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
                            ),
                            Gaps.v24,
                            CognitionQuizTable(
                                tableTitle: "성별 객관식 문제 데이터",
                                titleColor: Palette().dashBlue,
                                tableHeaderOne: "총 문제풀기 횟수",
                                tableHeaderTwo: "틀린 횟수",
                                tableHeaderThree: "빈도",
                                list: [
                                  CognitionQuizTableModel(
                                    tableContentZero: "남성",
                                    tableContentOne: "124 회",
                                    tableContentTwo: "7 회",
                                    tableContentThree: "5.65",
                                  ),
                                  CognitionQuizTableModel(
                                    tableContentZero: "여성",
                                    tableContentOne: "124 회",
                                    tableContentTwo: "7 회",
                                    tableContentThree: "5.65",
                                  ),
                                ]),
                            Gaps.v10,
                            CognitionQuizTable(
                                tableTitle: "연령별 객관식 문제 데이터",
                                titleColor: Palette().dashBlue,
                                tableHeaderOne: "총 문제풀기 횟수",
                                tableHeaderTwo: "틀린 횟수",
                                tableHeaderThree: "빈도",
                                list: [
                                  CognitionQuizTableModel(
                                    tableContentZero: "40대 미만",
                                    tableContentOne: "124 회",
                                    tableContentTwo: "7 회",
                                    tableContentThree: "5.65",
                                  ),
                                  CognitionQuizTableModel(
                                    tableContentZero: "40대",
                                    tableContentOne: "124 회",
                                    tableContentTwo: "7 회",
                                    tableContentThree: "5.65",
                                  ),
                                  CognitionQuizTableModel(
                                    tableContentZero: "50대",
                                    tableContentOne: "124 회",
                                    tableContentTwo: "7 회",
                                    tableContentThree: "5.65",
                                  ),
                                  CognitionQuizTableModel(
                                    tableContentZero: "60대",
                                    tableContentOne: "124 회",
                                    tableContentTwo: "7 회",
                                    tableContentThree: "5.65",
                                  ),
                                  CognitionQuizTableModel(
                                    tableContentZero: "70대",
                                    tableContentOne: "124 회",
                                    tableContentTwo: "7 회",
                                    tableContentThree: "5.65",
                                  ),
                                  CognitionQuizTableModel(
                                    tableContentZero: "80대",
                                    tableContentOne: "124 회",
                                    tableContentTwo: "7 회",
                                    tableContentThree: "5.65",
                                  ),
                                  CognitionQuizTableModel(
                                    tableContentZero: "90대 이상",
                                    tableContentOne: "124 회",
                                    tableContentTwo: "7 회",
                                    tableContentThree: "5.65",
                                  ),
                                ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 인지 검사 데이터
                const DashType(type: "인지 검사 데이터"),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: WhiteBox(
                        boxTitle: "",
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SubHeaderBox(
                              subHeader: "전체",
                              subHeaderColor: Palette().dashPink,
                              contentData: "32 회",
                            ),
                            const GrayDivider(height: 60),
                            SubHeaderBox(
                              subHeader: "온라인 치매 검사",
                              subHeaderColor: Palette().dashBlue,
                              contentData: "20 회",
                            ),
                            const GrayDivider(height: 60),
                            SubHeaderBox(
                              subHeader: "노인 우울척도 검사",
                              subHeaderColor: Palette().dashGreen,
                              contentData: "12 회",
                            ),
                          ],
                        ),
                      ),
                    ),
                    Gaps.h20,
                    Expanded(
                      child: Container(),
                    ),
                  ],
                ),
                Gaps.v16,
                const Row(
                  children: [
                    // 온라인 치매 검사
                    CognitionDetailTestBox(
                      detailTest: "온라인 치매 검사",
                      testResult1: "정상",
                      testResult1Data: "18회",
                      testResult2: "치매 조기 검진 필요",
                      testResult2Data: "2회",
                      listName: "치매 조기 검진 필요 대상자",
                    ),
                    Gaps.h20,
                    CognitionDetailTestBox(
                      detailTest: "노인 우울척도 검사",
                      testResult1: "정상",
                      testResult1Data: "18회",
                      testResult2: "우울",
                      testResult2Data: "2회",
                      listName: "우울 대상자",
                    ),
                  ],
                ),
                // 걸음수 데이터
                const DashType(type: "AI 대화하기 데이터"),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: WhiteBox(
                          key: aiColumnKey,
                          boxTitle: "",
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    SubHeaderBox(
                                      subHeader: "총 대화 횟수",
                                      subHeaderColor: Palette().dashPink,
                                      contentData: "20 회",
                                    ),
                                    Gaps.v20,
                                    SubHeaderBox(
                                      subHeader: "총 대화 시간",
                                      subHeaderColor: Palette().dashBlue,
                                      contentData: "2시간 30분",
                                    ),
                                    Gaps.v20,
                                    SubHeaderBox(
                                      subHeader: "평균 대화 시간",
                                      subHeaderColor: Palette().dashGreen,
                                      contentData: "2분 30초",
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Gaps.h20,
                      Expanded(
                        child: Column(
                          children: [
                            DashboardTable(
                              tableTitle: "성별 AI 대화 시간",
                              titleColor: Palette().dashGreen,
                              list: [
                                TableModel(
                                    tableHeader: "남성", tableContent: "40명"),
                                TableModel(
                                    tableHeader: "여성", tableContent: "40명"),
                              ],
                            ),
                            Gaps.v5,
                            DashboardTable(
                              tableTitle: "연령별 AI 대화 시간",
                              titleColor: Palette().dashGreen,
                              list: [
                                TableModel(
                                    tableHeader: "40대 미만", tableContent: "40명"),
                                TableModel(
                                    tableHeader: "40대", tableContent: "40명"),
                                TableModel(
                                    tableHeader: "50대", tableContent: "40명"),
                                TableModel(
                                    tableHeader: "60대", tableContent: "40명"),
                                TableModel(
                                    tableHeader: "70대", tableContent: "40명"),
                                TableModel(
                                    tableHeader: "80대", tableContent: "40명"),
                                TableModel(
                                    tableHeader: "90대 이상", tableContent: "40명"),
                              ],
                            )
                          ],
                        ),
                      ),
                      HeightDivider(
                        borderColor: Palette().lightGray,
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Spacer(),
                            SfCartesianChart(
                              primaryXAxis: const CategoryAxis(),
                              series: <CartesianSeries>[
                                ColumnSeries<ChartData, String>(
                                  dataSource: stepData,
                                  xValueMapper: (ChartData datum, index) =>
                                      datum.x,
                                  yValueMapper: (ChartData datum, index) =>
                                      datum.y,
                                  pointColorMapper: (datum, index) =>
                                      Palette().darkPurple,
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                // 걸음수 데이터
                const DashType(type: "걸음수 데이터"),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.white,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 30,
                                        vertical: 15,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            "기간 평균 걸음수",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: Sizes.size13,
                                                color: Palette().darkPurple),
                                          ),
                                          Text(
                                            "940 보",
                                            style: TextStyle(
                                              fontSize: Sizes.size16,
                                              fontWeight: FontWeight.w800,
                                              color: Palette().darkGray,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Gaps.v24,
                                  DashboardTable(
                                    tableTitle: "성별 평균 걸음수",
                                    titleColor: Palette().dashGreen,
                                    list: [
                                      TableModel(
                                          tableHeader: "남성",
                                          tableContent: "40명"),
                                      TableModel(
                                          tableHeader: "여성",
                                          tableContent: "40명"),
                                    ],
                                  ),
                                  Gaps.v10,
                                  DashboardTable(
                                    tableTitle: "연령별 평균 걸음수",
                                    titleColor: Palette().dashGreen,
                                    list: [
                                      TableModel(
                                          tableHeader: "40대 미만",
                                          tableContent: "40명"),
                                      TableModel(
                                          tableHeader: "40대",
                                          tableContent: "40명"),
                                      TableModel(
                                          tableHeader: "50대",
                                          tableContent: "40명"),
                                      TableModel(
                                          tableHeader: "60대",
                                          tableContent: "40명"),
                                      TableModel(
                                          tableHeader: "70대",
                                          tableContent: "40명"),
                                      TableModel(
                                          tableHeader: "80대",
                                          tableContent: "40명"),
                                      TableModel(
                                          tableHeader: "90대 이상",
                                          tableContent: "40명"),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 200,
                            ),
                          ],
                        ),
                      ),
                      HeightDivider(
                        borderColor: Palette().lightGray,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SfCartesianChart(
                              primaryXAxis: const CategoryAxis(),
                              series: <CartesianSeries>[
                                ColumnSeries<ChartData, String>(
                                  dataSource: stepData,
                                  xValueMapper: (ChartData datum, index) =>
                                      datum.x,
                                  yValueMapper: (ChartData datum, index) =>
                                      datum.y,
                                  pointColorMapper: (datum, index) =>
                                      Palette().darkPurple,
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Gaps.v40,
              ],
            ),
          ),
        )
      ],
    );
  }
}

class HeightDivider extends StatelessWidget {
  final Color borderColor;
  const HeightDivider({
    super.key,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: 0.5,
              height: 80,
              decoration: BoxDecoration(
                color: borderColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WhiteBox extends StatelessWidget {
  final String boxTitle;
  final Widget child;
  const WhiteBox({
    super.key,
    required this.boxTitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 25,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (boxTitle != "")
              Column(
                children: [
                  Text(
                    boxTitle,
                    style: TextStyle(
                      color: Palette().darkPurple,
                      fontWeight: FontWeight.w700,
                      fontSize: Sizes.size14,
                    ),
                  ),
                  Gaps.v20,
                ],
              ),
            child,
          ],
        ),
      ),
    );
  }
}

class CognitionDetailTestBox extends StatelessWidget {
  final String detailTest;
  final String testResult1;
  final String testResult1Data;
  final String testResult2;
  final String testResult2Data;
  final String listName;
  const CognitionDetailTestBox({
    super.key,
    required this.detailTest,
    required this.testResult1,
    required this.testResult1Data,
    required this.testResult2,
    required this.testResult2Data,
    required this.listName,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CognitionWhiteBox(
        boxTitle: detailTest,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 30,
                right: 30,
                bottom: 10,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              testResult1,
                              style: TextStyle(
                                color: Palette().normalGray,
                                fontSize: Sizes.size12,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Gaps.v10,
                            Text(
                              testResult1Data,
                              style: TextStyle(
                                color: Palette().darkGray,
                                fontSize: Sizes.size16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const GrayDivider(
                          height: 60,
                        ),
                        Column(
                          children: [
                            Text(
                              testResult2,
                              style: TextStyle(
                                color: Palette().normalGray,
                                fontSize: Sizes.size12,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Gaps.v10,
                            Text(
                              testResult2Data,
                              style: TextStyle(
                                color: Palette().darkGray,
                                fontSize: Sizes.size16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(),
                  ),
                ],
              ),
            ),
            // divider
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 0.5,
                    color: Palette().normalGray,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listName,
                    style: TextStyle(
                      fontSize: Sizes.size13,
                      fontWeight: FontWeight.w600,
                      color: Palette().normalGray,
                    ),
                  ),
                  Gaps.v10,
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      itemCount: 5,
                      separatorBuilder: (context, index) => Gaps.v5,
                      padding: const EdgeInsets.only(
                        top: 10,
                      ),
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                "${index + 1}",
                                style: TextStyle(
                                  fontSize: Sizes.size14,
                                  fontWeight: FontWeight.w700,
                                  color: Palette().darkGray,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                "김영자",
                                style: TextStyle(
                                  fontSize: Sizes.size14,
                                  fontWeight: FontWeight.w600,
                                  color: Palette().darkGray,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "여성",
                                style: TextStyle(
                                  fontSize: Sizes.size14,
                                  fontWeight: FontWeight.w600,
                                  color: Palette().darkGray,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "40세",
                                style: TextStyle(
                                  fontSize: Sizes.size14,
                                  fontWeight: FontWeight.w600,
                                  color: Palette().darkGray,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "010-0000-0000",
                                    style: TextStyle(
                                      fontSize: Sizes.size14,
                                      fontWeight: FontWeight.w800,
                                      color: Palette().darkGray,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CognitionWhiteBox extends StatelessWidget {
  final String boxTitle;
  final Widget child;
  const CognitionWhiteBox({
    super.key,
    required this.boxTitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 25,
            ),
            child: Column(
              children: [
                Text(
                  boxTitle,
                  style: TextStyle(
                    color: Palette().darkPurple,
                    fontWeight: FontWeight.w700,
                    fontSize: Sizes.size14,
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class DashType extends StatelessWidget {
  final String type;
  const DashType({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Gaps.v52,
        Row(
          children: [
            Text(
              type,
              style: TextStyle(
                fontSize: Sizes.size14,
                fontWeight: FontWeight.w700,
                color: Palette().darkGray,
              ),
            ),
          ],
        ),
        Gaps.v32,
      ],
    );
  }
}

class SubHeader extends StatelessWidget {
  final String headerText;
  final Color containerColor;
  const SubHeader({
    super.key,
    required this.headerText,
    required this.containerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: containerColor.withOpacity(0.2),
              ),
              child: Text(
                headerText,
                style: TextStyle(
                  color: Palette().darkGray,
                  fontSize: Sizes.size12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        Gaps.v16,
      ],
    );
  }
}

class HeaderBox extends StatelessWidget {
  final String headerText;
  final Color headerColor;
  final String contentData;

  const HeaderBox({
    super.key,
    required this.headerText,
    required this.headerColor,
    required this.contentData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Gaps.v10,
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Text(
            headerText,
            style: TextStyle(
              color: headerColor,
              fontSize: Sizes.size12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Gaps.v10,
        Text(
          contentData,
          style: const TextStyle(
            fontSize: Sizes.size20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class SubHeaderBox extends StatelessWidget {
  final String subHeader;
  final Color subHeaderColor;
  final String contentData;
  const SubHeaderBox({
    super.key,
    required this.subHeader,
    required this.subHeaderColor,
    required this.contentData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            subHeader,
            style: TextStyle(
              color: subHeaderColor,
              fontSize: Sizes.size12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Gaps.v20,
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            contentData,
            style: TextStyle(
              fontSize: Sizes.size16,
              fontWeight: FontWeight.w800,
              color: Palette().darkGray,
            ),
          ),
        ),
      ],
    );
  }
}

class GrayDivider extends StatelessWidget {
  final double height;
  const GrayDivider({
    super.key,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.5,
      height: height,
      decoration: BoxDecoration(
        color: Palette().lightGray,
      ),
    );
  }
}

class PeriodDropdownMenu extends StatelessWidget {
  final List<DropdownMenuItem<String>> items;
  final String value;
  final Function(String?) onChangedFunction;
  const PeriodDropdownMenu({
    super.key,
    required this.items,
    required this.value,
    required this.onChangedFunction,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 0.1,
      height: 35,
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          items: items,
          value: value,
          onChanged: (value) => onChangedFunction(value),
          buttonStyleData: ButtonStyleData(
            padding: const EdgeInsets.only(left: 14, right: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
              border: Border.all(
                color: Palette().lightGray,
                width: 0.5,
              ),
            ),
          ),
          iconStyleData: IconStyleData(
            icon: const Icon(
              Icons.expand_more_rounded,
            ),
            iconSize: 14,
            iconEnabledColor: Palette().normalGray,
            iconDisabledColor: Palette().normalGray,
          ),
          dropdownStyleData: DropdownStyleData(
            elevation: 2,
            width: size.width * 0.1,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(10),
              thumbVisibility: WidgetStateProperty.all(true),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 25,
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
            ),
          ),
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}

class TableModel {
  final String tableHeader;
  final String tableContent;
  TableModel({
    required this.tableHeader,
    required this.tableContent,
  });
}

class DashboardTable extends StatelessWidget {
  final String tableTitle;
  final Color titleColor;
  final List<TableModel> list;
  const DashboardTable({
    super.key,
    required this.tableTitle,
    required this.titleColor,
    required this.list,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SubHeader(
            headerText: tableTitle,
            containerColor: titleColor,
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Palette().lightGray,
              ),
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Column(
              children: [
                for (int i = 0; i < list.length; i++)
                  Column(
                    children: [
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                child: Text(
                                  list[i].tableHeader,
                                  textAlign: TextAlign.center,
                                  style: contentTextStyle,
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    width: 1,
                                    decoration: BoxDecoration(
                                      color: Palette().lightGray,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                child: Text(
                                  list[i].tableContent,
                                  textAlign: TextAlign.end,
                                  style: contentTextStyle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (i < list.length - 1)
                        Container(
                          height: 1,
                          decoration: BoxDecoration(
                            color: Palette().lightGray,
                          ),
                        ),
                    ],
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CognitionQuizTableModel {
  final String tableContentZero;
  final String tableContentOne;
  final String tableContentTwo;
  final String tableContentThree;
  CognitionQuizTableModel({
    required this.tableContentZero,
    required this.tableContentOne,
    required this.tableContentTwo,
    required this.tableContentThree,
  });
}

class CognitionQuizTable extends StatelessWidget {
  final String tableTitle;
  final Color titleColor;
  final String tableHeaderOne;
  final String tableHeaderTwo;
  final String tableHeaderThree;
  final List<CognitionQuizTableModel> list;
  const CognitionQuizTable({
    super.key,
    required this.tableTitle,
    required this.titleColor,
    required this.tableHeaderOne,
    required this.tableHeaderTwo,
    required this.tableHeaderThree,
    required this.list,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SubHeader(
            headerText: tableTitle,
            containerColor: titleColor,
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Palette().lightGray,
              ),
              borderRadius: BorderRadius.circular(3),
            ),
            clipBehavior: Clip.hardEdge,
            child: Container(
              decoration: BoxDecoration(
                color: Palette().lightGray,
              ),
              child: Column(
                children: [
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            child: Text(
                              textAlign: TextAlign.center,
                              "",
                              style: contentTextStyle,
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Expanded(
                              child: Container(
                                width: 1,
                                decoration: BoxDecoration(
                                  color: Palette().lightGray,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            child: Text(
                              textAlign: TextAlign.center,
                              tableHeaderOne,
                              style: contentTextStyle,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            child: Text(
                              textAlign: TextAlign.center,
                              tableHeaderTwo,
                              style: contentTextStyle,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            child: Text(
                              textAlign: TextAlign.center,
                              tableHeaderThree,
                              style: contentTextStyle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (int i = 0; i < list.length; i++)
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    child: Text(
                                      textAlign: TextAlign.center,
                                      list[i].tableContentZero,
                                      style: contentTextStyle,
                                    ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        width: 1,
                                        decoration: BoxDecoration(
                                          color: Palette().lightGray,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    child: Text(
                                      textAlign: TextAlign.end,
                                      list[i].tableContentOne,
                                      style: contentTextStyle,
                                    ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        width: 1,
                                        decoration: BoxDecoration(
                                          color: Palette().lightGray,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    child: Text(
                                      textAlign: TextAlign.end,
                                      list[i].tableContentTwo,
                                      style: contentTextStyle,
                                    ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        width: 1,
                                        decoration: BoxDecoration(
                                          color: Palette().lightGray,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    child: Text(
                                      textAlign: TextAlign.end,
                                      list[i].tableContentThree,
                                      style: contentTextStyle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (i < list.length - 1)
                            Container(
                              height: 1,
                              decoration: BoxDecoration(
                                color: Palette().lightGray,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

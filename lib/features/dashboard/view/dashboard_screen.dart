import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/common/widgets/period_button.dart';
import 'package:onldocc_admin/common/widgets/report_button.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/injicare_font.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
  final String _selectedPeriod = "이번달";

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
      _showDashboardConstruction();
      _diaryCalculateHeight();
      _aiCalculateHeight();
    });
  }

  @override
  void dispose() {
    removeDashboardConstruction();
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

  void _showDashboardConstruction() async {
    assert(overlayEntry == null);

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.black54,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ColorFiltered(
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                child: SvgPicture.asset(
                  "assets/svg/tools.svg",
                  width: 40,
                ),
              ),
              Gaps.v40,
              Text(
                "대시보드 화면은\n현재 작업 중입니다\n\n완성되기 전까지는 매달 메일로 전달드리는\n[인지케어 월별 리포트]를 참고해주세요",
                style: InjicareFont().body07.copyWith(
                      color: Colors.white,
                    ),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
    Overlay.of(context, debugRequiredFor: widget).insert(overlayEntry!);
  }

  void removeDashboardConstruction() {
    overlayEntry?.remove();
    overlayEntry = null;
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
                    const PeriodButton(),
                    ReportButton(
                      iconExists: true,
                      buttonText: "리포트 출력하기",
                      buttonColor: Palette().darkPurple,
                      action: () {},
                    )
                  ],
                ),
                Gaps.v32,
                // headerin
                Container(
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
                        HeaderBox(
                          headerText: "누적 회원가입 수",
                          headerColor: Palette().dashPink,
                          contentData: "820 명",
                        ),
                        Container(
                          width: 0.5,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Palette().darkGray,
                          ),
                        ),
                        HeaderBox(
                          headerText: "기간 회원가입 수",
                          headerColor: Palette().dashBlue,
                          contentData: "122 명",
                        ),
                        Container(
                          width: 0.5,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Palette().darkGray,
                          ),
                        ),
                        HeaderBox(
                          headerText: "기간 방문 횟수",
                          headerColor: Palette().dashGreen,
                          contentData: "2000 번",
                        ),
                        Container(
                          width: 0.5,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Palette().darkGray,
                          ),
                        ),
                        HeaderBox(
                          headerText: "기간 방문자 수",
                          headerColor: Palette().dashYellow,
                          contentData: "153 명",
                        ),
                      ],
                    ),
                  ),
                ),
                // 일기 데이터
                const DashType(type: "일기 데이터"),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        key: diaryColumnKey,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          WhiteBox(
                            boxTitle: "",
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                        xValueMapper: (datum, index) => datum.x,
                                        yValueMapper: (datum, index) => datum.y,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Gaps.v16,
                          WhiteBox(
                            boxTitle: "문제 풀기",
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 80,
                                left: 30,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
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
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Gaps.h20,
                    Expanded(
                      child: SizedBox(
                        height: diaryWidgetHeight,
                        child: WhiteBox(
                          boxTitle: "10회 이상 일기 작성자",
                          child: Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.only(
                                top: 20,
                              ),
                              itemCount: 10,
                              itemBuilder: (context, index) {
                                return Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        "${index + 1}",
                                        style: TextStyle(
                                          fontSize: Sizes.size16,
                                          fontWeight: FontWeight.w700,
                                          color: Palette().darkGray,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Palette().lightGray,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 8,
                                      child: Text(
                                        "김영자",
                                        style: TextStyle(
                                          fontSize: Sizes.size16,
                                          fontWeight: FontWeight.w600,
                                          color: Palette().darkGray,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "18회",
                                            style: TextStyle(
                                              fontSize: Sizes.size16,
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
                              separatorBuilder: (context, index) => Gaps.v10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
                Row(
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
                                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      flex: 2,
                      child: SizedBox(
                        height: aiWidgetHeight,
                        child: WhiteBox(
                          boxTitle: "AI 대화하기 사용자",
                          child: Expanded(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        "#",
                                        style: TextStyle(
                                          color: Palette().darkGray,
                                          fontWeight: FontWeight.w700,
                                          fontSize: Sizes.size14,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "사용 횟수",
                                            style: TextStyle(
                                              color: Palette().darkGray,
                                              fontWeight: FontWeight.w700,
                                              fontSize: Sizes.size14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "총 사용 시간",
                                            style: TextStyle(
                                              color: Palette().darkGray,
                                              fontWeight: FontWeight.w700,
                                              fontSize: Sizes.size14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Gaps.v10,
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: 5,
                                    padding: const EdgeInsets.only(top: 10),
                                    separatorBuilder: (context, index) =>
                                        Gaps.v10,
                                    itemBuilder: (context, index) {
                                      return Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              "${index + 1}",
                                              style: TextStyle(
                                                color: Palette().darkGray,
                                                fontWeight: FontWeight.w600,
                                                fontSize: Sizes.size14,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    color: Palette().lightGray,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              "김영자",
                                              style: TextStyle(
                                                color: Palette().darkGray,
                                                fontWeight: FontWeight.w600,
                                                fontSize: Sizes.size14,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "18회",
                                                  style: TextStyle(
                                                    color: Palette().darkGray,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: Sizes.size14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "4분 30초",
                                                  style: TextStyle(
                                                    color: Palette().darkGray,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: Sizes.size14,
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
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                // 걸음수 데이터
                const DashType(type: "걸음수 데이터"),
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
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
                        ),
                        Gaps.h20,
                        Expanded(
                          flex: 2,
                          child: Container(),
                        )
                      ],
                    ),
                    Gaps.v20,
                    SfCartesianChart(
                      primaryXAxis: const CategoryAxis(),
                      series: <CartesianSeries>[
                        SplineSeries<ChartData, String>(
                          dataSource: stepData,
                          xValueMapper: (ChartData datum, index) => datum.x,
                          yValueMapper: (ChartData datum, index) => datum.y,
                          pointColorMapper: (datum, index) =>
                              Palette().darkPurple,
                        ),
                      ],
                    )
                  ],
                ),
                const DashType(type: "보호자 지정 알림"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "사용자가 설정한 '설정일'을 기준으로 사용자의 활동이 없을 경우 상태에 빨간불 표시가 되어있습니다.",
                      style: TextStyle(
                        fontSize: Sizes.size12,
                        color: Palette().normalGray,
                      ),
                    ),
                  ],
                ),
                Gaps.v16,
                Row(
                  children: [
                    Expanded(
                      child: WhiteBox(
                        boxTitle: "",
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "#",
                                    style: TextStyle(
                                      color: Palette().darkGray,
                                      fontWeight: FontWeight.w700,
                                      fontSize: Sizes.size14,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "사진",
                                    style: TextStyle(
                                      color: Palette().darkGray,
                                      fontWeight: FontWeight.w700,
                                      fontSize: Sizes.size14,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "이름",
                                    style: TextStyle(
                                      color: Palette().darkGray,
                                      fontWeight: FontWeight.w700,
                                      fontSize: Sizes.size14,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "설정일",
                                        style: TextStyle(
                                          color: Palette().darkGray,
                                          fontWeight: FontWeight.w700,
                                          fontSize: Sizes.size14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "상태",
                                        style: TextStyle(
                                          color: Palette().darkGray,
                                          fontWeight: FontWeight.w700,
                                          fontSize: Sizes.size14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Gaps.v10,
                            SizedBox(
                              height: 150,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: ListView.separated(
                                      itemCount: 5,
                                      padding: const EdgeInsets.only(top: 10),
                                      separatorBuilder: (context, index) =>
                                          Gaps.v10,
                                      itemBuilder: (context, index) {
                                        return Row(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Text(
                                                "${index + 1}",
                                                style: TextStyle(
                                                  color: Palette().darkGray,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: Sizes.size14,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 30,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      color:
                                                          Palette().lightGray,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                "김영자",
                                                style: TextStyle(
                                                  color: Palette().darkGray,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: Sizes.size14,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "7일",
                                                    style: TextStyle(
                                                      color: Palette().darkGray,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: Sizes.size14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "🚨",
                                                    style: TextStyle(
                                                      color: Palette().darkGray,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: Sizes.size14,
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
                )
              ],
            ),
          ),
        )
      ],
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
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Palette().lightGray,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 8,
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "2회",
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

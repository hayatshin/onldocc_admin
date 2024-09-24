import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/common/widgets/period_button.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/dashboard/model/ai_chat_model.dart';
import 'package:onldocc_admin/features/dashboard/model/cognition_data_test_model.dart';
import 'package:onldocc_admin/features/dashboard/model/dashboard_count_model.dart';
import 'package:onldocc_admin/features/dashboard/model/step_data_model.dart';
import 'package:onldocc_admin/features/dashboard/view_models/dashboard_view_model.dart';
import 'package:onldocc_admin/features/event/view/event_screen.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/features/users/view_models/user_view_model.dart';
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

  List<UserModel?> _totalUserDataList = [];
  List<UserModel?> _periodUserDataList = [];

  bool _loadingFinished = false;

  DateRange _selectedDateRange = DateRange(
    getThisWeekMonday(),
    DateTime.now(),
  );
  int _selectedStartSeconds =
      convertStartDateTimeToSeconds(getThisWeekMonday());
  int _selectedEndSeconds = convertDateTimeToSeconds(DateTime.now());

  final TextStyle _headerTextStyle = TextStyle(
    fontSize: Sizes.size12,
    fontWeight: FontWeight.w600,
    color: Palette().darkGray,
  );

  final TextStyle _contentTextStyle = TextStyle(
    fontSize: Sizes.size10,
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

  // data
  List<DashboardCountModel> _diaryList = [];
  List<DashboardCountModel> _commentList = [];
  List<DashboardCountModel> _likeList = [];
  List<DashboardCountModel> _quizMathList = [];
  List<DashboardCountModel> _quizMultipleChoicesList = [];
  List<CognitionDataTestModel> _cognitionTestList = [];
  List<AiChatModel> _aiChatList = [];
  String _chatSumTime = "";
  String _chatAvgTime = "";
  List<StepDataModel> _stepDataList = [];

  @override
  void initState() {
    super.initState();

    if (selectContractRegion.value != null) {
      _initializeDashboard();
    }

    selectContractRegion.addListener(() async {
      if (mounted) {
        await ref
            .read(userProvider.notifier)
            .initializeUserList(selectContractRegion.value!.subdistrictId);
        _initializeDashboard();
      }
    });

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
                          _selectedStartSeconds = convertStartDateTimeToSeconds(
                              dateRange.startDate!);
                          _selectedEndSeconds =
                              convertEndDateTimeToSeconds(dateRange.endDate!);
                          _loadingFinished = false;
                        });
                        _removePeriodCalender();
                        _initializeDashboard();

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

  void _initializeDashboard() {
    _initializeUserDashboard();
    _initializeDiaryDashboard();
    _initializeCognitionTestType();
    _initializeAiChatTime();
    _initializeStepData();
  }

// 회원 가입자 수 데이터
  Future<void> _initializeUserDashboard() async {
    List<UserModel?> userDataList = ref.read(userProvider).value ??
        await ref
            .read(userProvider.notifier)
            .initializeUserList(selectContractRegion.value!.subdistrictId);

    final periodUserDataList = userDataList
        .where((element) =>
            _selectedStartSeconds <= element!.createdAt &&
            element.createdAt <= _selectedEndSeconds)
        .toList();
    if (selectContractRegion.value!.contractCommunityId == null) {
      // 전체보기
      if (mounted) {
        setState(() {
          _totalUserDataList = userDataList;
          _periodUserDataList = periodUserDataList;
        });
      }
    } else {
      // 기관 선택
      final filterList = userDataList
          .where((e) =>
              e!.contractCommunityId ==
              selectContractRegion.value!.contractCommunityId)
          .toList();
      final filterPeriodList = periodUserDataList
          .where((e) =>
              e!.contractCommunityId ==
              selectContractRegion.value!.contractCommunityId)
          .toList();
      if (mounted) {
        setState(() {
          _totalUserDataList = filterList;
          _periodUserDataList = filterPeriodList;
        });
      }
    }
  }

  // 일기 데이터
  Future<void> _initializeDiaryDashboard() async {
    final diaryList = await ref
        .read(dashboardProvider.notifier)
        .diaryCount(_selectedStartSeconds, _selectedEndSeconds);
    final commentList = await ref
        .read(dashboardProvider.notifier)
        .commentCount(_selectedStartSeconds, _selectedEndSeconds);
    final likeList = await ref
        .read(dashboardProvider.notifier)
        .likeCount(_selectedStartSeconds, _selectedEndSeconds);
    final quizMathList = await ref
        .read(dashboardProvider.notifier)
        .quizMath(_selectedStartSeconds, _selectedEndSeconds);
    final quizMultipleChoices = await ref
        .read(dashboardProvider.notifier)
        .quizMultipleChoices(_selectedStartSeconds, _selectedEndSeconds);

    setState(() {
      _diaryList = diaryList;
      _commentList = commentList;
      _likeList = likeList;
      _quizMathList = quizMathList;
      _quizMultipleChoicesList = quizMultipleChoices;
    });
  }

  // 인지 검사 데이터
  Future<void> _initializeCognitionTestType() async {
    final cognitionTesetList = await ref
        .read(dashboardProvider.notifier)
        .cognitionTest(_selectedStartSeconds, _selectedEndSeconds);

    setState(() {
      _cognitionTestList = cognitionTesetList;
    });
  }

  // AI
  String formatDuration(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    return "${hours != 0 ? "$hours " : ""}${minutes != 0 ? "$minutes " : ""}${seconds != 0 ? "$seconds" : "0초"}";
  }

  String _getSumChatTimeString(List<AiChatModel> list) {
    int chatSumTime = 0;

    for (int i = 0; i < list.length; i++) {
      chatSumTime += list[i].chatTime;
    }
    return formatDuration(chatSumTime);
  }

  double _getSumChatTimeDouble(List<AiChatModel> list) {
    double chatSumTime = 0;

    for (int i = 0; i < list.length; i++) {
      chatSumTime += list[i].chatTime;
    }
    return chatSumTime;
  }

  Future<void> _initializeAiChatTime() async {
    final aiChatList = await ref
        .read(dashboardProvider.notifier)
        .aiChat(_selectedStartSeconds, _selectedEndSeconds);

    int chatSumTime = 0;
    double chatAvgTime = 0;
    for (int i = 0; i < aiChatList.length; i++) {
      chatSumTime += aiChatList[i].chatTime;
    }
    chatAvgTime = aiChatList.isNotEmpty ? chatSumTime / aiChatList.length : 0;

    setState(() {
      _aiChatList = aiChatList;
      _chatSumTime = formatDuration(chatSumTime);
      _chatAvgTime = formatDuration(chatAvgTime.toInt());
    });
  }

  List<String> _generateDateStrings() {
    List<String> dateStrings = [];
    for (DateTime current = _selectedDateRange.start;
        current.isBefore(_selectedDateRange.end.add(const Duration(days: 1)));
        current = current.add(const Duration(days: 1))) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(current);
      dateStrings.add(formattedDate);
    }
    return dateStrings;
  }

  Future<void> _initializeStepData() async {
    final dateStrings = _generateDateStrings();
    final stepDataList =
        await ref.read(dashboardProvider.notifier).steps(dateStrings);

    setState(() {
      _stepDataList = stepDataList;
    });
  }

  double _getAvgStepDouble(List<StepDataModel> steps) {
    double sumStep = 0;

    for (int i = 0; i < steps.length; i++) {
      sumStep += steps[i].step;
    }
    return steps.isEmpty ? 0 : (sumStep / steps.length).roundToDouble();
  }

  // void _generatePdf() async {
  //   final pdf = pw.Document();

  //   pdf.addPage(
  //     pw.Page(
  //       pageFormat: PdfPageFormat.a4,
  //       build: (context) {
  //         return pw.Center(
  //           child: pw.Column(
  //             children: [],
  //           ),
  //         );
  //       },
  //     ),
  //   );

  //   var savedFile = await pdf.save();
  //   List<int> fileInts = List.from(savedFile);
  //   html.AnchorElement()
  //     ..href =
  //         "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(fileInts)}"
  //     ..setAttribute("download", "${DateTime.now().millisecondsSinceEpoch}.pdf")
  //     ..click();
  // }

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
                  mainAxisAlignment: MainAxisAlignment.start,
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
                    // ReportButton(
                    //   iconExists: true,
                    //   buttonText: "차트 출력하기",
                    //   buttonColor: Palette().darkPurple,
                    //   action: _generatePdf,
                    // )
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
                                  contentData: "${_totalUserDataList.length} 명",
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
                                  contentData:
                                      "${_periodUserDataList.length} 명",
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
                            UserGenderAgeTable(
                                title: "누적 회원가입자 수",
                                userDataList: _totalUserDataList),
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
                                UserGenderAgeTable(
                                  title: "기간 내 회원가입자 수",
                                  userDataList: _periodUserDataList,
                                ),
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
                                    contentData: "${_diaryList.length} 회",
                                  ),
                                  const GrayDivider(
                                    height: 60,
                                  ),
                                  SubHeaderBox(
                                    subHeader: "일기 작성자 수",
                                    subHeaderColor: Palette().dashPink,
                                    contentData:
                                        "${removeDuplicateUserId(_diaryList).length} 명",
                                  ),
                                  const GrayDivider(
                                    height: 60,
                                  ),
                                  SubHeaderBox(
                                    subHeader: "댓글 횟수",
                                    subHeaderColor: Palette().dashBlue,
                                    contentData: "${_commentList.length} 회",
                                  ),
                                  const GrayDivider(
                                    height: 60,
                                  ),
                                  SubHeaderBox(
                                    subHeader: "좋아요 횟수",
                                    subHeaderColor: Palette().dashGreen,
                                    contentData: "${_likeList.length} 회",
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
                                    height: 350,
                                    child: SfCircularChart(
                                      palette: const [
                                        Color(0xffD53736),
                                        Color(0xffE68E3C),
                                        Color(0xffE5CF50),
                                        Color(0xff4AA058),
                                        Color(0xff5D9DDD),
                                        Color(0xffC62D8C),
                                        Color(0xff633794),
                                        Color(0xff5D748D),
                                        Color(0xff663717),
                                        Color(0xff0F1113),
                                        Color(0xff666666),
                                      ],
                                      legend: const Legend(isVisible: true),
                                      series: <PieSeries<ChartData, String>>[
                                        PieSeries(
                                          explode: true,
                                          explodeIndex: 0,
                                          dataSource: [
                                            ChartData(
                                                "기뻐요",
                                                ((_diaryList
                                                            .where((element) =>
                                                                element
                                                                    .diaryTodayMood ==
                                                                0)
                                                            .length
                                                            .toDouble()) /
                                                        _diaryList.length) *
                                                    100),
                                            ChartData(
                                                "설레요",
                                                ((_diaryList
                                                            .where((element) =>
                                                                element
                                                                    .diaryTodayMood ==
                                                                1)
                                                            .length
                                                            .toDouble()) /
                                                        _diaryList.length) *
                                                    100),
                                            ChartData(
                                                "감사해요",
                                                ((_diaryList
                                                            .where((element) =>
                                                                element
                                                                    .diaryTodayMood ==
                                                                2)
                                                            .length
                                                            .toDouble()) /
                                                        _diaryList.length) *
                                                    100),
                                            ChartData(
                                                "평온해요",
                                                ((_diaryList
                                                            .where((element) =>
                                                                element
                                                                    .diaryTodayMood ==
                                                                3)
                                                            .length
                                                            .toDouble()) /
                                                        _diaryList.length) *
                                                    100),
                                            ChartData(
                                                "그냥 그래요",
                                                ((_diaryList
                                                            .where((element) =>
                                                                element
                                                                    .diaryTodayMood ==
                                                                4)
                                                            .length
                                                            .toDouble()) /
                                                        _diaryList.length) *
                                                    100),
                                            ChartData(
                                                "외로워요",
                                                ((_diaryList
                                                            .where((element) =>
                                                                element
                                                                    .diaryTodayMood ==
                                                                5)
                                                            .length
                                                            .toDouble()) /
                                                        _diaryList.length) *
                                                    100),
                                            ChartData(
                                                "불안해요",
                                                ((_diaryList
                                                            .where((element) =>
                                                                element
                                                                    .diaryTodayMood ==
                                                                6)
                                                            .length
                                                            .toDouble()) /
                                                        _diaryList.length) *
                                                    100),
                                            ChartData(
                                                "우울해요",
                                                ((_diaryList
                                                            .where((element) =>
                                                                element
                                                                    .diaryTodayMood ==
                                                                7)
                                                            .length
                                                            .toDouble()) /
                                                        _diaryList.length) *
                                                    100),
                                            ChartData(
                                                "슬퍼요",
                                                ((_diaryList
                                                            .where((element) =>
                                                                element
                                                                    .diaryTodayMood ==
                                                                8)
                                                            .length
                                                            .toDouble()) /
                                                        _diaryList.length) *
                                                    100),
                                            ChartData(
                                                "화나요",
                                                ((_diaryList
                                                            .where((element) =>
                                                                element
                                                                    .diaryTodayMood ==
                                                                9)
                                                            .length
                                                            .toDouble()) /
                                                        _diaryList.length) *
                                                    100),
                                          ],
                                          xValueMapper: (datum, index) =>
                                              datum.x,
                                          yValueMapper: (datum, index) =>
                                              datum.y,
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: DashboardTable(
                                      tableTitle: "",
                                      titleColor: Palette().dashYellow,
                                      list: [
                                        TableModel(
                                            tableHeader: "기뻐요",
                                            tableContent:
                                                "${_diaryList.where((element) => element.diaryTodayMood == 0).length} 회"),
                                        TableModel(
                                            tableHeader: "설레요",
                                            tableContent:
                                                "${_diaryList.where((element) => element.diaryTodayMood == 1).length} 회"),
                                        TableModel(
                                            tableHeader: "감사해요",
                                            tableContent:
                                                "${_diaryList.where((element) => element.diaryTodayMood == 2).length} 회"),
                                        TableModel(
                                            tableHeader: "평온해요",
                                            tableContent:
                                                "${_diaryList.where((element) => element.diaryTodayMood == 3).length} 회"),
                                        TableModel(
                                            tableHeader: "그냥 그래요",
                                            tableContent:
                                                "${_diaryList.where((element) => element.diaryTodayMood == 4).length} 회"),
                                        TableModel(
                                            tableHeader: "외로워요",
                                            tableContent:
                                                "${_diaryList.where((element) => element.diaryTodayMood == 5).length} 회"),
                                        TableModel(
                                            tableHeader: "불안해요",
                                            tableContent:
                                                "${_diaryList.where((element) => element.diaryTodayMood == 6).length} 회"),
                                        TableModel(
                                            tableHeader: "우울해요",
                                            tableContent:
                                                "${_diaryList.where((element) => element.diaryTodayMood == 7).length} 회"),
                                        TableModel(
                                            tableHeader: "슬퍼요",
                                            tableContent:
                                                "${_diaryList.where((element) => element.diaryTodayMood == 8).length} 회"),
                                        TableModel(
                                            tableHeader: "화나요",
                                            tableContent:
                                                "${_diaryList.where((element) => element.diaryTodayMood == 9).length} 회"),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Gaps.v24,
                            CognitionQuizWidget(
                              quizTitle: "수학 문제",
                              quizlist: _quizMathList,
                            ),
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
                                        tableHeader: "남성",
                                        tableContent:
                                            "${_diaryList.where((element) => element.userGender == "남성").length} 명"),
                                    TableModel(
                                        tableHeader: "여성",
                                        tableContent:
                                            "${_diaryList.where((element) => element.userGender == "여성").length} 명"),
                                  ],
                                ),
                                Gaps.v10,
                                DashboardTable(
                                  tableTitle: "연령별 일기 작성 횟수",
                                  titleColor: Palette().dashPink,
                                  list: [
                                    TableModel(
                                        tableHeader: "40대 미만",
                                        tableContent:
                                            "${_diaryList.where((element) => element.userAgeGroup == "40대 미만").length} 명"),
                                    TableModel(
                                        tableHeader: "40대",
                                        tableContent:
                                            "${_diaryList.where((element) => element.userAgeGroup == "40대").length} 명"),
                                    TableModel(
                                        tableHeader: "50대",
                                        tableContent:
                                            "${_diaryList.where((element) => element.userAgeGroup == "50대").length} 명"),
                                    TableModel(
                                        tableHeader: "60대",
                                        tableContent:
                                            "${_diaryList.where((element) => element.userAgeGroup == "60대").length} 명"),
                                    TableModel(
                                        tableHeader: "70대",
                                        tableContent:
                                            "${_diaryList.where((element) => element.userAgeGroup == "70대").length} 명"),
                                    TableModel(
                                        tableHeader: "80대",
                                        tableContent:
                                            "${_diaryList.where((element) => element.userAgeGroup == "80대").length} 명"),
                                    TableModel(
                                        tableHeader: "90대 이상",
                                        tableContent:
                                            "${_diaryList.where((element) => element.userAgeGroup == "90대 이상").length} 명"),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(),
                            CognitionQuizWidget(
                              quizTitle: "객관식 문제",
                              quizlist: _quizMultipleChoicesList,
                            ),
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
                              contentData: "${_cognitionTestList.length} 회",
                            ),
                            const GrayDivider(height: 60),
                            SubHeaderBox(
                              subHeader: "온라인 치매 검사",
                              subHeaderColor: Palette().dashBlue,
                              contentData:
                                  "${_cognitionTestList.where((element) => element.testType == "alzheimer_test").toList().length} 회",
                            ),
                            const GrayDivider(height: 60),
                            SubHeaderBox(
                              subHeader: "노인 우울척도 검사",
                              subHeaderColor: Palette().dashGreen,
                              contentData:
                                  "${_cognitionTestList.where((element) => element.testType == "depression_test").toList().length} 회",
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
                Row(
                  children: [
                    // 온라인 치매 검사
                    CognitionDetailTestBox(
                      detailTest: "온라인 치매 검사",
                      testResult1: "정상",
                      testResult1Data:
                          "${_cognitionTestList.where((element) => element.testType == "alzheimer_test" && element.result == "정상").toList().length}회",
                      testResult2: "치매 조기 검진 필요",
                      testResult2Data:
                          "${_cognitionTestList.where((element) => element.testType == "alzheimer_test" && element.result == "치매 조기 검진 필요").toList().length}회",
                      listName: "치매 조기 검진 필요 대상자",
                      list: _cognitionTestList
                          .where((element) =>
                              element.testType == "alzheimer_test" &&
                              element.result == "치매 조기 검진 필요")
                          .toList(),
                    ),
                    Gaps.h20,
                    CognitionDetailTestBox(
                      detailTest: "노인 우울척도 검사",
                      testResult1: "정상",
                      testResult1Data:
                          "${_cognitionTestList.where((element) => element.testType == "depression_test" && element.result == "정상").toList().length}회",
                      testResult2: "우울",
                      testResult2Data:
                          "${_cognitionTestList.where((element) => element.testType == "depression_test" && element.result == "우울").toList().length}회",
                      listName: "우울 대상자",
                      list: _cognitionTestList
                          .where((element) =>
                              element.testType == "depression_test" &&
                              element.result == "우울")
                          .toList(),
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
                                      contentData: "${_aiChatList.length} 회",
                                    ),
                                    Gaps.v20,
                                    SubHeaderBox(
                                      subHeader: "총 대화 시간",
                                      subHeaderColor: Palette().dashBlue,
                                      contentData: _chatSumTime,
                                    ),
                                    Gaps.v20,
                                    SubHeaderBox(
                                      subHeader: "평균 대화 시간",
                                      subHeaderColor: Palette().dashGreen,
                                      contentData: _chatAvgTime,
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
                                  tableHeader: "남성",
                                  tableContent: _getSumChatTimeString(
                                    _aiChatList
                                        .where((element) =>
                                            element.userGender == "남성")
                                        .toList(),
                                  ),
                                ),
                                TableModel(
                                    tableHeader: "여성",
                                    tableContent: _getSumChatTimeString(
                                      _aiChatList
                                          .where((element) =>
                                              element.userGender == "여성")
                                          .toList(),
                                    )),
                              ],
                            ),
                            Gaps.v5,
                            DashboardTable(
                              tableTitle: "연령별 AI 대화 시간",
                              titleColor: Palette().dashGreen,
                              list: [
                                TableModel(
                                    tableHeader: "40대 미만",
                                    tableContent: _getSumChatTimeString(
                                      _aiChatList
                                          .where((element) =>
                                              element.userAgeGroup == "40대 미만")
                                          .toList(),
                                    )),
                                TableModel(
                                    tableHeader: "40대",
                                    tableContent: _getSumChatTimeString(
                                      _aiChatList
                                          .where((element) =>
                                              element.userAgeGroup == "40대")
                                          .toList(),
                                    )),
                                TableModel(
                                    tableHeader: "50대",
                                    tableContent: _getSumChatTimeString(
                                      _aiChatList
                                          .where((element) =>
                                              element.userAgeGroup == "50대")
                                          .toList(),
                                    )),
                                TableModel(
                                    tableHeader: "60대",
                                    tableContent: _getSumChatTimeString(
                                      _aiChatList
                                          .where((element) =>
                                              element.userAgeGroup == "60대")
                                          .toList(),
                                    )),
                                TableModel(
                                    tableHeader: "70대",
                                    tableContent: _getSumChatTimeString(
                                      _aiChatList
                                          .where((element) =>
                                              element.userAgeGroup == "70대")
                                          .toList(),
                                    )),
                                TableModel(
                                    tableHeader: "80대",
                                    tableContent: _getSumChatTimeString(
                                      _aiChatList
                                          .where((element) =>
                                              element.userAgeGroup == "80대")
                                          .toList(),
                                    )),
                                TableModel(
                                    tableHeader: "90대 이상",
                                    tableContent: _getSumChatTimeString(
                                      _aiChatList
                                          .where((element) =>
                                              element.userAgeGroup == "90대 이상")
                                          .toList(),
                                    )),
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
                                  dataSource: [
                                    ChartData(
                                        "40대 미만",
                                        _getSumChatTimeDouble(
                                          _aiChatList
                                              .where((element) =>
                                                  element.userAgeGroup ==
                                                  "40대 미만")
                                              .toList(),
                                        )),
                                    ChartData(
                                        "40대",
                                        _getSumChatTimeDouble(
                                          _aiChatList
                                              .where((element) =>
                                                  element.userAgeGroup == "40대")
                                              .toList(),
                                        )),
                                    ChartData(
                                        "50대",
                                        _getSumChatTimeDouble(
                                          _aiChatList
                                              .where((element) =>
                                                  element.userAgeGroup == "50대")
                                              .toList(),
                                        )),
                                    ChartData(
                                        "60대",
                                        _getSumChatTimeDouble(
                                          _aiChatList
                                              .where((element) =>
                                                  element.userAgeGroup == "60대")
                                              .toList(),
                                        )),
                                    ChartData(
                                        "70대",
                                        _getSumChatTimeDouble(
                                          _aiChatList
                                              .where((element) =>
                                                  element.userAgeGroup == "70대")
                                              .toList(),
                                        )),
                                    ChartData(
                                        "80대",
                                        _getSumChatTimeDouble(
                                          _aiChatList
                                              .where((element) =>
                                                  element.userAgeGroup == "80대")
                                              .toList(),
                                        )),
                                    ChartData(
                                        "90대 이상",
                                        _getSumChatTimeDouble(
                                          _aiChatList
                                              .where((element) =>
                                                  element.userAgeGroup ==
                                                  "90대 이상")
                                              .toList(),
                                        )),
                                  ],
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
                                            "${_getAvgStepDouble(_stepDataList)} 보",
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
                                          tableContent:
                                              "${_getAvgStepDouble(_stepDataList.where((element) => element.userGender == "남성").toList())} 보"),
                                      TableModel(
                                          tableHeader: "여성",
                                          tableContent:
                                              "${_getAvgStepDouble(_stepDataList.where((element) => element.userGender == "여성").toList())} 보"),
                                    ],
                                  ),
                                  Gaps.v10,
                                  DashboardTable(
                                    tableTitle: "연령별 평균 걸음수",
                                    titleColor: Palette().dashGreen,
                                    list: [
                                      TableModel(
                                          tableHeader: "40대 미만",
                                          tableContent:
                                              "${_getAvgStepDouble(_stepDataList.where((element) => element.userAgeGroup == "40대 미만").toList())} 보"),
                                      TableModel(
                                          tableHeader: "40대",
                                          tableContent:
                                              "${_getAvgStepDouble(_stepDataList.where((element) => element.userAgeGroup == "40대").toList())} 보"),
                                      TableModel(
                                          tableHeader: "50대",
                                          tableContent:
                                              "${_getAvgStepDouble(_stepDataList.where((element) => element.userAgeGroup == "50대").toList())} 보"),
                                      TableModel(
                                          tableHeader: "60대",
                                          tableContent:
                                              "${_getAvgStepDouble(_stepDataList.where((element) => element.userAgeGroup == "60대").toList())} 보"),
                                      TableModel(
                                          tableHeader: "70대",
                                          tableContent:
                                              "${_getAvgStepDouble(_stepDataList.where((element) => element.userAgeGroup == "70대").toList())} 보"),
                                      TableModel(
                                          tableHeader: "80대",
                                          tableContent:
                                              "${_getAvgStepDouble(_stepDataList.where((element) => element.userAgeGroup == "80대").toList())} 보"),
                                      TableModel(
                                          tableHeader: "90대 이상",
                                          tableContent:
                                              "${_getAvgStepDouble(_stepDataList.where((element) => element.userAgeGroup == "90대 이상").toList())} 보"),
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
                                  dataSource: [
                                    ChartData(
                                      "40대 미만",
                                      _getAvgStepDouble(_stepDataList
                                          .where((element) =>
                                              element.userAgeGroup == "40대 미만")
                                          .toList()),
                                    ),
                                    ChartData(
                                      "40대",
                                      _getAvgStepDouble(_stepDataList
                                          .where((element) =>
                                              element.userAgeGroup == "40대")
                                          .toList()),
                                    ),
                                    ChartData(
                                      "50대",
                                      _getAvgStepDouble(_stepDataList
                                          .where((element) =>
                                              element.userAgeGroup == "50대")
                                          .toList()),
                                    ),
                                    ChartData(
                                      "60대",
                                      _getAvgStepDouble(_stepDataList
                                          .where((element) =>
                                              element.userAgeGroup == "60대")
                                          .toList()),
                                    ),
                                    ChartData(
                                      "70대",
                                      _getAvgStepDouble(_stepDataList
                                          .where((element) =>
                                              element.userAgeGroup == "70대")
                                          .toList()),
                                    ),
                                    ChartData(
                                      "80대",
                                      _getAvgStepDouble(_stepDataList
                                          .where((element) =>
                                              element.userAgeGroup == "80대")
                                          .toList()),
                                    ),
                                    ChartData(
                                      "90대 이상",
                                      _getAvgStepDouble(_stepDataList
                                          .where((element) =>
                                              element.userAgeGroup == "90대 이상")
                                          .toList()),
                                    ),
                                  ],
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
  final List<CognitionDataTestModel> list;
  const CognitionDetailTestBox({
    super.key,
    required this.detailTest,
    required this.testResult1,
    required this.testResult1Data,
    required this.testResult2,
    required this.testResult2Data,
    required this.listName,
    required this.list,
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
                    height: 96,
                    child: ListView.separated(
                      itemCount: list.length,
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
                                list[index].userName,
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
                                list[index].userGender,
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
                                list[index].userAge,
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
                                    list[index].userPhone,
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

List<DashboardCountModel> removeDuplicateUserId(
    List<DashboardCountModel> list) {
  List<DashboardCountModel> uniqueUserIds = [];
  for (DashboardCountModel model in list) {
    if (!uniqueUserIds.any((element) => element.userId == model.userId)) {
      uniqueUserIds.add(model);
    }
  }
  return uniqueUserIds;
}

class CognitionQuizWidget extends StatelessWidget {
  final String quizTitle;
  final List<DashboardCountModel> quizlist;
  const CognitionQuizWidget({
    super.key,
    required this.quizTitle,
    required this.quizlist,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WhiteBox(
          boxTitle: "문제 풀기 [$quizTitle]",
          child: Padding(
            padding: const EdgeInsets.only(
              right: 80,
              left: 30,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 수학
                Expanded(
                  flex: 3,
                  child: Text(
                    "${quizlist.length} 회",
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            "${quizlist.where((element) => element.quizCorrect == true).toList().length} 회",
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
                            "${quizlist.where((element) => element.quizCorrect == false).toList().length} 회",
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
            tableTitle: "성별 $quizTitle 데이터",
            titleColor: Palette().dashBlue,
            tableHeaderOne: "총 문제풀기 횟수",
            tableHeaderTwo: "틀린 횟수",
            tableHeaderThree: "빈도",
            list: [
              CognitionQuizTableModel(
                tableContentZero: "남성",
                tableContentOne:
                    "${quizlist.where((element) => element.userGender == "남성").length} 회",
                tableContentTwo:
                    "${quizlist.where((element) => element.userGender == "남성" && element.quizCorrect == false).length} 회",
                tableContentThree: quizlist
                        .map((element) => element.userGender == "남성")
                        .isEmpty
                    ? "0.00"
                    : ((quizlist
                                .where((element) =>
                                    element.userGender == "남성" &&
                                    element.quizCorrect == false)
                                .length) /
                            (quizlist
                                .where((element) => element.userGender == "남성")
                                .length))
                        .toStringAsFixed(2),
              ),
              CognitionQuizTableModel(
                tableContentZero: "여성",
                tableContentOne:
                    "${quizlist.where((element) => element.userGender == "여성").length} 회",
                tableContentTwo:
                    "${quizlist.where((element) => element.userGender == "여성" && element.quizCorrect == false).length} 회",
                tableContentThree: quizlist
                        .where((element) => element.userGender == "여성")
                        .isEmpty
                    ? "0.00"
                    : ((quizlist
                                .where((element) =>
                                    element.userGender == "여성" &&
                                    element.quizCorrect == false)
                                .length) /
                            (quizlist
                                .where((element) => element.userGender == "여성")
                                .length))
                        .toStringAsFixed(2),
              ),
            ]),
        Gaps.v10,
        CognitionQuizTable(
            tableTitle: "연령별 $quizTitle 데이터",
            titleColor: Palette().dashBlue,
            tableHeaderOne: "총 문제풀기 횟수",
            tableHeaderTwo: "틀린 횟수",
            tableHeaderThree: "빈도",
            list: [
              CognitionQuizTableModel(
                tableContentZero: "40대 미만",
                tableContentOne:
                    "${quizlist.where((element) => element.userAgeGroup == "40대 미만").length} 회",
                tableContentTwo:
                    "${quizlist.where((element) => element.userAgeGroup == "40대 미만" && element.quizCorrect == false).length} 회",
                tableContentThree: quizlist
                        .where((element) => element.userAgeGroup == "40대 미만")
                        .isEmpty
                    ? "0.00"
                    : ((quizlist
                                .where((element) =>
                                    element.userAgeGroup == "40대 미만" &&
                                    element.quizCorrect == false)
                                .length) /
                            (quizlist
                                .where((element) =>
                                    element.userAgeGroup == "40대 미만")
                                .length))
                        .toStringAsFixed(2),
              ),
              CognitionQuizTableModel(
                tableContentZero: "40대",
                tableContentOne:
                    "${quizlist.where((element) => element.userAgeGroup == "40대").length} 회",
                tableContentTwo:
                    "${quizlist.where((element) => element.userAgeGroup == "40대" && element.quizCorrect == false).length} 회",
                tableContentThree: quizlist
                        .where((element) => element.userAgeGroup == "40대")
                        .isEmpty
                    ? "0.00"
                    : ((quizlist
                                .where((element) =>
                                    element.userAgeGroup == "40대" &&
                                    element.quizCorrect == false)
                                .length) /
                            (quizlist
                                .where(
                                    (element) => element.userAgeGroup == "40대")
                                .length))
                        .toStringAsFixed(2),
              ),
              CognitionQuizTableModel(
                tableContentZero: "50대",
                tableContentOne:
                    "${quizlist.where((element) => element.userAgeGroup == "50대").length} 회",
                tableContentTwo:
                    "${quizlist.where((element) => element.userAgeGroup == "50대" && element.quizCorrect == false).length} 회",
                tableContentThree: quizlist
                        .where((element) => element.userAgeGroup == "50대")
                        .isEmpty
                    ? "0.00"
                    : ((quizlist
                                .where((element) =>
                                    element.userAgeGroup == "50대" &&
                                    element.quizCorrect == false)
                                .length) /
                            (quizlist
                                .where(
                                    (element) => element.userAgeGroup == "50대")
                                .length))
                        .toStringAsFixed(2),
              ),
              CognitionQuizTableModel(
                tableContentZero: "60대",
                tableContentOne:
                    "${quizlist.where((element) => element.userAgeGroup == "60대").length} 회",
                tableContentTwo:
                    "${quizlist.where((element) => element.userAgeGroup == "60대" && element.quizCorrect == false).length} 회",
                tableContentThree: quizlist
                        .where((element) => element.userAgeGroup == "60대")
                        .isEmpty
                    ? "0.00"
                    : ((quizlist
                                .where((element) =>
                                    element.userAgeGroup == "60대" &&
                                    element.quizCorrect == false)
                                .length) /
                            (quizlist
                                .where(
                                    (element) => element.userAgeGroup == "60대")
                                .length))
                        .toStringAsFixed(2),
              ),
              CognitionQuizTableModel(
                tableContentZero: "70대",
                tableContentOne:
                    "${quizlist.where((element) => element.userAgeGroup == "70대").length} 회",
                tableContentTwo:
                    "${quizlist.where((element) => element.userAgeGroup == "70대" && element.quizCorrect == false).length} 회",
                tableContentThree: quizlist
                        .where((element) => element.userAgeGroup == "70대")
                        .isEmpty
                    ? "0.00"
                    : ((quizlist
                                .where((element) =>
                                    element.userAgeGroup == "70대" &&
                                    element.quizCorrect == false)
                                .length) /
                            (quizlist
                                .where(
                                    (element) => element.userAgeGroup == "70대")
                                .length))
                        .toStringAsFixed(2),
              ),
              CognitionQuizTableModel(
                tableContentZero: "80대",
                tableContentOne:
                    "${quizlist.where((element) => element.userAgeGroup == "80대").length} 회",
                tableContentTwo:
                    "${quizlist.where((element) => element.userAgeGroup == "80대" && element.quizCorrect == false).length} 회",
                tableContentThree: quizlist
                        .where((element) => element.userAgeGroup == "80대")
                        .isEmpty
                    ? "0.00"
                    : ((quizlist
                                .where((element) =>
                                    element.userAgeGroup == "80대" &&
                                    element.quizCorrect == false)
                                .length) /
                            (quizlist
                                .where(
                                    (element) => element.userAgeGroup == "80대")
                                .length))
                        .toStringAsFixed(2),
              ),
              CognitionQuizTableModel(
                tableContentZero: "90대 이상",
                tableContentOne:
                    "${quizlist.where((element) => element.userAgeGroup == "90대 이상").length} 회",
                tableContentTwo:
                    "${quizlist.where((element) => element.userAgeGroup == "90대 이상" && element.quizCorrect == false).length} 회",
                tableContentThree: quizlist
                        .where((element) => element.userAgeGroup == "90대 이상")
                        .isEmpty
                    ? "0.00"
                    : ((quizlist
                                .where((element) =>
                                    element.userAgeGroup == "90대 이상" &&
                                    element.quizCorrect == false)
                                .length) /
                            (quizlist
                                .where((element) =>
                                    element.userAgeGroup == "90대 이상")
                                .length))
                        .toStringAsFixed(2),
              ),
            ])
      ],
    );
  }
}

class UserGenderAgeTable extends StatelessWidget {
  final String title;
  final List<UserModel?> userDataList;
  const UserGenderAgeTable({
    super.key,
    required this.title,
    required this.userDataList,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle contentTextStyle = TextStyle(
      fontSize: Sizes.size10,
      fontWeight: FontWeight.w500,
      color: Palette().darkGray,
    );
    return Column(
      children: [
        DashboardTable(
          tableTitle: "성별 $title",
          titleColor: Palette().dashPink,
          list: [
            TableModel(
                tableHeader: "남성",
                tableContent:
                    "${userDataList.where((element) => element!.gender == "남성").length} 명"),
            TableModel(
                tableHeader: "여성",
                tableContent:
                    "${userDataList.where((element) => element!.gender == "여성").length} 명"),
          ],
        ),
        Gaps.v10,
        DashboardTable(
          tableTitle: "연령별 $title",
          titleColor: Palette().dashPink,
          list: [
            TableModel(
                tableHeader: "40대 미만",
                tableContent:
                    "${userDataList.where((element) => element!.userAgeGroup == "40대 미만").length} 명"),
            TableModel(
                tableHeader: "40대",
                tableContent:
                    "${userDataList.where((element) => element!.userAgeGroup == "40대").length} 명"),
            TableModel(
                tableHeader: "50대",
                tableContent:
                    "${userDataList.where((element) => element!.userAgeGroup == "50대").length} 명"),
            TableModel(
                tableHeader: "60대",
                tableContent:
                    "${userDataList.where((element) => element!.userAgeGroup == "60대").length} 명"),
            TableModel(
                tableHeader: "70대",
                tableContent:
                    "${userDataList.where((element) => element!.userAgeGroup == "70대").length} 명"),
            TableModel(
                tableHeader: "80대",
                tableContent:
                    "${userDataList.where((element) => element!.userAgeGroup == "80대").length} 명"),
            TableModel(
                tableHeader: "90대 이상",
                tableContent:
                    "${userDataList.where((element) => element!.userAgeGroup == "90대 이상").length} 명"),
          ],
        ),
        Gaps.v40,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 250,
              height: 250,
              child: SfCircularChart(
                title: ChartTitle(
                  text: "[성별 $title]",
                  textStyle: contentTextStyle,
                ),
                palette: const [
                  Color(0xff6A6EF6),
                  Color(0xffEDAFFA),
                ],
                legend: Legend(
                  isVisible: true,
                  textStyle: InjicareFont().label03,
                ),
                series: <PieSeries<ChartData, String>>[
                  PieSeries(
                    explode: true,
                    explodeIndex: 0,
                    dataSource: [
                      ChartData(
                          '남성',
                          (userDataList
                                  .where((element) => element!.gender == "남성")
                                  .length)
                              .toDouble()),
                      ChartData(
                          '여성',
                          (userDataList
                                  .where((element) => element!.gender == "여성")
                                  .length)
                              .toDouble()),
                    ],
                    xValueMapper: (datum, index) => datum.x,
                    yValueMapper: (datum, index) => datum.y,
                  )
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 250,
              height: 300,
              child: SfCircularChart(
                title: ChartTitle(
                  text: "[연령별 $title]",
                  textStyle: contentTextStyle,
                ),
                palette: const [
                  Color(0xffE6514C),
                  Color(0xffE3783F),
                  Color(0xffEA9B3F),
                  Color(0xffF1C964),
                  Color(0xff9ABD76),
                  Color(0xff60A88D),
                  Color(0xff5D748D),
                ],
                legend: Legend(
                  isVisible: true,
                  textStyle: InjicareFont().label03,
                ),
                series: <PieSeries<ChartData, String>>[
                  PieSeries(
                    explode: true,
                    explodeIndex: 0,
                    dataSource: [
                      ChartData(
                          '40대 미만',
                          (userDataList
                                  .where((element) =>
                                      element!.userAgeGroup == "40대 미만")
                                  .length)
                              .toDouble()),
                      ChartData(
                          '40대',
                          (userDataList
                                  .where((element) =>
                                      element!.userAgeGroup == "40대")
                                  .length)
                              .toDouble()),
                      ChartData(
                          '50대',
                          (userDataList
                                  .where((element) =>
                                      element!.userAgeGroup == "50대")
                                  .length)
                              .toDouble()),
                      ChartData(
                          '60대',
                          (userDataList
                                  .where((element) =>
                                      element!.userAgeGroup == "60대")
                                  .length)
                              .toDouble()),
                      ChartData(
                          '70대',
                          (userDataList
                                  .where((element) =>
                                      element!.userAgeGroup == "70대")
                                  .length)
                              .toDouble()),
                      ChartData(
                          '80대',
                          (userDataList
                                  .where((element) =>
                                      element!.userAgeGroup == "80대")
                                  .length)
                              .toDouble()),
                      ChartData(
                          '90대 이상',
                          (userDataList
                                  .where((element) =>
                                      element!.userAgeGroup == "90대 이상")
                                  .length)
                              .toDouble()),
                    ],
                    xValueMapper: (datum, index) => datum.x,
                    yValueMapper: (datum, index) => datum.y,
                  )
                ],
              ),
            )
          ],
        )
      ],
    );
  }
}

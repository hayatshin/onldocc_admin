import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/models/mood_model.dart';
import 'package:onldocc_admin/common/view/csv_period.dart';
import 'package:onldocc_admin/common/view/search_below.dart';
import 'package:onldocc_admin/common/view/skeleton_loading_screen.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/ranking/models/diary_model.dart';
import 'package:onldocc_admin/features/ranking/view_models/diary_view_model.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:to_csv/to_csv.dart' as exportCSV;

class RankingDiaryScreen extends ConsumerStatefulWidget {
  // final String? index;
  final String? userId;
  final String? userName;
  final String? rankingType;

  const RankingDiaryScreen({
    super.key,
    // required this.index,
    required this.userId,
    required this.userName,
    required this.rankingType,
  });

  @override
  ConsumerState<RankingDiaryScreen> createState() => _RankingDiaryScreenState();
}

class _RankingDiaryScreenState extends ConsumerState<RankingDiaryScreen> {
  final List<String> _listHeader = ["#", "날짜", "일기", "감정", "비밀"];
  List<DiaryModel> _diaryDataList = [];
  bool loadingFinished = false;
  final String _periodType = "이번달";
  Map<int, bool> expandMap = {};
  bool expandclick = false;
  bool expandUpdate = false;
  late List<MoodData> _moodDistribution;
  final String _userName = "";
  final TextEditingController sortPeriodControllder = TextEditingController();

  DateRange _selectedDateRange = DateRange(
    getThisWeekMonday(),
    DateTime.now(),
  );

  @override
  void initState() {
    super.initState();

    getUserDiaryData();
  }

  List<String> exportToList(DiaryModel diaryModel, int index) {
    return [
      (index + 1).toString(),
      secondsToStringLine(diaryModel.createdAt),
      diaryModel.secretType != "전체 공개" ? "비밀 글" : diaryModel.todayDiary,
      moodeList
          .firstWhere((element) => element.position == diaryModel.todayMood)
          .description,
      diaryModel.secretType != "전체 공개" ? "O" : "",
    ];
  }

  void updateOrderPeriod(DateRange dateRange) {
    setState(() {
      _selectedDateRange = dateRange;
      loadingFinished = false;
    });
    getUserDiaryData();
  }

  List<List<String>> exportToFullList(List<DiaryModel?> diaryModelList) {
    List<List<String>> list = [];

    // list.add(_listHeader);

    for (int i = 0; i < diaryModelList.length; i++) {
      final itemList = exportToList(diaryModelList[i]!, i);
      list.add(itemList);
    }
    return list;
  }

  void generateUserCsv() {
    final csvData = exportToFullList(_diaryDataList);
    const String fileName = "인지케어 회원별 일기";

    exportCSV.myCSV(
      _listHeader,
      csvData,
      fileName: fileName,
    );
  }

  Future<void> getUserDiaryData() async {
    List<DiaryModel> diaryDataList = await ref
        .read(diaryProvider.notifier)
        .getUserDateDiaryData(widget.userId!, _selectedDateRange);

    int totalMoods = diaryDataList.length;
    int joyCounts =
        diaryDataList.where((element) => element.todayMood == 0).length;
    int throbCounts =
        diaryDataList.where((element) => element.todayMood == 1).length;
    int thanksfulCounts =
        diaryDataList.where((element) => element.todayMood == 2).length;
    int shalomCounts =
        diaryDataList.where((element) => element.todayMood == 3).length;
    int sosoCounts =
        diaryDataList.where((element) => element.todayMood == 4).length;
    int lonelyCounts =
        diaryDataList.where((element) => element.todayMood == 5).length;
    int anxiousCounts =
        diaryDataList.where((element) => element.todayMood == 6).length;
    int gloomyCounts =
        diaryDataList.where((element) => element.todayMood == 7).length;
    int sadCounts =
        diaryDataList.where((element) => element.todayMood == 8).length;
    int angryCounts =
        diaryDataList.where((element) => element.todayMood == 9).length;
    int extraCounts = totalMoods -
        (joyCounts +
            throbCounts +
            thanksfulCounts +
            shalomCounts +
            sosoCounts +
            lonelyCounts +
            anxiousCounts +
            gloomyCounts +
            sadCounts +
            angryCounts);

    List<MoodData>? moodDistribution = [
      MoodData(mood: "기뻐요", count: joyCounts, color: const Color(0xFFFF2D78)),
      MoodData(mood: "설레요", count: throbCounts, color: const Color(0xFFF68E50)),
      MoodData(
          mood: "감사해요", count: thanksfulCounts, color: const Color(0xFFB994C5)),
      MoodData(
          mood: "평온해요", count: shalomCounts, color: const Color(0xFF7DB7D5)),
      MoodData(
          mood: "그냥 그래요", count: sosoCounts, color: const Color(0xFFF9E1C9)),
      MoodData(
          mood: "외로워요", count: lonelyCounts, color: const Color(0xFFBDD84C)),
      MoodData(
          mood: "불안해요", count: anxiousCounts, color: const Color(0xFFFEE05D)),
      MoodData(
          mood: "우울해요", count: gloomyCounts, color: const Color(0xFF5A5A5A)),
      MoodData(mood: "슬퍼요", count: sadCounts, color: const Color(0xFF104474)),
      MoodData(mood: "화나요", count: angryCounts, color: const Color(0xFFEE3438)),
      MoodData(mood: "기타", count: extraCounts, color: Colors.grey.shade200),
    ];

    setState(() {
      expandclick = true;
      _diaryDataList = diaryDataList;
      _moodDistribution = moodDistribution;
      loadingFinished = true;
    });
  }

  int linesCountString(String description) {
    String enter = '\n';
    List<String> parts = description.trim().split(enter);

    int count = 0;
    for (String str in parts) {
      if (str.isNotEmpty) count++;
    }
    return count;
  }

  int getLongestLineCount(List<DiaryModel> diaryDataList) {
    int longestLineCount = 0;

    for (int i = 0; i < diaryDataList.length; i++) {
      final description = diaryDataList[i].todayDiary;
      if (linesCountString(description) > longestLineCount) {
        longestLineCount = linesCountString(description);
      }
    }
    return longestLineCount;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final chartWidth = size.width / 2 - 300;

    return Column(
      children: [
        CsvPeriod(
          generateCsv: generateUserCsv,
          rankingType: widget.rankingType!,
          userName: widget.userName ?? "",
          updateOrderPeriod: updateOrderPeriod,
          sortPeriodControllder: sortPeriodControllder,
        ),
        loadingFinished
            ? SearchBelow(
                size: size,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(
                          Sizes.size36,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              width: chartWidth,
                              child: SfCalendar(
                                view: CalendarView.month,
                                dataSource:
                                    DiaryDataSource(_diaryDataList, context),
                                todayHighlightColor: Colors.grey.shade500,
                                // view: CalendarView.week,
                                // firstDayOfWeek: 1, // monday
                              ),
                            ),
                            if (_diaryDataList.isNotEmpty)
                              SizedBox(
                                width: chartWidth,
                                child: SfCircularChart(
                                  legend: const Legend(
                                    isVisible: true,
                                    toggleSeriesVisibility: true,
                                  ),
                                  title: ChartTitle(
                                    text: "감정 추이",
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  series: <PieSeries<MoodData, String>>[
                                    PieSeries<MoodData, String>(
                                      dataSource: _moodDistribution,
                                      xValueMapper: (MoodData mood, _) =>
                                          mood.mood,
                                      yValueMapper: (MoodData mood, _) =>
                                          mood.count,
                                      dataLabelMapper: (MoodData mood, _) =>
                                          "${mood.mood}: ${mood.count}",
                                      pointColorMapper: (MoodData mood, _) =>
                                          mood.color,
                                      dataLabelSettings:
                                          const DataLabelSettings(
                                        isVisible: true,
                                        showZeroValue: false,
                                        // labelPosition:
                                        //     ChartDataLabelPosition.outside,
                                        // useSeriesColor: true,
                                      ),
                                      explode: true,
                                    ),
                                  ],
                                ),
                              ),
                            if (_diaryDataList.isEmpty)
                              SizedBox(
                                width: chartWidth,
                                child: const Center(
                                  child: Text(
                                    "일기 데이터가 없습니다.",
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey.shade200,
                        thickness: 1,
                        indent: Sizes.size48,
                      ),
                      Gaps.v36,
                      Center(
                        child: Container(
                          width: size.width - 400,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              Sizes.size10,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: Sizes.size16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        "#",
                                        style: TextStyle(
                                          // color: Colors.white,
                                          fontSize: Sizes.size13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        "날짜",
                                        style: TextStyle(
                                          // color: Colors.white,
                                          fontSize: Sizes.size13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 8,
                                      child: Text(
                                        "일기",
                                        style: TextStyle(
                                          // color: Colors.white,
                                          fontSize: Sizes.size13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "감정",
                                        style: TextStyle(
                                          // color: Colors.white,
                                          fontSize: Sizes.size13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "비밀",
                                        style: TextStyle(
                                          // color: Colors.white,
                                          fontSize: Sizes.size13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        "",
                                        style: TextStyle(
                                          fontSize: Sizes.size13,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_diaryDataList.isNotEmpty)
                                Divider(
                                  color: Colors.grey.shade200,
                                ),
                              if (_diaryDataList.isNotEmpty) Gaps.v10,
                              Column(
                                children: List.generate(
                                  _diaryDataList.length,
                                  (index) => ExpansionPanelList(
                                    elevation: 0,
                                    expandIconColor: Colors.grey.shade500,
                                    expansionCallback:
                                        (panelIndex, isExpanded) {
                                      setState(() {
                                        expandclick = true;
                                        expandMap[index] = isExpanded;
                                      });
                                    },
                                    children: [
                                      ExpansionPanel(
                                        canTapOnHeader:
                                            _diaryDataList[index].secretType ==
                                                        "전체 공개" &&
                                                    _diaryDataList[index]
                                                            .todayDiary
                                                            .length >
                                                        40
                                                ? true
                                                : false,
                                        isExpanded:
                                            _diaryDataList[index].secretType ==
                                                    "전체 공개" &&
                                                (expandMap[index] ?? false),
                                        backgroundColor: Colors.white,
                                        headerBuilder: (context, isExpanded) {
                                          return Container(
                                            color: expandMap[index] ?? false
                                                ? Colors.lightBlue.shade50
                                                    .withOpacity(0.4)
                                                : Colors.white,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    (index + 1).toString(),
                                                    style: const TextStyle(
                                                      fontSize: Sizes.size13,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    secondsToStringLine(
                                                        _diaryDataList[index]
                                                            .createdAt),
                                                    style: const TextStyle(
                                                      fontSize: Sizes.size13,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                _diaryDataList[index]
                                                            .secretType !=
                                                        "전체 공개"
                                                    ? Expanded(
                                                        flex: 8,
                                                        child: Text(
                                                          "비밀 글",
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey.shade400,
                                                            fontSize:
                                                                Sizes.size13,
                                                          ),
                                                        ),
                                                      )
                                                    : Expanded(
                                                        flex: 8,
                                                        child: Text(
                                                          _diaryDataList[index]
                                                                      .todayDiary
                                                                      .length >
                                                                  40
                                                              ? "${_diaryDataList[index].todayDiary.substring(0, 41)}..."
                                                              : _diaryDataList[
                                                                      index]
                                                                  .todayDiary,
                                                          style:
                                                              const TextStyle(
                                                            fontSize:
                                                                Sizes.size13,
                                                          ),
                                                          textAlign:
                                                              TextAlign.left,
                                                        ),
                                                      ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    moodeList
                                                        .firstWhere((element) =>
                                                            element.position ==
                                                            _diaryDataList[
                                                                    index]
                                                                .todayMood)
                                                        .description,
                                                    style: const TextStyle(
                                                      fontSize: Sizes.size13,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Center(
                                                    child: Icon(
                                                      _diaryDataList[index]
                                                                  .secretType !=
                                                              "전체 공개"
                                                          ? Icons.check
                                                          : null,
                                                      size: Sizes.size13,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                        body: ListTile(
                                          title: Row(
                                            children: [
                                              const Expanded(
                                                flex: 1,
                                                child: Text(
                                                  "",
                                                  style: TextStyle(
                                                    fontSize: Sizes.size13,
                                                  ),
                                                ),
                                              ),
                                              const Expanded(
                                                flex: 2,
                                                child: Text(
                                                  "",
                                                  style: TextStyle(
                                                    fontSize: Sizes.size13,
                                                  ),
                                                ),
                                              ),
                                              _diaryDataList[index]
                                                          .secretType !=
                                                      "전체 공개"
                                                  ? Expanded(
                                                      flex: 6,
                                                      child: Container())
                                                  : Expanded(
                                                      flex: 6,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          bottom: Sizes.size10,
                                                        ),
                                                        child: Text(
                                                          _diaryDataList[index]
                                                              .todayDiary,
                                                          style:
                                                              const TextStyle(
                                                            fontSize:
                                                                Sizes.size13,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                              const Expanded(
                                                flex: 2,
                                                child: Text(
                                                  "",
                                                  style: TextStyle(
                                                    fontSize: Sizes.size13,
                                                  ),
                                                ),
                                              ),
                                              const Expanded(
                                                flex: 2,
                                                child: Text(
                                                  "",
                                                  style: TextStyle(
                                                    fontSize: Sizes.size13,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (_diaryDataList.isNotEmpty) Gaps.v10,
                            ],
                          ),
                        ),
                      ),
                      Gaps.v36,
                    ],
                  ),
                ),
              )
            : const Expanded(
                child: SkeletonLoadingScreen(),
              )
      ],
    );
  }
}

class DiaryDataSource extends CalendarDataSource {
  BuildContext context;
  DiaryDataSource(List<DiaryModel> diaryDataList, this.context) {
    appointments = diaryDataList;
  }

  @override
  DateTime getStartTime(int index) {
    return secondsToDatetime(appointments![index].createdAt);
  }

  @override
  DateTime getEndTime(int index) {
    return secondsToDatetime(appointments![index].createdAt);
  }

  @override
  String getSubject(int index) {
    return appointments![index].diaryId;
  }

  @override
  Color getColor(int index) {
    return Theme.of(context).primaryColor;
  }

  @override
  bool isAllDay(int index) {
    return false;
  }
}

class MoodData {
  final String mood;
  final int count;
  final Color color;

  MoodData({
    required this.mood,
    required this.count,
    required this.color,
  });
}

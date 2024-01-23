import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:onldocc_admin/common/models/mood_model.dart';
import 'package:onldocc_admin/common/view/csv_period.dart';
import 'package:onldocc_admin/common/view/search_below.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/ranking/models/diary_model.dart';
import 'package:onldocc_admin/features/ranking/repo/diary_repo.dart';
import 'package:onldocc_admin/features/ranking/view_models/diary_view_model.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:universal_html/html.dart';

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
  String _periodType = "이번달";
  Map<int, bool> expandMap = {};
  bool expandclick = false;
  bool expandUpdate = false;
  late List<MoodData> _moodDistribution;
  final String _userName = "";
  final TextEditingController sortPeriodControllder = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserDiaryData();
  }

  List<dynamic> exportToList(DiaryModel diaryModel, int index) {
    return [
      (index + 1).toString(),
      convertTimettampToStringDate(diaryModel.timestamp),
      diaryModel.secret ? "비밀 글" : diaryModel.todayDiary,
      diaryModel.todayMood.description,
      diaryModel.secret ? "O" : "",
    ];
  }

  void updateOrderPeriod(String periodType) {
    setState(() {
      _periodType = periodType;
      loadingFinished = false;
    });
    getUserDiaryData();
  }

  List<List<dynamic>> exportToFullList(List<DiaryModel?> diaryModelList) {
    List<List<dynamic>> list = [];

    list.add(_listHeader);

    for (int i = 0; i < diaryModelList.length; i++) {
      final itemList = exportToList(diaryModelList[i]!, i);
      list.add(itemList);
    }
    return list;
  }

  void generateUserCsv() {
    final csvData = exportToFullList(_diaryDataList);

    String csvContent = '';
    for (var row in csvData) {
      for (var i = 0; i < row.length; i++) {
        if (row[i].toString().contains(',')) {
          csvContent += '"${row[i]}"';
        } else {
          csvContent += row[i];
        }
        // csvContent += row[i].toString();

        if (i != row.length - 1) {
          csvContent += ',';
        }
      }
      csvContent += '\n';
    }
    final currentDate = DateTime.now();
    final formatDate =
        "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";

    final String fileName = "인지케어 회원별 일기 $_userName $formatDate.csv";

    final encodedUri = Uri.dataFromString(
      csvContent,
      encoding: Encoding.getByName("utf-8"),
    ).toString();
    final anchor = AnchorElement(href: encodedUri)
      ..setAttribute('download', fileName)
      ..click();
  }

  Future<void> getUserDiaryData() async {
    List<DiaryModel> diaryDataList = await ref
        .read(diaryProvider.notifier)
        .getUserDateDiaryData(widget.userId!, _periodType);

    int totalMoods = diaryDataList.length;
    int joyCounts = diaryDataList
        .where((element) => element.todayMood is int
            ? element.todayMood == 0
            : (element.todayMood as Map)["description"] == "기뻐요")
        .length;
    int throbCounts = diaryDataList
        .where((element) => element.todayMood is int
            ? element.todayMood == 1
            : (element.todayMood as Map)["description"] == "설레요")
        .length;
    int thanksfulCounts = diaryDataList
        .where((element) => element.todayMood is int
            ? element.todayMood == 2
            : (element.todayMood as Map)["description"] == "감사해요")
        .length;
    int shalomCounts = diaryDataList
        .where((element) => element.todayMood is int
            ? element.todayMood == 3
            : (element.todayMood as Map)["description"] == "평온해요")
        .length;
    int sosoCounts = diaryDataList
        .where((element) => element.todayMood is int
            ? element.todayMood == 4
            : (element.todayMood as Map)["description"] == "그냥 그래요")
        .length;
    int lonelyCounts = diaryDataList
        .where((element) => element.todayMood is int
            ? element.todayMood == 5
            : (element.todayMood as Map)["description"] == "외로워요")
        .length;
    int anxiousCounts = diaryDataList
        .where((element) => element.todayMood is int
            ? element.todayMood == 6
            : (element.todayMood as Map)["description"] == "불안해요")
        .length;
    int gloomyCounts = diaryDataList
        .where((element) => element.todayMood is int
            ? element.todayMood == 7
            : (element.todayMood as Map)["description"] == "우울해요")
        .length;
    int sadCounts = diaryDataList
        .where((element) => element.todayMood is int
            ? element.todayMood == 8
            : (element.todayMood as Map)["description"] == "슬퍼요")
        .length;
    int angryCounts = diaryDataList
        .where((element) => element.todayMood is int
            ? element.todayMood == 9
            : (element.todayMood as Map)["description"] == "화나요")
        .length;
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
                                    dataLabelSettings: const DataLabelSettings(
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
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Column(
                              mainAxisSize: MainAxisSize.max,
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
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _diaryDataList.length,
                                  itemBuilder: (context, index) {
                                    return ExpansionPanelList(
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
                                              !_diaryDataList[index].secret &&
                                                      _diaryDataList[index]
                                                              .todayDiary
                                                              .length >
                                                          40
                                                  ? true
                                                  : false,
                                          isExpanded:
                                              !_diaryDataList[index].secret &&
                                                  (expandMap[index] ?? false),
                                          backgroundColor: Colors.white,
                                          headerBuilder: (context, isExpanded) {
                                            return Row(
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
                                                    convertTimettampToStringDate(
                                                      _diaryDataList[index]
                                                          .timestamp,
                                                    ),
                                                    style: const TextStyle(
                                                      fontSize: Sizes.size13,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                _diaryDataList[index].secret
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
                                                    _diaryDataList[index]
                                                            .todayMood is int
                                                        ? moodeList
                                                            .firstWhere((element) =>
                                                                element
                                                                    .position ==
                                                                _diaryDataList[
                                                                        index]
                                                                    .todayMood)
                                                            .description
                                                        : (_diaryDataList[index]
                                                                    .todayMood
                                                                as Map)[
                                                            "description"],
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
                                                              .secret
                                                          ? Icons.check
                                                          : null,
                                                      size: Sizes.size13,
                                                    ),
                                                  ),
                                                )
                                              ],
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
                                                _diaryDataList[index].secret
                                                    ? Expanded(
                                                        flex: 6,
                                                        child: Container())
                                                    : Expanded(
                                                        flex: 6,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            bottom:
                                                                Sizes.size10,
                                                          ),
                                                          child: Text(
                                                            _diaryDataList[
                                                                    index]
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
                                    );
                                  },
                                ),
                                if (_diaryDataList.isNotEmpty) Gaps.v10,
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    Gaps.v36,
                  ],
                ),
              )
            : Expanded(
                child: Center(
                  child: LoadingAnimationWidget.inkDrop(
                    color: Colors.grey.shade600,
                    size: Sizes.size32,
                  ),
                ),
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
    return appointments![index].timestamp;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].timestamp;
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

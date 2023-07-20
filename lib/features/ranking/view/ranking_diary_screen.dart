import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/view/csv_period.dart';
import 'package:onldocc_admin/common/view/error_screen.dart';
import 'package:onldocc_admin/common/view/search_below.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/ranking/models/diary_model.dart';
import 'package:onldocc_admin/features/ranking/view_models/diary_view_model.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:universal_html/html.dart';

class RankingDiaryScreen extends ConsumerStatefulWidget {
  final String? index;
  final String? userId;
  final String? userName;
  final String? rankingType;

  const RankingDiaryScreen({
    super.key,
    required this.index,
    required this.userId,
    required this.userName,
    required this.rankingType,
  });

  @override
  ConsumerState<RankingDiaryScreen> createState() => _RankingDiaryScreenState();
}

class _RankingDiaryScreenState extends ConsumerState<RankingDiaryScreen> {
  final List<String> _listHeader = ["#" "날짜", "일기", "감정", "비밀"];
  final List<DiaryModel> _diaryDataList = [];
  bool loadingFinished = false;
  String _periodType = "이번달";
  List<int> diaryIndexShowState = [];
  Map<int, bool> expandMap = {};
  bool expandclick = false;
  bool expandUpdate = false;
  late List<MoodData> moodDistribution;

  List<dynamic> exportToList(DiaryModel diaryModel, int index) {
    return [
      index,
      diaryModel.timestamp,
      diaryModel.secret ? "비밀 글" : diaryModel.todayDiary,
      diaryModel.todayMood.description,
      diaryModel.secret ? "O" : "",
    ];
  }

  void updateOrderPeriod(String periodType) {
    setState(() {
      expandclick = false;
      _periodType = periodType;
    });
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
        if (row[i].contains(',')) {
          csvContent += '"${row[i]}"';
        } else {
          csvContent += row[i];
        }
        csvContent += row[i].toString();

        if (i != row.length - 1) {
          csvContent += ',';
        }
      }
      csvContent += '\n';
    }
    final currentDate = DateTime.now();
    final formatDate =
        "${currentDate.year}-${currentDate.month}-${currentDate.day}";

    final String fileName = "오늘도청춘 회원별 일기 ${widget.userName} $formatDate.csv";

    final encodedUri = Uri.dataFromString(
      csvContent,
      encoding: Encoding.getByName("utf-8"),
    ).toString();
    final anchor = AnchorElement(href: encodedUri)
      ..setAttribute('download', fileName)
      ..click();
  }

  // final List<StepModel> chartData = [
  //   StepModel(date: 'David', dailyStep: 25),
  //   StepModel(date: 'Steve', dailyStep: 38),
  //   StepModel(date: 'Jack', dailyStep: 34),
  //   StepModel(date: 'Others', dailyStep: 52)
  // ];

  // List<Meeting> _getDataSource() {
  //   final List<Meeting> meetings = <Meeting>[];
  //   final DateTime today = DateTime.now();
  //   final DateTime startTime =
  //       DateTime(today.year, today.month, today.day, 9, 0, 0);
  //   final DateTime endTime = startTime.add(const Duration(hours: 2));
  //   meetings.add(Meeting(
  //       'Conference', startTime, endTime, const Color(0xFF0F8644), false));
  //   return meetings;
  // }

  Future<List<DiaryModel>> getUserDiaryData() async {
    await Future.delayed(const Duration(seconds: 1));
    List<DiaryModel> diaryDataList = await ref
        .read(diaryProvider.notifier)
        .getUserDateDiaryData(widget.userId!, _periodType);

    int totalMoods = diaryDataList.length;
    int joyCounts = diaryDataList
        .where((element) => element.todayMood.description == "기뻐요")
        .length;
    int throbCounts = diaryDataList
        .where((element) => element.todayMood.description == "설레요")
        .length;
    int thanksfulCounts = diaryDataList
        .where((element) => element.todayMood.description == "감사해요")
        .length;
    int shalomCounts = diaryDataList
        .where((element) => element.todayMood.description == "평온해요")
        .length;
    int sosoCounts = diaryDataList
        .where((element) => element.todayMood.description == "그냥 그래요")
        .length;
    int lonelyCounts = diaryDataList
        .where((element) => element.todayMood.description == "외로워요")
        .length;
    int anxiousCounts = diaryDataList
        .where((element) => element.todayMood.description == "불안해요")
        .length;
    int gloomyCounts = diaryDataList
        .where((element) => element.todayMood.description == "우울해요")
        .length;
    int sadCounts = diaryDataList
        .where((element) => element.todayMood.description == "슬퍼요")
        .length;
    int angryCounts = diaryDataList
        .where((element) => element.todayMood.description == "화나요")
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

    moodDistribution = [
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

    return diaryDataList;

    // setState(() {
    //   _diaryDataList = diaryDataList;
    //   // loadingFinished = true;
    // });
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

  void userMoodCounts(List<DiaryModel> diaryModelList) {}

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final chartWidth = size.width / 2 - 300;

    return FutureBuilder<List<DiaryModel>>(
      future: expandclick ? null : getUserDiaryData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator.adaptive(
            backgroundColor: Theme.of(context).primaryColor,
          );
        } else if (snapshot.hasError) {
          return const ErrorScreen();
        } else if (snapshot.hasData) {
          List<DiaryModel> diaryModelList = snapshot.data!;

          return Column(
            children: [
              CsvPeriod(
                generateCsv: generateUserCsv,
                rankingType: widget.rankingType!,
                userName: widget.userName!,
                updateOrderPeriod: updateOrderPeriod,
              ),
              SearchBelow(
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
                                  DiaryDataSource(diaryModelList, context),
                              todayHighlightColor: Colors.grey.shade400,
                              // view: CalendarView.week,
                              // firstDayOfWeek: 1, // monday
                            ),
                          ),
                          SizedBox(
                            width: chartWidth,
                            child: SfCircularChart(
                              legend: const Legend(
                                isVisible: true,
                                toggleSeriesVisibility: true,
                              ),
                              title: ChartTitle(
                                text: "감정 추이",
                                textStyle: const TextStyle(),
                              ),
                              series: <PieSeries<MoodData, String>>[
                                PieSeries<MoodData, String>(
                                  dataSource: moodDistribution,
                                  xValueMapper: (MoodData mood, _) => mood.mood,
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
                      child: SizedBox(
                        width: size.width - 400,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final totalWidth = constraints.maxWidth - 360;
                            final dateWidth = totalWidth * 0.1;
                            final diaryWidth = totalWidth * 0.7;
                            final moodWidth = totalWidth * 0.1;
                            final secretWidth = totalWidth * 0.1;
                            final longestLineCount =
                                getLongestLineCount(snapshot.data!);
                            final oneLineHeight = calculateMaxContentHeight(
                                "안녕하세요", diaryWidth - Sizes.size20);
                            final maxHeight =
                                oneLineHeight * longestLineCount + Sizes.size32;
                            return DataTable(
                              dataRowHeight: expandUpdate ? maxHeight : 48,
                              columns: [
                                DataColumn(
                                  label: SizedBox(
                                    width: dateWidth,
                                    child: const Text(
                                      "#",
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: dateWidth,
                                    child: const Text(
                                      "날짜",
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: diaryWidth,
                                    child: const Text(
                                      "일기",
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: moodWidth,
                                    child: const Text(
                                      "감정",
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: secretWidth,
                                    child: const Text(
                                      "비밀",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                              rows: List.generate(
                                diaryModelList.length,
                                (index) {
                                  final rowData = diaryModelList[index];
                                  final descriptionTrim = diaryModelList[index]
                                      .todayDiary
                                      .trim()
                                      .replaceAll('\n', ' ');

                                  final isExpanded =
                                      expandMap.containsKey(index) &&
                                          expandMap[index] == true;
                                  final description = expandUpdate
                                      ? rowData.todayDiary
                                      : rowData.todayDiary.length > 51
                                          ? "${descriptionTrim.substring(0, 51)}..."
                                          : descriptionTrim;

                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            (index + 1).toString(),
                                            style: const TextStyle(
                                              fontSize: Sizes.size13,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            convertTimettampToString(
                                              rowData.timestamp,
                                            ),
                                            style: const TextStyle(
                                              fontSize: Sizes.size13,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Align(
                                            alignment: Alignment.centerLeft,
                                            child: rowData.secret
                                                ? Text(
                                                    "비밀 글",
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade300,
                                                    ),
                                                  )
                                                : expandUpdate
                                                    ? Text(
                                                        rowData.todayDiary
                                                            .trim(),
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: const TextStyle(
                                                          fontSize:
                                                              Sizes.size13,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      )
                                                    : Text(
                                                        description,
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: const TextStyle(
                                                          fontSize:
                                                              Sizes.size13,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      )),
                                        onTap: () {
                                          setState(() {
                                            expandclick = true;
                                            expandUpdate = !expandUpdate;
                                            if (isExpanded) {
                                              expandMap.remove(index);
                                            } else {
                                              expandMap[index] = true;
                                            }
                                          });
                                        },
                                      ),
                                      DataCell(
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            rowData.todayMood.description!,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: Sizes.size13,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Align(
                                          alignment: Alignment.center,
                                          child: rowData.secret
                                              ? const Icon(Icons.check)
                                              : null,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        } else {
          return const Text("?");
        }
      },
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

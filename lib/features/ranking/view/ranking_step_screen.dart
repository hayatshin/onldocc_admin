import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/view/csv_period.dart';
import 'package:onldocc_admin/common/view/search_below.dart';
import 'package:onldocc_admin/common/view/skeleton_loading_screen.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/ranking/models/step_model.dart';
import 'package:onldocc_admin/features/ranking/view_models/step_view_model.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:universal_html/html.dart';

class RankingStepScreen extends ConsumerStatefulWidget {
  // final String? index;
  final String? userId;
  final String? userName;
  final String? rankingType;

  const RankingStepScreen({
    super.key,
    // required this.index,
    required this.userId,
    required this.userName,
    required this.rankingType,
  });

  @override
  ConsumerState<RankingStepScreen> createState() => _RankingStepScreenState();
}

class _RankingStepScreenState extends ConsumerState<RankingStepScreen> {
  final List<String> _listHeader = ["날짜", "걸음수"];
  List<StepModel> _stepDataList = [];
  final String _userName = "";
  bool loadingFinished = false;
  final TextEditingController sortPeriodControllder = TextEditingController();
  DateRange _selectedDateRange = DateRange(
    getThisWeekMonday(),
    DateTime.now(),
  );

  Future<void> updateOrderPeriod(DateRange dateRange) async {
    setState(() {
      _selectedDateRange = dateRange;
      loadingFinished = false;
    });

    final stepDataList = await ref
        .read(stepProvider.notifier)
        .getUserDateStepData(widget.userId!, dateRange);

    setState(() {
      loadingFinished = true;
      _stepDataList = stepDataList;
    });
  }

  List<dynamic> exportToList(StepModel stepModel) {
    return [
      stepModel.date,
      stepModel.dailyStep.toString(),
    ];
  }

  List<List<dynamic>> exportToFullList(List<StepModel?> stepDataList) {
    List<List<dynamic>> list = [];

    list.add(_listHeader);

    for (var item in stepDataList) {
      final itemList = exportToList(item!);
      list.add(itemList);
    }
    return list;
  }

  void generateUserCsv() {
    final csvData = exportToFullList(_stepDataList);
    String csvContent = '';
    for (var row in csvData) {
      for (var i = 0; i < row.length; i++) {
        if (row[i].toString().contains(',')) {
          csvContent += '"${row[i]}"';
        } else {
          csvContent += row[i].toString();
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

    final String fileName = "인지케어 회원별 걸음수 $_userName $formatDate.csv";

    final encodedUri = Uri.dataFromString(
      csvContent,
      encoding: Encoding.getByName(encodingType()),
    ).toString();
    final anchor = AnchorElement(href: encodedUri)
      ..setAttribute('download', fileName)
      ..click();
  }

  Future<void> getUserStepData() async {
    final stepDataList = await ref
        .read(stepProvider.notifier)
        .getUserDateStepData(widget.userId!, _selectedDateRange);

    setState(() {
      loadingFinished = true;
      _stepDataList = stepDataList;
    });
  }

  @override
  void initState() {
    super.initState();
    getUserStepData();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
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
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: Sizes.size60,
                          ),
                          child: SizedBox(
                            width: size.width - 600,
                            height: 300,
                            child: SfCartesianChart(
                              // Initialize category axis
                              primaryXAxis: CategoryAxis(),
                              series: <LineSeries<StepModel, String>>[
                                LineSeries(
                                    // Bind data source
                                    dataSource: _stepDataList,
                                    xValueMapper: (StepModel step, _) =>
                                        step.date,
                                    yValueMapper: (StepModel step, _) =>
                                        step.dailyStep)
                              ],
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          width: size.width - 600,
                          child: DataTable(
                            columns: const [
                              DataColumn(
                                label: Expanded(
                                  child: SelectableText(
                                    "날짜",
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: SelectableText(
                                    "걸음수",
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                            rows: [
                              for (var i = 0; i < _stepDataList.length; i++)
                                DataRow(
                                  cells: [
                                    DataCell(
                                      Align(
                                        alignment: Alignment.center,
                                        child: SelectableText(
                                          _stepDataList[i].date,
                                          style: const TextStyle(
                                            fontSize: Sizes.size13,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Align(
                                        alignment: Alignment.center,
                                        child: SelectableText(
                                          numberDecimalCommans(
                                              _stepDataList[i].dailyStep!),
                                          textAlign: TextAlign.end,
                                          style: const TextStyle(
                                            fontSize: Sizes.size13,
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

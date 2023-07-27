import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/view/csv_period.dart';
import 'package:onldocc_admin/common/view/loading_screen.dart';
import 'package:onldocc_admin/common/view/search_below.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/ranking/models/step_model.dart';
import 'package:onldocc_admin/features/ranking/view_models/step_view_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:universal_html/html.dart';

import '../../users/view_models/user_view_model.dart';

class RankingStepScreen extends ConsumerStatefulWidget {
  // final String? index;
  final String? userId;
  // final String? userName;
  final String? rankingType;

  const RankingStepScreen({
    super.key,
    // required this.index,
    required this.userId,
    // required this.userName,
    required this.rankingType,
  });

  @override
  ConsumerState<RankingStepScreen> createState() => _RankingStepScreenState();
}

class _RankingStepScreenState extends ConsumerState<RankingStepScreen> {
  final List<String> _listHeader = ["날짜", "일기", "마음", "비밀"];
  List<StepModel> _stepDataList = [];
  bool loadingFinished = false;
  String _periodType = "이번달";
  String _userName = "";

  void updateOrderPeriod(String periodType) {
    setState(() {
      _periodType = periodType;
    });
  }

  List<dynamic> exportToList(StepModel stepModel) {
    return [
      stepModel.date,
      stepModel.dailyStep,
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

    final String fileName = "오늘도청춘 회원별 걸음수 $_userName $formatDate.csv";

    final encodedUri = Uri.dataFromString(
      csvContent,
      encoding: Encoding.getByName("utf-8"),
    ).toString();
    final anchor = AnchorElement(href: encodedUri)
      ..setAttribute('download', fileName)
      ..click();
  }

  Future<void> getUserStepData() async {
    final userProfile =
        await ref.read(userProvider.notifier).getUserModel(widget.userId!);
    _userName = userProfile!.name;

    if (_periodType == "이번달") {
      final stepDataList = await ref
          .read(stepProvider.notifier)
          .getUserDateStepData(widget.userId!, _periodType);
      setState(() {
        _stepDataList = stepDataList;
        loadingFinished = true;
      });
    } else if (_periodType == "이번주") {
      final stepDataList = await ref
          .read(stepProvider.notifier)
          .getUserDateStepData(widget.userId!, _periodType);
      setState(() {
        _stepDataList = stepDataList;
        loadingFinished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return FutureBuilder(
      future: getUserStepData(),
      builder: (context, snapshot) => Column(children: [
        CsvPeriod(
          generateCsv: generateUserCsv,
          rankingType: widget.rankingType!,
          userName: _userName,
          updateOrderPeriod: updateOrderPeriod,
        ),
        loadingFinished
            ? SearchBelow(
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
                                child: Text(
                                  "날짜",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text(
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
                                      child: Text(
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
                                      child: Text(
                                        _stepDataList[i].dailyStep.toString(),
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
              )
            : const LoadingScreen()
      ]),
    );
  }
}

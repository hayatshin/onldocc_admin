import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:onldocc_admin/common/view/search_below.dart';
import 'package:onldocc_admin/features/ca/models/ca_model.dart';
import 'package:onldocc_admin/features/ca/view_models/ca_view_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:universal_html/html.dart';

import '../../../common/view/csv_period.dart';
import '../../../constants/sizes.dart';
import '../../../utils.dart';

class CaScreen extends ConsumerStatefulWidget {
  static const routeURL = "/ca";
  static const routeName = "ca";
  // final String? index;
  final String? userId;
  final String? userName;
  final String? rankingType;

  const CaScreen({
    super.key,
    // required this.index,
    required this.userId,
    required this.userName,
    required this.rankingType,
  });

  @override
  ConsumerState<CaScreen> createState() => _CaScreenState();
}

class _CaScreenState extends ConsumerState<CaScreen> {
  final List<String> _listHeader = ["#", "날짜", "인지 결과", "문제", "정답", "제출 답"];
  List<CaModel> _caDataList = [];
  bool loadingFinished = false;
  String _periodType = "이번달";
  final String _userName = "";
  late List<QuestionResultData> qrDistribution;
  final TextEditingController sortPeriodControllder = TextEditingController();

  List<dynamic> exportToList(CaModel caModel, int index) {
    return [
      (index + 1).toString(),
      convertTimettampToStringDate(caModel.timestamp),
      caModel.recognitionResult ? "O" : "X",
      caModel.recognitionQuestion,
      caModel.realAnswer,
      caModel.userAnswer,
    ];
  }

  void updateOrderPeriod(String periodType) {
    setState(() {
      _periodType = periodType;
      loadingFinished = false;
    });
    getUserCaData();
  }

  List<List<dynamic>> exportToFullList(List<CaModel?> caModelList) {
    List<List<dynamic>> list = [];

    list.add(_listHeader);

    for (int i = 0; i < caModelList.length; i++) {
      final itemList = exportToList(caModelList[i]!, i);
      list.add(itemList);
    }
    return list;
  }

  void generateUserCsv() {
    print(_caDataList);
    final csvData = exportToFullList(_caDataList);
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

    final String fileName = "인지케어 회원별 인지 관리 $_userName $formatDate.csv";

    final encodedUri = Uri.dataFromString(
      csvContent,
      encoding: Encoding.getByName("utf-8"),
    ).toString();
    final anchor = AnchorElement(href: encodedUri)
      ..setAttribute('download', fileName)
      ..click();
  }

  Future<List<CaModel>> getUserCaData() async {
    List<CaModel> caDataList = await ref
        .read(caProvider.notifier)
        .getUserDateCaData(widget.userId!, _periodType);

    int totalQuestions = caDataList.length;
    int correctCounts =
        caDataList.where((element) => element.recognitionResult == true).length;
    int wrongCounts = totalQuestions - correctCounts;

    qrDistribution = [
      QuestionResultData(
          result: "맞음", count: correctCounts, color: const Color(0xFFFF2D78)),
      QuestionResultData(
          result: "틀림", count: wrongCounts, color: Colors.grey.shade500),
    ];

    setState(() {
      loadingFinished = true;
      _caDataList = caDataList;
    });
    return caDataList;
  }

  @override
  void initState() {
    super.initState();
    getUserCaData();
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
                      child: SizedBox(
                        child: _caDataList.isNotEmpty
                            ? SfCircularChart(
                                legend: const Legend(
                                  isVisible: true,
                                  toggleSeriesVisibility: true,
                                ),
                                title: ChartTitle(
                                  text: "인지 능력 추이",
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                series: <PieSeries<QuestionResultData, String>>[
                                  PieSeries<QuestionResultData, String>(
                                    dataSource: qrDistribution,
                                    xValueMapper: (QuestionResultData qr, _) =>
                                        qr.result,
                                    yValueMapper: (QuestionResultData qr, _) =>
                                        qr.count,
                                    dataLabelMapper:
                                        (QuestionResultData qr, _) =>
                                            "${qr.result}: ${qr.count}",
                                    pointColorMapper:
                                        (QuestionResultData qr, _) => qr.color,
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
                              )
                            : const SizedBox(
                                height: 200,
                                child: Center(
                                  child: Text(
                                    "인지 데이터가 없습니다.",
                                  ),
                                ),
                              ),
                      ),
                    ),
                    Divider(
                      color: Colors.grey.shade200,
                      thickness: 1,
                      indent: Sizes.size48,
                    ),
                    // Gaps.v36,
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: Sizes.size36,
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final totalWidth = constraints.maxWidth - 500;
                            final indexWidth = totalWidth * 0.1;
                            final dateWidth = totalWidth * 0.2;
                            final resultWidth = totalWidth * 0.2;
                            final questionWidth = totalWidth * 0.2;
                            final caWidth = totalWidth * 0.1;
                            final usWidth = totalWidth * 0.1;
                            return DataTable(
                              columns: [
                                DataColumn(
                                  label: SizedBox(
                                    width: indexWidth,
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
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: resultWidth,
                                    child: const Text(
                                      "인지 결과",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: questionWidth,
                                    child: const Text(
                                      "문제",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: caWidth,
                                    child: const Text(
                                      "정답",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: usWidth,
                                    child: const Text(
                                      "제출 답",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                              rows: List.generate(
                                _caDataList.length,
                                (index) {
                                  final rowData = _caDataList[index];

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
                                          alignment: Alignment.center,
                                          child: Text(
                                            convertTimettampToStringDate(
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
                                          alignment: Alignment.center,
                                          child: rowData.recognitionResult ==
                                                  true
                                              ? Icon(
                                                  Icons.radio_button_unchecked,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                )
                                              : const Icon(Icons.close),
                                        ),
                                      ),
                                      DataCell(
                                        Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            rowData.recognitionQuestion,
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
                                          child: Text(
                                            rowData.realAnswer,
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
                                          child: Text(
                                            rowData.userAnswer,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: Sizes.size13,
                                            ),
                                          ),
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
            : Expanded(
                child: Center(
                  child: LoadingAnimationWidget.inkDrop(
                    color: Colors.grey.shade600,
                    size: Sizes.size32,
                  ),
                ),
              ),
      ],
    );
  }
}

class QuestionResultData {
  final String result;
  final int count;
  final Color color;

  QuestionResultData({
    required this.result,
    required this.count,
    required this.color,
  });
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:onldocc_admin/common/view/csv.dart';
import 'package:onldocc_admin/common/view/search_below.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/ca/consts/cognition_test_questionnaire.dart';
import 'package:onldocc_admin/features/ca/models/cognition_test_model.dart';
import 'package:universal_html/html.dart';

class CognitionTestDetailScreen extends StatefulWidget {
  final CognitionTestModel model;
  const CognitionTestDetailScreen({
    super.key,
    required this.model,
  });

  @override
  State<CognitionTestDetailScreen> createState() =>
      _CognitionTestDetailScreenState();
}

class _CognitionTestDetailScreenState extends State<CognitionTestDetailScreen> {
  final List<String> _listHeader = ["문항", "답변"];
  String testDate = "";
  String totalPoint = "";
  String result = "";
  String name = "";
  String gender = "";
  String age = "";
  String phone = "";
  String testType = "";

  void _initializeTestInfo() {
    testDate = "시행 날짜: ${widget.model.timestamp}";
    totalPoint =
        "총점: ${widget.model.totalPoint}점 / ${widget.model.testType == "alzheimer_test" ? alzheimer_questionnaire_strings.length : depression_questionnaire_strings.length}점";
    result = "분류: ${widget.model.result}";

    name = "이름: ${widget.model.userName}";
    gender = "성별: ${widget.model.userGender}";
    age = "나이: ${widget.model.userAge}";
    phone = "번호: ${widget.model.userPhone}";

    testType =
        widget.model.testType == "alzheimer_test" ? "치매 조기 검사" : "노인 우울척도 검사";

    setState(() {});
  }

  List<dynamic> exportToList(String questionnaire, String answer) {
    return [
      questionnaire,
      answer,
    ];
  }

  List<List<dynamic>> exportToFullList() {
    List<List<dynamic>> list = [];

    list.add(_listHeader);

    for (int i = 0; i < alzheimer_questionnaire_strings.length; i++) {
      String answer = widget.model.answerList[i] == true ? "예" : "아니오";
      final itemlist = exportToList(alzheimer_questionnaire_strings[i], answer);
      list.add(itemlist);
    }

    return list;
  }

  void generateUserCsv() {
    String testInfo =
        "$testDate\n$totalPoint\n$result\n\n$name\n$gender\n$age\n$phone";

    final csvData = exportToFullList();
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

    final String fileName = "인지케어 $testType ${widget.model.userName}.csv";

    final encodedUri = Uri.dataFromString(
      "$testInfo\n\n$csvContent",
      encoding: Encoding.getByName("utf-8"),
    ).toString();
    final anchor = AnchorElement(href: encodedUri)
      ..setAttribute('download', fileName)
      ..click();
  }

  @override
  void initState() {
    super.initState();
    _initializeTestInfo();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Csv(
          generateCsv: generateUserCsv,
          rankingType: testType,
          userName: widget.model.userName!,
        ),
        SearchBelow(
          size: size,
          child: Padding(
            padding: const EdgeInsets.all(
              60,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TestInfoText(text: testDate),
                TestInfoText(text: totalPoint),
                TestInfoText(text: result),
                TestInfoText(text: name),
                TestInfoText(text: gender),
                TestInfoText(text: age),
                TestInfoText(text: phone),
                Gaps.v32,
                Center(
                  child: SizedBox(
                    width: size.width - 600,
                    child: DataTable(
                      columns: const [
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              "문항",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Text(
                              "답변",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                      rows: [
                        for (var i = 0;
                            i < alzheimer_questionnaire_strings.length;
                            i++)
                          DataRow(
                            cells: [
                              DataCell(
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    alzheimer_questionnaire_strings[i],
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
                                    widget.model.answerList[i] == true
                                        ? "예"
                                        : "아니오",
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
        ),
      ],
    );
  }
}

class TestInfoText extends StatelessWidget {
  final String text;
  const TestInfoText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "◦ $text",
          style: const TextStyle(
            fontSize: Sizes.size15,
            fontWeight: FontWeight.w500,
          ),
        ),
        Gaps.v10,
      ],
    );
  }
}

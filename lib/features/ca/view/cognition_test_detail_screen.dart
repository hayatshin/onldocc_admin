import 'package:flutter/material.dart';
import 'package:onldocc_admin/common/view/csv.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/ca/consts/cognition_test_questionnaire.dart';
import 'package:onldocc_admin/features/ca/models/cognition_test_model.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';

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
  final TextStyle _headerTextStyle = TextStyle(
    fontSize: Sizes.size13,
    fontWeight: FontWeight.w600,
    color: Palette().darkGray,
  );

  final TextStyle _contentTextStyle = TextStyle(
    fontSize: Sizes.size12,
    fontWeight: FontWeight.w500,
    color: Palette().darkGray,
  );

  List<String> testQuestionnare = [];
  final List<String> _listHeader = ["문항", "답변"];
  String testDate = "";
  String totalPoint = "";
  String result = "";
  String name = "";
  String gender = "";
  String age = "";
  String phone = "";
  String testName = "";

  void _initializeTestInfo() {
    testDate = "시행 날짜:  ${secondsToStringLine(widget.model.createdAt)}";
    totalPoint =
        "총점:  ${widget.model.totalPoint}점 / ${widget.model.testType == "alzheimer_test" ? alzheimer_questionnaire_strings.length : depression_questionnaire_strings.length}점";
    result = "분류:  ${widget.model.result}";

    name = "이름:  ${widget.model.userName}";
    gender = "성별:  ${widget.model.userGender}";
    age = "나이:  ${widget.model.userAge}세";
    phone = "번호:  ${widget.model.userPhone}";

    switch (widget.model.testType) {
      case "alzheimer_test":
        testName = "온라인 치매 검사";
        testQuestionnare = alzheimer_questionnaire_strings;
        break;
      case "depression_test":
        testName = "우울척도 단축형 검사";
        testQuestionnare = depression_questionnaire_strings;
        break;
      case "stress_test":
        testName = "스트레스 척도 검사";
        testQuestionnare = stressQuestionnaireStrings;
        break;
      case "anxiety_test":
        testName = "불안장애 척도 검사";
        testQuestionnare = anxietyQuestionnaireStrings;
        break;
      case "trauma_test":
        testName = "외상 후 스트레스 검사";
        testQuestionnare = traumaQuestionnaireStrings;
        break;
      case "esteem_test":
        testName = "자아존중감 검사";
        testQuestionnare = esteemQuestionnaireStrings;
        break;
      case "sleep_test":
        testName = "수면(불면증) 검사";
        testQuestionnare = sleepQuestionnaireStrings;
        break;

      default:
        testName = "온라인 치매 검사";
        testQuestionnare = alzheimer_questionnaire_strings;
        break;
    }

    setState(() {});
  }

  List<String> exportToList(String questionnaire, String answer) {
    return [
      questionnaire.toString(),
      answer.toString(),
    ];
  }

  List<List<String>> exportToFullList() {
    List<List<String>> list = [];

    list.add(_listHeader);

    for (int i = 0; i < testQuestionnare.length; i++) {
      String answer = (widget.model.userAnswers["a$i"]!).runtimeType == bool
          ? widget.model.userAnswers["a$i"]!
              ? "예"
              : "아니오"
          : (widget.model.userAnswers["a$i"]!);
      final itemlist = exportToList(testQuestionnare[i], answer);
      list.add(itemlist);
    }

    return list;
  }

  void generateExcel() {
    final csvData = exportToFullList();
    final String fileName = "인지케어 $testName ${widget.model.userName}.xlsx";
    exportExcel(csvData, fileName);
  }

  @override
  void initState() {
    super.initState();
    _initializeTestInfo();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: Palette().bgLightBlue,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Gaps.v20,
              Csv(
                generateCsv: generateExcel,
                rankingType: testName,
                userName: widget.model.userName!,
                menu: menuList[4],
              ),
              Gaps.v40,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 70,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TestInfoText(text: testDate),
                            TestInfoText(text: totalPoint),
                            TestInfoText(text: result),
                          ],
                        ),
                        Gaps.h80,
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            UserInfoText(text: name),
                            UserInfoText(text: gender),
                            UserInfoText(text: age),
                            UserInfoText(text: phone),
                          ],
                        )
                      ],
                    ),
                  ),
                  Gaps.v52,
                  Center(
                    child: SizedBox(
                      width: size.width - 600,
                      child: DataTable(
                        dividerThickness: 0.1,
                        border: TableBorder(
                          borderRadius: BorderRadius.circular(20),
                          top: BorderSide(
                            color: Palette().darkPurple,
                            width: 1.5,
                          ),
                          bottom: BorderSide(
                            color: Palette().darkPurple,
                            width: 1.5,
                          ),
                          horizontalInside: BorderSide(
                            color: Palette().lightGray,
                            width: 0.1,
                          ),
                        ),
                        columns: [
                          DataColumn(
                            label: Expanded(
                              child: SelectableText(
                                "#",
                                style: _headerTextStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: SelectableText(
                                "문항",
                                style: _headerTextStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: SelectableText(
                                "답변",
                                style: _headerTextStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                        rows: [
                          for (int i = 0; i < testQuestionnare.length; i++)
                            DataRow(
                              cells: [
                                DataCell(
                                  Align(
                                    alignment: Alignment.center,
                                    child: SelectableText(
                                      (i + 1).toString(),
                                      style: _contentTextStyle,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Align(
                                    alignment: Alignment.center,
                                    child: SelectableText(
                                      testQuestionnare[i],
                                      style: _contentTextStyle,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Align(
                                    alignment: Alignment.center,
                                    child: SelectableText(
                                      (widget.model.userAnswers["a$i"]!)
                                                  .runtimeType ==
                                              bool
                                          ? widget.model.userAnswers["a$i"]
                                              ? "예"
                                              : "아니오"
                                          : widget.model.userAnswers["a$i"],
                                      textAlign: TextAlign.end,
                                      style: _contentTextStyle.copyWith(
                                        fontWeight: FontWeight.w800,
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
                  Gaps.v52,
                ],
              )
            ],
          ),
        ),
      ),
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
    final header = text.split(':')[0];
    final contents = text.replaceAll("$header: ", "");
    return Column(
      children: [
        Row(
          children: [
            SelectableText(
              "▪︎   $header",
              style: caHeaderTextStyle,
            ),
            Gaps.h20,
            SelectableText(
              contents,
              style: caContentTextStyle,
            ),
          ],
        ),
        Gaps.v10,
      ],
    );
  }
}

class UserInfoText extends StatelessWidget {
  final String text;

  const UserInfoText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final header = text.split(':')[0];
    final contents = text.replaceAll("$header: ", "");
    return Column(
      children: [
        Row(
          children: [
            SelectableText(
              "▫︎   $header",
              style: caHeaderTextStyle,
            ),
            Gaps.h20,
            SelectableText(
              contents,
              style: caContentTextStyle,
            ),
          ],
        ),
        Gaps.v10,
      ],
    );
  }
}

final TextStyle caHeaderTextStyle = TextStyle(
  fontSize: Sizes.size14,
  fontWeight: FontWeight.w800,
  color: Palette().darkGray,
);

final TextStyle caContentTextStyle = TextStyle(
  fontSize: Sizes.size14,
  fontWeight: FontWeight.w500,
  color: Palette().darkGray,
);

import 'dart:convert';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/models/contract_notifier.dart';
import 'package:onldocc_admin/common/view/search.dart';
import 'package:onldocc_admin/common/view/search_below.dart';
import 'package:onldocc_admin/common/view/search_csv.dart';
import 'package:onldocc_admin/common/widgets/loading_widget.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/ca/models/cognition_test_model.dart';
import 'package:onldocc_admin/features/ca/view_models/cognition_test_view_model.dart';
import 'package:onldocc_admin/utils.dart';

class AlzheimerTestScreen extends ConsumerStatefulWidget {
  static const routeURL = "/alzheimer";
  static const routeName = "alzheimer";

  const AlzheimerTestScreen({super.key});

  @override
  ConsumerState<AlzheimerTestScreen> createState() =>
      _AlzheimerTestScreenState();
}

class _AlzheimerTestScreenState extends ConsumerState<AlzheimerTestScreen> {
  bool loadingFinihsed = false;
  final List<String> _tableHeader = [
    "시행 날짜",
    "분류",
    "점수",
    "이름",
    "성별",
    "나이",
    "핸드폰 번호",
    "자세히 보기",
  ];
  List<CognitionTestModel> _beforeFilterTestDataList = [];
  List<CognitionTestModel> _testList = [];

  List<dynamic> exportToList(CognitionTestModel testModel) {
    return [
      secondsToStringLine(testModel.createdAt),
      testModel.result,
      testModel.totalPoint,
      testModel.userName,
      testModel.userGender,
      testModel.userAge,
      testModel.userPhone,
    ];
  }

  List<List<dynamic>> exportToFullList() {
    List<List<dynamic>> list = [];

    final csvHeader = _tableHeader.sublist(0, _tableHeader.length);
    list.add(csvHeader);

    for (var item in _testList) {
      final itemList = exportToList(item);
      list.add(itemList);
    }
    return list;
  }

  void generateUserCsv() {
    final csvData = exportToFullList();
    String csvContent = '';
    for (var row in csvData) {
      for (var i = 0; i < row.length; i++) {
        if (row[i].toString().contains(',')) {
          csvContent += '"${row[i]}"';
        } else {
          csvContent += row[i];
        }

        if (i != row.length - 1) {
          csvContent += ',';
        }
      }
      csvContent += '\n';
    }
    final currentDate = DateTime.now();
    final formatDate = convertTimettampToStringDate(currentDate);

    final String fileName = "온라인 치매 검사 $formatDate.csv";

    final encodedUri = Uri.dataFromString(
      csvContent,
      encoding: Encoding.getByName("utf-8"),
    ).toString();
    final anchor = AnchorElement(href: encodedUri)
      ..setAttribute('download', fileName)
      ..click();
  }

  void resetInitialState() {
    setState(() {
      _testList = _beforeFilterTestDataList;
    });
  }

  void filterUserDataList(String? searchBy, String searchKeyword) {
    final newTableList = ref
        .read(cognitionTestProvider.notifier)
        .filterTableRows(
          _testList,
          searchBy!,
          searchKeyword,
        )
        .where((element) => element != null)
        .cast<CognitionTestModel>()
        .toList();

    setState(() {
      _beforeFilterTestDataList = _testList;
      _testList = newTableList;
    });
  }

  Future<void> _initializeTableList() async {
    final testList = await ref
        .read(cognitionTestProvider.notifier)
        .getCognitionTestData(alzheimer_test);
    setState(() {
      loadingFinihsed = true;
      _testList = testList;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeTableList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final tableWidth = size.width - 270 - 64;
    return AnimatedBuilder(
      animation: contractNotifier,
      builder: (context, child) {
        return loadingFinihsed
            ? Column(
                children: [
                  SearchCsv(
                    filterUserList: filterUserDataList,
                    resetInitialList: resetInitialState,
                    generateCsv: generateUserCsv,
                  ),
                  SearchBelow(
                    size: size,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: tableWidth,
                        child: DataTable(
                          columns: [
                            for (String header in _tableHeader)
                              DataColumn(
                                label: Text(
                                  header,
                                  style: TextStyle(
                                    fontSize: Sizes.size13,
                                    color: header == "자세히 보기"
                                        ? Theme.of(context).primaryColor
                                        : Colors.black,
                                  ),
                                ),
                              ),
                          ],
                          rows: [
                            for (int i = 0; i < _testList.length; i++)
                              DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      secondsToStringLine(
                                          _testList[i].createdAt),
                                      style: const TextStyle(
                                        fontSize: Sizes.size13,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      _testList[i].result,
                                      style: const TextStyle(
                                        fontSize: Sizes.size13,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      _testList[i].totalPoint.toString(),
                                      style: const TextStyle(
                                        fontSize: Sizes.size13,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      _testList[i].userName!,
                                      style: const TextStyle(
                                        fontSize: Sizes.size13,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      _testList[i].userGender!,
                                      style: const TextStyle(
                                        fontSize: Sizes.size13,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      _testList[i].userAge!.toString(),
                                      style: const TextStyle(
                                        fontSize: Sizes.size13,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      _testList[i].userPhone!,
                                      style: const TextStyle(
                                        fontSize: Sizes.size13,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          context.go(
                                            "/alzheimer/${_testList[i].testId}",
                                            extra: _testList[i],
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: Sizes.size10,
                                          ),
                                          child: CircleAvatar(
                                            backgroundColor:
                                                Colors.grey.shade200,
                                            child: Icon(
                                              Icons.chevron_right,
                                              size: Sizes.size16,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : loadingWidget();
      },
    );
  }
}

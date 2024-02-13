import 'dart:convert';
import 'dart:html';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/view/search_below.dart';
import 'package:onldocc_admin/common/view/search_csv.dart';
import 'package:onldocc_admin/common/view/skeleton_loading_screen.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/ca/models/cognition_test_model.dart';
import 'package:onldocc_admin/features/ca/view_models/cognition_test_view_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
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
  bool loadingFinished = false;
  final List<String> _tableHeader = [
    "시행 날짜",
    "분류",
    "점수",
    "이름",
    "성별",
    "나이",
    "핸드폰 번호",
    "자세히 보기"
  ];
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

    final csvHeader = _tableHeader.sublist(0, _tableHeader.length - 1);
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
          csvContent += row[i].toString();
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
      encoding: Encoding.getByName(encodingType()),
    ).toString();
    final anchor = AnchorElement(href: encodedUri)
      ..setAttribute('download', fileName)
      ..click();
  }

  Future<void> filterUserDataList(
      String? searchBy, String searchKeyword) async {
    List<CognitionTestModel> initialList =
        ref.read(cognitionTestProvider).value ??
            await ref
                .read(cognitionTestProvider.notifier)
                .getCognitionTestData(alzheimer_test);

    List<CognitionTestModel> filterList = [];
    if (searchBy == "name") {
      filterList = initialList
          .where((element) => element.userName!.contains(searchKeyword))
          .cast<CognitionTestModel>()
          .toList();
    } else {
      filterList = initialList
          .where((element) => element.userPhone!.contains(searchKeyword))
          .cast<CognitionTestModel>()
          .toList();
    }

    setState(() {
      _testList = filterList;
    });

    // final newTableList = ref
    //     .read(cognitionTestProvider.notifier)
    //     .filterTableRows(
    //       _testList,
    //       searchBy!,
    //       searchKeyword,
    //     )
    //     .where((element) => element != null)
    //     .cast<CognitionTestModel>()
    //     .toList();

    // setState(() {
    //   _beforeFilterTestDataList = _testList;
    //   _testList = newTableList;
    // });
  }

  Future<void> _initializeTableList() async {
    final testList = await ref
        .read(cognitionTestProvider.notifier)
        .getCognitionTestData(alzheimer_test);

    if (selectContractRegion.value.subdistrictId == "") {
      if (mounted) {
        setState(() {
          loadingFinished = true;
          _testList = testList;
        });
      }
    } else {
      if (selectContractRegion.value.contractCommunityId != "" &&
          selectContractRegion.value.contractCommunityId != null) {
        final filterDataList = testList
            .where((e) =>
                e.userContractCommunityId ==
                selectContractRegion.value.contractCommunityId)
            .toList();
        if (mounted) {
          setState(() {
            loadingFinished = true;
            _testList = filterDataList;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            loadingFinished = true;
            _testList = testList;
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeTableList();

    selectContractRegion.addListener(() async {
      if (mounted) {
        setState(() {
          loadingFinished = false;
        });

        await _initializeTableList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final tableWidth = size.width - 270 - 64;
    return ValueListenableBuilder(
      valueListenable: selectContractRegion,
      builder: (context, value, child) {
        return loadingFinished
            ? Column(
                children: [
                  SearchCsv(
                    filterUserList: filterUserDataList,
                    resetInitialList: _initializeTableList,
                    generateCsv: generateUserCsv,
                  ),
                  SearchBelow(
                    size: size,
                    child: SizedBox(
                      width: tableWidth,
                      child: DataTable2(
                        columns: [
                          const DataColumn2(
                            fixedWidth: 150,
                            label: Text(
                              "시행 날짜",
                              style: TextStyle(
                                fontSize: Sizes.size13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const DataColumn2(
                            fixedWidth: 200,
                            label: Text(
                              "분류",
                              style: TextStyle(
                                fontSize: Sizes.size13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const DataColumn2(
                            fixedWidth: 100,
                            label: Text(
                              "점수",
                              style: TextStyle(
                                fontSize: Sizes.size13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const DataColumn2(
                            label: Text(
                              "이름",
                              style: TextStyle(
                                fontSize: Sizes.size13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const DataColumn2(
                            fixedWidth: 100,
                            label: Text(
                              "성별",
                              style: TextStyle(
                                fontSize: Sizes.size13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const DataColumn2(
                            fixedWidth: 80,
                            label: Text(
                              "나이",
                              style: TextStyle(
                                fontSize: Sizes.size13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const DataColumn2(
                            label: Text(
                              "핸드폰 번호",
                              style: TextStyle(
                                fontSize: Sizes.size13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          DataColumn2(
                            fixedWidth: 100,
                            label: Text(
                              "자세히 보기",
                              style: TextStyle(
                                fontSize: Sizes.size13,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                        rows: [
                          for (int i = 0; i < _testList.length; i++)
                            DataRow2(
                              cells: [
                                DataCell(
                                  Text(
                                    secondsToStringLine(_testList[i].createdAt),
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
                                      overflow: TextOverflow.ellipsis,
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
                                          backgroundColor: Colors.grey.shade200,
                                          child: Icon(
                                            Icons.chevron_right,
                                            size: Sizes.size16,
                                            color:
                                                Theme.of(context).primaryColor,
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
                ],
              )
            : const SkeletonLoadingScreen();
      },
    );
  }
}

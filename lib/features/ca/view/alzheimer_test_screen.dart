import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/view/search_csv.dart';
import 'package:onldocc_admin/common/view/skeleton_loading_screen.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/ca/models/cognition_test_model.dart';
import 'package:onldocc_admin/features/ca/view_models/cognition_test_view_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/palette.dart';
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
    downloadCsv(csvContent, fileName);
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

    if (selectContractRegion.value!.subdistrictId == "") {
      if (mounted) {
        setState(() {
          loadingFinished = true;
          _testList = testList;
        });
      }
    } else {
      if (selectContractRegion.value!.contractCommunityId != "" &&
          selectContractRegion.value!.contractCommunityId != null) {
        final filterDataList = testList
            .where((e) =>
                e.userContractCommunityId ==
                selectContractRegion.value!.contractCommunityId)
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
    if (selectContractRegion.value != null) {
      _initializeTableList();
    }

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
    return DefaultScreen(
      menu: menuList[5],
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: loadingFinished
            ? Column(
                children: [
                  SearchCsv(
                    filterUserList: filterUserDataList,
                    resetInitialList: _initializeTableList,
                    generateCsv: generateUserCsv,
                  ),
                  Expanded(
                    child: DataTable2(
                      isVerticalScrollBarVisible: false,
                      smRatio: 0.7,
                      lmRatio: 1.2,
                      dividerThickness: 0.1,
                      horizontalMargin: 0,
                      headingRowDecoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Palette().lightGray,
                            width: 0.1,
                          ),
                        ),
                      ),
                      columns: [
                        DataColumn2(
                          fixedWidth: 140,
                          label: Text(
                            "시행 날짜",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          fixedWidth: 200,
                          label: Text(
                            "분류",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          fixedWidth: 80,
                          label: Text(
                            "점수",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          label: Text(
                            "이름",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          fixedWidth: 100,
                          label: Text(
                            "성별",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          fixedWidth: 80,
                          label: Text(
                            "나이",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          fixedWidth: 190,
                          label: Text(
                            "핸드폰 번호",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          fixedWidth: 100,
                          label: Text(
                            "자세히 보기",
                            style: _headerTextStyle,
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
                                Center(
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () {
                                        context.go(
                                          "/alzheimer/${_testList[i].testId}",
                                          extra: _testList[i],
                                        );
                                      },
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        size: Sizes.size16,
                                        color: Palette().darkGray,
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
                ],
              )
            : const SkeletonLoadingScreen(),
      ),
    );
  }
}

import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:onldocc_admin/common/models/contract_notifier.dart';
import 'package:onldocc_admin/common/view/search_below.dart';
import 'package:onldocc_admin/common/view/search_period_order.dart';
import 'package:onldocc_admin/common/widgets/loading_widget.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/ranking/view_models/ranking_view_model.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:universal_html/html.dart';

import '../../users/models/user_model.dart';
import '../../users/view_models/user_view_model.dart';

class RankingScreen extends ConsumerStatefulWidget {
  static const routeURL = "/ranking";
  static const routeName = "ranking";
  const RankingScreen({super.key});

  @override
  ConsumerState<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends ConsumerState<RankingScreen> {
  List<UserModel?> _userDataList = [];
  List<UserModel?> _beforeFilterUserDataList = [];

  final List<String> _userListHeader = [
    "#",
    "이름",
    "나이",
    "성별",
    "핸드폰 번호",
    "종합 점수",
    "걸음수",
    "일기",
    "댓글"
  ];

  bool loadingFinished = false;
  final int _currentSortColumn = 0;
  final bool _isSortAsc = true;
  WeekMonthDay weekMonthDay = getWeekMonthDay();

  String sortOder = "totalPoint";

  DateRange? selectedDateRange = DateRange(
    getThisWeekMonday(),
    DateTime.now(),
  );

  @override
  void initState() {
    super.initState();

    getScoreList(selectedDateRange);
    // contractNotifier.addListener(() async {
    //   setState(() {
    //     loadingFinished = false;
    //   });
    //   await getScoreList();
    // });
  }

  void resetInitialState() async {
    setState(() {
      _userDataList = _beforeFilterUserDataList;
    });
  }

  void filterUserDataList(String? searchBy, String searchKeyword) {
    final newUserDataList = ref.read(userProvider.notifier).filterTableRows(
          _userDataList,
          searchBy!,
          searchKeyword,
        );

    setState(() {
      _beforeFilterUserDataList = _userDataList;
      _userDataList = newUserDataList;
    });
  }

  List<dynamic> exportToList(UserModel userModel) {
    return [
      userModel.index,
      userModel.name,
      userModel.userAge,
      userModel.birthYear,
      userModel.gender,
      userModel.phone,
      userModel.fullRegion,
      userModel.createdAt
    ];
  }

  List<List<dynamic>> exportToFullList(List<UserModel?> userDataList) {
    List<List<dynamic>> list = [];

    list.add(_userListHeader);

    for (var item in userDataList) {
      final itemList = exportToList(item!);
      list.add(itemList);
    }
    return list;
  }

  void generateUserCsv() {
    final csvData = exportToFullList(_userDataList);
    String csvContent = '';
    for (var row in csvData) {
      for (var i = 0; i < row.length; i++) {
        if (row[i].contains(',')) {
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
    final formatDate =
        "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";

    final String fileName = "인지케어 전체 점수 $formatDate.csv";

    final encodedUri = Uri.dataFromString(
      csvContent,
      encoding: Encoding.getByName("utf-8"),
    ).toString();
    final anchor = AnchorElement(href: encodedUri)
      ..setAttribute('download', fileName)
      ..click();
  }

  Future<List<UserModel?>> getScoreList(DateRange? range) async {
    final userList =
        await ref.read(rankingProvider.notifier).getUserPoints(range!);

    if (mounted) {
      setState(() {
        loadingFinished = true;
        _userDataList = userList;
      });
    }
    return userList;
  }

  Future<void> updateOrderStandard(String value) async {
    List<UserModel?> copiedUserDataList = [..._userDataList];
    int count = 1;

    List<UserModel> list = [];
    switch (value) {
      case "totalPoint":
        copiedUserDataList
            .sort((a, b) => b!.totalScore!.compareTo(a!.totalScore!));

        for (int i = 0; i < copiedUserDataList.length - 1; i++) {
          UserModel indexUpdateUser = copiedUserDataList[i]!.copyWith(
            index: count,
          );
          list.add(indexUpdateUser);

          if (copiedUserDataList[i]!.totalScore !=
              copiedUserDataList[i + 1]!.totalScore) {
            count++;
          }
        }

        break;
      case "stepPoint":
        copiedUserDataList
            .sort((a, b) => b!.stepScore!.compareTo(a!.stepScore!));

        for (int i = 0; i < copiedUserDataList.length - 1; i++) {
          UserModel indexUpdateUser = copiedUserDataList[i]!.copyWith(
            index: count,
          );
          list.add(indexUpdateUser);

          if (copiedUserDataList[i]!.stepScore !=
              copiedUserDataList[i + 1]!.stepScore) {
            count++;
          }
        }
        break;
      case "diaryPoint":
        copiedUserDataList
            .sort((a, b) => b!.diaryScore!.compareTo(a!.diaryScore!));

        for (int i = 0; i < copiedUserDataList.length - 1; i++) {
          UserModel indexUpdateUser = copiedUserDataList[i]!.copyWith(
            index: count,
          );
          list.add(indexUpdateUser);

          if (copiedUserDataList[i]!.diaryScore !=
              copiedUserDataList[i + 1]!.diaryScore) {
            count++;
          }
        }
        break;
      case "commentPoint":
        copiedUserDataList
            .sort((a, b) => b!.commentScore!.compareTo(a!.commentScore!));

        for (int i = 0; i < copiedUserDataList.length - 1; i++) {
          UserModel indexUpdateUser = copiedUserDataList[i]!.copyWith(
            index: count,
          );
          list.add(indexUpdateUser);

          if (copiedUserDataList[i]!.commentScore !=
              copiedUserDataList[i + 1]!.commentScore) {
            count++;
          }
        }
        break;
    }
    setState(() {
      sortOder = value;
      _userDataList = list;
    });
  }

  void updateOrderPeriod(DateRange? value) async {
    setState(() {
      loadingFinished = false;
      selectedDateRange = value;
    });

    await getScoreList(value);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return loadingFinished
        ? Column(children: [
            SearchPeriodOrder(
              filterUserList: filterUserDataList,
              resetInitialList: resetInitialState,
              generateCsv: generateUserCsv,
              updateOrderStandard: updateOrderStandard,
              updateOrderPeriod: updateOrderPeriod,
            ),
            SearchBelow(
              size: size,
              child: Padding(
                padding: const EdgeInsets.all(
                  Sizes.size10,
                ),
                child: DataTable2(
                  sortColumnIndex: _currentSortColumn,
                  sortAscending: _isSortAsc,
                  columns: [
                    const DataColumn2(
                      fixedWidth: 50,
                      label: Text(
                        "#",
                        style: TextStyle(
                          fontSize: Sizes.size13,
                        ),
                      ),
                    ),
                    const DataColumn2(
                      label: Text(
                        "이름",
                        style: TextStyle(
                          fontSize: Sizes.size13,
                        ),
                      ),
                    ),
                    const DataColumn2(
                      fixedWidth: 80,
                      label: Text(
                        "나이",
                        style: TextStyle(
                          fontSize: Sizes.size13,
                        ),
                      ),
                    ),
                    const DataColumn2(
                      fixedWidth: 100,
                      label: Text(
                        "성별",
                        style: TextStyle(
                          fontSize: Sizes.size13,
                        ),
                      ),
                    ),
                    const DataColumn2(
                      fixedWidth: 180,
                      label: Text(
                        "핸드폰 번호",
                        style: TextStyle(
                          fontSize: Sizes.size13,
                        ),
                      ),
                    ),
                    DataColumn2(
                      fixedWidth: 150,
                      label: Row(
                        children: [
                          const Text(
                            "종합 점수",
                            style: TextStyle(
                              fontSize: Sizes.size13,
                            ),
                          ),
                          Gaps.h3,
                          Icon(
                            sortOder == "totalPoint"
                                ? Icons.expand_more_rounded
                                : Icons.expand_less_rounded,
                            size: 14,
                            color: Colors.grey.shade600,
                          )
                        ],
                      ),
                      onSort: (columnIndex, ascending) =>
                          updateOrderStandard("totalPoint"),
                    ),
                    DataColumn2(
                      fixedWidth: 140,
                      label: Row(
                        children: [
                          const Text(
                            "걸음수",
                            style: TextStyle(
                              fontSize: Sizes.size13,
                            ),
                          ),
                          Gaps.h3,
                          Icon(
                            sortOder == "stepPoint"
                                ? Icons.expand_more_rounded
                                : Icons.expand_less_rounded,
                            size: 14,
                            color: Colors.grey.shade600,
                          )
                        ],
                      ),
                      onSort: (columnIndex, ascending) =>
                          updateOrderStandard("stepPoint"),
                    ),
                    DataColumn2(
                      fixedWidth: 140,
                      label: Row(
                        children: [
                          const Text(
                            "일기",
                            style: TextStyle(
                              fontSize: Sizes.size13,
                            ),
                          ),
                          Gaps.h3,
                          Icon(
                            sortOder == "diaryPoint"
                                ? Icons.expand_more_rounded
                                : Icons.expand_less_rounded,
                            size: 14,
                            color: Colors.grey.shade600,
                          )
                        ],
                      ),
                      onSort: (columnIndex, ascending) =>
                          updateOrderStandard("diaryPoint"),
                    ),
                    DataColumn2(
                      fixedWidth: 140,
                      label: Row(
                        children: [
                          const Text(
                            "댓글",
                            style: TextStyle(
                              fontSize: Sizes.size13,
                            ),
                          ),
                          Gaps.h3,
                          Icon(
                            sortOder == "commentPoint"
                                ? Icons.expand_more_rounded
                                : Icons.expand_less_rounded,
                            size: 14,
                            color: Colors.grey.shade600,
                          )
                        ],
                      ),
                      onSort: (columnIndex, ascending) =>
                          updateOrderStandard("commentPoint"),
                    ),
                  ],
                  rows: [
                    for (var i = 0; i < _userDataList.length; i++)
                      DataRow2(
                        cells: [
                          DataCell(
                            Text(
                              _userDataList[i]!.index.toString(),
                              style: const TextStyle(
                                fontSize: Sizes.size13,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              _userDataList[i]!.name.length > 8
                                  ? "${_userDataList[i]!.name.substring(0, 8)}.."
                                  : _userDataList[i]!.name,
                              style: const TextStyle(
                                fontSize: Sizes.size13,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              _userDataList[i]!.userAge.toString(),
                              style: const TextStyle(
                                fontSize: Sizes.size13,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              _userDataList[i]!.gender,
                              style: const TextStyle(
                                fontSize: Sizes.size13,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              _userDataList[i]!.phone,
                              style: const TextStyle(
                                fontSize: Sizes.size13,
                              ),
                            ),
                          ),
                          DataCell(
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                numberDecimalCommans(
                                    _userDataList[i]!.totalScore!),
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontSize: Sizes.size13,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                numberDecimalCommans(
                                    _userDataList[i]!.stepScore!),
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontSize: Sizes.size13,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                numberDecimalCommans(
                                    _userDataList[i]!.diaryScore!),
                                style: const TextStyle(
                                  fontSize: Sizes.size13,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                numberDecimalCommans(
                                    _userDataList[i]!.commentScore!),
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
            )
          ])
        : loadingWidget(context);
  }
}

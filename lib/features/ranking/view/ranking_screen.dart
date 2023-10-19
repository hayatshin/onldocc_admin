import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:onldocc_admin/common/models/contract_notifier.dart';
import 'package:onldocc_admin/common/view/search_below.dart';
import 'package:onldocc_admin/common/view/search_period_order.dart';
import 'package:onldocc_admin/constants/sizes.dart';
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
  late String _userContractType;
  late String _userContractName;
  final bool _initialUserDataListState = true;
  bool _updateUserDataListState = false;
  final String _sortOrderStandard = "종합 점수";
  String _sortOrderPeriod = "이번주";
  bool loadingFinished = false;
  final int _currentSortColumn = 0;
  final bool _isSortAsc = true;
  WeekMonthDay weekMonthDay = getWeekMonthDay();

  @override
  void initState() {
    super.initState();

    getScoreList();
    contractNotifier.addListener(() async {
      setState(() {
        loadingFinished = false;
      });
      await getScoreList();
    });
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
      _updateUserDataListState = true;
      _userDataList = newUserDataList;
    });
  }

  List<dynamic> exportToList(UserModel userModel) {
    return [
      userModel.index,
      userModel.name,
      userModel.age,
      userModel.fullBirthday,
      userModel.gender,
      userModel.phone,
      userModel.fullRegion,
      userModel.registerDate
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

  Future<List<UserModel?>> getScoreList() async {
    final userList = await ref
        .read(rankingProvider.notifier)
        .updateUsersListScore(
            weekMonthDay.thisMonth.startDate, weekMonthDay.thisMonth.endDate);

    if (mounted) {
      setState(() {
        loadingFinished = true;
        _userDataList = userList;
      });
    }
    return userList;
  }

  void updateOrderStandard(String value) {
    List<UserModel?> copiedUserDataList = [..._userDataList];
    int count = 1;
    List<UserModel> list = [];

    switch (value) {
      case "종합 점수":
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
      case "걸음수":
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
      case "일기":
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
      case "댓글":
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
      _userDataList = copiedUserDataList;
    });
  }

  void updateOrderPeriod(String value) async {
    setState(() {
      _sortOrderPeriod = value;
      loadingFinished = false;
    });
    switch (value) {
      case "이번달":
        final userList = await ref
            .read(rankingProvider.notifier)
            .updateUsersListScore(weekMonthDay.thisMonth.startDate,
                weekMonthDay.thisMonth.endDate);

        if (mounted) {
          setState(() {
            loadingFinished = true;
            _userDataList = userList;
          });
        }
        break;
      case "이번주":
        final userList = await ref
            .read(rankingProvider.notifier)
            .updateUsersListScore(
                weekMonthDay.thisWeek.startDate, weekMonthDay.thisWeek.endDate);

        if (mounted) {
          setState(() {
            loadingFinished = true;
            _userDataList = userList;
          });
        }
        break;
      case "지난달":
        final userList = await ref
            .read(rankingProvider.notifier)
            .updateUsersListScore(weekMonthDay.lastMonth.startDate,
                weekMonthDay.lastMonth.endDate);

        if (mounted) {
          setState(() {
            loadingFinished = true;
            _userDataList = userList;
          });
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final tableWidth = size.width - 270 - 64;
    return AnimatedBuilder(
      animation: contractNotifier,
      builder: (context, child) {
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
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: tableWidth,
                      child: DataTable(
                        sortColumnIndex: _currentSortColumn,
                        sortAscending: _isSortAsc,
                        columns: [
                          const DataColumn(
                            label: Text(
                              "#",
                              style: TextStyle(
                                fontSize: Sizes.size13,
                              ),
                            ),
                          ),
                          const DataColumn(
                            label: Text(
                              "이름",
                              style: TextStyle(
                                fontSize: Sizes.size13,
                              ),
                            ),
                          ),
                          const DataColumn(
                            label: Text(
                              "나이",
                              style: TextStyle(
                                fontSize: Sizes.size13,
                              ),
                            ),
                          ),
                          const DataColumn(
                            label: Text(
                              "성별",
                              style: TextStyle(
                                fontSize: Sizes.size13,
                              ),
                            ),
                          ),
                          const DataColumn(
                            label: Text(
                              "핸드폰 번호",
                              style: TextStyle(
                                fontSize: Sizes.size13,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: const Text(
                              "종합 점수",
                              style: TextStyle(
                                fontSize: Sizes.size13,
                              ),
                            ),
                            onSort: (columnIndex, ascending) =>
                                updateOrderStandard("종합 점수"),
                          ),
                          DataColumn(
                            label: const Text(
                              "걸음수",
                              style: TextStyle(
                                fontSize: Sizes.size13,
                              ),
                            ),
                            onSort: (columnIndex, ascending) =>
                                updateOrderStandard("걸음수"),
                          ),
                          DataColumn(
                            label: const Text(
                              "일기",
                              style: TextStyle(
                                fontSize: Sizes.size13,
                              ),
                            ),
                            onSort: (columnIndex, ascending) =>
                                updateOrderStandard("일기"),
                          ),
                          DataColumn(
                            label: const Text(
                              "댓글",
                              style: TextStyle(
                                fontSize: Sizes.size13,
                              ),
                            ),
                            onSort: (columnIndex, ascending) =>
                                updateOrderStandard("댓글"),
                          ),
                        ],
                        rows: [
                          for (var i = 0; i < _userDataList.length; i++)
                            DataRow(
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
                                    _userDataList[i]!.name.length > 10
                                        ? "${_userDataList[i]!.name.substring(0, 10)}.."
                                        : _userDataList[i]!.name,
                                    style: const TextStyle(
                                      fontSize: Sizes.size13,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    _userDataList[i]!.age,
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
                  ),
                )
              ])
            : Center(
                child: LoadingAnimationWidget.inkDrop(
                  color: Colors.grey.shade600,
                  size: Sizes.size32,
                ),
              );
      },
    );
  }
}

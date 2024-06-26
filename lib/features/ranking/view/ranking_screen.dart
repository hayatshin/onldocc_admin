import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/view/search_below.dart';
import 'package:onldocc_admin/common/view/search_period_order_ranking.dart';
import 'package:onldocc_admin/common/view/skeleton_loading_screen.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/ranking/view_models/ranking_view_model.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:universal_html/html.dart';

import '../../users/models/user_model.dart';

class RankingScreen extends ConsumerStatefulWidget {
  static const routeURL = "/ranking";
  static const routeName = "ranking";
  const RankingScreen({super.key});

  @override
  ConsumerState<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends ConsumerState<RankingScreen> {
  List<UserModel?> _userDataList = [];
  List<UserModel?> _initialPointList = [];

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

  String sortOder = "totalPoint";

  DateRange? selectedDateRange = DateRange(
    getThisWeekMonday(),
    DateTime.now(),
  );

  @override
  void initState() {
    super.initState();

    if (selectContractRegion.value != null) {
      getScoreList(selectedDateRange);
    }

    selectContractRegion.addListener(() async {
      if (mounted) {
        setState(() {
          loadingFinished = false;
        });

        await getScoreList(selectedDateRange);
      }
    });
  }

  Future<void> filterUserDataList(
      String? searchBy, String searchKeyword) async {
    List<UserModel> filterList = [];
    if (searchBy == "name") {
      filterList = _initialPointList
          .where((element) => element!.name.contains(searchKeyword))
          .cast<UserModel>()
          .toList();
    } else {
      filterList = _initialPointList
          .where((element) => element!.phone.contains(searchKeyword))
          .cast<UserModel>()
          .toList();
    }

    setState(() {
      _userDataList = filterList;
    });
  }

  List<dynamic> exportToList(UserModel userModel) {
    return [
      userModel.index,
      userModel.name,
      userModel.userAge,
      userModel.gender,
      userModel.phone,
      userModel.totalScore,
      userModel.stepScore,
      userModel.diaryScore,
      userModel.commentScore,
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
    final formatDate =
        "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";

    final String fileName = "인지케어 전체 점수 $formatDate.csv";

    final encodedUri = Uri.dataFromString(
      csvContent,
      encoding: Encoding.getByName(encodingType()),
    ).toString();
    final anchor = AnchorElement(href: encodedUri)
      ..setAttribute('download', fileName)
      ..click();
  }

  Future<void> resetInitialList() async {
    final userList = ref.read(rankingProvider).value ??
        await ref
            .read(rankingProvider.notifier)
            .getUserPoints(selectedDateRange ??
                DateRange(
                  getThisWeekMonday(),
                  DateTime.now(),
                ));
    setState(() {
      _userDataList = userList;
    });
  }

  Future<void> getScoreList(DateRange? range) async {
    final userList =
        await ref.read(rankingProvider.notifier).getUserPoints(range!);

    if (selectContractRegion.value!.subdistrictId == "") {
      if (mounted) {
        setState(() {
          loadingFinished = true;
          _userDataList = userList;
          _initialPointList = userList;
        });
      }
    } else {
      if (selectContractRegion.value!.contractCommunityId != "" &&
          selectContractRegion.value!.contractCommunityId != null) {
        final filterDataList = userList
            .where((e) =>
                e.contractCommunityId ==
                selectContractRegion.value!.contractCommunityId)
            .toList();
        if (mounted) {
          setState(() {
            loadingFinished = true;
            _userDataList = filterDataList;
            _initialPointList = userList;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            loadingFinished = true;
            _userDataList = userList;
            _initialPointList = userList;
          });
        }
      }
    }
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
      case "likePoint":
        copiedUserDataList
            .sort((a, b) => b!.likeScore!.compareTo(a!.likeScore!));

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
            SearchPeriodOrderRanking(
              filterUserList: filterUserDataList,
              resetInitialList: () => getScoreList(selectedDateRange),
              generateCsv: generateUserCsv,
              updateOrderStandard: updateOrderStandard,
              updateOrderPeriod: updateOrderPeriod,
            ),
            SearchBelow(
              size: size,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Sizes.size5,
                  vertical: Sizes.size10,
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
                          fontSize: Sizes.size12,
                        ),
                      ),
                    ),
                    const DataColumn2(
                      fixedWidth: 160,
                      label: Text(
                        "이름",
                        style: TextStyle(
                          fontSize: Sizes.size12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const DataColumn2(
                      fixedWidth: 100,
                      label: Text(
                        "나이",
                        style: TextStyle(
                          fontSize: Sizes.size12,
                        ),
                      ),
                    ),
                    const DataColumn2(
                      fixedWidth: 100,
                      label: Text(
                        "성별",
                        style: TextStyle(
                          fontSize: Sizes.size12,
                        ),
                      ),
                    ),
                    const DataColumn2(
                      fixedWidth: 180,
                      label: Text(
                        "핸드폰 번호",
                        style: TextStyle(
                          fontSize: Sizes.size12,
                        ),
                      ),
                    ),
                    DataColumn2(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "종합",
                            style: TextStyle(
                              fontSize: Sizes.size12,
                            ),
                          ),
                          Gaps.h3,
                          Icon(
                            sortOder == "totalPoint"
                                ? Icons.expand_more_rounded
                                : Icons.expand_less_rounded,
                            size: Sizes.size12,
                            color: Colors.grey.shade600,
                          )
                        ],
                      ),
                      onSort: (columnIndex, ascending) =>
                          updateOrderStandard("totalPoint"),
                    ),
                    DataColumn2(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "걸음수",
                            style: TextStyle(
                              fontSize: Sizes.size12,
                            ),
                          ),
                          Gaps.h3,
                          Icon(
                            sortOder == "stepPoint"
                                ? Icons.expand_more_rounded
                                : Icons.expand_less_rounded,
                            size: Sizes.size12,
                            color: Colors.grey.shade600,
                          )
                        ],
                      ),
                      onSort: (columnIndex, ascending) =>
                          updateOrderStandard("stepPoint"),
                    ),
                    DataColumn2(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "일기",
                            style: TextStyle(
                              fontSize: Sizes.size12,
                            ),
                          ),
                          Gaps.h3,
                          Icon(
                            sortOder == "diaryPoint"
                                ? Icons.expand_more_rounded
                                : Icons.expand_less_rounded,
                            size: Sizes.size12,
                            color: Colors.grey.shade600,
                          )
                        ],
                      ),
                      onSort: (columnIndex, ascending) =>
                          updateOrderStandard("diaryPoint"),
                    ),
                    DataColumn2(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "댓글",
                            style: TextStyle(
                              fontSize: Sizes.size12,
                            ),
                          ),
                          Gaps.h3,
                          Icon(
                            sortOder == "commentPoint"
                                ? Icons.expand_more_rounded
                                : Icons.expand_less_rounded,
                            size: Sizes.size12,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                      onSort: (columnIndex, ascending) =>
                          updateOrderStandard("commentPoint"),
                    ),
                    DataColumn2(
                      fixedWidth: 90,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "좋아요",
                            style: TextStyle(
                              fontSize: Sizes.size12,
                            ),
                          ),
                          Gaps.h3,
                          Icon(
                            sortOder == "likePoint"
                                ? Icons.expand_more_rounded
                                : Icons.expand_less_rounded,
                            size: Sizes.size12,
                            color: Colors.grey.shade600,
                          )
                        ],
                      ),
                      onSort: (columnIndex, ascending) =>
                          updateOrderStandard("likePoint"),
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
                              _userDataList[i]!.userAge!,
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
                          DataCell(
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                numberDecimalCommans(
                                    _userDataList[i]!.likeScore!),
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
        : const SkeletonLoadingScreen();
  }
}

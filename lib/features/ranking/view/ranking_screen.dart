import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/view/error_screen.dart';
import 'package:onldocc_admin/common/view/loading_screen.dart';
import 'package:onldocc_admin/common/view/search_below.dart';
import 'package:onldocc_admin/common/view/search_period_order.dart';
import 'package:onldocc_admin/common/view_models/contract_config_view_model.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/ranking/view_models/month_ranking_vm.dart';
import 'package:onldocc_admin/features/ranking/view_models/week_ranking_vm.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:universal_html/html.dart';

import '../../users/models/user_model.dart';
import '../../users/repo/user_repo.dart';
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
  bool _initialUserDataListState = true;
  bool _updateUserDataListState = false;
  final String _sortOrderStandard = "종합 점수";
  String _sortOrderPeriod = "이번주";
  bool loadingFinished = false;
  final List<UserModel?> _weekData = [];
  final List<UserModel?> _monthData = [];
  int _currentSortColumn = 0;
  bool _isSortAsc = true;

  @override
  void initState() {
    super.initState();
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

    final String fileName = "오늘도청춘 전체 점수 $formatDate.csv";

    final encodedUri = Uri.dataFromString(
      csvContent,
      encoding: Encoding.getByName("utf-8"),
    ).toString();
    final anchor = AnchorElement(href: encodedUri)
      ..setAttribute('download', fileName)
      ..click();
  }

  Future<void> getUserModelList(
      String getUserContractType, String getUserContractName) async {
    if (_initialUserDataListState ||
        _userContractType != getUserContractType ||
        _userContractName != getUserContractName) {
      if (getUserContractType == "지역") {
        final userDataList =
            await ref.read(userRepo).getRegionUserData(getUserContractName);
        await getScoreList(
            userDataList, getUserContractType, getUserContractName);
      } else if (getUserContractType == "기관") {
        final userDataList =
            await ref.read(userRepo).getCommunityUserData(getUserContractName);
        await getScoreList(
            userDataList, getUserContractType, getUserContractName);
      } else if (getUserContractType == "마스터" || getUserContractType == "전체") {
        final userDataList = await ref.read(userRepo).getAllUserData();
        await getScoreList(
            userDataList, getUserContractType, getUserContractName);
      }
    }
  }

  Future<void> getScoreList(List<UserModel?> userDataList,
      String getUserContractType, String getUserContractName) async {
    final weekList = await ref
        .read(weekRankingProvider.notifier)
        .updateUserScore(userDataList, _sortOrderStandard);

    setState(() {
      _initialUserDataListState = false;
      _userContractType = getUserContractType;
      _userContractName = getUserContractName;
      _userDataList = weekList;
      loadingFinished = true;
    });
  }

  void updateOrderStandard(String value) {
    List<UserModel?> copiedUserDataList = [..._userDataList];
    switch (value) {
      case "종합 점수":
        copiedUserDataList
            .sort((a, b) => b!.totalScore!.compareTo(a!.totalScore!));
        // final indexList = ref.read(userProvider.notifier).indexUserModel(
        //       value,
        //       copiedUserDataList,
        //     );
        setState(() {
          _userDataList = copiedUserDataList;
        });
        break;
      case "걸음수":
        copiedUserDataList
            .sort((a, b) => b!.stepScore!.compareTo(a!.stepScore!));
        // final indexList = ref.read(userProvider.notifier).indexUserModel(
        //       value,
        //       copiedUserDataList,
        //     );
        setState(() {
          _userDataList = copiedUserDataList;
        });
        break;
      case "일기":
        copiedUserDataList
            .sort((a, b) => b!.diaryScore!.compareTo(a!.diaryScore!));
        // final indexList = ref.read(userProvider.notifier).indexUserModel(
        //       value,
        //       copiedUserDataList,
        //     );
        setState(() {
          _userDataList = copiedUserDataList;
        });
        break;
      case "댓글":
        copiedUserDataList
            .sort((a, b) => b!.commentScore!.compareTo(a!.commentScore!));
        // final indexList = ref.read(userProvider.notifier).indexUserModel(
        //       value,
        //       copiedUserDataList,
        //     );
        setState(() {
          _userDataList = copiedUserDataList;
        });
        break;
    }
  }

  void updateOrderPeriod(String value) async {
    setState(() {
      _sortOrderPeriod = value;
      loadingFinished = false;
    });
    switch (value) {
      case "이번달":
        List<UserModel?> monthList = await ref
            .read(monthRankingProvider.notifier)
            .updateUserScore(_userDataList, _sortOrderStandard);
        setState(() {
          _userDataList = monthList;
          loadingFinished = true;
        });
        break;
      case "이번주":
        setState(() {
          _sortOrderPeriod = "이번주";
        });
        List<UserModel?> weekList = await ref
            .read(weekRankingProvider.notifier)
            .updateUserScore(_userDataList, _sortOrderStandard);
        setState(() {
          _userDataList = weekList;
          loadingFinished = true;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final tableWidth = size.width - 270 - 64;
    return ref.watch(contractConfigProvider).when(
          data: (data) {
            final getUserContractType = data.contractType;
            final getUserContractName = data.contractName;
            return FutureBuilder(
              future:
                  getUserModelList(getUserContractType, getUserContractName),
              builder: (context, snapshot) => Column(children: [
                SearchPeriodOrder(
                  filterUserList: filterUserDataList,
                  resetInitialList: resetInitialState,
                  constractType: getUserContractType,
                  contractName: getUserContractName,
                  generateCsv: generateUserCsv,
                  updateOrderStandard: updateOrderStandard,
                  updateOrderPeriod: updateOrderPeriod,
                ),
                loadingFinished
                    ? SearchBelow(
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
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      _currentSortColumn = columnIndex;
                                      if (_isSortAsc) {
                                        _userDataList.sort((a, b) => b!
                                            .totalScore!
                                            .compareTo(a!.totalScore!));
                                      } else {
                                        _userDataList.sort((a, b) => a!
                                            .totalScore!
                                            .compareTo(b!.totalScore!));
                                      }
                                      _isSortAsc = !_isSortAsc;
                                    });
                                  },
                                ),
                                DataColumn(
                                  label: const Text(
                                    "걸음수",
                                    style: TextStyle(
                                      fontSize: Sizes.size13,
                                    ),
                                  ),
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      _currentSortColumn = columnIndex;
                                      if (_isSortAsc) {
                                        _userDataList.sort((a, b) => b!
                                            .stepScore!
                                            .compareTo(a!.stepScore!));
                                      } else {
                                        _userDataList.sort((a, b) => a!
                                            .stepScore!
                                            .compareTo(b!.stepScore!));
                                      }
                                      _isSortAsc = !_isSortAsc;
                                    });
                                  },
                                ),
                                DataColumn(
                                  label: const Text(
                                    "일기",
                                    style: TextStyle(
                                      fontSize: Sizes.size13,
                                    ),
                                  ),
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      _currentSortColumn = columnIndex;
                                      if (_isSortAsc) {
                                        _userDataList.sort((a, b) => b!
                                            .diaryScore!
                                            .compareTo(a!.diaryScore!));
                                      } else {
                                        _userDataList.sort((a, b) => a!
                                            .diaryScore!
                                            .compareTo(b!.diaryScore!));
                                      }
                                      _isSortAsc = !_isSortAsc;
                                    });
                                  },
                                ),
                                DataColumn(
                                  label: const Text(
                                    "댓글",
                                    style: TextStyle(
                                      fontSize: Sizes.size13,
                                    ),
                                  ),
                                  onSort: (columnIndex, ascending) {
                                    setState(() {
                                      _currentSortColumn = columnIndex;
                                      if (_isSortAsc) {
                                        _userDataList.sort((a, b) => b!
                                            .commentScore!
                                            .compareTo(a!.commentScore!));
                                      } else {
                                        _userDataList.sort((a, b) => a!
                                            .commentScore!
                                            .compareTo(b!.commentScore!));
                                      }
                                      _isSortAsc = !_isSortAsc;
                                    });
                                  },
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
                                                _userDataList[i]!
                                                    .commentScore!),
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
                    : Expanded(
                        child: Center(
                          child: CircularProgressIndicator.adaptive(
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
              ]),
            );
          },
          error: (error, stackTrace) {
            print(error);

            print(error);
            return const ErrorScreen();
          },
          loading: () => const LoadingScreen(),
        );
  }
}

import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/view/search_csv.dart';
import 'package:onldocc_admin/common/view/skeleton_loading_screen.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/common/widgets/period_button.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/ranking/view_models/ranking_view_model.dart';
import 'package:onldocc_admin/palette.dart';
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
  final String _selectedPeriod = "이번달";
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

  bool _loadingFinished = true;
  int _sortColumnIndex = 5;

  String sortOder = "totalPoint";

  final TextStyle _headerTextStyle = TextStyle(
    fontSize: Sizes.size12,
    fontWeight: FontWeight.w600,
    color: Palette().darkGray,
  );

  final TextStyle _contentTextStyle = TextStyle(
    fontSize: Sizes.size11,
    fontWeight: FontWeight.w500,
    color: Palette().darkGray,
  );

  DateRange? selectedDateRange = DateRange(
    getThisWeekMonday(),
    DateTime.now(),
  );

  @override
  void initState() {
    super.initState();

    // if (selectContractRegion.value != null) {
    //   getScoreList(selectedDateRange);
    // }

    // selectContractRegion.addListener(() async {
    //   if (mounted) {
    //     setState(() {
    //       loadingFinished = false;
    //     });

    //     await getScoreList(selectedDateRange);
    //   }
    // });
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
          _loadingFinished = true;
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
            _loadingFinished = true;
            _userDataList = filterDataList;
            _initialPointList = userList;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _loadingFinished = true;
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
    }
    setState(() {
      sortOder = value;
      _userDataList = list;
    });
  }

  void updateOrderPeriod(DateRange? value) async {
    setState(() {
      _loadingFinished = false;
      selectedDateRange = value;
    });

    await getScoreList(value);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return DefaultScreen(
      menu: menuList[2],
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Column(
          children: [
            SearchCsv(
              filterUserList: filterUserDataList,
              resetInitialList: resetInitialList,
              generateCsv: generateUserCsv,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const PeriodButton(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "점수 계산 방법",
                      style: TextStyle(
                        fontSize: Sizes.size12,
                        color: Palette().normalGray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Gaps.v5,
                    Text(
                      "걸음수: 1,000보당 10점 (하루 최대 만보)",
                      style: TextStyle(
                        fontSize: Sizes.size11,
                        color: Palette().normalGray,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Gaps.v5,
                    Text(
                      "일기: 100점 / 댓글: 20점 / 좋아요: 10점",
                      style: TextStyle(
                        fontSize: Sizes.size11,
                        color: Palette().normalGray,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Gaps.v40,
            _loadingFinished
                ? Expanded(
                    child: DataTable2(
                      isVerticalScrollBarVisible: false,
                      smRatio: 0.7,
                      lmRatio: 1.2,
                      dividerThickness: 0.1,
                      sortColumnIndex: _sortColumnIndex,
                      sortArrowIcon: Icons.arrow_downward_rounded,
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
                          fixedWidth: 50,
                          label: Text(
                            "#",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          size: ColumnSize.L,
                          label: Text(
                            "이름",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          size: ColumnSize.S,
                          label: Text(
                            "나이",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          size: ColumnSize.S,
                          label: Text(
                            "성별",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          size: ColumnSize.L,
                          label: Text(
                            "핸드폰 번호",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          tooltip: "클릭하면 '종합 점수'를 기준으로 정렬됩니다.",
                          onSort: (columnIndex, sortAscending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                            });
                          },
                          label: Text(
                            "종합 점수",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          tooltip: "클릭하면 '걸음수'를 기준으로 정렬됩니다.",
                          onSort: (columnIndex, sortAscending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                            });
                          },
                          label: Text(
                            "걸음수",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          tooltip: "클릭하면 '일기'를 기준으로 정렬됩니다.",
                          onSort: (columnIndex, sortAscending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                            });
                          },
                          label: Text(
                            "일기",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          tooltip: "클릭하면 '댓글'을 기준으로 정렬됩니다.",
                          onSort: (columnIndex, sortAscending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                            });
                          },
                          label: Text(
                            "댓글",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          tooltip: "클릭하면 '좋아요'를 기준으로 정렬됩니다.",
                          onSort: (columnIndex, sortAscending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                            });
                          },
                          label: Text(
                            "좋아요",
                            style: _headerTextStyle,
                          ),
                        ),
                      ],
                      rows: [
                        for (var i = 0; i < _userDataList.length; i++)
                          DataRow2(
                            cells: [
                              DataCell(
                                Text(
                                  (i + 1).toString(),
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  _userDataList[i]!.name.length > 10
                                      ? "${_userDataList[i]!.name.substring(0, 10)}.."
                                      : _userDataList[i]!.name,
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  _userDataList[i]!.userAge!,
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  _userDataList[i]!.gender,
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  _userDataList[i]!.phone,
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  "${_userDataList[i]!.totalScore}",
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  "${_userDataList[i]!.stepScore}",
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  "${_userDataList[i]!.diaryScore}",
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  "${_userDataList[i]!.commentScore}",
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  "${_userDataList[i]!.likeScore}",
                                  style: _contentTextStyle,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  )
                : const SkeletonLoadingScreen()
          ],
        ),
      ),
    );
  }
}

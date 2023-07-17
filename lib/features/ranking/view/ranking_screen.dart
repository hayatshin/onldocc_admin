import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/view/error_screen.dart';
import 'package:onldocc_admin/common/view/search_below.dart';
import 'package:onldocc_admin/common/view/search_period.dart';
import 'package:onldocc_admin/common/view_models/contract_config_view_model.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/ranking/view_models/ranking_view_model.dart';
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
  final List<String> _userListHeader = [
    "#",
    "이름",
    "나이",
    "성별",
    "핸드폰 번호",
    "종합",
    "걸음수",
    "일기",
    "댓글"
  ];
  late String _userContractType;
  late String _userContractName;
  bool _initialUserDataListState = true;
  bool _updateUserDataListState = false;

  void resetInitialState() {
    setState(() {
      _initialUserDataListState = true;
    });
    getUserModelList(_userContractType, _userContractName);
  }

  void filterUserDataList(String? searchBy, String searchKeyword) {
    final newUserDataList = ref.read(userProvider.notifier).filterTableRows(
          _userDataList,
          searchBy!,
          searchKeyword,
        );

    setState(() {
      _updateUserDataListState = true;
      _userDataList = newUserDataList;
    });
  }

  List<dynamic> exportToList(UserModel userModel) {
    return [
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
        "${currentDate.year}-${currentDate.month}-${currentDate.day}";

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
    DateTime now = DateTime.now();
    DateTime firstDateOfMonth = DateTime(now.year, now.month, 1);
    DateTime firstDateOfWeek = now.subtract(Duration(days: now.weekday - 1));
    List<UserModel?> list = [];

    await Future.forEach(
      userDataList,
      (UserModel? user) async {
        final scoreUserModel = await ref
            .read(rankingProvider.notifier)
            .calculateUserScore(user, firstDateOfWeek, now);
        list.add(scoreUserModel);
      },
    );

    orderingList(list, getUserContractType, getUserContractName);

    // for (UserModel? user in userDataList) {
    //   final userModel = await ref
    //       .read(rankingProvider.notifier)
    //       .calculateUserScore(user, firstDateOfWeek, now);
    //   list.add(userModel);
    // }
  }

  void orderingList(List<UserModel?> userDataList, String getUserContractType,
      String getUserContractName) {
    userDataList.sort((a, b) => b!.totalScore!.compareTo(a!.totalScore!));
    setState(() {
      _initialUserDataListState = false;
      _userContractType = getUserContractType;
      _userContractName = getUserContractName;
      _userDataList = userDataList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(contractConfigProvider).when(
          data: (data) {
            final getUserContractType = data.contractType;
            final getUserContractName = data.contractName;
            getUserModelList(getUserContractType, getUserContractName);
            return Column(
              children: [
                SearchPeriod(
                  filterUserList: filterUserDataList,
                  resetInitialList: resetInitialState,
                  constractType: getUserContractType,
                  contractName: getUserContractName,
                  generateCsv: generateUserCsv,
                ),
                SearchBelow(
                  child: DataTable(
                    columns: const [
                      DataColumn(
                        label: Text("#"),
                      ),
                      DataColumn(
                        label: Text("이름"),
                      ),
                      DataColumn(
                        label: Text("나이"),
                      ),
                      DataColumn(
                        label: Text("성별"),
                      ),
                      DataColumn(
                        label: Text("핸드폰 번호"),
                      ),
                      DataColumn(
                        label: Text("종합"),
                      ),
                      DataColumn(
                        label: Text("걸음수"),
                      ),
                      DataColumn(
                        label: Text("일기"),
                      ),
                      DataColumn(
                        label: Text("댓글"),
                      ),
                    ],
                    rows: [
                      for (var i = 0; i < _userDataList.length; i++)
                        DataRow(
                          cells: [
                            DataCell(
                              Text(
                                i.toString(),
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
                              Text(
                                _userDataList[i]!.totalScore.toString(),
                                style: const TextStyle(
                                  fontSize: Sizes.size13,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                _userDataList[i]!.stepScore.toString(),
                                style: const TextStyle(
                                  fontSize: Sizes.size13,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                _userDataList[i]!.diaryScore.toString(),
                                style: const TextStyle(
                                  fontSize: Sizes.size13,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                _userDataList[i]!.commentScore.toString(),
                                style: const TextStyle(
                                  fontSize: Sizes.size13,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                )
              ],
            );
          },
          error: (error, stackTrace) => const ErrorScreen(),
          loading: () => CircularProgressIndicator.adaptive(
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:onldocc_admin/common/models/contract_notifier.dart';
import 'package:onldocc_admin/common/view/search.dart';
import 'package:onldocc_admin/common/view/search_below.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/ranking/models/ranking_extra.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/features/users/view_models/user_view_model.dart';
import 'package:universal_html/html.dart';

class RankingUsersScreen extends ConsumerStatefulWidget {
  static const stepRouteURL = "step";
  static const stepRouteName = "stepRanking";
  static const diaryRouteURL = "diary";
  static const diaryRouteName = "diaryRanking";
  static const caRouteURL = "ca";
  static const caRouteName = "caRanking";
  final String? rankingType;
  const RankingUsersScreen({
    super.key,
    required this.rankingType,
  });

  @override
  ConsumerState<RankingUsersScreen> createState() => _RankingUsersScreenState();
}

class _RankingUsersScreenState extends ConsumerState<RankingUsersScreen> {
  List<UserModel?> _beforeFilterUserDataList = [];
  bool loadingFinished = false;

  List<UserModel?> _userDataList = [];
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final List<String> _userListHeader = [
    "이름",
    "나이",
    "출생일",
    "성별",
    "핸드폰 번호",
    "거주 지역",
    "가입일",
    "마지막 방문일"
  ];
  late String _userContractType;
  late String _userContractName;
  final bool _initialUserDataListState = true;
  bool _updateUserDataListState = false; // getUserModelList xxxx

  @override
  void initState() {
    super.initState();
    getUserModelList();
    contractNotifier.addListener(() async {
      setState(() {
        loadingFinished = false;
      });
      await getUserModelList();
    });
  }

  void resetInitialState() {
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

    final String fileName = "인지케어 회원관리 $formatDate.csv";

    final encodedUri = Uri.dataFromString(
      csvContent,
      encoding: Encoding.getByName("utf-8"),
    ).toString();
    final anchor = AnchorElement(href: encodedUri)
      ..setAttribute('download', fileName)
      ..click();
  }

  void goDetailPage({int? index, String? userId, String? userName}) {
    Map<String, String?> extraJson = {
      "userId": userId,
      "userName": userName,
    };
    if (widget.rankingType == "step") {
      context.go("/ranking/step/$userId",
          extra: RankingExtra.fromJson(extraJson));
    } else if (widget.rankingType == "diary") {
      context.go("/ranking/diary/$userId",
          extra: RankingExtra.fromJson(extraJson));
    } else if (widget.rankingType == "ca") {
      context.go("/ca/$userId", extra: RankingExtra.fromJson(extraJson));
    }
  }

  Future<List<UserModel?>> getUserModelList() async {
    List<UserModel?> userDataList =
        await ref.read(userProvider.notifier).getContractUserList();
    if (mounted) {
      setState(() {
        loadingFinished = true;
        _userDataList = userDataList;
      });
    }

    return userDataList;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final tableWidth = size.width - 270 - 64;
    return AnimatedBuilder(
      animation: contractNotifier,
      builder: (context, child) {
        return loadingFinished
            ? Column(
                children: [
                  Search(
                    filterUserList: filterUserDataList,
                    resetInitialList: resetInitialState,
                  ),
                  SearchBelow(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: tableWidth,
                        child: DataTable(
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
                                "출생일",
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
                            const DataColumn(
                              label: Text(
                                "거주 지역",
                                style: TextStyle(
                                  fontSize: Sizes.size13,
                                ),
                              ),
                            ),
                            // const DataColumn(
                            //   label: Text(
                            //     "가입일",
                            //     style: TextStyle(
                            //       fontSize: Sizes.size13,
                            //     ),
                            //   ),
                            // ),
                            // const DataColumn(
                            //   label: Text(
                            //     "마지막 방문일",
                            //     style: TextStyle(
                            //       fontSize: Sizes.size13,
                            //     ),
                            //   ),
                            // ),
                            DataColumn(
                              label: Text(
                                "선택",
                                style: TextStyle(
                                  fontSize: Sizes.size13,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                          rows: [
                            for (var i = 0; i < _userDataList.length; i++)
                              DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      (i + 1).toString(),
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
                                      _userDataList[i]!.fullBirthday,
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
                                      _userDataList[i]!.fullRegion,
                                      style: const TextStyle(
                                        fontSize: Sizes.size13,
                                      ),
                                    ),
                                  ),
                                  // DataCell(
                                  //   Text(
                                  //     _userDataList[i]!.registerDate,
                                  //     style: const TextStyle(
                                  //       fontSize: Sizes.size12,
                                  //     ),
                                  //   ),
                                  // ),
                                  // DataCell(
                                  //   Text(
                                  //     _userDataList[i]!.lastVisit,
                                  //     style: const TextStyle(
                                  //       fontSize: Sizes.size12,
                                  //     ),
                                  //   ),
                                  // ),
                                  DataCell(
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () => goDetailPage(
                                          index: i + 1,
                                          userId: _userDataList[i]!.userId,
                                          userName: _userDataList[i]!.name,
                                        ),
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
                              ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              )
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

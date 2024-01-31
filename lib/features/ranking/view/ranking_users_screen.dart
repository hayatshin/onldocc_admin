import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/models/contract_notifier.dart';
import 'package:onldocc_admin/common/view/search.dart';
import 'package:onldocc_admin/common/view/search_below.dart';
import 'package:onldocc_admin/common/widgets/loading_widget.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/ranking/models/ranking_extra.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/features/users/view_models/user_view_model.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:universal_html/html.dart';

class RankingUsersScreen extends ConsumerStatefulWidget {
  static const stepRouteURL = "step";
  static const stepRouteName = "stepRanking";
  static const diaryRouteURL = "diary";
  static const diaryRouteName = "diaryRanking";
  static const caRouteURL = "quiz";
  static const caRouteName = "quizRanking";
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
  final List<String> _tableHeader = [
    "#",
    "이름",
    "나이",
    "출생일",
    "성별",
    "핸드폰 번호",
    "거주 지역",
    "선택"
  ];
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
      _userDataList = newUserDataList;
    });
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
    } else if (widget.rankingType == "quiz") {
      context.go("/quiz/$userId", extra: RankingExtra.fromJson(extraJson));
    }
  }

  Future<List<UserModel?>> getUserModelList() async {
    final userList = ref.read(userProvider).value ??
        await ref.read(userProvider.notifier).initializeUserList();
    if (mounted) {
      setState(() {
        loadingFinished = true;
        _userDataList = userList;
      });
    }

    return userList;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final menuTitle = widget.rankingType == "step"
        ? "회원별 걸음수"
        : widget.rankingType == "diary"
            ? "회원별 일기"
            : "회원별 문제 풀기";
    return loadingFinished
        ? Column(
            children: [
              Search(
                menuText: menuTitle,
                filterUserList: filterUserDataList,
                resetInitialList: resetInitialState,
              ),
              SearchBelow(
                size: size,
                child: DataTable2(
                  columns: [
                    const DataColumn2(
                      fixedWidth: 80,
                      label: Text(
                        "#",
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
                      fixedWidth: 120,
                      label: Text(
                        "출생일",
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
                      fixedWidth: 200,
                      label: Text(
                        "핸드폰 번호",
                        style: TextStyle(
                          fontSize: Sizes.size13,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const DataColumn2(
                      label: Text(
                        "거주 지역",
                        style: TextStyle(
                          fontSize: Sizes.size13,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    DataColumn2(
                      fixedWidth: 100,
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
                      DataRow2(
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
                              _userDataList[i]!.name.length > 20
                                  ? "${_userDataList[i]!.name.substring(0, 20)}.."
                                  : _userDataList[i]!.name,
                              style: const TextStyle(
                                fontSize: Sizes.size13,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              userAgeCalculation(_userDataList[i]!.birthYear,
                                      _userDataList[i]!.birthDay)
                                  .toString(),
                              style: const TextStyle(
                                fontSize: Sizes.size13,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              _userDataList[i]!.birthYear,
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
                                    backgroundColor: Colors.grey.shade200,
                                    child: Icon(
                                      Icons.chevron_right,
                                      size: Sizes.size16,
                                      color: Theme.of(context).primaryColor,
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
              )
            ],
          )
        : loadingWidget(context);
  }
}

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/view/search.dart';
import 'package:onldocc_admin/common/view/search_below.dart';
import 'package:onldocc_admin/common/view/skeleton_loading_screen.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/ranking/models/ranking_extra.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/features/users/view_models/user_view_model.dart';

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
  bool loadingFinished = false;

  List<UserModel?> _userDataList = [];
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  void initState() {
    super.initState();
    getUserModelList();

    selectContractRegion.addListener(() async {
      if (mounted) {
        setState(() {
          loadingFinished = false;
        });

        await getUserModelList();
      }
    });
  }

  Future<void> filterUserDataList(
      String? searchBy, String searchKeyword) async {
    AdminProfileModel? adminProfileModel = ref.read(adminProfileProvider).value;
    List<UserModel?> userDataList = ref.read(userProvider).value ??
        await ref
            .read(userProvider.notifier)
            .initializeUserList(adminProfileModel!.subdistrictId);

    List<UserModel> filterList = [];
    if (searchBy == "name") {
      filterList = userDataList
          .where((element) => element!.name.contains(searchKeyword))
          .cast<UserModel>()
          .toList();
    } else {
      filterList = userDataList
          .where((element) => element!.phone.contains(searchKeyword))
          .cast<UserModel>()
          .toList();
    }

    setState(() {
      _userDataList = filterList;
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

  Future<void> getUserModelList() async {
    AdminProfileModel? adminProfileModel =
        ref.read(adminProfileProvider).value ??
            await ref.read(adminProfileProvider.notifier).getAdminProfile();
    final userList = adminProfileModel!.master
        ? ref.read(userProvider).value ??
            await ref
                .read(userProvider.notifier)
                .initializeUserList(selectContractRegion.value.subdistrictId)
        : await ref
            .read(userProvider.notifier)
            .initializeUserList(selectContractRegion.value.subdistrictId);

    if (selectContractRegion.value.subdistrictId == "") {
      if (mounted) {
        setState(() {
          loadingFinished = true;
          _userDataList = userList;
        });
      }
    } else {
      if (selectContractRegion.value.contractCommunityId != "" &&
          selectContractRegion.value.contractCommunityId != null) {
        final filterDataList = userList
            .where((e) =>
                e!.contractCommunityId ==
                selectContractRegion.value.contractCommunityId)
            .toList();
        if (mounted) {
          setState(() {
            loadingFinished = true;
            _userDataList = filterDataList;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            loadingFinished = true;
            _userDataList = userList;
          });
        }
      }
    }
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
                resetInitialList: getUserModelList,
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
                              _userDataList[i]!.userAge!,
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
        : const SkeletonLoadingScreen();
  }
}

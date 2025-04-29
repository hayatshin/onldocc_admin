import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/models/path_extra.dart';
import 'package:onldocc_admin/common/view/search.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/features/users/repo/user_repo.dart';
import 'package:onldocc_admin/features/users/view_models/user_view_model.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';

class DiaryCognitionQuizScreen extends ConsumerStatefulWidget {
  static const routeURL = "/diary-quiz";
  static const routeName = "diary-quiz";
  const DiaryCognitionQuizScreen({super.key});

  @override
  ConsumerState<DiaryCognitionQuizScreen> createState() =>
      _DiaryCognitionQuizScreenState();
}

class _DiaryCognitionQuizScreenState
    extends ConsumerState<DiaryCognitionQuizScreen> {
  final _scrollController = ScrollController();
  int _sortColumnIndex = 5;

  List<UserModel?> _userDataList = [];
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();
  OverlayEntry? overlayEntry;
  final List<String> _userListHeader = [
    "#",
    "이름",
    "연령",
    "출생일",
    "성별",
    "핸드폰 번호",
    "거주 지역",
    "가입일",
    "마지막 방문일"
  ];

  final tableFontSize = 11.5;

  bool createdAtSort = false;
  bool lastVisitSort = false;
  AdminProfileModel _adminProfile = AdminProfileModel.empty();

  bool _filtered = false;
  int _pageCount = 0;
  final int _offset = 20;
  int _rowCount = 0;

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

  @override
  void initState() {
    super.initState();

    if (selectContractRegion.value != null) {
      _initializeTable();
    }

    selectContractRegion.addListener(() async {
      if (mounted) {
        await ref
            .read(userProvider.notifier)
            .initializeUserList(selectContractRegion.value!.subdistrictId);
        _getUserModelList();
      }
    });

    _scrollController.addListener(_onDetectScroll);
  }

  @override
  void dispose() {
    removeDeleteOverlay();
    _scrollController.removeListener(_onDetectScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onDetectScroll() {
    if (_filtered) return;
    if (_scrollController.position.atEdge) {
      bool isTop = _scrollController.position.pixels == 0;
      _pageCount += _offset;

      if (!isTop) {
        setState(() {
          _rowCount = (_pageCount + _offset) > _userDataList.length
              ? _userDataList.length
              : _pageCount + _offset;
        });
      }
    }
  }

  Future<void> _initializeAdminProfile() async {
    final adminProfile = ref.read(adminProfileProvider).value ??
        await ref.read(adminProfileProvider.notifier).getAdminProfile();
    final sortColumnIndex = adminProfile.master ? 6 : 5;
    setState(() {
      _sortColumnIndex = sortColumnIndex;
      _adminProfile = adminProfile;
    });
  }

  Future<void> _getUserModelList() async {
    List<UserModel?> userDataList = ref.read(userProvider).value ??
        await ref
            .read(userProvider.notifier)
            .initializeUserList(selectContractRegion.value!.subdistrictId);

    int rowCount =
        userDataList.length > 20 ? _pageCount + _offset : userDataList.length;
    if (selectContractRegion.value!.contractCommunityId == null) {
      // 전체보기
      if (mounted) {
        setState(() {
          _userDataList = userDataList;
          _filtered = false;
          _rowCount = rowCount;
        });
      }
    } else {
      // 기관 선택
      final filterList = userDataList
          .where((e) =>
              e!.contractCommunityId ==
              selectContractRegion.value!.contractCommunityId)
          .toList();
      if (mounted) {
        setState(() {
          _userDataList = filterList;
          _filtered = false;
          _rowCount = filterList.length;
        });
      }
    }
  }

  void _initializeTable() async {
    await Future.wait([
      _initializeAdminProfile(),
      _getUserModelList(),
    ]);
  }

  Future<void> _filterUserDataList(
      String? searchBy, String searchKeyword) async {
    List<UserModel?> userDataList = ref.read(userProvider).value!;

    List<UserModel> filterList = [];
    if (searchBy == "이름") {
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
      _filtered = true;
      _userDataList = filterList;
      _rowCount = filterList.length;
    });
  }

  // excel
  List<String> exportToList(int index, UserModel userModel) {
    return [
      index.toString(),
      userModel.name.toString(),
      userModel.userAge.toString(),
      userModel.birthYear.toString(),
      userModel.gender.toString(),
      userModel.phone.toString(),
      userModel.fullRegion.toString(),
      secondsToStringLine(userModel.createdAt).toString(),
      userModel.lastVisit != 0
          ? secondsToStringLine(userModel.lastVisit!).toString()
          : "-",
    ];
  }

  List<List<String>> exportToFullList(List<UserModel?> userDataList) {
    List<List<String>> list = [];

    list.add(_userListHeader);

    for (var i = 0; i < userDataList.length; i++) {
      final itemList = exportToList(i + 1, userDataList[i]!);
      list.add(itemList);
    }
    return list;
  }

  void removeDeleteOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  void showDeleteOverlay(
      BuildContext context, String userId, String userName) async {
    removeDeleteOverlay();

    assert(overlayEntry == null);

    overlayEntry = OverlayEntry(builder: (context) {
      return deleteOverlay(userName, removeDeleteOverlay, () async {
        await ref.read(userRepo).deleteUser(userId);
        removeDeleteOverlay();
        setState(() {});
      });
    });
    Overlay.of(context, debugRequiredFor: widget).insert(overlayEntry!);
  }

  void goUserDashBoard({
    required String userId,
    required String userName,
  }) {
    Map<String, String> extraJson = {
      "userId": userId,
      "userName": userName,
    };
    context.go("/diary-quiz/$userId", extra: PathExtra.fromJson(extraJson));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Overlay(initialEntries: [
      OverlayEntry(
        builder: (context) => DefaultScreen(
          menu: menuList[5],
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Column(
              children: [
                Search(
                  filterUserList: _filterUserDataList,
                  resetInitialList: _getUserModelList,
                ),
                Expanded(
                  child: DataTable2(
                    scrollController: _scrollController,
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
                        fixedWidth: 80,
                        label: SelectableText(
                          "#",
                          style: _headerTextStyle,
                        ),
                      ),
                      DataColumn2(
                        size: ColumnSize.L,
                        label: SelectableText(
                          "이름",
                          style: _headerTextStyle,
                        ),
                      ),
                      DataColumn2(
                        size: ColumnSize.S,
                        label: SelectableText(
                          "연령",
                          style: _headerTextStyle,
                        ),
                      ),
                      DataColumn2(
                        size: ColumnSize.S,
                        label: SelectableText(
                          "성별",
                          style: _headerTextStyle,
                        ),
                      ),
                      DataColumn2(
                        size: ColumnSize.L,
                        label: SelectableText(
                          "핸드폰 번호",
                          style: _headerTextStyle,
                        ),
                      ),
                      if (_adminProfile.master)
                        DataColumn2(
                          size: ColumnSize.L,
                          label: SelectableText(
                            "거주 지역",
                            style: _headerTextStyle,
                          ),
                        ),
                      DataColumn2(
                        tooltip: "클릭하면 '가입일'을 기준으로 정렬됩니다",
                        onSort: (columnIndex, sortAscending) {
                          _sortColumnIndex = columnIndex;
                          final sortIndex = _adminProfile.master ? 6 : 5;
                          if (columnIndex == sortIndex) {
                            createdAtSort = !createdAtSort;
                            if (createdAtSort) {
                              _userDataList.sort((a, b) =>
                                  b!.createdAt.compareTo(a!.createdAt));
                            } else {
                              _userDataList.sort((a, b) =>
                                  a!.createdAt.compareTo(b!.createdAt));
                            }
                            setState(() {});
                          }
                        },
                        label: SelectableText(
                          "가입일",
                          style: _headerTextStyle,
                        ),
                      ),
                      DataColumn2(
                        tooltip: "클릭하면 '마지막 방문일'을 기준으로 정렬됩니다",
                        onSort: (columnIndex, sortAsending) {
                          _sortColumnIndex = columnIndex;
                          final sortIndex = _adminProfile.master ? 7 : 6;

                          if (columnIndex == sortIndex) {
                            lastVisitSort = !lastVisitSort;
                            if (lastVisitSort) {
                              _userDataList.sort((a, b) =>
                                  b!.lastVisit!.compareTo(a!.lastVisit!));
                            } else {
                              _userDataList.sort((a, b) =>
                                  a!.lastVisit!.compareTo(b!.lastVisit!));
                            }
                            setState(() {});
                          }
                        },
                        label: SelectableText(
                          "최근 방문일",
                          style: _headerTextStyle,
                        ),
                      ),
                      DataColumn2(
                        fixedWidth: 150,
                        onSort: (columnIndex, sortAscending) {
                          setState(() {
                            _sortColumnIndex = columnIndex;
                          });
                        },
                        label: SelectableText(
                          "문제 풀기 결과\n자세히 보기",
                          style: _headerTextStyle,
                          textAlign: TextAlign.end,
                        ),
                      ),
                      // DataColumn2(
                      //   fixedWidth: 80,
                      //   size: ColumnSize.S,
                      //   label: SelectableText(
                      //     "대시보드",
                      //     style: _headerTextStyle,
                      //   ),
                      // ),
                    ],
                    rows: [
                      if (_userDataList.isNotEmpty)
                        for (var i = 0; i < _rowCount; i++)
                          DataRow2(
                            cells: [
                              DataCell(
                                SelectableText(
                                  (i + 1).toString(),
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                SelectableText(
                                  _userDataList[i]!.name.length > 10
                                      ? "${_userDataList[i]!.name.substring(0, 10)}.."
                                      : _userDataList[i]!.name,
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                SelectableText(
                                  _userDataList[i]!.userAge!,
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                SelectableText(
                                  _userDataList[i]!.gender,
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                SelectableText(
                                  _userDataList[i]!.phone,
                                  style: _contentTextStyle,
                                ),
                              ),
                              if (_adminProfile.master)
                                DataCell(
                                  SelectableText(
                                    _userDataList[i]!.fullRegion,
                                    style: _contentTextStyle,
                                  ),
                                ),
                              DataCell(
                                SelectableText(
                                  secondsToStringLine(
                                      _userDataList[i]!.createdAt),
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                SelectableText(
                                  _userDataList[i]!.lastVisit != 0
                                      ? secondsToStringLine(
                                          _userDataList[i]!.lastVisit!)
                                      : "-",
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () => goUserDashBoard(
                                        userId: _userDataList[i]!.userId,
                                        userName: _userDataList[i]!.name,
                                      ),
                                      child: FaIcon(
                                        FontAwesomeIcons.arrowRight,
                                        color: Palette().darkGray,
                                        size: 14,
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
            ),
          ),
        ),
      ),
    ]);
  }
}

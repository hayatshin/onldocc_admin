import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/models/path_extra.dart';
import 'package:onldocc_admin/common/view/search_csv.dart';
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

class UsersScreen extends ConsumerStatefulWidget {
  static const routeURL = "/users";
  static const routeName = "users";
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final _scrollController = ScrollController();
  int _sortColumnIndex = 5;

  List<UserModel?> _userDataList = [];
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();
  OverlayEntry? overlayEntry;
  final List<String> _userListHeader = [
    "#",
    "이름",
    "나이",
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

    // if (selectContractRegion.value!.subdistrictId == "") {
    //   if (mounted) {
    //     setState(() {
    //       _userDataList = userDataList;
    //       _filtered = false;
    //       _rowCount = rowCount;
    //     });
    //   }
    // } else {
    //   if (selectContractRegion.value!.contractCommunityId != "" &&
    //       selectContractRegion.value!.contractCommunityId != null) {
    //     final filterDataList = userDataList
    //         .where((e) =>
    //             e!.contractCommunityId ==
    //             selectContractRegion.value!.contractCommunityId)
    //         .toList();
    //     if (mounted) {
    //       setState(() {
    //         _userDataList = filterDataList;
    //         _filtered = false;
    //         _rowCount = rowCount;
    //       });
    //     }
    //   } else {
    //     if (mounted) {
    //       setState(() {
    //         _userDataList = userDataList;
    //         _filtered = false;
    //         _rowCount = rowCount;
    //       });
    //     }
    //   }
    // }
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

  // void generateUserCsv() {
  //   final csvData = exportToFullList(_userDataList);
  //   String csvContent = '';
  //   for (var row in csvData) {
  //     for (var i = 0; i < row.length; i++) {
  //       if (row[i].toString().contains(',')) {
  //         csvContent += '"${row[i]}"';
  //       } else {
  //         csvContent += row[i].toString();
  //       }

  //       if (i != row.length - 1) {
  //         csvContent += ',';
  //       }
  //     }
  //     csvContent += '\n';
  //   }
  //   final currentDate = DateTime.now();
  //   final formatDate =
  //       "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";

  //   final String fileName = "인지케어 회원관리 $formatDate.csv";

  //   downloadCsv(csvContent, fileName);
  // }

  void generateExcel() {
    final csvData = exportToFullList(_userDataList);
    final String fileName = "인지케어 회원관리 ${todayToStringDot()}.xlsx";
    exportExcel(csvData, fileName);
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

  void goUserDashBoard({String? userId, String? userName}) {
    Map<String, String?> extraJson = {
      "userId": userId,
      "userName": userName,
    };
    context.go("/users/$userId", extra: PathExtra.fromJson(extraJson));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Overlay(initialEntries: [
      OverlayEntry(
        builder: (context) => DefaultScreen(
          menu: menuList[1],
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Column(
              children: [
                SearchCsv(
                  filterUserList: _filterUserDataList,
                  resetInitialList: _getUserModelList,
                  generateCsv: generateExcel,
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
                      if (_adminProfile.master)
                        DataColumn2(
                          size: ColumnSize.L,
                          label: Text(
                            "거주 지역",
                            style: _headerTextStyle,
                          ),
                        ),
                      DataColumn2(
                        tooltip: "클릭하면 '가입일'을 기준으로 정렬됩니다",
                        onSort: (columnIndex, sortAscending) {
                          _sortColumnIndex = columnIndex;
                          if (columnIndex == 5) {
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
                        label: Text(
                          "가입일",
                          style: _headerTextStyle,
                        ),
                      ),
                      DataColumn2(
                        tooltip: "클릭하면 '마지막 방문일'을 기준으로 정렬됩니다",
                        onSort: (columnIndex, sortAsending) {
                          _sortColumnIndex = columnIndex;
                          if (columnIndex == 6) {
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
                        label: Text(
                          "최근 방문일",
                          style: _headerTextStyle,
                        ),
                      ),
                      DataColumn2(
                        fixedWidth: 80,
                        label: Text(
                          "삭제",
                          style: _headerTextStyle,
                        ),
                      ),
                      // DataColumn2(
                      //   fixedWidth: 80,
                      //   size: ColumnSize.S,
                      //   label: Text(
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
                              if (_adminProfile.master)
                                DataCell(
                                  Text(
                                    _userDataList[i]!.fullRegion,
                                    style: _contentTextStyle,
                                  ),
                                ),
                              DataCell(
                                Text(
                                  secondsToStringLine(
                                      _userDataList[i]!.createdAt),
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  _userDataList[i]!.lastVisit != 0
                                      ? secondsToStringLine(
                                          _userDataList[i]!.lastVisit!)
                                      : "-",
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () => showDeleteOverlay(
                                      context,
                                      _userDataList[i]!.userId,
                                      _userDataList[i]!.name,
                                    ),
                                    child: Icon(
                                      Icons.delete,
                                      size: Sizes.size16,
                                      color: Palette().darkGray,
                                    ),
                                  ),
                                ),
                              ),
                              // DataCell(
                              //   MouseRegion(
                              //     cursor: SystemMouseCursors.click,
                              //     child: GestureDetector(
                              //       onTap: () => goUserDashBoard(
                              //         userId: _userDataList[i]!.userId,
                              //         userName: _userDataList[i]!.name,
                              //       ),
                              //       child: ColorFiltered(
                              //         colorFilter: ColorFilter.mode(
                              //           Palette().darkBlue,
                              //           BlendMode.srcIn,
                              //         ),
                              //         child: SvgPicture.asset(
                              //           "assets/svg/pie-chart.svg",
                              //           width: 15,
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),
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

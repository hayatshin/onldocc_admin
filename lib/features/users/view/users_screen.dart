import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/models/path_extra.dart';
import 'package:onldocc_admin/common/view/search_csv.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/features/users/repo/user_repo.dart';
import 'package:onldocc_admin/features/users/view_models/user_view_model.dart';
import 'package:onldocc_admin/injicare_color.dart';
import 'package:onldocc_admin/injicare_font.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';

final TextStyle contentTextStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: InjicareColor().gray100,
);

class UsersScreen extends ConsumerStatefulWidget {
  static const routeURL = "/users";
  static const routeName = "users";
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
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

  final TextStyle _headerTextStyle = TextStyle(
    fontSize: Sizes.size13,
    fontWeight: FontWeight.w600,
    color: Palette().darkGray,
  );

  static const int _itemsPerPage = 20;
  int _currentPage = 0;
  int _pageIndication = 0;
  int _totalListLength = 0;
  int _endPage = 0;

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
        _initializeTable();
      }
    });
  }

  @override
  void dispose() {
    removeDeleteOverlay();

    super.dispose();
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

    int startPage = _currentPage * _itemsPerPage + 1;
    int endPage = userDataList.length ~/ _itemsPerPage + 1;
    if (selectContractRegion.value!.contractCommunityId == null ||
        selectContractRegion.value!.contractCommunityId == "") {
      // 전체보기
      if (mounted) {
        setState(() {
          _filtered = false;
          _totalListLength = userDataList.length;
          _endPage = endPage;
        });
      }
      _updateUserlistPerPage();
    } else {
      // 기관 선택
      final filterList = userDataList
          .where((e) =>
              e!.contractCommunityId ==
              selectContractRegion.value!.contractCommunityId)
          .toList();
      if (mounted) {
        setState(() {
          _userDataList = filterList.sublist(startPage, startPage + 20);
          _totalListLength = filterList.length;
          _endPage = endPage;
        });
      }
    }

    setState(() {
      _currentPage = 0;
      _pageIndication = 0;
    });
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
          .where((element) {
            if (element != null) {
              return element.name.contains(searchKeyword);
            } else {
              return false;
            }
          })
          .cast<UserModel>()
          .toList();
    } else {
      filterList = userDataList
          .where((element) {
            if (element != null) {
              return element.phone.contains(searchKeyword);
            } else {
              return false;
            }
          })
          .cast<UserModel>()
          .toList();
    }
    int endPage = filterList.length ~/ _itemsPerPage + 1;

    setState(() {
      _filtered = true;
      _userDataList = filterList;
      _currentPage = 0;
      _pageIndication = 0;
      _endPage = endPage;
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
    context.push("/users/$userId", extra: PathExtra.fromJson(extraJson));
  }

  void _updateUserlistPerPage() {
    List<UserModel?>? userDataList = ref.read(userProvider).value;
    if (userDataList == null) return;

    int startPage = _currentPage * _itemsPerPage;
    int endPage = startPage + 20 > userDataList.length
        ? userDataList.length
        : startPage + 20;

    setState(() {
      _userDataList = userDataList.sublist(startPage, endPage);
    });
  }

  void _previousPage() {
    if (_pageIndication == 0) return;

    setState(() {
      _pageIndication--;
      _currentPage = _pageIndication * 5;
    });
    _updateUserlistPerPage();
  }

  void _nextPage() {
    int endIndication = _endPage ~/ 5;
    if (_pageIndication >= endIndication) return;
    setState(() {
      _pageIndication++;
      _currentPage = _pageIndication * 5;
    });
    _updateUserlistPerPage();
  }

  void _changePage(int s) {
    setState(() {
      _currentPage = s - 1;
    });
    _updateUserlistPerPage();
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(initialEntries: [
      OverlayEntry(
        builder: (context) => DefaultScreen(
          menu: menuList[1],
          child: Column(
            children: [
              Column(
                children: [
                  SearchCsv(
                    filterUserList: _filterUserDataList,
                    resetInitialList: _getUserModelList,
                    generateCsv: generateExcel,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "총 ${numberFormat(_totalListLength)}개",
                        style: InjicareFont().label03.copyWith(
                              color: InjicareColor().gray70,
                            ),
                      ),
                      Gaps.v14,
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFE9EDF9),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                  ),
                                  border: Border.all(
                                    width: 1,
                                    color: const Color(0xFFF3F6FD),
                                  )),
                              child: Center(
                                child: Text(
                                  "#",
                                  style: contentTextStyle,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFE9EDF9),
                                  border: Border.all(
                                    width: 1,
                                    color: const Color(0xFFF3F6FD),
                                  )),
                              child: Center(
                                child: Text(
                                  "이름",
                                  style: contentTextStyle,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFE9EDF9),
                                  border: Border.all(
                                    width: 1,
                                    color: const Color(0xFFF3F6FD),
                                  )),
                              child: Center(
                                child: Text(
                                  "연령",
                                  style: contentTextStyle,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFE9EDF9),
                                  border: Border.all(
                                    width: 1,
                                    color: const Color(0xFFF3F6FD),
                                  )),
                              child: Center(
                                child: Text(
                                  "성별",
                                  style: contentTextStyle,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFE9EDF9),
                                  border: Border.all(
                                    width: 1,
                                    color: const Color(0xFFF3F6FD),
                                  )),
                              child: Center(
                                child: Text(
                                  "핸드폰 번호",
                                  style: contentTextStyle,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFE9EDF9),
                                  border: Border.all(
                                    width: 2,
                                    color: const Color(0xFFF3F6FD),
                                  )),
                              child: Center(
                                child: Text(
                                  "거주 지역",
                                  style: contentTextStyle,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFE9EDF9),
                                  border: Border.all(
                                    width: 1,
                                    color: const Color(0xFFF3F6FD),
                                  )),
                              child: Center(
                                child: Text(
                                  "가입일",
                                  style: contentTextStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFE9EDF9),
                                  border: Border.all(
                                    width: 1,
                                    color: const Color(0xFFF3F6FD),
                                  )),
                              child: Center(
                                child: Text(
                                  "방문일",
                                  style: contentTextStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFE9EDF9),
                                  border: Border.all(
                                    width: 1,
                                    color: const Color(0xFFF3F6FD),
                                  )),
                              child: Center(
                                child: Text(
                                  "삭제",
                                  style: contentTextStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  color: const Color(0xFFE9EDF9),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(16),
                                  ),
                                  border: Border.all(
                                    width: 1,
                                    color: const Color(0xFFF3F6FD),
                                  )),
                              child: Center(
                                child: Text(
                                  "대시보드",
                                  style: contentTextStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_userDataList.isNotEmpty)
                        for (int i = 0; i < _userDataList.length; i++)
                          Column(
                            children: [
                              SizedBox(
                                height: 50,
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: SelectableText(
                                        "${_currentPage * 20 + 1 + i}",
                                        style: contentTextStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: SelectableText(
                                        _userDataList[i]!.name,
                                        style: contentTextStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: SelectableText(
                                        "${_userDataList[i]!.userAge!}세",
                                        style: contentTextStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: SelectableText(
                                        _userDataList[i]!.gender,
                                        style: contentTextStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: SelectableText(
                                        _userDataList[i]!.phone,
                                        style: contentTextStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: SelectableText(
                                        _userDataList[i]!.fullRegion,
                                        style: contentTextStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: SelectableText(
                                        secondsToStringLine(
                                            _userDataList[i]!.createdAt),
                                        style: contentTextStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: SelectableText(
                                        secondsToStringLine(
                                            _userDataList[i]!.lastVisit!),
                                        style: contentTextStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () => showDeleteOverlay(
                                            context,
                                            _userDataList[i]!.userId,
                                            _userDataList[i]!.name,
                                          ),
                                          child: Icon(
                                            Icons.delete,
                                            size: 16,
                                            color: InjicareColor().gray80,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () => goUserDashBoard(
                                            userId: _userDataList[i]!.userId,
                                            userName: _userDataList[i]!.name,
                                          ),
                                          child: ColorFiltered(
                                            colorFilter: ColorFilter.mode(
                                              InjicareColor().secondary50,
                                              BlendMode.srcIn,
                                            ),
                                            child: SvgPicture.asset(
                                              "assets/svg/pie-chart.svg",
                                              width: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: InjicareColor().gray30,
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                    ],
                  )
                ],
              ),
              Gaps.v40,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _previousPage,
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                            _pageIndication == 0
                                ? InjicareColor().gray50
                                : InjicareColor().gray100,
                            BlendMode.srcIn),
                        child: SvgPicture.asset(
                          "assets/svg/chevron-left.svg",
                        ),
                      ),
                    ),
                  ),
                  Gaps.h10,
                  for (int s = (_pageIndication * 5 + 1);
                      s <
                          (s >= _endPage + 1
                              ? _endPage + 1
                              : (_pageIndication * 5 + 1) + 5);
                      s++)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Gaps.h10,
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => _changePage(s),
                            child: Text(
                              "$s",
                              style: InjicareFont().body07.copyWith(
                                  color: _currentPage + 1 == s
                                      ? InjicareColor().gray100
                                      : InjicareColor().gray60,
                                  fontWeight: _currentPage + 1 == s
                                      ? FontWeight.w900
                                      : FontWeight.w400),
                            ),
                          ),
                        ),
                        Gaps.h10,
                      ],
                    ),
                  Gaps.h10,
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _nextPage,
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                            _pageIndication + 5 > _endPage
                                ? InjicareColor().gray50
                                : InjicareColor().gray100,
                            BlendMode.srcIn),
                        child: SvgPicture.asset(
                          "assets/svg/chevron-right.svg",
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    ]);
  }
}

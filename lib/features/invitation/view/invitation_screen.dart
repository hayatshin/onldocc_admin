import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/models/path_extra.dart';
import 'package:onldocc_admin/common/view/search_csv.dart';
import 'package:onldocc_admin/common/view/skeleton_loading_screen.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/invitation/models/invitation_model.dart';
import 'package:onldocc_admin/features/invitation/view_models/invitation_view_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/users/view/users_screen.dart';
import 'package:onldocc_admin/injicare_color.dart';
import 'package:onldocc_admin/injicare_font.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';

class InvitationScreen extends ConsumerStatefulWidget {
  static const routeURL = "/invitation";
  static const routeName = "invitation";
  const InvitationScreen({super.key});

  @override
  ConsumerState<InvitationScreen> createState() => _InvitationScreenState();
}

class _InvitationScreenState extends ConsumerState<InvitationScreen> {
  bool _loadingFinished = true;
  final _scrollController = ScrollController();
  int _sortColumnIndex = 1;

  final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();
  OverlayEntry? overlayEntry;

  final List<String> _userListHeader = [
    "번호",
    "친구 초대 수",
    "이름",
    "연령",
    "성별",
    "핸드폰 번호",
  ];
  List<InvitationModel?> _userDataList = [];
  List<InvitationModel?> _initialList = [];

  final double _tabHeight = 50;

  static const int _itemsPerPage = 20;
  int _currentPage = 0;
  int _pageIndication = 0;
  int _totalListLength = 0;
  int _endPage = 0;

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

  Map<int, bool> expandMap = {};
  bool expandclick = false;
  bool expandUpdate = false;

  DateRange? _selectedDateRange = DateRange(
    getThisWeekMonday(),
    DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    getInvitationList(_selectedDateRange);

    selectContractRegion.addListener(() async {
      if (mounted) {
        setState(() {
          _loadingFinished = false;
        });

        await getInvitationList(_selectedDateRange);
      }
    });

    _scrollController.addListener(_onDetectScroll);
  }

  @override
  void dispose() {
    _removePeriodCalender();
    _scrollController.removeListener(_onDetectScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onDetectScroll() {
    if (_scrollController.position.atEdge) {}
  }

  void _removePeriodCalender() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  Future<void> filterUserDataList(
      String? searchBy, String searchKeyword) async {
    List<InvitationModel> filterList = [];
    if (searchBy == "name") {
      filterList = _initialList
          .where((element) => element!.userName.contains(searchKeyword))
          .cast<InvitationModel>()
          .toList();
    } else {
      filterList = _initialList
          .where((element) => element!.userPhone.contains(searchKeyword))
          .cast<InvitationModel>()
          .toList();
    }

    setState(() {
      _userDataList = filterList;
    });
  }

  List<String> exportToList(InvitationModel userModel) {
    return [
      userModel.index.toString(),
      userModel.receiveUsers.length.toString(),
      userModel.userName.toString(),
      userModel.userAge.toString(),
      userModel.userGender.toString(),
      userModel.userPhone.toString(),
    ];
  }

  List<List<String>> exportToFullList(List<InvitationModel?> userDataList) {
    List<List<String>> list = [];

    list.add(_userListHeader);

    for (var item in userDataList) {
      final itemList = exportToList(item!);
      list.add(itemList);
    }
    return list;
  }

  void generateExcel() {
    final csvData = exportToFullList(_userDataList);
    final String fileName = "인지케어 친구초대 ${todayToStringDot()}.xlsx";
    exportExcel(csvData, fileName);
  }

  Future<void> resetInitialList() async {
    final userList = ref.read(invitationProvider).value ??
        await ref
            .read(invitationProvider.notifier)
            .fetchInvitations(selectContractRegion.value!.subdistrictId);
    setState(() {
      _userDataList = userList;
    });
  }

  void updateOrderPeriod(DateRange? value) async {
    setState(() {
      _loadingFinished = false;
      _selectedDateRange = value;
    });

    await getInvitationList(value);
  }

  Future<void> getInvitationList(DateRange? range) async {
    if (selectContractRegion.value == null) return;
    final userList = await ref
        .read(invitationProvider.notifier)
        .fetchInvitations(selectContractRegion.value!.subdistrictId);
    int endPage = userList.length ~/ _itemsPerPage + 1;

    if (selectContractRegion.value!.subdistrictId == "") {
      if (mounted) {
        setState(() {
          _loadingFinished = true;
          _totalListLength = userList.length;
          _initialList = userList;
          _endPage = endPage;
        });
        _updateUserlistPerPage();
      }
    } else {
      if (selectContractRegion.value!.contractCommunityId != "" &&
          selectContractRegion.value!.contractCommunityId != null) {
        final filterList = userList
            .where((e) =>
                e.userContractCommunityId ==
                selectContractRegion.value!.contractCommunityId)
            .toList();
        int endPage = filterList.length ~/ _itemsPerPage + 1;

        if (mounted) {
          setState(() {
            _loadingFinished = true;
            _totalListLength = filterList.length;
            _initialList = filterList;
            _endPage = endPage;
          });
          _updateUserlistPerPage();
        }
      } else {
        if (mounted) {
          setState(() {
            _loadingFinished = true;
            _totalListLength = userList.length;
            _initialList = userList;
            _endPage = endPage;
          });
          _updateUserlistPerPage();
        }
      }
    }
  }

  void expansionCallbackFunc(int index, bool isExpanded) {
    setState(() {
      expandclick = true;
      expandMap[index] = isExpanded;
    });
  }

  Future<void> updateOrderStandard(int columnIndex) async {
    List<InvitationModel?> copiedUserDataList = [..._userDataList];
    int count = 1;

    List<InvitationModel> list = [];

    switch (columnIndex) {
      case 1:
        // 초대 횟수
        copiedUserDataList
            .sort((a, b) => b!.sendCounts.compareTo(a!.sendCounts));

        for (int i = 0; i < copiedUserDataList.length; i++) {
          InvitationModel indexUpdateUser = copiedUserDataList[i]!.copyWith(
            index: count,
          );
          list.add(indexUpdateUser);

          if ((i != copiedUserDataList.length - 1) &&
              (copiedUserDataList[i]!.sendCounts !=
                  copiedUserDataList[i + 1]!.sendCounts)) {
            count++;
          }
        }

        break;
      case 2:
        // 초대 친구 가입자 수
        copiedUserDataList.sort(
            (a, b) => b!.receiveUsers.length.compareTo(a!.receiveUsers.length));

        for (int i = 0; i < copiedUserDataList.length; i++) {
          // 0, 1, 2
          InvitationModel indexUpdateUser = copiedUserDataList[i]!.copyWith(
            index: count,
          );
          list.add(indexUpdateUser);

          if ((i != copiedUserDataList.length - 1) &&
              (copiedUserDataList[i]!.receiveUsers.length !=
                  copiedUserDataList[i + 1]!.receiveUsers.length)) {
            count++;
          }
        }

        break;
    }

    setState(() {
      _sortColumnIndex = columnIndex;
      _userDataList = list;
    });
  }

  void goUserInvitation({
    required String userId,
    required String userName,
    required DateRange dateRange,
  }) {
    // final startSeconds = convertStartDateTimeToSeconds(dateRange.start);
    // final endSeconds = convertEndDateTimeToSeconds(dateRange.end);

    Map<String, String> extraJson = {
      "userId": userId,
      "userName": userName,
      // "dateRange": encodeDateRange(dateRange),
    };
    context.go("/invitation/$userId", extra: PathExtra.fromJson(extraJson));
  }

  void _updateUserlistPerPage() {
    int startPage = _currentPage * _itemsPerPage;
    int endPage = startPage + _itemsPerPage > _initialList.length
        ? _initialList.length
        : startPage + _itemsPerPage;

    setState(() {
      _userDataList = _initialList.sublist(startPage, endPage);
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
    final size = MediaQuery.of(context).size;
    return DefaultScreen(
      menu: menuList[10],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchCsv(
              filterUserList: filterUserDataList,
              resetInitialList: resetInitialList,
              generateCsv: generateExcel,
            ),
            Text(
              "총 ${numberFormat(_totalListLength)}개",
              style: InjicareFont().label03.copyWith(
                    color: InjicareColor().gray70,
                  ),
            ),
            Gaps.v14,
            !_loadingFinished
                ? const SkeletonLoadingScreen()
                : SizedBox(
                    height: 50,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
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
                                "번호",
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "초대 횟수",
                                  style: contentTextStyle,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Gaps.h5,
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () => updateOrderStandard(1),
                                    child: ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                          InjicareColor().gray70,
                                          BlendMode.srcIn),
                                      child: SvgPicture.asset(
                                        _sortColumnIndex == 1
                                            ? "assets/svg/arrow-up.svg"
                                            : "assets/svg/arrow-down.svg",
                                        width: 8,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "초대한 친구\n가입자 수",
                                  style: contentTextStyle,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Gaps.h5,
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () => updateOrderStandard(2),
                                    child: ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                          InjicareColor().gray70,
                                          BlendMode.srcIn),
                                      child: SvgPicture.asset(
                                        _sortColumnIndex == 2
                                            ? "assets/svg/arrow-up.svg"
                                            : "assets/svg/arrow-down.svg",
                                        width: 8,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
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
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
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
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
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
                          flex: 2,
                          child: Container(
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
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                                color: const Color(0xFFE9EDF9),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(16),
                                ),
                                border: Border.all(
                                  width: 2,
                                  color: const Color(0xFFF3F6FD),
                                )),
                            child: Center(
                              child: Text(
                                "초대한 친구\n가입자 보기",
                                style: contentTextStyle,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            if (_userDataList.isNotEmpty)
              for (int i = 0; i < _userDataList.length; i++)
                Column(
                  children: [
                    SizedBox(
                      height: _tabHeight,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: SelectableText(
                              "${_userDataList[i]!.index}",
                              style: contentTextStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: SelectableText(
                              "${_userDataList[i]!.sendCounts}회",
                              style: contentTextStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: SelectableText(
                              "${_userDataList[i]!.receiveUsers.length}명",
                              style: contentTextStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: SelectableText(
                              _userDataList[i]!.userName,
                              style: contentTextStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: SelectableText(
                              "${_userDataList[i]!.userAge}세",
                              style: contentTextStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: SelectableText(
                              _userDataList[i]!.userGender,
                              style: contentTextStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: SelectableText(
                              _userDataList[i]!.userPhone,
                              style: contentTextStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => () => goUserInvitation(
                                      userId: _userDataList[i]!.userId,
                                      userName: _userDataList[i]!.userName,
                                      dateRange: _selectedDateRange ??
                                          DateRange(
                                            getThisWeekMonday(),
                                            DateTime.now(),
                                          ),
                                    ),
                                child: ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                      InjicareColor().gray100, BlendMode.srcIn),
                                  child: SvgPicture.asset(
                                      "assets/svg/arrow-small-right.svg",
                                      width: 20),
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
    );

    return DefaultScreen(
      menu: menuList[10],
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Column(
          children: [
            SearchCsv(
              filterUserList: filterUserDataList,
              resetInitialList: resetInitialList,
              generateCsv: generateExcel,
            ),
            const Row(
              children: [
                // MouseRegion(
                //   cursor: SystemMouseCursors.click,
                //   child: GestureDetector(
                //     onTap: _showPeriodCalender,
                //     child: PeriodButton(
                //       startDate: _selectedDateRange!.start,
                //       endDate: _selectedDateRange!.end,
                //     ),
                //   ),
                // ),
              ],
            ),
            Gaps.v20,
            !_loadingFinished
                ? const SkeletonLoadingScreen()
                : Expanded(
                    child: DataTable2(
                      scrollController: _scrollController,
                      isVerticalScrollBarVisible: false,
                      smRatio: 0.8,
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
                          label: SelectableText(
                            "번호",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          tooltip: "친구 초대를 한 횟수 기준으로 정렬됩니다.",
                          onSort: (columnIndex, sortAscending) {
                            updateOrderStandard(columnIndex);
                          },
                          label: SelectableText(
                            "초대 횟수",
                            style: _headerTextStyle.copyWith(
                              color: InjicareColor().secondary50,
                            ),
                          ),
                        ),
                        DataColumn2(
                          tooltip: "친구 초대를 통해 인지케어에 가입한 수를 기준으로 정렬됩니다.",
                          onSort: (columnIndex, sortAscending) {
                            updateOrderStandard(columnIndex);
                          },
                          label: SelectableText(
                            "초대 친구\n가입자 수",
                            style: _headerTextStyle.copyWith(
                              color: InjicareColor().primary50,
                            ),
                          ),
                        ),
                        DataColumn2(
                          label: SelectableText(
                            "이름",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          label: SelectableText(
                            "연령",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          label: SelectableText(
                            "성별",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          label: SelectableText(
                            "핸드폰 번호",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          fixedWidth: 100,
                          onSort: (columnIndex, sortAscending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                            });
                          },
                          label: SelectableText(
                            "초대 친구\n가입자 목록",
                            style: _headerTextStyle.copyWith(
                              color: InjicareColor().primary50,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                      rows: [
                        for (var i = 0; i < _userDataList.length; i++)
                          DataRow2(
                            cells: [
                              DataCell(
                                SelectableText(
                                  _userDataList[i]!.index.toString(),
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                SelectableText(
                                  _userDataList[i]!.sendCounts.toString(),
                                  style: _contentTextStyle.copyWith(
                                    // color:
                                    //     InjicareColor().primary50,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              DataCell(
                                SelectableText(
                                  _userDataList[i]!
                                      .receiveUsers
                                      .length
                                      .toString(),
                                  style: _contentTextStyle.copyWith(
                                    // color:
                                    //     InjicareColor().primary50,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              DataCell(
                                SelectableText(
                                  _userDataList[i]!.userName,
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                SelectableText(
                                  _userDataList[i]!.userAge,
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                SelectableText(
                                  _userDataList[i]!.userGender,
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                SelectableText(
                                  _userDataList[i]!.userPhone,
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () => goUserInvitation(
                                        userId: _userDataList[i]!.userId,
                                        userName: _userDataList[i]!.userName,
                                        dateRange: _selectedDateRange ??
                                            DateRange(
                                              getThisWeekMonday(),
                                              DateTime.now(),
                                            ),
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
                          )
                      ],
                    ),
                  )
          ],
        ),
      ),
    );
  }
}

String invitationDatesToTable(List<dynamic> dates) {
  String tableDates = "";
  for (int i = 0; i < dates.length; i++) {
    if (i == dates.length - 1) {
      tableDates += "◦  ${dates[i]}";
    } else {
      tableDates += "◦  ${dates[i]}\n";
    }
  }
  return tableDates;
}

String invitationDatesToCSV(List<dynamic> dates) {
  String tableDates = "";
  for (int i = 0; i < dates.length; i++) {
    if (i == dates.length - 1) {
      tableDates += "${dates[i]}";
    } else {
      tableDates += "${dates[i]} / ";
    }
  }
  return tableDates;
}

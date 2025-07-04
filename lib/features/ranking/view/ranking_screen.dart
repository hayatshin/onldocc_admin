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
import 'package:onldocc_admin/common/widgets/period_button.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/ranking/view_models/ranking_view_model.dart';
import 'package:onldocc_admin/features/users/view/users_screen.dart';
import 'package:onldocc_admin/features/users/view_models/user_view_model.dart';
import 'package:onldocc_admin/injicare_color.dart';
import 'package:onldocc_admin/injicare_font.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../users/models/user_model.dart';

class RankingScreen extends ConsumerStatefulWidget {
  static const routeURL = "/ranking";
  static const routeName = "ranking";
  const RankingScreen({super.key});

  @override
  ConsumerState<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends ConsumerState<RankingScreen> {
  List<UserModel?> _userDataList = [];
  List<UserModel?> _initialPointList = [];

  final List<String> _userListHeader = [
    "#",
    "이름",
    "핸드폰 번호",
    "종합",
    "걸음수",
    "일기",
    "댓글",
  ];

  bool _loadingFinished = false;

  String _sortOder = "totalPoint";

  final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();
  OverlayEntry? overlayEntry;

  // page
  bool _filtered = false;

  static const int _itemsPerPage = 20;
  int _currentPage = 0;
  int _pageIndication = 0;
  int _totalListLength = 0;
  int _endPage = 0;

  DateRange? _selectedDateRange = DateRange(
    getThisWeekMonday(),
    DateTime.now(),
  );

  @override
  void initState() {
    super.initState();

    if (selectContractRegion.value != null) {
      _getScoreList(_selectedDateRange);
    }

    selectContractRegion.addListener(() async {
      if (mounted) {
        setState(() {
          _loadingFinished = false;
        });
        await ref
            .read(userProvider.notifier)
            .initializeUserList(selectContractRegion.value!.subdistrictId);
        await _getScoreList(_selectedDateRange);
      }
    });
  }

  @override
  void dispose() {
    _removePeriodCalender();

    super.dispose();
  }

  Future<void> _getScoreList(DateRange? range) async {
    final userDataList =
        await ref.read(rankingProvider.notifier).getUserPoints(range!);
    int startPage = _currentPage * _itemsPerPage + 1;
    int endPage = userDataList.length ~/ _itemsPerPage + 1;

    if (selectContractRegion.value!.contractCommunityId == null ||
        selectContractRegion.value!.contractCommunityId == "") {
      // 전체보기
      if (mounted) {
        setState(() {
          _loadingFinished = true;
          _filtered = false;
          _initialPointList = userDataList;
          _totalListLength = userDataList.length;
          _endPage = endPage;
        });
        _updateUserlistPerPage();
      }
    } else {
      final filterList = userDataList
          .where((e) =>
              e.contractCommunityId ==
              selectContractRegion.value!.contractCommunityId)
          .toList();
      int endPageItems = startPage + _itemsPerPage > userDataList.length
          ? userDataList.length
          : startPage + _itemsPerPage;
      if (mounted) {
        setState(() {
          _loadingFinished = true;
          _userDataList = filterList.sublist(startPage, endPageItems);
          _filtered = false;
          _totalListLength = userDataList.length;
          _endPage = endPage;
        });
      }
    }
  }

  void _removePeriodCalender() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  void _showPeriodCalender() {
    overlayEntry = OverlayEntry(
      builder: (context) {
        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.light(
              primary: Palette().darkBlue,
            ),
          ),
          child: Positioned.fill(
            child: Material(
              color: Colors.black38,
              child: Center(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: SfDateRangePicker(
                    backgroundColor: Colors.white,
                    headerHeight: 50,
                    confirmText: "확인",
                    cancelText: "취소",
                    onCancel: () {
                      _removePeriodCalender();
                    },
                    onSubmit: (dateRange) async {
                      if (dateRange is PickerDateRange) {
                        setState(() {
                          _selectedDateRange = DateRange(dateRange.startDate!,
                              dateRange.endDate ?? dateRange.startDate!);
                          _loadingFinished = false;
                        });
                        _removePeriodCalender();
                        await _getScoreList(_selectedDateRange);
                      }
                    },
                    showActionButtons: true,
                    viewSpacing: 10,
                    selectionColor: Palette().darkBlue,
                    selectionTextStyle: InjicareFont().body07,
                    rangeTextStyle: InjicareFont().body07,
                    rangeSelectionColor: Palette().lightBlue,
                    startRangeSelectionColor: Palette().darkBlue,
                    endRangeSelectionColor: Palette().darkBlue,
                    headerStyle: DateRangePickerHeaderStyle(
                      backgroundColor: Palette().darkBlue,
                      textStyle: InjicareFont().body01.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    monthCellStyle: DateRangePickerMonthCellStyle(
                      textStyle: InjicareFont().body07,
                      leadingDatesTextStyle: InjicareFont().body07,
                      trailingDatesTextStyle: InjicareFont().body07,
                    ),
                    monthViewSettings: const DateRangePickerMonthViewSettings(),
                    selectionMode: DateRangePickerSelectionMode.range,
                    initialSelectedRange: PickerDateRange(
                      _selectedDateRange!.start,
                      _selectedDateRange!.end,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context, debugRequiredFor: widget, rootOverlay: true)
        .insert(overlayEntry!);
  }

  Future<void> _filterUserDataList(
      String? searchBy, String searchKeyword) async {
    List<UserModel> filterList = [];
    if (searchBy == "이름") {
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
  List<String> exportToList(UserModel userModel) {
    return [
      userModel.index.toString(),
      userModel.name.toString(),
      userModel.phone.toString(),
      userModel.totalPoint.toString(),
      userModel.stepPoint.toString(),
      userModel.diaryPoint.toString(),
      userModel.commentPoint.toString(),
      // userModel.invitationPoint.toString(),
    ];
  }

  List<List<String>> exportToFullList(List<UserModel?> userDataList) {
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
    final String fileName = "인지케어 점수관리 ${todayToStringDot()}.xlsx";
    exportExcel(csvData, fileName);
  }

  void goUserRankingDashboard({
    required String userId,
    required String userName,
    required DateRange dateRange,
  }) {
    final startSeconds = convertStartDateTimeToSeconds(dateRange.start);
    final endSeconds = convertEndDateTimeToSeconds(dateRange.end);

    Map<String, String> extraJson = {
      "userId": userId,
      "userName": userName,
      "dateRange": encodeDateRange(dateRange),
    };
    context.go("/ranking/$userId?start=$startSeconds&end=$endSeconds",
        extra: DatePathExtra.fromJson(extraJson));
  }

  Future<void> updateOrderStandard(String value) async {
    List<UserModel?> copiedUserDataList = [..._userDataList];
    int count = 1;

    List<UserModel> list = [];
    switch (value) {
      case "totalPoint":
        copiedUserDataList
            .sort((a, b) => b!.totalPoint!.compareTo(a!.totalPoint!));

        for (int i = 0; i < copiedUserDataList.length; i++) {
          UserModel indexUpdateUser = copiedUserDataList[i]!.copyWith(
            index: count,
          );
          list.add(indexUpdateUser);

          if ((i != copiedUserDataList.length - 1) &&
              (copiedUserDataList[i]!.totalPoint !=
                  copiedUserDataList[i + 1]!.totalPoint)) {
            count++;
          }
        }

        break;
      case "stepPoint":
        copiedUserDataList
            .sort((a, b) => b!.stepPoint!.compareTo(a!.stepPoint!));

        for (int i = 0; i < copiedUserDataList.length; i++) {
          UserModel indexUpdateUser = copiedUserDataList[i]!.copyWith(
            index: count,
          );
          list.add(indexUpdateUser);

          if ((i != copiedUserDataList.length - 1) &&
              (copiedUserDataList[i]!.stepPoint !=
                  copiedUserDataList[i + 1]!.stepPoint)) {
            count++;
          }
        }
        break;
      case "diaryPoint":
        copiedUserDataList
            .sort((a, b) => b!.diaryPoint!.compareTo(a!.diaryPoint!));

        for (int i = 0; i < copiedUserDataList.length; i++) {
          UserModel indexUpdateUser = copiedUserDataList[i]!.copyWith(
            index: count,
          );
          list.add(indexUpdateUser);

          if ((i != copiedUserDataList.length - 1) &&
              (copiedUserDataList[i]!.diaryPoint !=
                  copiedUserDataList[i + 1]!.diaryPoint)) {
            count++;
          }
        }
        break;
      case "commentPoint":
        copiedUserDataList
            .sort((a, b) => b!.commentPoint!.compareTo(a!.commentPoint!));

        for (int i = 0; i < copiedUserDataList.length; i++) {
          UserModel indexUpdateUser = copiedUserDataList[i]!.copyWith(
            index: count,
          );
          list.add(indexUpdateUser);

          if ((i != copiedUserDataList.length - 1) &&
              (copiedUserDataList[i]!.commentPoint !=
                  copiedUserDataList[i + 1]!.commentPoint)) {
            count++;
          }
        }
        break;
      case "likePoint":
        copiedUserDataList
            .sort((a, b) => b!.likePoint!.compareTo(a!.likePoint!));

        for (int i = 0; i < copiedUserDataList.length; i++) {
          UserModel indexUpdateUser = copiedUserDataList[i]!.copyWith(
            index: count,
          );
          list.add(indexUpdateUser);

          if ((i != copiedUserDataList.length - 1) &&
              (copiedUserDataList[i]!.likePoint !=
                  copiedUserDataList[i + 1]!.likePoint)) {
            count++;
          }
        }
        break;
      // case "invitationPoint":
      //   copiedUserDataList
      //       .sort((a, b) => b!.invitationPoint!.compareTo(a!.invitationPoint!));

      //   for (int i = 0; i < copiedUserDataList.length - 1; i++) {
      //     UserModel indexUpdateUser = copiedUserDataList[i]!.copyWith(
      //       index: count,
      //     );
      //     list.add(indexUpdateUser);

      //     if (copiedUserDataList[i]!.invitationPoint !=
      //         copiedUserDataList[i + 1]!.invitationPoint) {
      //       count++;
      //     }
      //   }
      //   break;
    }
    setState(() {
      _sortOder = value;
      _userDataList = list;
    });
  }

  void _updateUserlistPerPage() {
    int startPage = _currentPage * _itemsPerPage;
    int endPage = startPage + 20 > _initialPointList.length
        ? _initialPointList.length
        : startPage + 20;

    setState(() {
      _userDataList = _initialPointList.sublist(startPage, endPage);
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
  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      menu: menuList[2],
      child: Column(
        children: [
          SearchCsv(
            filterUserList: _filterUserDataList,
            resetInitialList: () => _getScoreList(_selectedDateRange),
            generateCsv: generateExcel,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _showPeriodCalender,
                  child: PeriodButton(
                    startDate: _selectedDateRange!.start,
                    endDate: _selectedDateRange!.end,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    "점수 계산 방법",
                    style: TextStyle(
                      fontSize: Sizes.size12,
                      color: Palette().normalGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Gaps.v5,
                  SelectableText(
                    "걸음수: 1,000보당 10점 (하루 최대 7천보)",
                    style: TextStyle(
                      fontSize: Sizes.size11,
                      color: Palette().normalGray,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Gaps.v5,
                  SelectableText(
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
          Gaps.v32,
          !_loadingFinished
              ? const SkeletonLoadingScreen()
              : Column(
                  children: [
                    Column(
                      children: [
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
                                        "출생연도",
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
                                          width: 1,
                                          color: const Color(0xFFF3F6FD),
                                        )),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "종합",
                                          style: contentTextStyle,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                        Gaps.h5,
                                        MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            onTap: () => updateOrderStandard(
                                                "totalPoint"),
                                            child: ColorFiltered(
                                              colorFilter: ColorFilter.mode(
                                                  InjicareColor().gray70,
                                                  BlendMode.srcIn),
                                              child: SvgPicture.asset(
                                                _sortOder == "totalPoint"
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
                                    height: 50,
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFE9EDF9),
                                        border: Border.all(
                                          width: 2,
                                          color: const Color(0xFFF3F6FD),
                                        )),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "걸음수",
                                          style: contentTextStyle,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                        Gaps.h5,
                                        MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            onTap: () => updateOrderStandard(
                                                "stepPoint"),
                                            child: ColorFiltered(
                                              colorFilter: ColorFilter.mode(
                                                  InjicareColor().gray70,
                                                  BlendMode.srcIn),
                                              child: SvgPicture.asset(
                                                _sortOder == "stepPoint"
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
                                    height: 50,
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFE9EDF9),
                                        border: Border.all(
                                          width: 1,
                                          color: const Color(0xFFF3F6FD),
                                        )),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "일기",
                                          style: contentTextStyle,
                                          textAlign: TextAlign.center,
                                        ),
                                        Gaps.h5,
                                        MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            onTap: () => updateOrderStandard(
                                                "diaryPoint"),
                                            child: ColorFiltered(
                                              colorFilter: ColorFilter.mode(
                                                  InjicareColor().gray70,
                                                  BlendMode.srcIn),
                                              child: SvgPicture.asset(
                                                _sortOder == "diaryPoint"
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
                                    height: 50,
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFE9EDF9),
                                        border: Border.all(
                                          width: 1,
                                          color: const Color(0xFFF3F6FD),
                                        )),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "댓글",
                                          style: contentTextStyle,
                                          textAlign: TextAlign.center,
                                        ),
                                        Gaps.h5,
                                        MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            onTap: () => updateOrderStandard(
                                                "commentPoint"),
                                            child: ColorFiltered(
                                              colorFilter: ColorFilter.mode(
                                                  InjicareColor().gray70,
                                                  BlendMode.srcIn),
                                              child: SvgPicture.asset(
                                                _sortOder == "commentPoint"
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
                                    height: 50,
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFE9EDF9),
                                        border: Border.all(
                                          width: 1,
                                          color: const Color(0xFFF3F6FD),
                                        )),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "좋아요",
                                          style: contentTextStyle,
                                          textAlign: TextAlign.center,
                                        ),
                                        Gaps.h5,
                                        MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            onTap: () => updateOrderStandard(
                                                "likePoint"),
                                            child: ColorFiltered(
                                              colorFilter: ColorFilter.mode(
                                                  InjicareColor().gray70,
                                                  BlendMode.srcIn),
                                              child: SvgPicture.asset(
                                                _sortOder == "likePoint"
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
                                        "활동\n자세히 보기",
                                        style: contentTextStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                                            "${_userDataList[i]!.index ?? 0}",
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
                                          flex: 2,
                                          child: SelectableText(
                                            "${_userDataList[i]!.birthYear}년",
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
                                            "${numberFormat(_userDataList[i]!.totalPoint ?? 0)}점",
                                            style: contentTextStyle,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: SelectableText(
                                            "${numberFormat(_userDataList[i]!.stepPoint ?? 0)}점",
                                            style: contentTextStyle,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: SelectableText(
                                            "${numberFormat(_userDataList[i]!.diaryPoint ?? 0)}점",
                                            style: contentTextStyle,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: SelectableText(
                                            "${numberFormat(_userDataList[i]!.commentPoint ?? 0)}점",
                                            style: contentTextStyle,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: SelectableText(
                                            "${numberFormat(_userDataList[i]!.likePoint ?? 0)}점",
                                            style: contentTextStyle,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: () =>
                                                  goUserRankingDashboard(
                                                userId:
                                                    _userDataList[i]!.userId,
                                                userName:
                                                    _userDataList[i]!.name,
                                                dateRange: _selectedDateRange ??
                                                    DateRange(
                                                      getThisWeekMonday(),
                                                      DateTime.now(),
                                                    ),
                                              ),
                                              child: Center(
                                                child: FaIcon(
                                                  FontAwesomeIcons.arrowRight,
                                                  size: 14,
                                                  color: InjicareColor()
                                                      .secondary50,
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
                )

          //  DataTable2(
          //     scrollController: _scrollController,
          //     isVerticalScrollBarVisible: false,
          //     smRatio: 0.8,
          //     lmRatio: 1.2,
          //     dividerThickness: 0.1,
          //     sortColumnIndex: _sortColumnIndex,
          //     sortArrowIcon: Icons.arrow_downward_rounded,
          //     horizontalMargin: 0,
          //     headingRowDecoration: BoxDecoration(
          //       border: Border(
          //         bottom: BorderSide(
          //           color: Palette().lightGray,
          //           width: 0.1,
          //         ),
          //       ),
          //     ),
          //     columns: [
          //       DataColumn2(
          //         fixedWidth: 50,
          //         label: SelectableText(
          //           "#",
          //           style: _headerTextStyle,
          //         ),
          //       ),
          //       DataColumn2(
          //         // size: ColumnSize.L,
          //         label: SelectableText(
          //           "이름",
          //           style: _headerTextStyle,
          //         ),
          //       ),
          //       DataColumn2(
          //         size: ColumnSize.S,
          //         label: SelectableText(
          //           "출생연도",
          //           style: _headerTextStyle,
          //         ),
          //       ),
          //       DataColumn2(
          //         // size: ColumnSize.L,
          //         label: SelectableText(
          //           "핸드폰 번호",
          //           style: _headerTextStyle,
          //         ),
          //       ),
          //       DataColumn2(
          //         size: ColumnSize.S,
          //         tooltip: "클릭하면 '종합 점수'를 기준으로 정렬됩니다.",
          //         onSort: (columnIndex, sortAscending) {
          //           updateOrderStandard("totalPoint", columnIndex);
          //         },
          //         label: SelectableText(
          //           "종합",
          //           style: _headerTextStyle,
          //         ),
          //       ),
          //       DataColumn2(
          //         size: ColumnSize.S,
          //         tooltip: "클릭하면 '걸음수'를 기준으로 정렬됩니다.",
          //         onSort: (columnIndex, sortAscending) {
          //           updateOrderStandard("stepPoint", columnIndex);
          //         },
          //         label: SelectableText(
          //           "걸음수",
          //           style: _headerTextStyle,
          //         ),
          //       ),
          //       DataColumn2(
          //         size: ColumnSize.S,
          //         tooltip: "클릭하면 '일기'를 기준으로 정렬됩니다",
          //         onSort: (columnIndex, sortAscending) {
          //           updateOrderStandard("diaryPoint", columnIndex);
          //         },
          //         label: SelectableText(
          //           "일기",
          //           style: _headerTextStyle,
          //         ),
          //       ),
          //       DataColumn2(
          //         size: ColumnSize.S,
          //         tooltip: "클릭하면 '댓글'을 기준으로 정렬됩니다",
          //         onSort: (columnIndex, sortAscending) {
          //           updateOrderStandard("commentPoint", columnIndex);
          //         },
          //         label: SelectableText(
          //           "댓글",
          //           style: _headerTextStyle,
          //         ),
          //       ),
          //       DataColumn2(
          //         size: ColumnSize.S,
          //         tooltip: "클릭하면 '좋아요'를 기준으로 정렬됩니다",
          //         onSort: (columnIndex, sortAscending) {
          //           updateOrderStandard("likePoint", columnIndex);
          //         },
          //         label: SelectableText(
          //           "좋아요",
          //           style: _headerTextStyle,
          //         ),
          //       ),
          //       // DataColumn2(
          //       //   size: ColumnSize.S,
          //       //   tooltip: "클릭하면 '친구초대'를 기준으로 정렬됩니다",
          //       //   onSort: (columnIndex, sortAscending) {
          //       //     updateOrderStandard(
          //       //         "invitationPoint", columnIndex);
          //       //   },
          //       //   label: SelectableText(
          //       //     "친구초대",
          //       //     style: _headerTextStyle,
          //       //   ),
          //       // ),
          //       DataColumn2(
          //         fixedWidth: 100,
          //         onSort: (columnIndex, sortAscending) {
          //           setState(() {
          //             _sortColumnIndex = columnIndex;
          //           });
          //         },
          //         label: SelectableText(
          //           "활동\n자세히 보기",
          //           style: _headerTextStyle,
          //           textAlign: TextAlign.end,
          //         ),
          //       ),
          //     ],
          //     rows: [
          //       if (_userDataList.isNotEmpty)
          //         for (var i = 0; i < _rowCount; i++)
          //           DataRow2(
          //             cells: [
          //               DataCell(
          //                 SelectableText(
          //                   (i + 1).toString(),
          //                   style: _contentTextStyle,
          //                 ),
          //               ),
          //               DataCell(
          //                 SelectableText(
          //                   _userDataList[i]!.name.length > 10
          //                       ? "${_userDataList[i]!.name.substring(0, 10)}.."
          //                       : _userDataList[i]!.name,
          //                   style: _contentTextStyle,
          //                 ),
          //               ),
          //               DataCell(
          //                 SelectableText(
          //                   _userDataList[i]!.birthYear,
          //                   style: _contentTextStyle,
          //                 ),
          //               ),
          //               DataCell(
          //                 SelectableText(
          //                   _userDataList[i]!.phone,
          //                   style: _contentTextStyle,
          //                 ),
          //               ),
          //               DataCell(
          //                 SelectableText(
          //                   "${_userDataList[i]!.totalPoint}",
          //                   style: _contentTextStyle,
          //                 ),
          //               ),
          //               DataCell(
          //                 SelectableText(
          //                   "${_userDataList[i]!.stepPoint}",
          //                   style: _contentTextStyle,
          //                 ),
          //               ),
          //               DataCell(
          //                 SelectableText(
          //                   "${_userDataList[i]!.diaryPoint}",
          //                   style: _contentTextStyle,
          //                 ),
          //               ),
          //               DataCell(
          //                 SelectableText(
          //                   "${_userDataList[i]!.commentPoint}",
          //                   style: _contentTextStyle,
          //                 ),
          //               ),
          //               DataCell(
          //                 SelectableText(
          //                   "${_userDataList[i]!.likePoint}",
          //                   style: _contentTextStyle,
          //                 ),
          //               ),
          //               // DataCell(
          //               //   SelectableText(
          //               //     "${_userDataList[i]!.invitationPoint}",
          //               //     style: _contentTextStyle,
          //               //   ),
          //               // ),
          //               DataCell(
          //                 Center(
          //                   child: MouseRegion(
          //                     cursor: SystemMouseCursors.click,
          //                     child: GestureDetector(
          //                       onTap: () => goUserRankingDashboard(
          //                         userId: _userDataList[i]!.userId,
          //                         userName: _userDataList[i]!.name,
          //                         dateRange: _selectedDateRange ??
          //                             DateRange(
          //                               getThisWeekMonday(),
          //                               DateTime.now(),
          //                             ),
          //                       ),
          //                       child: FaIcon(
          //                         FontAwesomeIcons.arrowRight,
          //                         color: Palette().darkGray,
          //                         size: 14,
          //                       ),
          //                     ),
          //                   ),
          //                 ),
          //               )
          //             ],
          //           ),
          //     ],
          //   ),
        ],
      ),
    );
  }
}

DateTime getThisWeekStartDate() {
  DateTime now = DateTime.now();
  int currentDayOfWeek = now.weekday;
  DateTime startOfWeek = now.subtract(Duration(days: currentDayOfWeek - 1));
  return startOfWeek;
}

DateTime getThisWeekEndDate() {
  DateTime now = DateTime.now();
  int currentDayOfWeek = now.weekday;
  DateTime startOfWeek = now.subtract(Duration(days: currentDayOfWeek - 1));
  DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
  return endOfWeek;
}

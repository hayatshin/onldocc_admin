import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:onldocc_admin/injicare_color.dart';
import 'package:onldocc_admin/injicare_font.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

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
    "#",
    "친구 초대 수",
    "이름",
    "나이",
    "성별",
    "핸드폰 번호",
  ];
  List<InvitationModel?> _userDataList = [];
  List<InvitationModel?> _initialList = [];

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
                        await getInvitationList(_selectedDateRange);
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
    Overlay.of(context, debugRequiredFor: widget).insert(overlayEntry!);
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

    if (selectContractRegion.value!.subdistrictId == "") {
      if (mounted) {
        setState(() {
          _loadingFinished = true;
          _userDataList = userList;
          _initialList = userList;
        });
      }
    } else {
      if (selectContractRegion.value!.contractCommunityId != "" &&
          selectContractRegion.value!.contractCommunityId != null) {
        final filterDataList = userList
            .where((e) =>
                e.userContractCommunityId ==
                selectContractRegion.value!.contractCommunityId)
            .toList();
        if (mounted) {
          setState(() {
            _loadingFinished = true;
            _userDataList = filterDataList;
            _initialList = userList;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _loadingFinished = true;
            _userDataList = userList;
            _initialList = userList;
          });
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
        copiedUserDataList.sort(
            (a, b) => b!.receiveUsers.length.compareTo(a!.receiveUsers.length));

        for (int i = 0; i < copiedUserDataList.length - 1; i++) {
          InvitationModel indexUpdateUser = copiedUserDataList[i]!.copyWith(
            index: count,
          );
          list.add(indexUpdateUser);

          if (copiedUserDataList[i]!.receiveUsers.length !=
              copiedUserDataList[i + 1]!.receiveUsers.length) {
            count++;
          }
        }

        break;
      case 2:
        copiedUserDataList.sort(
            (a, b) => b!.receiveUsers.length.compareTo(a!.receiveUsers.length));

        for (int i = 0; i < copiedUserDataList.length - 1; i++) {
          InvitationModel indexUpdateUser = copiedUserDataList[i]!.copyWith(
            index: count,
          );
          list.add(indexUpdateUser);

          if (copiedUserDataList[i]!.receiveUsers.length !=
              copiedUserDataList[i + 1]!.receiveUsers.length) {
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
    final startSeconds = convertStartDateTimeToSeconds(dateRange.start);
    final endSeconds = convertEndDateTimeToSeconds(dateRange.end);

    Map<String, String> extraJson = {
      "userId": userId,
      "userName": userName,
      // "dateRange": encodeDateRange(dateRange),
    };
    context.go("/invitation/$userId", extra: PathExtra.fromJson(extraJson));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return DefaultScreen(
      menu: menuList[11],
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
                          label: Text(
                            "#",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          tooltip: "친구 초대를 통해 인지케어에 가입한 수를 기준으로 정렬됩니다.",
                          onSort: (columnIndex, sortAscending) {
                            updateOrderStandard(columnIndex);
                          },
                          label: Text(
                            "친구 초대 수",
                            style: _headerTextStyle.copyWith(
                              color: InjicareColor().secondary50,
                            ),
                          ),
                        ),
                        DataColumn2(
                          label: Text(
                            "이름",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          label: Text(
                            "나이",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          label: Text(
                            "성별",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          label: Text(
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
                          label: Text(
                            "초대 친구\n목록 보기",
                            style: _headerTextStyle,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                      rows: [
                        for (var i = 0; i < _userDataList.length; i++)
                          DataRow2(
                            cells: [
                              DataCell(
                                Text(
                                  _userDataList[i]!.index.toString(),
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
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
                                Text(
                                  _userDataList[i]!.userName,
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  _userDataList[i]!.userAge,
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  _userDataList[i]!.userGender,
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
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

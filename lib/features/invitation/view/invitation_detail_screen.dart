import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/common/widgets/loading_widget.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/invitation/models/invitation_model.dart';
import 'package:onldocc_admin/features/invitation/view_models/invitation_view_model.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/features/users/view_models/user_view_model.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';

class InvitationDetailScreen extends ConsumerStatefulWidget {
  final String? userId;
  final String? userName;
  // final String? dateRange;

  const InvitationDetailScreen({
    super.key,
    required this.userId,
    required this.userName,
    // required this.dateRange,
  });

  @override
  ConsumerState<InvitationDetailScreen> createState() =>
      _InvitationDetailScreenState();
}

class _InvitationDetailScreenState
    extends ConsumerState<InvitationDetailScreen> {
  UserModel? _userModel;
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

  final List<String> _listHeader = [
    "#",
    "날짜",
    "내용",
  ];
  // DateRange _selectedDateRange = DateRange(
  //   getThisWeekMonday(),
  //   DateTime.now(),
  // );

  bool _loadingFinished = false;
  List<ReceiveUser> _list = [];

  final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();
  OverlayEntry? overlayEntry;

  @override
  void initState() {
    super.initState();

    // _selectedDateRange = widget.dateRange != null
    //     ? decodeDateRange(widget.dateRange!)
    //     : DateRange(
    //         getThisWeekMonday(),
    //         DateTime.now(),
    //       );

    _initializeUser();
    _initializeData();
  }

  @override
  void dispose() {
    _removePeriodCalender();
    super.dispose();
  }

  void _initializeUser() async {
    if (widget.userId == null) return;
    final userModel =
        await ref.read(userProvider.notifier).getUserModel(widget.userId!);
    if (!mounted) return;
    setState(() {
      _userModel = userModel;
    });
  }

  // 데이터 목록
  void _initializeData() async {
    if (widget.userId == null) return;
    final userList = await ref
        .read(invitationProvider.notifier)
        .fetchUserInvitation(widget.userId!);
    if (!mounted) return;
    setState(() {
      _list = userList;
      _loadingFinished = true;
    });
  }

  void _removePeriodCalender() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  // excel
  List<String> exportToList(RankingDataSet ranking) {
    return [
      ranking.index.toString(),
      ranking.content.toString(),
    ];
  }

  List<List<String>> exportToFullList() {
    List<List<String>> list = [];

    list.add(_listHeader);

    // for (var item in _rankings) {
    //   final itemList = exportToList(item);
    //   list.add(itemList);
    // }
    return list;
  }

  void generateExcel() {
    final csvData = exportToFullList();
    final String fileName =
        "인지케어 점수 활동보기: ${_userModel != null ? _userModel!.name : ""}s.xlsx";
    exportExcel(csvData, fileName);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return !_loadingFinished
        ? loadingWidget(context)
        : Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (context) => DefaultScreen(
                  menu: Menu(
                    index: 11,
                    name:
                        "${_userModel != null ? _userModel!.name : ""} 님의 친구 초대로 인지케어에 가입한 사람",
                    routeName: "invitation",
                    child: Container(),
                    backButton: true,
                    colorButton: const Color(0xff21DDAB),
                  ),
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // header
                        Expanded(
                          child: DataTable2(
                            smRatio: 0.4,
                            lmRatio: 3.0,
                            isVerticalScrollBarVisible: false,
                            dividerThickness: 0.1,
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
                                size: ColumnSize.S,
                                label: Text(
                                  "#",
                                  style: _headerTextStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              DataColumn2(
                                size: ColumnSize.M,
                                label: Text(
                                  "날짜",
                                  style: _headerTextStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              DataColumn2(
                                size: ColumnSize.M,
                                label: Text(
                                  "초대 받은 사람",
                                  style: _headerTextStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                            rows: [
                              for (int i = 0; i < _list.length; i++)
                                DataRow2(
                                  cells: [
                                    DataCell(
                                      Text(
                                        "${i + 1}",
                                        style: _contentTextStyle,
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        _list[i].receiveDate,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.start,
                                        style: _contentTextStyle.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        _list[i].receiveUserName,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.start,
                                        style: _contentTextStyle.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        Gaps.v40,
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
  }
}

class RankingDataSet {
  final int index;
  final int? createdAt;
  final String? stepDate;
  final String content;

  RankingDataSet({
    required this.index,
    this.createdAt,
    this.stepDate,
    required this.content,
  });
}

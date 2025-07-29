import 'package:data_table_2/data_table_2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/view/skeleton_loading_screen.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/constants/const.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/ca/models/cognition_test_model.dart';
import 'package:onldocc_admin/features/ca/models/self_test_model.dart';
import 'package:onldocc_admin/features/ca/view/self_test_screen.dart';
import 'package:onldocc_admin/features/ca/view_models/cognition_test_view_model.dart';
import 'package:onldocc_admin/features/user-dashboard/view/user_dashboard_screen.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/features/users/view_models/user_view_model.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';

class DashboardSelfTestScreen extends ConsumerStatefulWidget {
  final String? userId;
  final String? userName;
  final String? quizType;
  final DateRange? periodType;

  const DashboardSelfTestScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.quizType,
    required this.periodType,
  });

  @override
  ConsumerState<DashboardSelfTestScreen> createState() =>
      _DashboardSelfTestScreenState();
}

class _DashboardSelfTestScreenState
    extends ConsumerState<DashboardSelfTestScreen> {
  bool _loadingFinished = false;
  final mainColor = const Color(0xff696EFF);
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

  UserModel? _userModel;
  DateRange _selectedDateRange = DateRange(
    getThisWeekMonday(),
    DateTime.now(),
  );
  SelfTestModel _selectedTestModel = testTypes[0];
  final List<String> _tableHeader = [
    "시행 날짜",
    "분류",
    "점수",
    "이름",
    "성별",
    "연령",
    "핸드폰 번호",
    "자세히 보기"
  ];

  List<CognitionTestModel> _testList = [];

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _initializePeriod();
    _initializeTestType();
    _initializeTableList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initializeUser() async {
    if (widget.userId == null) return;
    final userModel =
        await ref.read(userProvider.notifier).getUserModel(widget.userId!);
    setState(() {
      _userModel = userModel;
    });
  }

  void _initializePeriod() {
    _selectedDateRange = widget.periodType ??
        DateRange(
          getThisMonth1stdayStartDatetime(),
          getThisMonthLastdayEndDatetime(),
        );
  }

  void _initializeTestType() async {
    if (widget.quizType == null) return;

    final testModel = testTypes
        .where((element) => element.testType == widget.quizType!)
        .toList()[0];
    setState(() {
      _selectedTestModel = testModel;
    });
  }

  Future<void> _initializeTableList() async {
    if (widget.userId == null) return;

    final pageList = await ref
        .read(cognitionTestProvider.notifier)
        .getUserCognitionTestData(
            _selectedTestModel.testType, widget.userId!, _selectedDateRange);

    if (mounted) {
      setState(() {
        _loadingFinished = true;
        _testList = pageList;
      });
    }
  }

  List<String> exportToList(CognitionTestModel testModel) {
    return [
      secondsToStringLine(testModel.createdAt),
      testModel.result.toString(),
      testModel.totalPoint.toString(),
      testModel.userName.toString(),
      testModel.userGender.toString(),
      testModel.userAge.toString(),
      testModel.userPhone.toString(),
    ];
  }

  List<List<String>> exportToFullList() {
    List<List<String>> list = [];

    final csvHeader = _tableHeader.sublist(0, _tableHeader.length - 1);
    list.add(csvHeader);

    for (var item in _testList) {
      final itemList = exportToList(item);
      list.add(itemList);
    }
    return list;
  }

  void generateExcel() {
    final csvData = exportToFullList();
    final String fileName =
        "${_selectedTestModel.testName} ${todayToStringDot()}.xlsx";
    exportExcel(csvData, fileName);
  }

  void _changeTestType(String? sTestName) {
    if (sTestName == null) return;
    final selectedTestModel =
        testTypes.where((element) => element.testName == sTestName).toList()[0];
    setState(() {
      _selectedTestModel = selectedTestModel;
    });

    _initializeTableList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return DefaultScreen(
      menu: Menu(
        index: 1,
        name: "회원별 자가 검사: ${_userModel?.name}",
        routeName: "self-test",
        child: Container(),
        backButton: true,
        colorButton: const Color(0xff696EFF),
      ),
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: mainColor,
                  ),
                ),
                Gaps.h10,
                SelectableText(
                  "자가 검사 종류:",
                  style: TextStyle(
                    color: mainColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Gaps.h20,
                SizedBox(
                  width: 400,
                  height: buttonHeight,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      items: testTypes.map((SelfTestModel item) {
                        return DropdownMenuItem<String>(
                          value: item.testName,
                          child: Text(
                            item.testName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Palette().darkGray,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      value: _selectedTestModel.testName,
                      onChanged: null,
                      buttonStyleData: ButtonStyleData(
                        padding: const EdgeInsets.only(left: 14, right: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          border: Border.all(
                            color: mainColor,
                            width: 1,
                          ),
                        ),
                      ),
                      iconStyleData: IconStyleData(
                        icon: const Icon(
                          Icons.expand_more_rounded,
                        ),
                        iconSize: 14,
                        iconEnabledColor: mainColor,
                        iconDisabledColor: mainColor,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        elevation: 2,
                        // width: size.width * 0.1,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        scrollbarTheme: ScrollbarThemeData(
                          radius: const Radius.circular(10),
                          thumbVisibility: WidgetStateProperty.all(true),
                        ),
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        height: 25,
                        padding: EdgeInsets.only(
                          left: 15,
                          right: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Gaps.v40,
            // SearchCsv(
            //   filterUserList: _filterUserDataList,
            //   resetInitialList: _initializeTableList,
            //   generateCsv: generateExcel,
            // ),
            !_loadingFinished
                ? const SkeletonLoadingScreen()
                : Expanded(
                    child: DataTable2(
                      isVerticalScrollBarVisible: false,
                      smRatio: 0.7,
                      lmRatio: 1.2,
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
                          fixedWidth: 140,
                          label: SelectableText(
                            "시행 날짜",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          fixedWidth: 200,
                          label: SelectableText(
                            "분류",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          fixedWidth: 80,
                          label: SelectableText(
                            "점수",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          label: SelectableText(
                            "이름",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          fixedWidth: 100,
                          label: SelectableText(
                            "성별",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          fixedWidth: 80,
                          label: SelectableText(
                            "연령",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          fixedWidth: 190,
                          label: SelectableText(
                            "핸드폰 번호",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          fixedWidth: 100,
                          label: SelectableText(
                            "자세히 보기",
                            style: _headerTextStyle,
                          ),
                        ),
                      ],
                      rows: [
                        for (int i = 0; i < _testList.length; i++)
                          DataRow2(
                            cells: [
                              DataCell(
                                SelectableText(
                                  secondsToStringLine(_testList[i].createdAt),
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                SelectableText(
                                  _testList[i].result,
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                SelectableText(
                                  _testList[i].totalPoint.toString(),
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                SelectableText(
                                  _testList[i].userName!,
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                SelectableText(
                                  _testList[i].userGender!,
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                SelectableText(
                                  _testList[i].userAge!.toString(),
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                SelectableText(
                                  _testList[i].userPhone!,
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                Center(
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () {
                                        context.push(
                                          "/users/${widget.userId}/self-test/${_testList[i].testId}",
                                          extra: _testList[i],
                                        );
                                      },
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
                  ),
          ],
        ),
      ),
    );
  }
}

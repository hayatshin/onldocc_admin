import 'package:data_table_2/data_table_2.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/view/search_csv.dart';
import 'package:onldocc_admin/common/view/skeleton_loading_screen.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/constants/const.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/ca/models/cognition_test_model.dart';
import 'package:onldocc_admin/features/ca/models/self_test_model.dart';
import 'package:onldocc_admin/features/ca/view_models/cognition_test_view_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';

final testTypes = [
  SelfTestModel(testName: "온라인 치매 검사", testType: "alzheimer_test"),
  SelfTestModel(testName: "우울척도 단축형 검사", testType: "depression_test"),
  SelfTestModel(testName: "스트레스 척도 검사", testType: "stress_test"),
  SelfTestModel(testName: "불안장애 척도 검사", testType: "anxiety_test"),
  SelfTestModel(testName: "외상 후 스트레스 검사", testType: "trauma_test"),
  SelfTestModel(testName: "자아존중감 검사", testType: "esteem_test"),
  SelfTestModel(testName: "수면(불면증) 검사", testType: "sleep_test"),
];

class SelfTestScreen extends ConsumerStatefulWidget {
  static const routeURL = "/self-test";
  static const routeName = "self-test";

  const SelfTestScreen({super.key});

  @override
  ConsumerState<SelfTestScreen> createState() => _SelfTestScreenState();
}

class _SelfTestScreenState extends ConsumerState<SelfTestScreen> {
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

  SelfTestModel _selectedTestModel =
      SelfTestModel(testName: "온라인 치매 검사", testType: "alzheimer_test");
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
  List<CognitionTestModel> _initialTestList = [];

  // page
  bool _reset = false;
  final _scrollController = ScrollController();
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    if (selectContractRegion.value != null) {
      _initializeTableList();
    }

    selectContractRegion.addListener(() async {
      if (mounted) {
        setState(() {
          _loadingFinished = true;
        });

        await _initializeTableList();
      }
    });
    _scrollController.addListener(_onDetectScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onDetectScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onDetectScroll() {
    if (_reset) return;
    if (_scrollController.position.atEdge) {
      bool isTop = _scrollController.position.pixels == 0;

      if (!isTop) {
        setState(() => _currentPage++);
        _initializeTableList();
      }
    }
  }

  Future<void> _initializeTableList() async {
    if (_reset) {
      _testList.clear();
      setState(() => _reset = false);
    }
    final pageList = await ref
        .read(cognitionTestProvider.notifier)
        .getCognitionTestData(_selectedTestModel.testType, _currentPage);

    if (selectContractRegion.value!.contractCommunityId != "" &&
        selectContractRegion.value!.contractCommunityId != null) {
      final filterDataList = pageList
          .where((e) =>
              e.userContractCommunityId ==
              selectContractRegion.value!.contractCommunityId)
          .toList();
      if (mounted) {
        setState(() {
          _loadingFinished = true;
          _testList.addAll(filterDataList);
          _initialTestList = filterDataList;
          _reset = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _loadingFinished = true;
          _testList.addAll(pageList);
          _initialTestList = _testList;
          _reset = false;
        });
      }
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

  Future<void> _filterUserDataList(
      String? searchBy, String searchKeyword) async {
    List<CognitionTestModel> filterList = [];
    if (searchBy == "이름") {
      filterList = _initialTestList
          .where((element) => element.userName!.contains(searchKeyword))
          .cast<CognitionTestModel>()
          .toList();
    } else {
      filterList = _initialTestList
          .where((element) => element.userPhone!.contains(searchKeyword))
          .cast<CognitionTestModel>()
          .toList();
    }

    setState(() {
      _reset = true;
      _testList = filterList;
    });
  }

  void _changeTestType(String? sTestName) {
    if (sTestName == null) return;
    final selectedTestModel =
        testTypes.where((element) => element.testName == sTestName).toList()[0];
    setState(() {
      _reset = true;
      _selectedTestModel = selectedTestModel;
    });

    _initializeTableList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return DefaultScreen(
      menu: menuList[6],
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
                      onChanged: (value) => _changeTestType(value),
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
            SearchCsv(
              filterUserList: _filterUserDataList,
              resetInitialList: _initializeTableList,
              generateCsv: generateExcel,
            ),
            !_loadingFinished
                ? const SkeletonLoadingScreen()
                : Expanded(
                    child: DataTable2(
                      scrollController: _scrollController,
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
                                        context.go(
                                          "/self-test/${_testList[i].testId}",
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

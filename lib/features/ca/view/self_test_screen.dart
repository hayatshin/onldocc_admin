import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/view/search_csv.dart';
import 'package:onldocc_admin/common/view/skeleton_loading_screen.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/constants/const.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/features/ca/models/cognition_test_model.dart';
import 'package:onldocc_admin/features/ca/models/self_test_model.dart';
import 'package:onldocc_admin/features/ca/view_models/cognition_test_view_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/users/view/users_screen.dart';
import 'package:onldocc_admin/injicare_color.dart';
import 'package:onldocc_admin/injicare_font.dart';
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
  List<CognitionTestModel> _initialList = [];

  static const int _itemsPerPage = 20;
  int _currentPage = 0;
  int _pageIndication = 0;
  int _totalListLength = 0;
  int _endPage = 0;

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
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initializeTableList() async {
    final pageList = await ref
        .read(cognitionTestProvider.notifier)
        .getCognitionTestData(_selectedTestModel.testType);

    if (selectContractRegion.value!.contractCommunityId != "" &&
        selectContractRegion.value!.contractCommunityId != null) {
      final filterList = pageList
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
      int endPage = pageList.length ~/ _itemsPerPage + 1;

      if (mounted) {
        setState(() {
          _loadingFinished = true;
          _totalListLength = pageList.length;
          _initialList = pageList;
          _endPage = endPage;
        });
        _updateUserlistPerPage();
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
      filterList = _initialList
          .where((element) => element.userName!.contains(searchKeyword))
          .cast<CognitionTestModel>()
          .toList();
    } else {
      filterList = _initialList
          .where((element) => element.userPhone!.contains(searchKeyword))
          .cast<CognitionTestModel>()
          .toList();
    }

    setState(() {
      _testList = filterList;
    });
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

  void _updateUserlistPerPage() {
    int startPage = _currentPage * _itemsPerPage;
    int endPage = startPage + _itemsPerPage > _initialList.length
        ? _initialList.length
        : startPage + _itemsPerPage;

    setState(() {
      _testList = _initialList.sublist(startPage, endPage);
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
    return DefaultScreen(
      menu: menuList[6],
      child: SingleChildScrollView(
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
                  "자가 검사 종류",
                  style: InjicareFont().body07.copyWith(color: mainColor),
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
                            style: InjicareFont().body07.copyWith(
                                  color: InjicareColor().gray80,
                                  fontWeight: FontWeight.w600,
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
                : Column(
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
                                  "검사 시행 날짜",
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
                                  "검사 결과 분류",
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
                                  "검사 결과 점수",
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
                                    width: 2,
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
                            flex: 1,
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
                                  "연령",
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
                                    width: 2,
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
                                  "자세히 보기",
                                  style: contentTextStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_testList.isNotEmpty)
                        for (int i = 0; i < 20; i++)
                          Column(
                            children: [
                              SizedBox(
                                height: 50,
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: SelectableText(
                                        "${_currentPage * _itemsPerPage + 1 + i}",
                                        style: contentTextStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: SelectableText(
                                        _testList[i].userName ?? "-",
                                        style: contentTextStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: SelectableText(
                                        "${_testList[i].userAge ?? 0}세",
                                        style: contentTextStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: SelectableText(
                                        _testList[i].userGender ?? "-",
                                        style: contentTextStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: SelectableText(
                                        _testList[i].userPhone ?? "-",
                                        style: contentTextStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: gestureDetectorWithMouseClick(
                                        function: () {
                                          context.push(
                                            "/self-test/${_testList[i].testId}",
                                            extra: _testList[i],
                                          );
                                        },
                                        child: ColorFiltered(
                                          colorFilter: ColorFilter.mode(
                                              InjicareColor().gray100,
                                              BlendMode.srcIn),
                                          child: SvgPicture.asset(
                                              "assets/svg/arrow-small-right.svg",
                                              width: 20),
                                        ),
                                      ),
                                    )
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
                              ),
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
            // !_loadingFinished
            //     ? const SkeletonLoadingScreen()
            //     : Expanded(
            //         child: DataTable2(
            //           scrollController: _scrollController,
            //           isVerticalScrollBarVisible: false,
            //           smRatio: 0.7,
            //           lmRatio: 1.2,
            //           dividerThickness: 0.1,
            //           horizontalMargin: 0,
            //           headingRowDecoration: BoxDecoration(
            //             border: Border(
            //               bottom: BorderSide(
            //                 color: Palette().lightGray,
            //                 width: 0.1,
            //               ),
            //             ),
            //           ),
            //           columns: [
            //             DataColumn2(
            //               fixedWidth: 140,
            //               label: SelectableText(
            //                 "시행 날짜",
            //                 style: _headerTextStyle,
            //               ),
            //             ),
            //             DataColumn2(
            //               fixedWidth: 200,
            //               label: SelectableText(
            //                 "분류",
            //                 style: _headerTextStyle,
            //               ),
            //             ),
            //             DataColumn2(
            //               fixedWidth: 80,
            //               label: SelectableText(
            //                 "점수",
            //                 style: _headerTextStyle,
            //               ),
            //             ),
            //             DataColumn2(
            //               label: SelectableText(
            //                 "이름",
            //                 style: _headerTextStyle,
            //               ),
            //             ),
            //             DataColumn2(
            //               fixedWidth: 100,
            //               label: SelectableText(
            //                 "성별",
            //                 style: _headerTextStyle,
            //               ),
            //             ),
            //             DataColumn2(
            //               fixedWidth: 80,
            //               label: SelectableText(
            //                 "연령",
            //                 style: _headerTextStyle,
            //               ),
            //             ),
            //             DataColumn2(
            //               fixedWidth: 190,
            //               label: SelectableText(
            //                 "핸드폰 번호",
            //                 style: _headerTextStyle,
            //               ),
            //             ),
            //             DataColumn2(
            //               fixedWidth: 100,
            //               label: SelectableText(
            //                 "자세히 보기",
            //                 style: _headerTextStyle,
            //               ),
            //             ),
            //           ],
            //           rows: [
            //             for (int i = 0; i < _testList.length; i++)
            //               DataRow2(
            //                 cells: [
            //                   DataCell(
            //                     SelectableText(
            //                       secondsToStringLine(_testList[i].createdAt),
            //                       style: _contentTextStyle,
            //                     ),
            //                   ),
            //                   DataCell(
            //                     SelectableText(
            //                       _testList[i].result,
            //                       style: _contentTextStyle,
            //                     ),
            //                   ),
            //                   DataCell(
            //                     SelectableText(
            //                       _testList[i].totalPoint.toString(),
            //                       style: _contentTextStyle,
            //                     ),
            //                   ),
            //                   DataCell(
            //                     SelectableText(
            //                       _testList[i].userName!,
            //                       style: _contentTextStyle,
            //                     ),
            //                   ),
            //                   DataCell(
            //                     SelectableText(
            //                       _testList[i].userGender!,
            //                       style: _contentTextStyle,
            //                     ),
            //                   ),
            //                   DataCell(
            //                     SelectableText(
            //                       _testList[i].userAge!.toString(),
            //                       style: _contentTextStyle,
            //                     ),
            //                   ),
            //                   DataCell(
            //                     SelectableText(
            //                       _testList[i].userPhone!,
            //                       style: _contentTextStyle,
            //                     ),
            //                   ),
            //                   DataCell(
            //                     Center(
            //                       child: MouseRegion(
            //                         cursor: SystemMouseCursors.click,
            //                         child: GestureDetector(
            //                           onTap: () {
            //                             context.go(
            //                               "/self-test/${_testList[i].testId}",
            //                               extra: _testList[i],
            //                             );
            //                           },
            //                           child: FaIcon(
            //                             FontAwesomeIcons.arrowRight,
            //                             color: Palette().darkGray,
            //                             size: 14,
            //                           ),
            //                         ),
            //                       ),
            //                     ),
            //                   )
            //                 ],
            //               )
            //           ],
            //         ),
            //       ),
          ],
        ),
      ),
    );
  }
}

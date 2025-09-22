import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/common/widgets/loading_widget.dart';
import 'package:onldocc_admin/common/widgets/report_button.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/ca/models/quiz_model.dart';
import 'package:onldocc_admin/features/ca/view_models/quiz_view_model.dart';
import 'package:onldocc_admin/features/dashboard/view/dashboard_screen.dart';
import 'package:onldocc_admin/features/user-dashboard/view/user_dashboard_screen.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/features/users/view_models/user_view_model.dart';
import 'package:onldocc_admin/injicare_color.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';

class DashboardCognitionQuizUserScreen extends ConsumerStatefulWidget {
  final String? userId;
  final String? userName;
  final String? quizType;
  final DateRange? periodType;

  const DashboardCognitionQuizUserScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.quizType,
    required this.periodType,
  });

  @override
  ConsumerState<DashboardCognitionQuizUserScreen> createState() =>
      _DashboardCognitionQuizUserScreenState();
}

class _DashboardCognitionQuizUserScreenState
    extends ConsumerState<DashboardCognitionQuizUserScreen> {
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
    "날짜",
    "문제",
    "정답",
    "제출 답",
    "정답 여부",
  ];
  DateRange _selectedDateRange = DateRange(
    getThisWeekMonday(),
    DateTime.now(),
  );

  bool _loadingFinished = false;
  final _quizTypes = [
    "수학 문제",
    "객관식 문제",
  ];
  String _selectedQuizType = "수학 문제";

  List<QuizModel> _quizzes = [];

  final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();
  OverlayEntry? overlayEntry;

  @override
  void initState() {
    super.initState();

    _selectedQuizType = widget.quizType ?? "수학 문제";

    _initializePeriod();
    _initializeUser();
    _initializeQuizData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initializeUser() async {
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

  // 데이터 목록
  void _initializeQuizData() async {
    final quizzes = _selectedQuizType == "수학 문제"
        ? await ref
            .read(caProvider.notifier)
            .getUserQuizMathData(widget.userId!, _selectedDateRange)
        : await ref
            .read(caProvider.notifier)
            .getUserQuizMultipleChoicesData(widget.userId!, _selectedDateRange);
    setState(() {
      _loadingFinished = true;
      _quizzes = quizzes;
    });
  }

  // excel
  List<String> exportToList(QuizModel quiz) {
    return [
      secondsToStringLine(quiz.createdAt),
      quiz.quiz,
      quiz.quizAnswer.toString(),
    ];
  }

  List<List<String>> exportToFullList() {
    List<List<String>> list = [];

    list.add(_listHeader);

    for (var item in _quizzes) {
      final itemList = exportToList(item);
      list.add(itemList);
    }
    return list;
  }

  void generateExcel() {
    final csvData = exportToFullList();
    final String fileName =
        "인지케어 문제 풀기 [$_selectedQuizType]: ${_userModel != null ? _userModel!.name : ""} ${todayToStringDot()}.xlsx";
    exportExcel(csvData, fileName);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    print('selected: $_selectedQuizType');
    print('items: $_quizTypes');
    return !_loadingFinished
        ? loadingWidget(context)
        : Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (context) => DefaultScreen(
                  menu: Menu(
                    index: 1,
                    name: "회원별 문제 풀기: ${_userModel!.name}",
                    routeName: "diary-quiz",
                    child: Container(),
                    backButton: true,
                    colorButton: const Color(0xffD5306C),
                  ),
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Gaps.v20,
                        Row(
                          children: [
                            SelectableText(
                              "문제 풀기 항목:",
                              style: TextStyle(
                                fontSize: Sizes.size14,
                                color: Palette().darkPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Gaps.h10,
                            PeriodDropdownMenu(
                              items: _quizTypes.map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Palette().normalGray,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              value: _selectedQuizType,
                              onChangedFunction: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedQuizType = value;
                                  });
                                  _initializePeriod();
                                  _initializeQuizData();
                                }
                              },
                            ),
                            // PeriodDropdownMenu(
                            //   items: _quizTypes.map((String item) {
                            //     return DropdownMenuItem<String>(
                            //       value: item,
                            //       child: Text(
                            //         item,
                            //         style: TextStyle(
                            //           fontSize: 12,
                            //           color: Palette().normalGray,
                            //         ),
                            //         overflow: TextOverflow.ellipsis,
                            //       ),
                            //     );
                            //   }).toList(),
                            //   value: _selectedQuizType,
                            // ),
                          ],
                        ),
                        Gaps.v16,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ReportButton(
                              iconExists: true,
                              buttonText: "리포트 출력하기",
                              buttonColor: Palette().darkPurple,
                              action: generateExcel,
                            )
                          ],
                        ),
                        Gaps.v40,
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
                                size: ColumnSize.M,
                                label: SelectableText(
                                  "날짜",
                                  style: _headerTextStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              DataColumn2(
                                size: ColumnSize.L,
                                label: SelectableText(
                                  "문제",
                                  style: _headerTextStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              DataColumn2(
                                size: ColumnSize.M,
                                label: SelectableText(
                                  "정답",
                                  style: _headerTextStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              DataColumn2(
                                size: ColumnSize.M,
                                label: SelectableText(
                                  "제출 답",
                                  style: _headerTextStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              DataColumn2(
                                size: ColumnSize.M,
                                label: SelectableText(
                                  "정답 여부",
                                  style: _headerTextStyle,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                            rows: [
                              for (int i = 0; i < _quizzes.length; i++)
                                DataRow2(
                                  cells: [
                                    DataCell(
                                      SelectableText(
                                        secondsToStringDateComment(
                                            _quizzes[i].createdAt),
                                        style: _contentTextStyle,
                                      ),
                                    ),
                                    DataCell(
                                      SelectableText(
                                        _quizzes[i].quiz,
                                        style: _contentTextStyle,
                                      ),
                                    ),
                                    DataCell(
                                      SelectableText(
                                        _quizzes[i].quizAnswer,
                                        maxLines: 2,
                                        // overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.start,
                                        style: _contentTextStyle.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      SelectableText(
                                        _quizzes[i].userAnswer,
                                        maxLines: 2,
                                        // overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.start,
                                        style: _contentTextStyle.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      SelectableText(
                                        _quizzes[i].quizAnswer ==
                                                _quizzes[i].userAnswer
                                            ? "정답"
                                            : "틀림",
                                        style: _contentTextStyle.copyWith(
                                          color: _quizzes[i].quizAnswer ==
                                                  _quizzes[i].userAnswer
                                              ? Palette().darkBlue
                                              : InjicareColor().primary50,
                                          fontWeight: _quizzes[i].quizAnswer ==
                                                  _quizzes[i].userAnswer
                                              ? FontWeight.w800
                                              : FontWeight.w500,
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

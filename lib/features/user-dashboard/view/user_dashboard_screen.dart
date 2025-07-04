import 'dart:async';
import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:onldocc_admin/common/view/skeleton_loading_screen.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/http.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/ca/view/self_test_screen.dart';
import 'package:onldocc_admin/features/dashboard/view/dashboard_screen.dart';
import 'package:onldocc_admin/features/user-dashboard/models/path/cognition_path_model.dart';
import 'package:onldocc_admin/features/user-dashboard/models/user_ai_chat_model.dart';
import 'package:onldocc_admin/features/user-dashboard/models/user_cognition_data_test_model.dart';
import 'package:onldocc_admin/features/user-dashboard/models/user_dashboard_count_model.dart';
import 'package:onldocc_admin/features/user-dashboard/models/user_dashboard_diary_model.dart';
import 'package:onldocc_admin/features/user-dashboard/models/user_dashboard_quiz_model.dart';
import 'package:onldocc_admin/features/user-dashboard/view_models/user_dashboard_view_model.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/features/users/view_models/user_view_model.dart';
import 'package:onldocc_admin/injicare_color.dart';
import 'package:onldocc_admin/injicare_font.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class UserDashboardScreen extends ConsumerStatefulWidget {
  final String? userId;
  final String? userName;
  const UserDashboardScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  ConsumerState<UserDashboardScreen> createState() =>
      _UserDashboardScreenState();
}

class _UserDashboardScreenState extends ConsumerState<UserDashboardScreen> {
  UserModel? _userModel;
  final _periodList = ["이번달", "지난달", "이번주", "지난주"];
  String _selectedPeriod = "이번달";
  DateTime _startDatetime = DateTime.now();
  DateTime _endDatetime = DateTime.now();
  GlobalKey diaryColumnKey = GlobalKey();
  double? diaryWidgetHeight = 300;
  GlobalKey aiColumnKey = GlobalKey();
  double? aiWidgetHeight = 300;

  bool _loadingAiDiagnosis = true;
  final _aiStreamControllder = StreamController<String>.broadcast();

  get data => null;

  // data
  List<UserDashboardDiaryModel> _diaryList = [];
  List<UserDashboardCountModel> _commentList = [];
  List<UserDashboardCountModel> _likeList = [];
  List<UserDashboardQuizModel> _quizMathList = [];
  List<UserDashboardQuizModel> _quizMultipleChoicesList = [];
  List<UserCognitionDataTestModel> _cognitionTestList = [];
  List<UserAiChatModel> _aiChatList = [];
  String _chatSumTime = "";
  String _chatAvgTime = "";

  List<ChartData> _stepDataList = [];

  String _selectedCognitionTestName = "온라인 치매 검사";

  @override
  void initState() {
    super.initState();

    _initializeUserDashboard();
  }

  void _initializeUserDashboard() async {
    if (!mounted) return;
    setState(() {
      _loadingAiDiagnosis = true;
    });
    await Future.wait([
      _initializeUser(),
      _updatePeriod(),
    ]);
    await _initializeDashboardData();
    await _getAIDiagnosisResult();
  }

  Future<void> _initializeUser() async {
    final userModel =
        await ref.read(userProvider.notifier).getUserModel(widget.userId!);
    if (!mounted) return;
    setState(() {
      _userModel = userModel;
    });
  }

  Future<void> _updatePeriod() async {
    switch (_selectedPeriod) {
      case "이번달":
        _startDatetime = getThisMonth1stdayStartDatetime();
        _endDatetime = getThisMonthLastdayEndDatetime();

        break;
      case "지난달":
        _startDatetime = getLastMonth1stdayStartDatetime();
        _endDatetime = getLastMonthLastdayEndDatetime();

        break;
      case "이번주":
        _startDatetime = getThisWeekMondayStartDatetime();
        _endDatetime = getThisWeekSundayEndtDatetime();

        break;
      case "지난주":
        _startDatetime = getLastWeekMondayStartDateTime();
        _endDatetime = getLastWeekSundayEndDateTime();

        break;
      default:
        _startDatetime = getThisMonth1stdayStartDatetime();
        _endDatetime = getThisMonthLastdayEndDatetime();

        break;
    }
  }

  Future<void> _initializeDashboardData() async {
    final selectedStartSeconds = convertDateTimeToSeconds(_startDatetime);
    final selectedEndSeconds = convertDateTimeToSeconds(_endDatetime);
    await Future.wait([
      _initializeDiaryDashboard(selectedStartSeconds, selectedEndSeconds),
      _initializeCognitionTestType(selectedStartSeconds, selectedEndSeconds),
      _initializeStepData(),
      _initializeAiChatTime(selectedStartSeconds, selectedEndSeconds),
    ]);
  }

  Future<void> _getAIDiagnosisResult() async {
    try {
      final sysPrompt =
          "You will be acting as a medical asssiant to help assess ${_userModel!.name}'s physical, mental and cognitive health including discrimination of dementia based on state of mind, diary content, math problems, multiple choice problems, steps, self-examination data. Please respond in Korean. You have to draw any conclusions regarding your health, and don't end with questions. Begin your response with the heading: ${_userModel?.name}님의 건강 진단";

      final mindAndDiaryData =
          _diaryList.map((element) => element.toString()).toList();
      final mathQuizData =
          _quizMathList.map((element) => element.toMathString()).toList();
      final multipleQuizData = _quizMultipleChoicesList
          .map((element) => element.toMultipleString())
          .toList();
      final stepData = _stepDataList
          .map((element) => "Step(date:${element.x}, step:${element.y})")
          .toList();
      final selfTestData =
          _cognitionTestList.map((element) => element.toString()).toList();
      final mindAndDiaryMessage =
          "*This is the data that shows the state of mind and diary content based on each date. Please at least summarize this data into one item from a mental health perspective:\n$mindAndDiaryData\n";
      final mathQuizMessage =
          "*This is the data that shows how much math problems have been solved by him/her based on each date. Please at least summarize this data into one item from a cognitive health perspective:\n$mathQuizData\n";
      final multiipleQuizMessage =
          "*This is the data that shows how much multiple-choices problems have been solved by him/her based on each date. Please at least summarize this data into one item from a cognitive health perspective:\n$multipleQuizData\n";
      final stepMessage =
          "This is the data that shows how much he/she has walked based on each date. Please at least summarize this data into one item from a physical health perspective:\n$stepData\n";
      final selfTestMessage =
          "This is the mental cognitive health self test examination data for each type of question. Please at least summarize this data into one item as self test examination:\n$selfTestData";

      Map<String, dynamic> requestBody = {
        'sysPrompt': sysPrompt,
        'userPrompt': mindAndDiaryMessage +
            mathQuizMessage +
            multiipleQuizMessage +
            stepMessage +
            selfTestMessage,
      };

      String requestBodyJson = jsonEncode(requestBody);

      final response = await http.post(
        Uri.parse(
            "https://diejlcrtffmlsdyvcagq.supabase.co/functions/v1/chatgpt-user-dashboard"),
        body: requestBodyJson,
        headers: headers,
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _loadingAiDiagnosis = false;
        });
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final content = data["choices"][0]["message"]["content"] as String;
        String aiDiagnosis = "";

        for (final char in content.characters) {
          if (!mounted) return;
          aiDiagnosis += char;
          _aiStreamControllder.add(aiDiagnosis);
          await Future.delayed(const Duration(milliseconds: 1));
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print("_getAIDiagnosisResult -> $e");
    }
  }

  // 일기 데이터
  Future<void> _initializeDiaryDashboard(
    int selectedStartSeconds,
    int selectedEndSeconds,
  ) async {
    if (widget.userId == null) return;
    final diaryList = await ref
        .read(userDashboardProvider.notifier)
        .userDiaryCount(
            selectedStartSeconds, selectedEndSeconds, widget.userId!);
    final commentList = await ref
        .read(userDashboardProvider.notifier)
        .userCommentCount(
            selectedStartSeconds, selectedEndSeconds, widget.userId!);
    final likeList = await ref
        .read(userDashboardProvider.notifier)
        .userLikeCount(
            selectedStartSeconds, selectedEndSeconds, widget.userId!);
    final quizMathList = await ref
        .read(userDashboardProvider.notifier)
        .userQuizMath(selectedStartSeconds, selectedEndSeconds, widget.userId!);
    final quizMultipleChoices = await ref
        .read(userDashboardProvider.notifier)
        .userQuizMultipleChoices(
            selectedStartSeconds, selectedEndSeconds, widget.userId!);

    setState(() {
      _diaryList = diaryList;
      _commentList = commentList;
      _likeList = likeList;
      _quizMathList = quizMathList;
      _quizMultipleChoicesList = quizMultipleChoices;
    });
  }

  // 인지 검사 데이터
  Future<void> _initializeCognitionTestType(
    int selectedStartSeconds,
    int selectedEndSeconds,
  ) async {
    if (widget.userId == null) return;
    final cognitionTesetList = await ref
        .read(userDashboardProvider.notifier)
        .userCognitionTest(
            selectedStartSeconds, selectedEndSeconds, widget.userId!);

    setState(() {
      _cognitionTestList = cognitionTesetList;
    });
  }

  Future<void> _initializeAiChatTime(
    int selectedStartSeconds,
    int selectedEndSeconds,
  ) async {
    if (widget.userId == null) return;
    final aiChatList = await ref
        .read(userDashboardProvider.notifier)
        .userAiChat(selectedStartSeconds, selectedEndSeconds, widget.userId!);

    int chatSumTime = 0;
    double chatAvgTime = 0;
    for (int i = 0; i < aiChatList.length; i++) {
      chatSumTime += aiChatList[i].chatTime;
    }
    chatAvgTime = aiChatList.isNotEmpty ? chatSumTime / aiChatList.length : 0;

    setState(() {
      _aiChatList = aiChatList;
      _chatSumTime = formatDuration(chatSumTime);
      _chatAvgTime = formatDuration(chatAvgTime.toInt());
    });
  }

  Future<void> _initializeStepData() async {
    if (widget.userId == null) return;

    final dateStrings = _generateDateStrings();
    final stepDataList = await ref
        .read(userDashboardProvider.notifier)
        .userSteps(dateStrings, widget.userId!);

    final stepCharList = stepDataList
        .map((element) => ChartData(element.date, element.step.toDouble()))
        .toList();

    stepCharList.sort((a, b) {
      final dateA = DateTime.parse(a.x);
      final dateB = DateTime.parse(b.x);
      return dateA.compareTo(dateB);
    });

    setState(() {
      _stepDataList = stepCharList;
    });
  }

  // AI
  String formatDuration(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    return "${hours != 0 ? "$hours시간 " : ""}${minutes != 0 ? "$minutes분 " : ""}${seconds != 0 ? "$seconds초" : "0초"}";
  }

  List<String> _generateDateStrings() {
    List<String> dateStrings = [];
    for (DateTime current = _startDatetime;
        current.isBefore(_endDatetime);
        current = current.add(const Duration(days: 1))) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(current);
      dateStrings.add(formattedDate);
    }
    return dateStrings;
  }

  void _goUserCognitionQuizDashBoard({
    required String userId,
    required String userName,
    required String quizType,
  }) {
    Map<String, String> extraJson = {
      "userId": userId,
      "userName": userName,
      "quizType": quizType,
      "periodType": _selectedPeriod,
    };
    context.push(
      "/users/$userId/diary-quiz",
      extra: DahsboardDetailPathModel.fromJson(extraJson),
    );
  }

  void _goUserSelfTestDashBoard({
    required String userId,
    required String userName,
    required String quizType,
  }) {
    Map<String, String> extraJson = {
      "userId": userId,
      "userName": userName,
      "quizType": quizType,
      "periodType": _selectedPeriod,
    };
    context.push(
      "/users/$userId/self-test",
      extra: DahsboardDetailPathModel.fromJson(extraJson),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      menu: Menu(
        index: 1,
        name: "회원별 데이터: ${_userModel?.name}",
        routeName: "user-dashboard",
        child: Container(),
        backButton: true,
        colorButton: Palette().darkBlue,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "기간 선택:",
                        style: TextStyle(
                          fontSize: Sizes.size14,
                          color: Palette().darkPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Gaps.h10,
                      PeriodDropdownMenu(
                        items: _periodList.map((String item) {
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
                        value: _selectedPeriod,
                        onChangedFunction: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedPeriod = value;
                            });
                            _initializeUserDashboard();
                          }
                        },
                      ),
                      // PeriodDropdownMenu(
                      //   items: _periodList.map((String item) {
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
                      //   value: _selectedPeriod,
                      // ),
                    ],
                  ),
                  Gaps.h12,
                  Column(
                    children: [
                      SelectableText(
                        "${datetimeToSlashString(_startDatetime)} ~ ${datetimeToSlashString(_endDatetime)}",
                        style: TextStyle(
                          color: Palette().darkBlue,
                          fontWeight: FontWeight.w300,
                          fontSize: Sizes.size12,
                        ),
                      ),
                      Gaps.v2,
                    ],
                  ),
                ],
              ),
            ],
          ),
          // AI 진단
          Gaps.v52,
          Row(
            children: [
              SelectableText(
                "AI의 진단",
                style: TextStyle(
                  fontSize: Sizes.size14,
                  fontWeight: FontWeight.w700,
                  color: InjicareColor().primary50,
                ),
              ),
            ],
          ),
          Gaps.v10,
          Row(
            children: [
              Text(
                "* AI의 진단은 ChatGPT가 ${_userModel?.name}님의 인지케어 활동 데이터를 바탕으로 진단한 내용이므로 참고용으로 사용해주시길 바랍니다. ",
                style: InjicareFont().label02.copyWith(
                      color: InjicareColor().gray70,
                      fontWeight: FontWeight.w300,
                    ),
              ),
            ],
          ),
          Gaps.v20,
          _loadingAiDiagnosis
              ? const SizedBox(
                  height: 150,
                  child: SkeletonLoadingScreen(),
                )
              : Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        StreamBuilder(
                            stream: _aiStreamControllder.stream,
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData) {
                                final aiDiagnosis = snapshot.data;
                                return Flexible(
                                  child: Text(
                                    aiDiagnosis,
                                    overflow: TextOverflow.visible,
                                    style: InjicareFont().label01.copyWith(
                                          color: InjicareColor().gray100,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                );
                              }
                              return Container();
                            }),
                      ],
                    ),
                    Gaps.v20,
                  ],
                ),
          // 일기 데이터
          const DashType(type: "일기 데이터"),
          Row(
            children: [
              Expanded(
                child: Column(
                  key: diaryColumnKey,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    WhiteBox(
                      boxTitle: "",
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SubHeaderBox(
                            subHeader: "일기 작성 횟수",
                            subHeaderColor: Palette().dashPink,
                            contentData: "${_diaryList.length} 회",
                          ),
                          const GrayDivider(
                            height: 60,
                          ),
                          SubHeaderBox(
                            subHeader: "댓글 횟수",
                            subHeaderColor: Palette().dashBlue,
                            contentData: "${_commentList.length} 회",
                          ),
                          const GrayDivider(
                            height: 60,
                          ),
                          SubHeaderBox(
                            subHeader: "좋아요 횟수",
                            subHeaderColor: Palette().darkBlue,
                            contentData: "${_likeList.length} 회",
                          ),
                        ],
                      ),
                    ),
                    Gaps.v16,
                    WhiteBox(
                      boxTitle: "마음 분포도",
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: 300,
                              height: 350,
                              child: SfCircularChart(
                                palette: const [
                                  Color(0xffD53736),
                                  Color(0xffE68E3C),
                                  Color(0xffE5CF50),
                                  Color(0xff4AA058),
                                  Color(0xff5D9DDD),
                                  Color(0xffC62D8C),
                                  Color(0xff633794),
                                  Color(0xff5D748D),
                                  Color(0xff663717),
                                  Color(0xff0F1113),
                                ],
                                series: <PieSeries<ChartData, String>>[
                                  PieSeries(
                                    explode: true,
                                    explodeIndex: 0,
                                    dataSource: [
                                      ChartData(
                                          "기뻐요",
                                          ((_diaryList
                                                      .where((element) =>
                                                          element
                                                              .diaryTodayMood ==
                                                          0)
                                                      .length
                                                      .toDouble()) /
                                                  _diaryList.length) *
                                              100),
                                      ChartData(
                                          "설레요",
                                          ((_diaryList
                                                      .where((element) =>
                                                          element
                                                              .diaryTodayMood ==
                                                          1)
                                                      .length
                                                      .toDouble()) /
                                                  _diaryList.length) *
                                              100),
                                      ChartData(
                                          "감사해요",
                                          ((_diaryList
                                                      .where((element) =>
                                                          element
                                                              .diaryTodayMood ==
                                                          2)
                                                      .length
                                                      .toDouble()) /
                                                  _diaryList.length) *
                                              100),
                                      ChartData(
                                          "평온해요",
                                          ((_diaryList
                                                      .where((element) =>
                                                          element
                                                              .diaryTodayMood ==
                                                          3)
                                                      .length
                                                      .toDouble()) /
                                                  _diaryList.length) *
                                              100),
                                      ChartData(
                                          "그냥 그래요",
                                          ((_diaryList
                                                      .where((element) =>
                                                          element
                                                              .diaryTodayMood ==
                                                          4)
                                                      .length
                                                      .toDouble()) /
                                                  _diaryList.length) *
                                              100),
                                      ChartData(
                                          "외로워요",
                                          ((_diaryList
                                                      .where((element) =>
                                                          element
                                                              .diaryTodayMood ==
                                                          5)
                                                      .length
                                                      .toDouble()) /
                                                  _diaryList.length) *
                                              100),
                                      ChartData(
                                          "불안해요",
                                          ((_diaryList
                                                      .where((element) =>
                                                          element
                                                              .diaryTodayMood ==
                                                          6)
                                                      .length
                                                      .toDouble()) /
                                                  _diaryList.length) *
                                              100),
                                      ChartData(
                                          "우울해요",
                                          ((_diaryList
                                                      .where((element) =>
                                                          element
                                                              .diaryTodayMood ==
                                                          7)
                                                      .length
                                                      .toDouble()) /
                                                  _diaryList.length) *
                                              100),
                                      ChartData(
                                          "슬퍼요",
                                          ((_diaryList
                                                      .where((element) =>
                                                          element
                                                              .diaryTodayMood ==
                                                          8)
                                                      .length
                                                      .toDouble()) /
                                                  _diaryList.length) *
                                              100),
                                      ChartData(
                                          "화나요",
                                          ((_diaryList
                                                      .where((element) =>
                                                          element
                                                              .diaryTodayMood ==
                                                          9)
                                                      .length
                                                      .toDouble()) /
                                                  _diaryList.length) *
                                              100),
                                    ],
                                    xValueMapper: (datum, index) => datum.x,
                                    yValueMapper: (datum, index) => datum.y,
                                    dataLabelMapper: (datum, index) {
                                      final percent = datum.y;
                                      return percent.isNaN
                                          ? ""
                                          : "${percent.round()}%";
                                    },
                                    dataLabelSettings: DataLabelSettings(
                                      textStyle: InjicareFont().label04,
                                      labelAlignment:
                                          ChartDataLabelAlignment.middle,
                                      labelPosition:
                                          ChartDataLabelPosition.inside,
                                      margin: EdgeInsets.zero,
                                      isVisible: true,
                                      showZeroValue: false,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 200),
                          Expanded(
                            child: DashboardTable(
                              tableTitle: "",
                              titleColor: Palette().dashYellow,
                              list: [
                                TableModel(
                                  tableHeader: "기뻐요",
                                  tableContent:
                                      "${_diaryList.where((element) => element.diaryTodayMood == 0).length} 회",
                                  headerColor: const Color(0xffD53736),
                                ),
                                TableModel(
                                  tableHeader: "설레요",
                                  tableContent:
                                      "${_diaryList.where((element) => element.diaryTodayMood == 1).length} 회",
                                  headerColor: const Color(0xffE68E3C),
                                ),
                                TableModel(
                                  tableHeader: "감사해요",
                                  tableContent:
                                      "${_diaryList.where((element) => element.diaryTodayMood == 2).length} 회",
                                  headerColor: const Color(0xffE5CF50),
                                ),
                                TableModel(
                                  tableHeader: "평온해요",
                                  tableContent:
                                      "${_diaryList.where((element) => element.diaryTodayMood == 3).length} 회",
                                  headerColor: const Color(0xff4AA058),
                                ),
                                TableModel(
                                  tableHeader: "그냥 그래요",
                                  tableContent:
                                      "${_diaryList.where((element) => element.diaryTodayMood == 4).length} 회",
                                  headerColor: const Color(0xff5D9DDD),
                                ),
                                TableModel(
                                  tableHeader: "외로워요",
                                  tableContent:
                                      "${_diaryList.where((element) => element.diaryTodayMood == 5).length} 회",
                                  headerColor: const Color(0xffC62D8C),
                                ),
                                TableModel(
                                  tableHeader: "불안해요",
                                  tableContent:
                                      "${_diaryList.where((element) => element.diaryTodayMood == 6).length} 회",
                                  headerColor: const Color(0xff633794),
                                ),
                                TableModel(
                                  tableHeader: "우울해요",
                                  tableContent:
                                      "${_diaryList.where((element) => element.diaryTodayMood == 7).length} 회",
                                  headerColor: const Color(0xff5D748D),
                                ),
                                TableModel(
                                  tableHeader: "슬퍼요",
                                  tableContent:
                                      "${_diaryList.where((element) => element.diaryTodayMood == 8).length} 회",
                                  headerColor: const Color(0xff663717),
                                ),
                                TableModel(
                                  tableHeader: "화나요",
                                  tableContent:
                                      "${_diaryList.where((element) => element.diaryTodayMood == 9).length} 회",
                                  headerColor: const Color(0xff0F1113),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Gaps.v16,
                    Row(
                      children: [
                        UserCognitionQuizTile(
                          title: "수학 문제",
                          totalCount: _quizMathList.length,
                          correctCount: _quizMathList
                              .where((element) =>
                                  element.isUserAnswerCorrect == true)
                              .toList()
                              .length,
                          wrongCount: _quizMathList
                              .where((element) =>
                                  element.isUserAnswerCorrect == false)
                              .toList()
                              .length,
                          navigationFunction: () =>
                              _goUserCognitionQuizDashBoard(
                            userId: _userModel!.userId,
                            userName: _userModel!.name,
                            quizType: "수학 문제",
                          ),
                        ),
                        Gaps.h20,
                        UserCognitionQuizTile(
                          title: "객관식 문제",
                          totalCount: _quizMultipleChoicesList.length,
                          correctCount: _quizMultipleChoicesList
                              .where((element) =>
                                  element.isUserAnswerCorrect == true)
                              .toList()
                              .length,
                          wrongCount: _quizMultipleChoicesList
                              .where((element) =>
                                  element.isUserAnswerCorrect == false)
                              .toList()
                              .length,
                          navigationFunction: () =>
                              _goUserCognitionQuizDashBoard(
                            userId: _userModel!.userId,
                            userName: _userModel!.name,
                            quizType: "객관식 문제",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // 인지 검사 데이터
          const DashType(type: "인지 검사 데이터"),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: WhiteBox(
                  boxTitle: "",
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SubHeaderBox(
                        subHeader: "전체",
                        subHeaderColor: Palette().dashPink,
                        contentData: "${_cognitionTestList.length} 회",
                      ),
                      const GrayDivider(height: 60),
                      SubHeaderBox(
                        subHeader: cognitionTestTypes[0].testName,
                        subHeaderColor: Colors.blue,
                        contentData:
                            "${_cognitionTestList.where((element) => element.testType == cognitionTestTypes[0].testId).toList().length}회",
                      ),
                      const GrayDivider(height: 60),
                      SubHeaderBox(
                        subHeader: cognitionTestTypes[1].testName,
                        subHeaderColor: Colors.orange,
                        contentData:
                            "${_cognitionTestList.where((element) => element.testType == cognitionTestTypes[1].testId).toList().length}회",
                      ),
                      const GrayDivider(height: 60),
                      SubHeaderBox(
                        subHeader: cognitionTestTypes[2].testName,
                        subHeaderColor: Colors.red,
                        contentData:
                            "${_cognitionTestList.where((element) => element.testType == cognitionTestTypes[2].testId).toList().length}회",
                      ),
                      const GrayDivider(height: 60),
                      SubHeaderBox(
                        subHeader: cognitionTestTypes[3].testName,
                        subHeaderColor: Colors.green,
                        contentData:
                            "${_cognitionTestList.where((element) => element.testType == cognitionTestTypes[3].testId).toList().length}회",
                      ),
                      const GrayDivider(height: 60),
                      SubHeaderBox(
                        subHeader: cognitionTestTypes[4].testName,
                        subHeaderColor: Colors.grey.shade700,
                        contentData:
                            "${_cognitionTestList.where((element) => element.testType == cognitionTestTypes[4].testId).toList().length}회",
                      ),
                      const GrayDivider(height: 60),
                      SubHeaderBox(
                        subHeader: cognitionTestTypes[5].testName,
                        subHeaderColor: Colors.teal,
                        contentData:
                            "${_cognitionTestList.where((element) => element.testType == cognitionTestTypes[5].testId).toList().length}회",
                      ),
                      const GrayDivider(height: 60),
                      SubHeaderBox(
                        subHeader: cognitionTestTypes[6].testName,
                        subHeaderColor: Colors.purple,
                        contentData:
                            "${_cognitionTestList.where((element) => element.testType == cognitionTestTypes[6].testId).toList().length}회",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Gaps.v32,
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 300,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    items: cognitionTestTypes.map((CognitionTestType item) {
                      return DropdownMenuItem<String>(
                        value: item.testName,
                        child: Text(
                          item.testName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Palette().normalGray,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    value: _selectedCognitionTestName,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCognitionTestName = value;
                        });
                      }
                    },
                    buttonStyleData: ButtonStyleData(
                      padding: const EdgeInsets.only(left: 14, right: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        border: Border.all(
                          color: Palette().darkBlue,
                          width: 0.5,
                        ),
                      ),
                    ),
                    iconStyleData: IconStyleData(
                      icon: const Icon(
                        Icons.expand_more_rounded,
                      ),
                      iconSize: 14,
                      iconEnabledColor: Palette().darkBlue,
                      iconDisabledColor: Palette().darkBlue,
                    ),
                    dropdownStyleData: DropdownStyleData(
                      elevation: 2,
                      width: 300,
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
              )
            ],
          ),
          Gaps.v20,
          Row(
            children: [
              if (_selectedCognitionTestName == cognitionTestTypes[0].testName)
                CognitionDetailTestBox(
                  detailTest: cognitionTestTypes[0].testName,
                  testResult1: "정상",
                  testResult1Data:
                      "${_cognitionTestList.where((element) => element.testType == "alzheimer_test" && element.result == "정상").toList().length}회",
                  testResult2: "치매 조기 검진 필요",
                  testResult2Data:
                      "${_cognitionTestList.where((element) => element.testType == "alzheimer_test" && element.result == "치매 조기검진 필요").toList().length}회",
                  navigation: () => _goUserSelfTestDashBoard(
                    userId: _userModel!.userId,
                    userName: _userModel!.name,
                    quizType: testTypes[0].testType,
                  ),
                ),
              if (_selectedCognitionTestName == cognitionTestTypes[1].testName)
                CognitionDetailTestBox(
                  detailTest: cognitionTestTypes[1].testName,
                  testResult1: "정상",
                  testResult1Data:
                      "${_cognitionTestList.where((element) => element.testType == cognitionTestTypes[1].testId && element.result == "정상").toList().length}회",
                  testResult2: "우울",
                  testResult2Data:
                      "${_cognitionTestList.where((element) => element.testType == cognitionTestTypes[1].testId && element.result == "우울").toList().length}회",
                  navigation: () => _goUserSelfTestDashBoard(
                    userId: _userModel!.userId,
                    userName: _userModel!.name,
                    quizType: testTypes[1].testType,
                  ),
                ),
              if (_selectedCognitionTestName == cognitionTestTypes[2].testName)
                CognitionDetailTestBox(
                  detailTest: cognitionTestTypes[2].testName,
                  testResult1: "정상",
                  testResult1Data:
                      "${_cognitionTestList.where((element) => element.testType == cognitionTestTypes[2].testId && element.result == "정상").toList().length}회",
                  testResult2: "스트레스 경험",
                  testResult2Data:
                      "${_cognitionTestList.where((element) => element.testType == cognitionTestTypes[2].testId && element.result == "스트레스 경험").toList().length}회",
                  navigation: () => _goUserSelfTestDashBoard(
                    userId: _userModel!.userId,
                    userName: _userModel!.name,
                    quizType: testTypes[2].testType,
                  ),
                ),
              if (_selectedCognitionTestName == cognitionTestTypes[3].testName)
                CognitionDetailTestBox(
                  detailTest: cognitionTestTypes[3].testName,
                  testResult1: "불안 아님",
                  testResult1Data:
                      "${_cognitionTestList.where((element) => element.testType == cognitionTestTypes[3].testId && element.result == "불안 아님").toList().length}회",
                  testResult2: "불안 시사됨",
                  testResult2Data:
                      "${_cognitionTestList.where((element) => element.testType == cognitionTestTypes[3].testId && element.result == "불안 시사됨").toList().length}회",
                  navigation: () => _goUserSelfTestDashBoard(
                    userId: _userModel!.userId,
                    userName: _userModel!.name,
                    quizType: testTypes[3].testType,
                  ),
                ),
              if (_selectedCognitionTestName == cognitionTestTypes[4].testName)
                CognitionDetailTestBox(
                  detailTest: cognitionTestTypes[4].testName,
                  testResult1: "정상",
                  testResult1Data:
                      "${_cognitionTestList.where((element) => element.testType == cognitionTestTypes[4].testId && element.result == "정상").toList().length}회",
                  testResult2: "주의 요망",
                  testResult2Data:
                      "${_cognitionTestList.where((element) => element.testType == cognitionTestTypes[4].testId && element.result == "주의 요망").toList().length}회",
                  testResult3: "심한 수준",
                  testResult3Data:
                      "${_cognitionTestList.where((element) => element.testType == cognitionTestTypes[4].testId && element.result == "심한 수준").toList().length}회",
                  navigation: () => _goUserSelfTestDashBoard(
                    userId: _userModel!.userId,
                    userName: _userModel!.name,
                    quizType: testTypes[4].testType,
                  ),
                ),
              if (_selectedCognitionTestName == cognitionTestTypes[5].testName)
                CognitionDetailTestBox(
                  detailTest: cognitionTestTypes[4].testName,
                  testResult1: "매우 높음",
                  testResult1Data:
                      "${_cognitionTestList.where((element) => element.testType == cognitionTestTypes[5].testId && element.result == "매우 높음").toList().length}회",
                  testResult2: "높음",
                  testResult2Data:
                      "${_cognitionTestList.where((element) => element.testType == cognitionTestTypes[5].testId && element.result == "높음").toList().length}회",
                  testResult3: "보통",
                  testResult3Data:
                      "${_cognitionTestList.where((element) => element.testType == cognitionTestTypes[5].testId && element.result == "보통").toList().length}회",
                  testResult4: "낮음",
                  testResult4Data:
                      "${_cognitionTestList.where((element) => element.testType == cognitionTestTypes[5].testId && element.result == "낮음").toList().length}회",
                  testResult5: "매우 낮음",
                  testResult5Data:
                      "${_cognitionTestList.where((element) => element.testType == cognitionTestTypes[5].testId && element.result == "매우 낮음").toList().length}회",
                  navigation: () => _goUserSelfTestDashBoard(
                    userId: _userModel!.userId,
                    userName: _userModel!.name,
                    quizType: testTypes[5].testType,
                  ),
                ),
              if (_selectedCognitionTestName == cognitionTestTypes[6].testName)
                CognitionDetailTestBox(
                  detailTest: cognitionTestTypes[6].testName,
                  testResult1: "불면증 아님",
                  testResult1Data:
                      "${_cognitionTestList.where((element) => element.testType == cognitionTestTypes[6].testId && element.result == "불면증 아님").toList().length}회",
                  testResult2: "경미한 수준",
                  testResult2Data:
                      "${_cognitionTestList.where((element) => element.testType == cognitionTestTypes[6].testId && element.result == "경미한 수준").toList().length}회",
                  testResult3: "중한 수준",
                  testResult3Data:
                      "${_cognitionTestList.where((element) => element.testType == cognitionTestTypes[6].testId && element.result == "중한 수준").toList().length}회",
                  testResult4: "심각한 수준",
                  testResult4Data:
                      "${_cognitionTestList.where((element) => element.testType == cognitionTestTypes[6].testId && element.result == "심각한 수준").toList().length}회",
                  navigation: () => _goUserSelfTestDashBoard(
                    userId: _userModel!.userId,
                    userName: _userModel!.name,
                    quizType: testTypes[6].testType,
                  ),
                ),
            ],
          ),
          const DashType(type: "AI 대화하기 데이터"),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: WhiteBox(
                  key: aiColumnKey,
                  boxTitle: "",
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SubHeaderBox(
                              subHeader: "총 대화 횟수",
                              subHeaderColor: Palette().dashPink,
                              contentData: "${_aiChatList.length} 회",
                            ),
                            Gaps.v20,
                            SubHeaderBox(
                              subHeader: "총 대화 시간",
                              subHeaderColor: Palette().dashBlue,
                              contentData: _chatSumTime,
                            ),
                            Gaps.v20,
                            SubHeaderBox(
                              subHeader: "평균 대화 시간",
                              subHeaderColor: Palette().darkBlue,
                              contentData: _chatAvgTime,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // 걸음수 데이터
          const DashType(type: "걸음수 데이터"),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SelectableText(
                              "기간 평균 걸음수",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: Sizes.size13,
                                  color: Palette().darkPurple),
                            ),
                            SelectableText(
                              "${_getAvgStepDouble(_stepDataList)} 보",
                              style: TextStyle(
                                fontSize: Sizes.size16,
                                fontWeight: FontWeight.w800,
                                color: Palette().darkGray,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Gaps.h20,
                  Expanded(
                    flex: 2,
                    child: Container(),
                  )
                ],
              ),
              Gaps.v20,
              SfCartesianChart(
                primaryXAxis: const CategoryAxis(),
                series: <CartesianSeries>[
                  SplineSeries<ChartData, String>(
                    dataSource: _stepDataList,
                    xValueMapper: (ChartData datum, index) =>
                        "${(datum.x).split('-')[1]}/${(datum.x).split('-')[2]}",
                    yValueMapper: (ChartData datum, index) => datum.y,
                    pointColorMapper: (datum, index) => Palette().darkPurple,
                  ),
                ],
              )
            ],
          ),
          Gaps.v40,
        ],
      ),
    );
  }
}

class UserCognitionQuizTile extends StatelessWidget {
  final String title;
  final int totalCount;
  final int correctCount;
  final int wrongCount;
  final Function() navigationFunction;
  const UserCognitionQuizTile({
    super.key,
    required this.title,
    required this.totalCount,
    required this.correctCount,
    required this.wrongCount,
    required this.navigationFunction,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: WhiteBox(
        boxTitle: "문제 풀기 [$title]",
        child: Padding(
          padding: const EdgeInsets.only(right: 30),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  right: 50,
                  left: 30,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 수학
                    Expanded(
                      flex: 3,
                      child: SelectableText(
                        "$totalCount 회",
                        style: TextStyle(
                          fontSize: Sizes.size16,
                          fontWeight: FontWeight.w800,
                          color: Palette().darkGray,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              SelectableText(
                                "맞음",
                                style: TextStyle(
                                  color: Palette().normalGray,
                                  fontSize: Sizes.size12,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Gaps.v10,
                              SelectableText(
                                "$correctCount 회",
                                style: TextStyle(
                                  color: Palette().darkGray,
                                  fontSize: Sizes.size16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const GrayDivider(
                            height: 60,
                          ),
                          Column(
                            children: [
                              SelectableText(
                                "틀림",
                                style: TextStyle(
                                  color: Palette().normalGray,
                                  fontSize: Sizes.size12,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Gaps.v10,
                              SelectableText(
                                "$wrongCount 회",
                                style: TextStyle(
                                  color: Palette().darkGray,
                                  fontSize: Sizes.size16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              UserDataDetailNavigation(
                text: "틀린 문제 자세히 보기",
                navigation: navigationFunction,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class WhiteBox extends StatelessWidget {
  final String boxTitle;
  final Widget child;
  const WhiteBox({
    super.key,
    required this.boxTitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 25,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (boxTitle != "")
              Column(
                children: [
                  SelectableText(
                    boxTitle,
                    style: TextStyle(
                      color: Palette().darkPurple,
                      fontWeight: FontWeight.w700,
                      fontSize: Sizes.size14,
                    ),
                  ),
                  Gaps.v20,
                ],
              ),
            child,
          ],
        ),
      ),
    );
  }
}

class CognitionDetailTestBox extends StatelessWidget {
  final String detailTest;
  final String testResult1;
  final String testResult1Data;
  final String testResult2;
  final String testResult2Data;
  final String? testResult3;
  final String? testResult3Data;
  final String? testResult4;
  final String? testResult4Data;
  final String? testResult5;
  final String? testResult5Data;
  final Function() navigation;
  const CognitionDetailTestBox({
    super.key,
    required this.detailTest,
    required this.testResult1,
    required this.testResult1Data,
    required this.testResult2,
    required this.testResult2Data,
    this.testResult3,
    this.testResult3Data,
    this.testResult4,
    this.testResult4Data,
    this.testResult5,
    this.testResult5Data,
    required this.navigation,
  });

  @override
  Widget build(BuildContext context) {
    return CognitionWhiteBox(
      boxTitle: detailTest,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 30,
              right: 30,
              bottom: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Row(
                      children: [
                        CognitionTestResultTile(
                          testResult: testResult1,
                          testResultData: testResult1Data,
                          first: true,
                        ),
                        CognitionTestResultTile(
                          testResult: testResult2,
                          testResultData: testResult2Data,
                        ),
                        if (testResult3 != null)
                          CognitionTestResultTile(
                            testResult: testResult3!,
                            testResultData: testResult3Data!,
                          ),
                        if (testResult4 != null)
                          CognitionTestResultTile(
                            testResult: testResult4!,
                            testResultData: testResult4Data!,
                          ),
                        if (testResult5 != null)
                          CognitionTestResultTile(
                            testResult: testResult5!,
                            testResultData: testResult5Data!,
                          ),
                      ],
                    ),
                  ],
                ),
                UserDataDetailNavigation(
                  text: "검사 항목 자세히 보기",
                  navigation: navigation,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UserDataDetailNavigation extends StatelessWidget {
  final Function() navigation;
  final String text;
  const UserDataDetailNavigation({
    super.key,
    required this.navigation,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Gaps.v32,
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: navigation,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  text,
                  style: InjicareFont().body06.copyWith(
                        color: Palette().darkBlue,
                      ),
                ),
                Gaps.h10,
                FaIcon(
                  FontAwesomeIcons.arrowRightLong,
                  color: Palette().darkBlue,
                  size: 20,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CognitionTestResultTile extends StatelessWidget {
  const CognitionTestResultTile({
    super.key,
    required this.testResult,
    required this.testResultData,
    this.first = false,
  });

  final bool first;
  final String testResult;
  final String testResultData;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!first)
            const GrayDivider(
              height: 60,
            ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                  ),
                  child: Column(
                    children: [
                      SelectableText(
                        testResult,
                        style: TextStyle(
                          color: Palette().normalGray,
                          fontSize: Sizes.size12,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Gaps.v10,
                      SelectableText(
                        testResultData,
                        style: TextStyle(
                          color: Palette().darkGray,
                          fontSize: Sizes.size16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CognitionWhiteBox extends StatelessWidget {
  final String boxTitle;
  final Widget child;
  const CognitionWhiteBox({
    super.key,
    required this.boxTitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 25,
            ),
            child: Column(
              children: [
                SelectableText(
                  boxTitle,
                  style: TextStyle(
                    color: Palette().darkPurple,
                    fontWeight: FontWeight.w700,
                    fontSize: Sizes.size14,
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class DashType extends StatelessWidget {
  final String type;
  const DashType({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Gaps.v52,
        Row(
          children: [
            SelectableText(
              type,
              style: TextStyle(
                fontSize: Sizes.size14,
                fontWeight: FontWeight.w700,
                color: Palette().darkGray,
              ),
            ),
          ],
        ),
        Gaps.v32,
      ],
    );
  }
}

class HeaderBox extends StatelessWidget {
  final String headerText;
  final Color headerColor;
  final String contentData;

  const HeaderBox({
    super.key,
    required this.headerText,
    required this.headerColor,
    required this.contentData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: SelectableText(
            headerText,
            style: TextStyle(
              color: headerColor,
              fontSize: Sizes.size12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Gaps.v10,
        SelectableText(
          contentData,
          style: const TextStyle(
            fontSize: Sizes.size20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class SubHeaderBox extends StatelessWidget {
  final String subHeader;
  final Color subHeaderColor;
  final String contentData;
  const SubHeaderBox({
    super.key,
    required this.subHeader,
    required this.subHeaderColor,
    required this.contentData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: SelectableText(
            subHeader,
            style: TextStyle(
              color: subHeaderColor,
              fontSize: Sizes.size12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Gaps.v20,
        Align(
          alignment: Alignment.centerRight,
          child: SelectableText(
            contentData,
            style: TextStyle(
                fontSize: Sizes.size16,
                fontWeight: FontWeight.w800,
                color: Palette().darkGray),
          ),
        ),
      ],
    );
  }
}

class GrayDivider extends StatelessWidget {
  final double height;
  const GrayDivider({
    super.key,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.5,
      height: height,
      decoration: BoxDecoration(
        color: Palette().lightGray,
      ),
    );
  }
}

// class PeriodDropdownMenu extends StatelessWidget {
//   final List<DropdownMenuItem<String>> items;
//   final String value;
//   const PeriodDropdownMenu({
//     super.key,
//     required this.items,
//     required this.value,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return SizedBox(
//       width: size.width * 0.1,
//       height: 35,
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton2<String>(
//           isExpanded: true,
//           items: items,
//           value: value,
//           onChanged: (value) {},
//           buttonStyleData: ButtonStyleData(
//             padding: const EdgeInsets.only(left: 14, right: 14),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(30),
//               color: Colors.white,
//               border: Border.all(
//                 color: Palette().lightGray,
//                 width: 0.5,
//               ),
//             ),
//           ),
//           iconStyleData: IconStyleData(
//             icon: const Icon(
//               Icons.expand_more_rounded,
//             ),
//             iconSize: 14,
//             iconEnabledColor: Palette().normalGray,
//             iconDisabledColor: Palette().normalGray,
//           ),
//           dropdownStyleData: DropdownStyleData(
//             elevation: 2,
//             width: size.width * 0.1,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(10),
//               color: Colors.white,
//             ),
//             scrollbarTheme: ScrollbarThemeData(
//               radius: const Radius.circular(10),
//               thumbVisibility: WidgetStateProperty.all(true),
//             ),
//           ),
//           menuItemStyleData: const MenuItemStyleData(
//             height: 25,
//             padding: EdgeInsets.only(
//               left: 15,
//               right: 15,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}

// 이번달
DateTime getThisMonth1stdayStartDatetime() {
  final now = DateTime.now();
  final firstDateOfMonth = DateTime(now.year, now.month, 1, 0, 0, 0);
  return firstDateOfMonth;
}

DateTime getThisMonthLastdayEndDatetime() {
  final now = DateTime.now();
  DateTime? thisMonthLastdayEndDatetime;
  switch (now.month) {
    case 1 || 3 || 5 || 7 || 8 || 10 || 12:
      thisMonthLastdayEndDatetime =
          DateTime(now.year, now.month, 31, 23, 59, 59);
      break;
    case 4 || 6 || 9 || 11:
      thisMonthLastdayEndDatetime =
          DateTime(now.year, now.month, 30, 23, 59, 59);
      break;
    case 2:
      thisMonthLastdayEndDatetime =
          DateTime(now.year, now.month, 28, 23, 59, 59);
      break;
    default:
      thisMonthLastdayEndDatetime =
          DateTime(now.year, now.month, 31, 23, 59, 59);
      break;
  }
  return thisMonthLastdayEndDatetime;
}

// 지난달
DateTime getLastMonth1stdayStartDatetime() {
  final now = DateTime.now();
  final firstDateOfMonth = DateTime(now.year, now.month - 1, 1, 0, 0, 0);
  return firstDateOfMonth;
}

DateTime getLastMonthLastdayEndDatetime() {
  final now = DateTime.now();
  final firstDateOfMonth = DateTime(now.year, now.month, 1);
  final lastDateOfLastMonth =
      firstDateOfMonth.subtract(const Duration(days: 1));
  final lastDateOfLastMonthEndDateTime = DateTime(lastDateOfLastMonth.year,
      lastDateOfLastMonth.month, lastDateOfLastMonth.day, 23, 59, 59);
  return lastDateOfLastMonthEndDateTime;
}

// 이번주
DateTime getThisWeekMondayStartDatetime() {
  final now = DateTime.now();
  final difference = now.weekday - 1;
  final thisMonday = now.subtract(Duration(days: difference));
  final thisMondayStartDatetime =
      DateTime(thisMonday.year, thisMonday.month, thisMonday.day, 0, 0, 0);
  return thisMondayStartDatetime;
}

DateTime getThisWeekSundayEndtDatetime() {
  final thisMonday = getThisWeekMondayStartDatetime();
  final thisSunday = thisMonday.add(const Duration(days: 6));
  final thisSundayEndDatetime =
      DateTime(thisSunday.year, thisSunday.month, thisSunday.day, 23, 59, 59);
  return thisSundayEndDatetime;
}

// 지난주
DateTime getLastWeekMondayStartDateTime() {
  final thisMonday = getThisWeekMondayStartDatetime();
  final lastMonday = thisMonday.subtract(const Duration(days: 7));
  final lastMondayStartDatetime =
      DateTime(lastMonday.year, lastMonday.month, lastMonday.day, 0, 0, 0);
  return lastMondayStartDatetime;
}

DateTime getLastWeekSundayEndDateTime() {
  final thisMonday = getThisWeekMondayStartDatetime();
  final lastSunday = thisMonday.subtract(const Duration(days: 1));
  final lastSundayEndDatetime =
      DateTime(lastSunday.year, lastSunday.month, lastSunday.day, 23, 59, 59);
  return lastSundayEndDatetime;
}

double _getAvgStepDouble(List<ChartData> steps) {
  double sumStep = 0;

  for (int i = 0; i < steps.length; i++) {
    sumStep += steps[i].y;
  }
  return steps.isEmpty ? 0 : (sumStep / steps.length).roundToDouble();
}

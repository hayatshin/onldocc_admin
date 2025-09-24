import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:onldocc_admin/common/view/search.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/constants/const.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/medical/health-consult/models/health_consult_inquiry_model.dart';
import 'package:onldocc_admin/features/medical/health-consult/view_models/health_consult_view_model.dart';
import 'package:onldocc_admin/features/medical/health-consult/widgets/response_health_consult.dart';
import 'package:onldocc_admin/features/medical/health-story/view/health_story_screen.dart';
import 'package:onldocc_admin/features/notice/views/notice_screen.dart';
import 'package:onldocc_admin/features/users/view/users_screen.dart';
import 'package:onldocc_admin/injicare_color.dart';
import 'package:onldocc_admin/injicare_font.dart';
import 'package:onldocc_admin/utils.dart';

class HealthConsultScreen extends ConsumerStatefulWidget {
  static const routeURL = "/health-consult";
  static const routeName = "healthConsult";
  const HealthConsultScreen({super.key});

  @override
  ConsumerState<HealthConsultScreen> createState() =>
      _HealthConsultScreenState();
}

class _HealthConsultScreenState extends ConsumerState<HealthConsultScreen> {
  final _testTypes = ["전체", "답변완료", "답변대기"];
  String _selectedTestType = "전체";

  List<HealthConsultInquiryModel> _list = [];
  List<HealthConsultInquiryModel> _initialList = [];

  static const int _itemsPerPage = 20;
  int _currentPage = 0;
  int _pageIndication = 0;
  int _totalListLength = 0;
  int _endPage = 0;

  @override
  void initState() {
    super.initState();
    _initializeHealthConsults();
  }

  Future<void> _filterUserDataList(
      String? searchBy, String searchKeyword) async {
    List<HealthConsultInquiryModel> filterList = [];
    if (searchBy == "이름") {
      filterList = _initialList
          .where((element) => element.userName!.contains(searchKeyword))
          .cast<HealthConsultInquiryModel>()
          .toList();
    } else {
      filterList = _initialList
          .where((element) => element.userPhone!.contains(searchKeyword))
          .cast<HealthConsultInquiryModel>()
          .toList();
    }
    int endPage = filterList.length ~/ _itemsPerPage + 1;

    setState(() {
      _list = filterList;
      _currentPage = 0;
      _pageIndication = 0;
      _endPage = endPage;
    });
  }

  Future<void> _initializeHealthConsults() async {
    final data =
        await ref.read(healthConsultProvider.notifier).fetchAllHealthConsults();

    int endPage = data.length ~/ _itemsPerPage + 1;

    setState(() {
      _initialList = data;
      _list = data;
      _totalListLength = data.length;
      _endPage = endPage;
    });
  }

  void _classifyHealthConsults(String? value) {
    List<HealthConsultInquiryModel> inquires = [];

    switch (value) {
      case "전체":
        inquires = _initialList;
      case "답변완료":
        inquires =
            _initialList.where((inquiry) => inquiry.response != null).toList();
      case "답변대기":
        inquires =
            _initialList.where((inquiry) => inquiry.response == null).toList();

      default:
        inquires = _initialList;
    }

    if (value != null) {
      setState(() {
        _selectedTestType = value;
        _list = inquires;
      });
    }
  }

  void _updateUserlistPerPage() {
    int startPage = _currentPage * _itemsPerPage;
    int endPage = startPage + _itemsPerPage > _initialList.length
        ? _initialList.length
        : startPage + _itemsPerPage;

    setState(() {
      _list = _initialList.sublist(startPage, endPage);
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

  void _respondHealthConsult(HealthConsultInquiryModel model) {
    final adminProfile = ref.read(adminProfileProvider).value;
    if (adminProfile == null) return;
    if (adminProfile.doctor == null ||
        adminProfile.doctor?.role != "counseling") {
      showTopWarningSnackBar(context, "작성 권한을 가진 의사가 아닙니다");
      return;
    }

    showRightModal(
      context,
      ResponseHealthConsult(
        model: model,
        updateHealthConsults: _initializeHealthConsults,
      ),
    );
  }

  void _editHealthConsult(HealthConsultInquiryModel model) {
    final adminProfile = ref.read(adminProfileProvider).value;
    if (adminProfile == null) return;
    if (adminProfile.doctor == null ||
        adminProfile.doctor?.role != "counseling") {
      showTopWarningSnackBar(context, "수정 권한을 가진 의사가 아닙니다");
      return;
    }

    showRightModal(
      context,
      ResponseHealthConsult(
        model: model,
        updateHealthConsults: _initializeHealthConsults,
        response: model.response!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
        menu: menuList[11],
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.2),
                          color: InjicareColor().gray100,
                        ),
                      ),
                      Gaps.h10,
                      SizedBox(
                        width: 150,
                        height: buttonHeight,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            selectedItemBuilder: (context) {
                              return _testTypes.map((String test) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _selectedTestType,
                                    style: InjicareFont().body07.copyWith(
                                          color: InjicareColor().gray90,
                                        ),
                                  ),
                                );
                              }).toList();
                            },
                            items: _testTypes.map((String test) {
                              return DropdownMenuItem<String>(
                                value: test,
                                child: Text(
                                  test,
                                  style: InjicareFont().label03.copyWith(
                                        color: InjicareColor().gray80,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            value: _selectedTestType,
                            onChanged: (value) =>
                                _classifyHealthConsults(value),
                            buttonStyleData: ButtonStyleData(
                              padding:
                                  const EdgeInsets.only(left: 14, right: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                                border: Border.all(
                                  color: InjicareColor().gray20,
                                  width: 1,
                                ),
                              ),
                            ),
                            iconStyleData: IconStyleData(
                              icon: const Icon(
                                Icons.expand_more_rounded,
                              ),
                              iconSize: 14,
                              iconEnabledColor: InjicareColor().gray60,
                              iconDisabledColor: InjicareColor().gray60,
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
                  Search(
                    filterUserList: _filterUserDataList,
                    resetInitialList: _initializeHealthConsults,
                    bottomGap: false,
                  ),
                ],
              ),
              Gaps.v40,
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
                              "번호",
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
                        flex: 10,
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
                              "상담 내용",
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
                              "질문 일자",
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
                              "답변 여부",
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
                              "답변 완료일자",
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
                              "조회수",
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
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(16),
                              ),
                              border: Border.all(
                                width: 1,
                                color: const Color(0xFFF3F6FD),
                              )),
                          child: Center(
                            child: Text(
                              "",
                              style: contentTextStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_list.isNotEmpty)
                    for (int i = 0; i < _list.length; i++)
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
                                  flex: 2,
                                  child: SelectableText(
                                    _list[i].userName ?? "-",
                                    style: contentTextStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: SelectableText(
                                    "${_list[i].userAge ?? 0}세",
                                    style: contentTextStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: SelectableText(
                                    _list[i].userGender ?? "-",
                                    style: contentTextStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 10,
                                  child: SelectableText(
                                    _list[i].title,
                                    style: contentTextStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: SelectableText(
                                    createdAtToDateDot(_list[i].createdAt),
                                    style: contentTextStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: _list[i].response == null
                                      ? Text(
                                          "답변대기",
                                          style: contentTextStyle.copyWith(
                                            color: InjicareColor().primary40,
                                          ),
                                          textAlign: TextAlign.center,
                                        )
                                      : Text(
                                          "답변완료",
                                          style: contentTextStyle.copyWith(
                                            color: InjicareColor().gray60,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: _list[i].response == null
                                      ? Container()
                                      : Text(
                                          createdAtToDateDot(
                                              _list[i].response!.createdAt),
                                          style: contentTextStyle,
                                          textAlign: TextAlign.center,
                                        ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: SelectableText(
                                    "${_list[i].views}",
                                    style: contentTextStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: _list[i].response == null
                                        ? gestureDetectorWithMouseClick(
                                            function: () =>
                                                _respondHealthConsult(_list[i]),
                                            child: const ResponseButton(),
                                          )
                                        : gestureDetectorWithMouseClick(
                                            function: () =>
                                                _editHealthConsult(_list[i]),
                                            child: const EditButton(),
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
            ],
          ),
        ));
  }
}

class ResponseButton extends StatelessWidget {
  const ResponseButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: InjicareColor().secondary50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 7,
          vertical: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorFiltered(
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              child: SvgPicture.asset(
                "assets/svg/comment-icon.svg",
                width: 14,
              ),
            ),
            Gaps.h2,
            Text(
              "답변하기",
              style: InjicareFont().label02.copyWith(color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}

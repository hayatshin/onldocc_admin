import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:onldocc_admin/common/view/search_csv.dart';
import 'package:onldocc_admin/common/view/skeleton_loading_screen.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/features/decibel/models/decibel_model.dart';
import 'package:onldocc_admin/features/decibel/view_models/decibel_view_model.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/users/view/users_screen.dart';
import 'package:onldocc_admin/features/users/view_models/user_view_model.dart';
import 'package:onldocc_admin/injicare_color.dart';
import 'package:onldocc_admin/injicare_font.dart';
import 'package:onldocc_admin/utils.dart';

class DecibelScreen extends ConsumerStatefulWidget {
  static const routeURL = "/decibel";
  static const routeName = "decibel";
  const DecibelScreen({super.key});

  @override
  ConsumerState<DecibelScreen> createState() => _DecibelScreenState();
}

class _DecibelScreenState extends ConsumerState<DecibelScreen> {
  List<DecibelModel> _userDataList = [];
  List<DecibelModel> _initialList = [];
  bool _loadingFinished = false;

  final double _tabHeight = 50;

  static const int _itemsPerPage = 20;
  int _currentPage = 0;
  int _pageIndication = 0;
  int _totalListLength = 0;
  int _endPage = 0;

  final List<String> _userListHeader = [
    "날짜",
    "데시벨",
    "이름",
    "연령",
    "성별",
    "핸드폰 번호",
  ];

  @override
  void initState() {
    super.initState();
    if (selectContractRegion.value != null) {
      _initializeUserDecibels();
    }

    selectContractRegion.addListener(() async {
      if (mounted) {
        setState(() {
          _loadingFinished = false;
        });
        await ref
            .read(userProvider.notifier)
            .initializeUserList(selectContractRegion.value!.subdistrictId);
        await _initializeUserDecibels();
      }
    });
  }

  Future<void> filterUserDataList(
      String? searchBy, String searchKeyword) async {
    List<DecibelModel> filterList = [];
    if (searchBy == "이름") {
      filterList = _initialList
          .where((element) => element.name.contains(searchKeyword))
          .cast<DecibelModel>()
          .toList();
    } else {
      filterList = _initialList
          .where((element) => element.phone.contains(searchKeyword))
          .cast<DecibelModel>()
          .toList();
    }

    setState(() {
      _userDataList = filterList;
    });
  }

  List<String> exportToList(DecibelModel userModel) {
    return [
      secondsToStringDiaryTimeLine(userModel.createdAt),
      userModel.decibel.toString(),
      userModel.name.toString(),
      userModel.age.toString(),
      userModel.gender.toString(),
      userModel.phone.toString(),
    ];
  }

  List<List<String>> exportToFullList(List<DecibelModel?> userDataList) {
    List<List<String>> list = [];

    list.add(_userListHeader);

    for (var item in userDataList) {
      final itemList = exportToList(item!);
      list.add(itemList);
    }
    return list;
  }

  // void generateUserCsv() {
  //   final csvData = exportToFullList(_userDataList);
  //   String csvContent = '';
  //   for (var row in csvData) {
  //     for (var i = 0; i < row.length; i++) {
  //       if (row[i].toString().contains(',')) {
  //         csvContent += '"${row[i]}"';
  //       } else {
  //         csvContent += row[i].toString();
  //       }

  //       if (i != row.length - 1) {
  //         csvContent += ',';
  //       }
  //     }
  //     csvContent += '\n';
  //   }
  //   final currentDate = DateTime.now();
  //   final formatDate =
  //       "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";

  //   final String fileName = "인지케어 화풀기 $formatDate.csv";

  //   final encodedUri = Uri.dataFromString(
  //     csvContent,
  //     encoding: Encoding.getByName(encodingType()),
  //   ).toString();
  //   final anchor = AnchorElement(href: encodedUri)
  //     ..setAttribute('download', fileName)
  //     ..click();
  // }

  void generateExcel() {
    final csvData = exportToFullList(_userDataList);
    final String fileName = "인지케어 화풀기 ${todayToStringDot()}.xlsx";
    exportExcel(csvData, fileName);
  }

  Future<void> resetInitialList() async {
    setState(() {
      _userDataList = _initialList;
    });
  }

  Future<void> _initializeUserDecibels() async {
    AdminProfileModel? adminProfileModel =
        ref.read(adminProfileProvider).value ??
            await ref.read(adminProfileProvider.notifier).getAdminProfile();
    final userSubdistrictId = adminProfileModel.master
        ? selectContractRegion.value!.subdistrictId
        : adminProfileModel.subdistrictId;

    final decibelList = await ref
        .read(decibelProvider.notifier)
        .fetchUserDecibels(userSubdistrictId);
    int endPage = decibelList.length ~/ _itemsPerPage + 1;

    if (selectContractRegion.value!.contractCommunityId == null) {
      // 전체보기
      setState(() {
        _loadingFinished = true;

        _totalListLength = decibelList.length;
        _initialList = decibelList;
        _endPage = endPage;
      });
      _updateUserlistPerPage();
    } else {
      // 기관 선택
      final filterList = _initialList
          .where((element) =>
              element.contractCommunityId ==
              selectContractRegion.value!.contractCommunityId)
          .cast<DecibelModel>()
          .toList();
      setState(() {
        _loadingFinished = true;
        _totalListLength = filterList.length;
        _initialList = filterList;
        _endPage = endPage;
      });
      _updateUserlistPerPage();
    }
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
    return DefaultScreen(
      menu: menuList[9],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchCsv(
                filterUserList: filterUserDataList,
                resetInitialList: resetInitialList,
                generateCsv: generateExcel),
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
                          flex: 2,
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
                                "날짜",
                                style: contentTextStyle,
                                overflow: TextOverflow.ellipsis,
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
                                "데시벨",
                                style: contentTextStyle,
                                overflow: TextOverflow.ellipsis,
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
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(16),
                                ),
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
                            flex: 2,
                            child: SelectableText(
                              secondsToYearMonthDayHourMinute(
                                  _userDataList[i].createdAt),
                              style: contentTextStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: SelectableText(
                              _userDataList[i].decibel,
                              style: contentTextStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                              flex: 2,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: SelectableText(
                                  _userDataList[i].name,
                                  style: contentTextStyle,
                                  textAlign: TextAlign.center,
                                ),
                              )),
                          Expanded(
                            flex: 1,
                            child: SelectableText(
                              "${_userDataList[i].age}세",
                              style: contentTextStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: SelectableText(
                              _userDataList[i].gender,
                              style: contentTextStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: SelectableText(
                              _userDataList[i].phone,
                              style: contentTextStyle,
                              textAlign: TextAlign.center,
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
  }
}

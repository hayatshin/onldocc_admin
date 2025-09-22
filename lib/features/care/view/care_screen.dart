import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:onldocc_admin/common/view/search_csv.dart';
import 'package:onldocc_admin/common/view/skeleton_loading_screen.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/care/models/care_model.dart';
import 'package:onldocc_admin/features/care/repo/care_repo.dart';
import 'package:onldocc_admin/features/care/view_models/care_view_model.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/users/view/users_screen.dart';
import 'package:onldocc_admin/features/users/view_models/user_view_model.dart';
import 'package:onldocc_admin/injicare_color.dart';
import 'package:onldocc_admin/injicare_font.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';

class CareScreen extends ConsumerStatefulWidget {
  static const routeURL = "/care";
  static const routeName = "care";
  const CareScreen({super.key});

  @override
  ConsumerState<CareScreen> createState() => _CareScreenState();
}

class _CareScreenState extends ConsumerState<CareScreen> {
  final TextStyle _contentTextStyle = TextStyle(
    fontSize: Sizes.size12,
    fontWeight: FontWeight.w500,
    color: Palette().darkGray,
  );

  List<CareModel?> _userDataList = [];
  List<CareModel?> _initialList = [];
  bool _loadingFinished = false;

  final double _tabHeight = 50;

  static const int _itemsPerPage = 20;
  int _currentPage = 0;
  int _pageIndication = 0;
  int _totalListLength = 0;
  int _endPage = 0;

  final List<String> _userListHeader = [
    "일수 지정",
    "이름",
    "연령",
    "성별",
    "핸드폰 번호",
    "마지막 방문일",
    "연락 필요",
  ];

  @override
  void initState() {
    super.initState();

    if (selectContractRegion.value != null) {
      _initializeUserCare();
    }

    selectContractRegion.addListener(() async {
      if (mounted) {
        setState(() {
          _loadingFinished = false;
        });

        await ref
            .read(userProvider.notifier)
            .initializeUserList(selectContractRegion.value!.subdistrictId);
        await _initializeUserCare();
        await _filterContractCommunity();
      }
    });
  }

  Future<void> _filterUserDataList(
      String? searchBy, String searchKeyword) async {
    List<CareModel> filterList = [];
    if (searchBy == "이름") {
      filterList = _initialList
          .where((element) => element!.name.contains(searchKeyword))
          .cast<CareModel>()
          .toList();
    } else {
      filterList = _initialList
          .where((element) => element!.phone.contains(searchKeyword))
          .cast<CareModel>()
          .toList();
    }

    setState(() {
      _userDataList = filterList;
    });
  }

  List<String> exportToList(CareModel userModel) {
    return [
      userModel.partnerDates.toString(),
      userModel.name.toString(),
      userModel.age.toString(),
      userModel.gender.toString(),
      userModel.phone.toString(),
      secondsToStringLine(userModel.lastVisit),
      userModel.partnerContact ? "🚨" : "X",
    ];
  }

  List<List<String>> exportToFullList(List<CareModel?> userDataList) {
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

  //   final String fileName = "인지케어 보호자 지정 $formatDate.csv";

  //   final encodedUri = Uri.dataFromString(
  //     csvContent,
  //     encoding: Encoding.getByName(encodingType()),
  //   ).toString();
  //   final anchor = AnchorElement(href: encodedUri)
  //     ..setAttribute('download', fileName)
  //     ..click();
  // }

  Future<void> resetInitialList() async {
    setState(() {
      _userDataList = _initialList;
    });
  }

  void generateExcel() {
    final csvData = exportToFullList(_userDataList);
    final String fileName = "인지케어 보호자케어 ${todayToStringDot()}.xlsx";
    exportExcel(csvData, fileName);
  }

  Future<void> _initializeUserCare() async {
    List<CareModel?> totalPartnerList = [];
    List<CareModel?> partnerList = [];

    AdminProfileModel? adminProfileModel =
        ref.read(adminProfileProvider).value ??
            await ref.read(adminProfileProvider.notifier).getAdminProfile();

    final totalList =
        await ref.read(careProvider.notifier).fetchPartners(adminProfileModel);

    if (selectContractRegion.value!.contractCommunityId == null ||
        selectContractRegion.value!.contractCommunityId == "") {
      // 전체보기
      totalPartnerList = totalList;
    } else {
      // 기관 선택
      totalPartnerList = totalList
          .where((element) =>
              element.contractCommunityId ==
              selectContractRegion.value!.contractCommunityId)
          .cast<CareModel>()
          .toList();
    }
    for (int i = 0; i > totalPartnerList.length; i++) {
      final partner = totalPartnerList[i];
      if (partner != null && (partner.agreed ?? false)) {
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final yesterdayTime =
            DateTime(yesterday.year, yesterday.month, yesterday.day, 0, 0, 0);

        int startSeconds = yesterdayTime.millisecondsSinceEpoch ~/ 1000;
        final lastVisitCheck =
            (partner.lastVisit) > startSeconds ? true : false;

        final iterateDays = [
          dateTimeToStringDateLine(yesterday),
          dateTimeToStringDateLine(now)
        ];
        final stepCheck = await ref
            .read(careRepo)
            .checkUserStepExists(partner.userId, iterateDays);

        bool partnerContact = !lastVisitCheck && !stepCheck;

        final newModel = partner.copyWith(
          partnerContact: partnerContact,
        );
        partnerList.add(newModel);
      }
    }

    int endPage = partnerList.length ~/ _itemsPerPage + 1;

    setState(() {
      _loadingFinished = true;
      _totalListLength = partnerList.length;
      _initialList = partnerList;
      _endPage = endPage;
    });
    _updateUserlistPerPage();
  }

  Future<void> _filterContractCommunity() async {
    if (selectContractRegion.value!.contractCommunityId != null) {
      final filterList = _initialList
          .where((element) =>
              element!.contractCommunityId ==
              selectContractRegion.value!.contractCommunityId)
          .cast<CareModel>()
          .toList();
      setState(() {
        _userDataList = filterList;
      });
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
      menu: menuList[8],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Colors.red,
                  BlendMode.srcIn,
                ),
                child: SvgPicture.asset(
                  "assets/svg/light-emergency-on.svg",
                ),
              ),
              Gaps.h20,
              Text(
                "서비스 이용약관에 동의한 사용자에 한해 1일동안 인지케어 활동 기록과 걸음수 기록이 없는 사용자에게 [연락 필요] 열에 빨간 불이 들어옵니다",
                style: _contentTextStyle.copyWith(
                  color: InjicareColor().gray70,
                ),
              ),
            ],
          ),
          Gaps.v40,
          SearchCsv(
              filterUserList: _filterUserDataList,
              resetInitialList: _initializeUserCare,
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
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
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
                                decoration: BoxDecoration(
                                    color: const Color(0xFFE9EDF9),
                                    border: Border.all(
                                      width: 1,
                                      color: const Color(0xFFF3F6FD),
                                    )),
                                child: Center(
                                  child: Text(
                                    "마지막 방문일",
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
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(16),
                                    ),
                                    border: Border.all(
                                      width: 1,
                                      color: const Color(0xFFF3F6FD),
                                    )),
                                child: Center(
                                  child: Text(
                                    "연락 필요",
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
                                        _userDataList[i]!.name,
                                        style: contentTextStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: Text(
                                          "${_userDataList[i]!.age}세",
                                          style: contentTextStyle,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        _userDataList[i]!.gender,
                                        style: contentTextStyle,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        _userDataList[i]!.phone,
                                        style: contentTextStyle,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        secondsToStringLine(
                                            _userDataList[i]!.lastVisit),
                                        style: contentTextStyle,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: _userDataList[i]!.partnerContact
                                          ? SvgPicture.asset(
                                              "assets/svg/light-emergency-on.svg",
                                            )
                                          : Container(),
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
        ],
      ),
    );
  }
}

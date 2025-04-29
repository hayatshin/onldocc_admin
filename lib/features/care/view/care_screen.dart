import 'package:data_table_2/data_table_2.dart';
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
import 'package:onldocc_admin/features/users/view_models/user_view_model.dart';
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

  List<CareModel?> _userDataList = [];
  List<CareModel?> _initialList = [];
  bool _loadingFinished = false;

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

    if (selectContractRegion.value!.contractCommunityId == null) {
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

    setState(() {
      _loadingFinished = true;
      _userDataList = partnerList;
      _initialList = partnerList;
    });
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return DefaultScreen(
        menu: menuList[9],
        child: SizedBox(
          width: size.width,
          height: size.height,
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
                  SelectableText(
                    "서비스 이용약관에 동의한 사용자에 한해 1일동안 인지케어 활동 기록과 걸음수 기록이 없는 사용자에게 [연락 필요] 열에 빨간 불이 들어옵니다",
                    style: _contentTextStyle.copyWith(
                      color: Palette().darkPurple,
                    ),
                  ),
                ],
              ),
              Gaps.v40,
              SearchCsv(
                filterUserList: _filterUserDataList,
                resetInitialList: _initializeUserCare,
                generateCsv: generateExcel,
              ),
              _loadingFinished
                  ? Expanded(
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
                          // DataColumn2(
                          //   size: ColumnSize.S,
                          //   label: SelectableText(
                          //     "일수 지정",
                          //     style: _headerTextStyle,
                          //   ),
                          // ),
                          DataColumn2(
                            size: ColumnSize.L,
                            label: SelectableText(
                              "이름",
                              style: _headerTextStyle,
                            ),
                          ),
                          DataColumn2(
                            size: ColumnSize.S,
                            label: SelectableText(
                              "연령",
                              style: _headerTextStyle,
                            ),
                          ),
                          DataColumn2(
                            size: ColumnSize.S,
                            label: SelectableText(
                              "성별",
                              style: _headerTextStyle,
                            ),
                          ),
                          DataColumn2(
                            size: ColumnSize.L,
                            label: SelectableText(
                              "핸드폰 번호",
                              style: _headerTextStyle,
                            ),
                          ),
                          DataColumn2(
                            size: ColumnSize.L,
                            label: SelectableText(
                              "마지막 방문일",
                              style: _headerTextStyle,
                            ),
                          ),
                          DataColumn2(
                            label: SelectableText(
                              "연락 필요",
                              style: _headerTextStyle,
                            ),
                          ),
                        ],
                        rows: [
                          for (int i = 0; i < _userDataList.length; i++)
                            DataRow2(
                              cells: [
                                // DataCell(
                                //   SelectableText(
                                //     "${_userDataList[i]!.partnerDates}일",
                                //     style: _contentTextStyle,
                                //   ),
                                // ),
                                DataCell(
                                  SelectableText(
                                    _userDataList[i]!.name.length > 8
                                        ? "${_userDataList[i]!.name.substring(0, 8)}.."
                                        : _userDataList[i]!.name,
                                    style: _contentTextStyle,
                                  ),
                                ),
                                DataCell(
                                  SelectableText(
                                    _userDataList[i]!.age,
                                    style: _contentTextStyle,
                                  ),
                                ),
                                DataCell(
                                  SelectableText(
                                    _userDataList[i]!.gender,
                                    style: _contentTextStyle,
                                  ),
                                ),
                                DataCell(
                                  SelectableText(
                                    _userDataList[i]!.phone,
                                    style: _contentTextStyle,
                                  ),
                                ),
                                DataCell(
                                  SelectableText(
                                    _userDataList[i]!.lastVisit != 0
                                        ? secondsToStringLine(
                                            _userDataList[i]!.lastVisit)
                                        : "-",
                                    style: _contentTextStyle,
                                  ),
                                ),
                                DataCell(
                                  _userDataList[i]!.partnerContact
                                      ? ColorFiltered(
                                          colorFilter: const ColorFilter.mode(
                                              Colors.red, BlendMode.srcIn),
                                          child: SvgPicture.asset(
                                            "assets/svg/light-emergency-on.svg",
                                          ),
                                        )
                                      : Container(),
                                ),
                              ],
                            )
                        ],
                      ),
                    )
                  : const SkeletonLoadingScreen(),
            ],
          ),
        ));
  }
}

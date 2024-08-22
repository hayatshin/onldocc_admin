import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/view/search_csv.dart';
import 'package:onldocc_admin/common/view/skeleton_loading_screen.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/decibel/models/decibel_model.dart';
import 'package:onldocc_admin/features/decibel/view_models/decibel_view_model.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/users/view_models/user_view_model.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';

class DecibelScreen extends ConsumerStatefulWidget {
  static const routeURL = "/decibel";
  static const routeName = "decibel";
  const DecibelScreen({super.key});

  @override
  ConsumerState<DecibelScreen> createState() => _DecibelScreenState();
}

class _DecibelScreenState extends ConsumerState<DecibelScreen> {
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
  List<DecibelModel> _userDataList = [];
  List<DecibelModel> _initialList = [];
  bool _loadingFinished = false;

  final List<String> _userListHeader = [
    "날짜",
    "데시벨",
    "이름",
    "나이",
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

    if (selectContractRegion.value!.contractCommunityId == null) {
      // 전체보기
      setState(() {
        _loadingFinished = true;
        _userDataList = decibelList;
        _initialList = decibelList;
      });
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
        _userDataList = filterList;
        _initialList = decibelList;
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
            SearchCsv(
              filterUserList: filterUserDataList,
              resetInitialList: resetInitialList,
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
                        DataColumn2(
                          label: Text(
                            "날짜",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          size: ColumnSize.L,
                          label: Text(
                            "데시벨",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          size: ColumnSize.L,
                          label: Text(
                            "이름",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          size: ColumnSize.S,
                          label: Text(
                            "나이",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          size: ColumnSize.S,
                          label: Text(
                            "성별",
                            style: _headerTextStyle,
                          ),
                        ),
                        DataColumn2(
                          label: Text(
                            "핸드폰 번호",
                            style: _headerTextStyle,
                          ),
                        ),
                      ],
                      rows: [
                        for (var i = 0; i < _userDataList.length; i++)
                          DataRow2(
                            cells: [
                              DataCell(
                                Text(
                                  secondsToYearMonthDayHourMinute(
                                      _userDataList[i].createdAt),
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  _userDataList[i].decibel,
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  _userDataList[i].name.length > 8
                                      ? "${_userDataList[i].name.substring(0, 8)}.."
                                      : _userDataList[i].name,
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  _userDataList[i].age,
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  _userDataList[i].gender,
                                  style: _contentTextStyle,
                                ),
                              ),
                              DataCell(
                                Text(
                                  _userDataList[i].phone,
                                  style: _contentTextStyle,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  )
                : const SkeletonLoadingScreen()
          ],
        ),
      ),
    );
  }
}

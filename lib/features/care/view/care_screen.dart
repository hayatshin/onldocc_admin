import 'dart:convert';
import 'dart:html';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/view/search_below.dart';
import 'package:onldocc_admin/common/view/search_csv.dart';
import 'package:onldocc_admin/common/view/skeleton_loading_screen.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/care/models/care_model.dart';
import 'package:onldocc_admin/features/care/repo/care_repo.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/features/users/view_models/user_view_model.dart';
import 'package:onldocc_admin/utils.dart';

class CareScreen extends ConsumerStatefulWidget {
  static const routeURL = "/care";
  static const routeName = "care";
  const CareScreen({super.key});

  @override
  ConsumerState<CareScreen> createState() => _CareScreenState();
}

class _CareScreenState extends ConsumerState<CareScreen> {
  List<CareModel?> _userDataList = [];
  List<CareModel?> _initialList = [];
  bool loadingFinished = false;

  final List<String> _userListHeader = [
    "일수 지정",
    "이름",
    "나이",
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
          loadingFinished = false;
        });
        await _initializeUserCare();
      }
    });
  }

  Future<void> filterUserDataList(
      String? searchBy, String searchKeyword) async {
    List<CareModel> filterList = [];
    if (searchBy == "name") {
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

  List<dynamic> exportToList(CareModel userModel) {
    return [
      userModel.partnerDates,
      userModel.name,
      userModel.age,
      userModel.gender,
      userModel.phone,
      secondsToStringLine(userModel.lastVisit),
      userModel.partnerContact ? "🚨" : "X",
    ];
  }

  List<List<dynamic>> exportToFullList(List<CareModel?> userDataList) {
    List<List<dynamic>> list = [];

    list.add(_userListHeader);

    for (var item in userDataList) {
      final itemList = exportToList(item!);
      list.add(itemList);
    }
    return list;
  }

  void generateUserCsv() {
    final csvData = exportToFullList(_userDataList);
    String csvContent = '';
    for (var row in csvData) {
      for (var i = 0; i < row.length; i++) {
        if (row[i].toString().contains(',')) {
          csvContent += '"${row[i]}"';
        } else {
          csvContent += row[i].toString();
        }

        if (i != row.length - 1) {
          csvContent += ',';
        }
      }
      csvContent += '\n';
    }
    final currentDate = DateTime.now();
    final formatDate =
        "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";

    final String fileName = "인지케어 보호자 지정 $formatDate.csv";

    final encodedUri = Uri.dataFromString(
      csvContent,
      encoding: Encoding.getByName(encodingType()),
    ).toString();
    final anchor = AnchorElement(href: encodedUri)
      ..setAttribute('download', fileName)
      ..click();
  }

  Future<void> resetInitialList() async {
    setState(() {
      _userDataList = _initialList;
    });
  }

  Future<void> _initializeUserCare() async {
    List<CareModel?> careList = [];
    AdminProfileModel? adminProfileModel = ref.read(adminProfileProvider).value;
    final subdistrictId = adminProfileModel!.master
        ? selectContractRegion.value!.subdistrictId
        : adminProfileModel.subdistrictId;

    final userList = ref.read(userProvider).value ??
        await ref.read(userProvider.notifier).initializeUserList(subdistrictId);

    for (UserModel? user in userList) {
      if (user != null && user.partnerDates! > 0) {
        final now = DateTime.now();
        final previousDay = now.subtract(Duration(days: user.partnerDates!));
        final previousDateTime = DateTime(
            previousDay.year, previousDay.month, previousDay.day, 0, 0, 0);

        int startSeconds = previousDateTime.millisecondsSinceEpoch ~/ 1000;
        final lastVisitCheck =
            (user.lastVisit ?? 0) > startSeconds ? true : false;

        final iterateDays = interatePreviousDays(user.partnerDates! + 1);

        final stepCheck = await ref
            .read(careRepo)
            .checkUserStepExists(user.userId, iterateDays);
        bool partnerContact = !lastVisitCheck && !stepCheck;

        final newModel = CareModel(
          partnerDates: user.partnerDates ?? 0,
          name: user.name,
          age: user.userAge!,
          gender: user.gender,
          phone: user.phone,
          lastVisit: user.lastVisit!,
          partnerContact: partnerContact,
        );
        careList.add(newModel);
      }
    }

    setState(() {
      loadingFinished = true;
      _userDataList = careList;
      _initialList = careList;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return DefaultScreen(
        menu: menuList[8],
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: loadingFinished
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SearchCsv(
                      filterUserList: filterUserDataList,
                      resetInitialList: _initializeUserCare,
                      generateCsv: generateUserCsv,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Text(
                        "보호자 지정을 설정한 사용자",
                        style: TextStyle(
                          background: Paint()
                            ..color =
                                Theme.of(context).primaryColor.withOpacity(0.1),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SearchBelow(
                      size: size,
                      child: Padding(
                        padding: const EdgeInsets.all(
                          Sizes.size10,
                        ),
                        child: DataTable2(
                          columns: const [
                            DataColumn2(
                              fixedWidth: 140,
                              label: Text(
                                "일수 지정",
                                style: TextStyle(
                                  fontSize: Sizes.size13,
                                ),
                              ),
                            ),
                            DataColumn2(
                              label: Text(
                                "이름",
                                style: TextStyle(
                                  fontSize: Sizes.size13,
                                ),
                              ),
                            ),
                            DataColumn2(
                              fixedWidth: 140,
                              label: Text(
                                "나이",
                                style: TextStyle(
                                  fontSize: Sizes.size13,
                                ),
                              ),
                            ),
                            DataColumn2(
                              fixedWidth: 140,
                              label: Text(
                                "성별",
                                style: TextStyle(
                                  fontSize: Sizes.size13,
                                ),
                              ),
                            ),
                            DataColumn2(
                              label: Text(
                                "핸드폰 번호",
                                style: TextStyle(
                                  fontSize: Sizes.size13,
                                ),
                              ),
                            ),
                            DataColumn2(
                              label: Text(
                                "마지막 방문일",
                                style: TextStyle(
                                  fontSize: Sizes.size13,
                                ),
                              ),
                            ),
                            DataColumn2(
                              fixedWidth: 180,
                              label: Text(
                                "연락 필요",
                                style: TextStyle(
                                  fontSize: Sizes.size13,
                                ),
                              ),
                            ),
                          ],
                          rows: [
                            for (var i = 0; i < _userDataList.length; i++)
                              DataRow2(
                                cells: [
                                  DataCell(
                                    Text(
                                      "${_userDataList[i]!.partnerDates}일",
                                      style: const TextStyle(
                                        fontSize: Sizes.size13,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      _userDataList[i]!.name.length > 8
                                          ? "${_userDataList[i]!.name.substring(0, 8)}.."
                                          : _userDataList[i]!.name,
                                      style: const TextStyle(
                                        fontSize: Sizes.size13,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      _userDataList[i]!.age,
                                      style: const TextStyle(
                                        fontSize: Sizes.size13,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      _userDataList[i]!.gender,
                                      style: const TextStyle(
                                        fontSize: Sizes.size13,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      _userDataList[i]!.phone,
                                      style: const TextStyle(
                                        fontSize: Sizes.size13,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      _userDataList[i]!.lastVisit != 0
                                          ? secondsToStringLine(
                                              _userDataList[i]!.lastVisit)
                                          : "-",
                                      style: const TextStyle(
                                        fontSize: Sizes.size13,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      _userDataList[i]!.partnerContact
                                          ? "🚨"
                                          : "X",
                                      style: TextStyle(
                                        fontSize:
                                            _userDataList[i]!.partnerContact
                                                ? Sizes.size20
                                                : Sizes.size14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    )
                  ],
                )
              : const SkeletonLoadingScreen(),
        ));
  }
}

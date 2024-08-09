import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/view/search_csv.dart';
import 'package:onldocc_admin/common/view/skeleton_loading_screen.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/invitation/models/invitation_model.dart';
import 'package:onldocc_admin/features/invitation/view_models/invitation_view_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/utils.dart';
import 'package:universal_html/html.dart';

class InvitationScreen extends ConsumerStatefulWidget {
  static const routeURL = "/invitation";
  static const routeName = "invitation";
  const InvitationScreen({super.key});

  @override
  ConsumerState<InvitationScreen> createState() => _InvitationScreenState();
}

class _InvitationScreenState extends ConsumerState<InvitationScreen> {
  bool loadingFinished = true;
  final List<String> _userListHeader = [
    "#",
    "이름",
    "나이",
    "성별",
    "핸드폰 번호",
    "초대 횟수",
    "날짜"
  ];
  List<InvitationModel?> _userDataList = [];
  List<InvitationModel?> _initialList = [];

  Map<int, bool> expandMap = {};
  bool expandclick = false;
  bool expandUpdate = false;

  DateRange? selectedDateRange = DateRange(
    getThisWeekMonday(),
    DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    getInvitationList(selectedDateRange);

    selectContractRegion.addListener(() async {
      if (mounted) {
        setState(() {
          loadingFinished = false;
        });

        await getInvitationList(selectedDateRange);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> filterUserDataList(
      String? searchBy, String searchKeyword) async {
    List<InvitationModel> filterList = [];
    if (searchBy == "name") {
      filterList = _initialList
          .where((element) => element!.userName.contains(searchKeyword))
          .cast<InvitationModel>()
          .toList();
    } else {
      filterList = _initialList
          .where((element) => element!.userPhone.contains(searchKeyword))
          .cast<InvitationModel>()
          .toList();
    }

    setState(() {
      _userDataList = filterList;
    });
  }

  List<dynamic> exportToList(InvitationModel userModel) {
    return [
      userModel.index,
      userModel.userName,
      userModel.userAge,
      userModel.userGender,
      userModel.userPhone,
      userModel.invitationCount,
      invitationDatesToCSV(userModel.invitationDates)
    ];
  }

  List<List<dynamic>> exportToFullList(List<InvitationModel?> userDataList) {
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

    final String fileName = "인지케어 친구 초대 $formatDate.csv";

    final encodedUri = Uri.dataFromString(
      csvContent,
      encoding: Encoding.getByName(encodingType()),
    ).toString();
    final anchor = AnchorElement(href: encodedUri)
      ..setAttribute('download', fileName)
      ..click();
  }

  Future<void> resetInitialList() async {
    final userList = ref.read(invitationProvider).value ??
        await ref.read(invitationProvider.notifier).fetchInvitations(
            selectedDateRange ??
                DateRange(
                  getThisWeekMonday(),
                  DateTime.now(),
                ),
            selectContractRegion.value!.subdistrictId);
    setState(() {
      _userDataList = userList;
    });
  }

  void updateOrderPeriod(DateRange? value) async {
    setState(() {
      loadingFinished = false;
      selectedDateRange = value;
    });

    await getInvitationList(value);
  }

  Future<void> getInvitationList(DateRange? range) async {
    final userList = await ref
        .read(invitationProvider.notifier)
        .fetchInvitations(range!, selectContractRegion.value!.subdistrictId);

    if (selectContractRegion.value!.subdistrictId == "") {
      if (mounted) {
        setState(() {
          loadingFinished = true;
          _userDataList = userList;
          _initialList = userList;
        });
      }
    } else {
      if (selectContractRegion.value!.contractCommunityId != "" &&
          selectContractRegion.value!.contractCommunityId != null) {
        final filterDataList = userList
            .where((e) =>
                e.userContractCommunityId ==
                selectContractRegion.value!.contractCommunityId)
            .toList();
        if (mounted) {
          setState(() {
            loadingFinished = true;
            _userDataList = filterDataList;
            _initialList = userList;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            loadingFinished = true;
            _userDataList = userList;
            _initialList = userList;
          });
        }
      }
    }
  }

  void expansionCallbackFunc(int index, bool isExpanded) {
    setState(() {
      expandclick = true;
      expandMap[index] = isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return DefaultScreen(
      menu: menuList[10],
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Column(
          children: [
            SearchCsv(
              filterUserList: filterUserDataList,
              resetInitialList: resetInitialList,
              generateCsv: generateUserCsv,
            ),
            const Row(
              children: [
                // PeriodButton(),
              ],
            ),
            Gaps.v20,
            !loadingFinished
                ? const SkeletonLoadingScreen()
                : Expanded(
                    child: DataTable2(
                      columns: const [
                        DataColumn2(
                          label: Text(
                            "#",
                            style: TextStyle(
                              fontSize: Sizes.size13,
                            ),
                          ),
                        ),
                        DataColumn2(
                          fixedWidth: 200,
                          label: Text(
                            "이름",
                            style: TextStyle(
                              fontSize: Sizes.size13,
                            ),
                          ),
                        ),
                        DataColumn2(
                          fixedWidth: 100,
                          label: Text(
                            "나이",
                            style: TextStyle(
                              fontSize: Sizes.size13,
                            ),
                          ),
                        ),
                        DataColumn2(
                          fixedWidth: 100,
                          label: Text(
                            "성별",
                            style: TextStyle(
                              fontSize: Sizes.size13,
                            ),
                          ),
                        ),
                        DataColumn2(
                          fixedWidth: 200,
                          label: Text(
                            "핸드폰 번호",
                            style: TextStyle(
                              fontSize: Sizes.size13,
                            ),
                          ),
                        ),
                        DataColumn2(
                          fixedWidth: 150,
                          label: Text(
                            "초대 횟수",
                            style: TextStyle(
                              fontSize: Sizes.size13,
                            ),
                          ),
                        ),
                        DataColumn2(
                          fixedWidth: 300,
                          label: Text(
                            "날짜",
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
                                  _userDataList[i]!.index.toString(),
                                  style: const TextStyle(
                                    fontSize: Sizes.size13,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  _userDataList[i]!.userName,
                                  style: const TextStyle(
                                    fontSize: Sizes.size13,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  _userDataList[i]!.userAge,
                                  style: const TextStyle(
                                    fontSize: Sizes.size13,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  _userDataList[i]!.userGender,
                                  style: const TextStyle(
                                    fontSize: Sizes.size13,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  _userDataList[i]!.userPhone,
                                  style: const TextStyle(
                                    fontSize: Sizes.size13,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  _userDataList[i]!.invitationCount.toString(),
                                  style: const TextStyle(
                                    fontSize: Sizes.size13,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  invitationDatesToTable(
                                      _userDataList[i]!.invitationDates),
                                  style: const TextStyle(
                                    fontSize: Sizes.size13,
                                  ),
                                ),
                              ),
                            ],
                          )
                      ],
                    ),
                  )
          ],
        ),
      ),
    );
  }
}

String invitationDatesToTable(List<dynamic> dates) {
  String tableDates = "";
  for (int i = 0; i < dates.length; i++) {
    if (i == dates.length - 1) {
      tableDates += "◦  ${dates[i]}";
    } else {
      tableDates += "◦  ${dates[i]}\n";
    }
  }
  return tableDates;
}

String invitationDatesToCSV(List<dynamic> dates) {
  String tableDates = "";
  for (int i = 0; i < dates.length; i++) {
    if (i == dates.length - 1) {
      tableDates += "${dates[i]}";
    } else {
      tableDates += "${dates[i]} / ";
    }
  }
  return tableDates;
}

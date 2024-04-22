import 'dart:convert';
import 'dart:html';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/view/search_below.dart';
import 'package:onldocc_admin/common/view/search_csv.dart';
import 'package:onldocc_admin/common/view/skeleton_loading_screen.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/decibel/models/decibel_model.dart';
import 'package:onldocc_admin/features/decibel/view_models/decibel_view_model.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
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
  bool loadingFinished = false;

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
          loadingFinished = false;
        });
        await _initializeUserDecibels();
      }
    });
  }

  Future<void> filterUserDataList(
      String? searchBy, String searchKeyword) async {
    List<DecibelModel> filterList = [];
    if (searchBy == "name") {
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

  List<dynamic> exportToList(DecibelModel userModel) {
    return [
      secondsToStringDiaryTimeLine(userModel.createdAt),
      userModel.decibel,
      userModel.name,
      userModel.age,
      userModel.gender,
      userModel.phone,
    ];
  }

  List<List<dynamic>> exportToFullList(List<DecibelModel?> userDataList) {
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

  Future<void> _initializeUserDecibels() async {
    AdminProfileModel? adminProfileModel = ref.read(adminProfileProvider).value;
    final userSubdistrictId = adminProfileModel!.master
        ? selectContractRegion.value!.subdistrictId
        : adminProfileModel.subdistrictId;
    final decibelList = await ref
        .read(decibelProvider.notifier)
        .fetchUserDecibels(userSubdistrictId);
    setState(() {
      loadingFinished = true;
      _userDataList = decibelList;
      _initialList = decibelList;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return !loadingFinished
        ? const SkeletonLoadingScreen()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SearchCsv(
                filterUserList: filterUserDataList,
                resetInitialList: resetInitialList,
                generateCsv: generateUserCsv,
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
                        label: Text(
                          "날짜",
                          style: TextStyle(
                            fontSize: Sizes.size13,
                          ),
                        ),
                      ),
                      DataColumn2(
                        fixedWidth: 200,
                        label: Text(
                          "데시벨",
                          style: TextStyle(
                            fontSize: Sizes.size13,
                          ),
                        ),
                      ),
                      DataColumn2(
                        fixedWidth: 140,
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
                    ],
                    rows: [
                      for (var i = 0; i < _userDataList.length; i++)
                        DataRow2(
                          cells: [
                            DataCell(
                              Text(
                                secondsToYearMonthDayHourMinute(
                                    _userDataList[i].createdAt),
                                style: const TextStyle(
                                  fontSize: Sizes.size13,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                _userDataList[i].decibel,
                                style: const TextStyle(
                                  fontSize: Sizes.size13,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                _userDataList[i].name.length > 8
                                    ? "${_userDataList[i].name.substring(0, 8)}.."
                                    : _userDataList[i].name,
                                style: const TextStyle(
                                  fontSize: Sizes.size13,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                _userDataList[i].age,
                                style: const TextStyle(
                                  fontSize: Sizes.size13,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                _userDataList[i].gender,
                                style: const TextStyle(
                                  fontSize: Sizes.size13,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                _userDataList[i].phone,
                                style: const TextStyle(
                                  fontSize: Sizes.size13,
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
          );
  }
}

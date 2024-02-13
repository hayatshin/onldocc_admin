import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/view/search_below.dart';
import 'package:onldocc_admin/common/view/search_csv.dart';
import 'package:onldocc_admin/common/view/skeleton_loading_screen.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/features/users/repo/user_repo.dart';
import 'package:onldocc_admin/features/users/view_models/user_view_model.dart';
import 'package:onldocc_admin/utils.dart';

class UsersScreen extends ConsumerStatefulWidget {
  static const routeURL = "/users";
  static const routeName = "users";
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  bool loadingFinished = false;

  List<UserModel?> _userDataList = [];
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();
  OverlayEntry? overlayEntry;
  final List<String> _userListHeader = [
    "이름",
    "나이",
    "출생일",
    "성별",
    "핸드폰 번호",
    "거주 지역",
    "가입일",
    "마지막 방문일"
  ];

  final tableFontSize = 11.5;

  bool createdAtSort = false;
  bool lastVisitSort = false;

  @override
  void initState() {
    super.initState();

    getUserModelList();

    selectContractRegion.addListener(() async {
      if (mounted) {
        setState(() {
          loadingFinished = false;
        });

        await getUserModelList();
      }
    });
  }

  Future<void> filterUserDataList(
      String? searchBy, String searchKeyword) async {
    AdminProfileModel? adminProfileModel = ref.read(adminProfileProvider).value;
    List<UserModel?> userDataList = ref.read(userProvider).value ??
        await ref
            .read(userProvider.notifier)
            .initializeUserList(adminProfileModel!.subdistrictId);

    List<UserModel> filterList = [];
    if (searchBy == "name") {
      filterList = userDataList
          .where((element) => element!.name.contains(searchKeyword))
          .cast<UserModel>()
          .toList();
    } else {
      filterList = userDataList
          .where((element) => element!.phone.contains(searchKeyword))
          .cast<UserModel>()
          .toList();
    }

    setState(() {
      _userDataList = filterList;
    });
  }

  List<dynamic> exportToList(UserModel userModel) {
    return [
      userModel.name,
      userModel.userAge,
      userModel.birthYear,
      userModel.gender,
      userModel.phone,
      userModel.fullRegion,
      secondsToStringLine(userModel.createdAt),
      userModel.lastVisit != 0
          ? secondsToStringLine(userModel.lastVisit!)
          : "-",
    ];
  }

  List<List<dynamic>> exportToFullList(List<UserModel?> userDataList) {
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

    final String fileName = "인지케어 회원관리 $formatDate.csv";

    downloadCsv(csvContent, fileName);

    // final encodedUri = Uri.dataFromString(
    //   csvContent,
    //   encoding: Encoding.getByName("utf-8"),
    // ).toString();

    // final anchor = AnchorElement(href: encodedUri)
    //   ..setAttribute('download', fileName)
    //   ..click();
  }

  Future<void> getUserModelList() async {
    List<UserModel?> userDataList = await ref
        .read(userProvider.notifier)
        .initializeUserList(selectContractRegion.value.subdistrictId);

    if (selectContractRegion.value.subdistrictId == "") {
      if (mounted) {
        setState(() {
          loadingFinished = true;
          _userDataList = userDataList;
        });
      }
    } else {
      if (selectContractRegion.value.contractCommunityId != "" &&
          selectContractRegion.value.contractCommunityId != null) {
        final filterDataList = userDataList
            .where((e) =>
                e!.contractCommunityId ==
                selectContractRegion.value.contractCommunityId)
            .toList();
        if (mounted) {
          setState(() {
            loadingFinished = true;
            _userDataList = filterDataList;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            loadingFinished = true;
            _userDataList = userDataList;
          });
        }
      }
    }
  }

  void removeDeleteOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  void showDeleteOverlay(
      BuildContext context, String userId, String userName) async {
    removeDeleteOverlay();

    assert(overlayEntry == null);

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.black54,
          child: Center(
            child: AlertDialog(
              title: Text(
                userName,
                style: const TextStyle(
                  fontSize: Sizes.size20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: Colors.white,
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "정말로 삭제하시겠습니까?",
                    style: TextStyle(
                      fontSize: Sizes.size13,
                    ),
                  ),
                  Text(
                    "삭제하면 다시 되돌릴 수 없습니다.",
                    style: TextStyle(
                      fontSize: Sizes.size13,
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: removeDeleteOverlay,
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.pink.shade100),
                  ),
                  child: Text(
                    "취소",
                    style: TextStyle(
                      fontSize: Sizes.size13,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await ref.read(userRepo).deleteUser(userId);

                    removeDeleteOverlay();
                    setState(() {});
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).primaryColor),
                  ),
                  child: const Text(
                    "삭제",
                    style: TextStyle(
                      fontSize: Sizes.size13,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    Overlay.of(context, debugRequiredFor: widget).insert(overlayEntry!);
  }

  @override
  void dispose() {
    removeDeleteOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return loadingFinished
        ? Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (context) => Scaffold(
                  body: Column(
                    children: [
                      SearchCsv(
                        filterUserList: filterUserDataList,
                        resetInitialList: getUserModelList,
                        generateCsv: generateUserCsv,
                      ),
                      SearchBelow(
                        size: size,
                        child: DataTable2(
                          columns: [
                            DataColumn2(
                              fixedWidth: 50,
                              label: Text(
                                "#",
                                style: TextStyle(
                                  fontSize: tableFontSize,
                                ),
                              ),
                            ),
                            DataColumn2(
                              label: Text(
                                "이름",
                                style: TextStyle(
                                  fontSize: tableFontSize,
                                ),
                              ),
                            ),
                            DataColumn2(
                              fixedWidth: 80,
                              label: Text(
                                "나이",
                                style: TextStyle(
                                  fontSize: tableFontSize,
                                ),
                              ),
                            ),
                            DataColumn2(
                              fixedWidth: 100,
                              label: Text(
                                "출생일",
                                style: TextStyle(
                                  fontSize: tableFontSize,
                                ),
                              ),
                            ),
                            DataColumn2(
                              fixedWidth: 100,
                              label: Text(
                                "성별",
                                style: TextStyle(
                                  fontSize: tableFontSize,
                                ),
                              ),
                            ),
                            DataColumn2(
                              fixedWidth: 160,
                              label: Text(
                                "핸드폰 번호",
                                style: TextStyle(
                                  fontSize: tableFontSize,
                                ),
                              ),
                            ),
                            DataColumn2(
                              fixedWidth: 180,
                              label: Text(
                                "거주 지역",
                                style: TextStyle(
                                  fontSize: tableFontSize,
                                ),
                              ),
                            ),
                            DataColumn2(
                              fixedWidth: 150,
                              onSort: (columnIndex, sortAscending) {
                                if (columnIndex == 7) {
                                  setState(() {
                                    createdAtSort = !createdAtSort;
                                    if (createdAtSort) {
                                      _userDataList.sort((a, b) =>
                                          b!.createdAt.compareTo(a!.createdAt));
                                    } else {
                                      _userDataList.sort((a, b) =>
                                          a!.createdAt.compareTo(b!.createdAt));
                                    }
                                  });
                                }
                              },
                              label: Row(
                                children: [
                                  Text(
                                    "가입일",
                                    style: TextStyle(
                                      fontSize: tableFontSize,
                                    ),
                                  ),
                                  Gaps.h6,
                                  Icon(
                                    createdAtSort
                                        ? Icons.expand_less_rounded
                                        : Icons.expand_more_rounded,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  )
                                ],
                              ),
                            ),
                            DataColumn2(
                              fixedWidth: 160,
                              onSort: (columnIndex, sortAsending) {
                                if (columnIndex == 8) {
                                  setState(() {
                                    lastVisitSort = !lastVisitSort;
                                    if (lastVisitSort) {
                                      _userDataList.sort((a, b) => b!.lastVisit!
                                          .compareTo(a!.lastVisit!));
                                    } else {
                                      _userDataList.sort((a, b) => a!.lastVisit!
                                          .compareTo(b!.lastVisit!));
                                    }
                                  });
                                }
                              },
                              label: Row(
                                children: [
                                  Text(
                                    "마지막 방문일",
                                    style: TextStyle(
                                      fontSize: tableFontSize,
                                    ),
                                  ),
                                  Gaps.h6,
                                  Icon(
                                    lastVisitSort
                                        ? Icons.expand_less_rounded
                                        : Icons.expand_more_rounded,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  )
                                ],
                              ),
                            ),
                            DataColumn2(
                              fixedWidth: 50,
                              label: Text(
                                "삭제",
                                style: TextStyle(
                                  fontSize: tableFontSize,
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
                                      (i + 1).toString(),
                                      style: TextStyle(
                                        fontSize: tableFontSize,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      _userDataList[i]!.name.length > 10
                                          ? "${_userDataList[i]!.name.substring(0, 10)}.."
                                          : _userDataList[i]!.name,
                                      style: TextStyle(
                                        fontSize: tableFontSize,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      _userDataList[i]!.userAge!,
                                      style: TextStyle(
                                        fontSize: tableFontSize,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      _userDataList[i]!.birthYear,
                                      style: TextStyle(
                                        fontSize: tableFontSize,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      _userDataList[i]!.gender,
                                      style: TextStyle(
                                        fontSize: tableFontSize,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      _userDataList[i]!.phone,
                                      style: TextStyle(
                                        fontSize: tableFontSize,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      _userDataList[i]!.fullRegion,
                                      style: TextStyle(
                                        fontSize: tableFontSize,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      secondsToStringLine(
                                          _userDataList[i]!.createdAt),
                                      style: TextStyle(
                                        fontSize: tableFontSize,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      _userDataList[i]!.lastVisit != 0
                                          ? secondsToStringLine(
                                              _userDataList[i]!.lastVisit!)
                                          : "-",
                                      style: TextStyle(
                                        fontSize: tableFontSize,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () => showDeleteOverlay(
                                          context,
                                          _userDataList[i]!.userId,
                                          _userDataList[i]!.name,
                                        ),
                                        child: const Icon(
                                          Icons.delete,
                                          size: Sizes.size16,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          )
        : const SkeletonLoadingScreen();
  }
}

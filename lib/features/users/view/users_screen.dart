import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:onldocc_admin/common/models/contract_notifier.dart';
import 'package:onldocc_admin/common/view/search_below.dart';
import 'package:onldocc_admin/common/view/search_csv.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/features/users/repo/user_repo.dart';
import 'package:onldocc_admin/features/users/view_models/user_view_model.dart';
import 'package:universal_html/html.dart';

class UsersScreen extends ConsumerStatefulWidget {
  static const routeURL = "/users";
  static const routeName = "users";
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  List<UserModel?> _beforeFilterUserDataList = [];

  bool loadingFinished = false;
  final ContractNotifier _contractNotifier = ContractNotifier();

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

  @override
  void initState() {
    super.initState();

    getUserModelList();
    contractNotifier.addListener(() async {
      setState(() {
        loadingFinished = false;
      });
      await getUserModelList();
    });
  }

  void resetInitialState() {
    setState(() {
      _userDataList = _beforeFilterUserDataList;
    });
  }

  void filterUserDataList(String? searchBy, String searchKeyword) {
    final newUserDataList = ref.read(userProvider.notifier).filterTableRows(
          _userDataList,
          searchBy!,
          searchKeyword,
        );

    setState(() {
      _beforeFilterUserDataList = _userDataList;
      _userDataList = newUserDataList;
    });
  }

  List<dynamic> exportToList(UserModel userModel) {
    return [
      userModel.name,
      userModel.age,
      userModel.fullBirthday,
      userModel.gender,
      userModel.phone,
      userModel.fullRegion,
      userModel.registerDate,
      userModel.lastVisit,
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
          csvContent += row[i];
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

    final String fileName = "오늘도청춘 회원관리 $formatDate.csv";

    final encodedUri = Uri.dataFromString(
      csvContent,
      encoding: Encoding.getByName("utf-8"),
    ).toString();
    final anchor = AnchorElement(href: encodedUri)
      ..setAttribute('download', fileName)
      ..click();
  }

  Future<List<UserModel?>> getUserModelList() async {
    List<UserModel?> userDataList =
        await ref.read(userProvider.notifier).getContractUserList();
    if (mounted) {
      setState(() {
        loadingFinished = true;
        _userDataList = userDataList;
      });
    }

    return userDataList;
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
    return AnimatedBuilder(
      animation: contractNotifier,
      builder: (context, child) {
        return loadingFinished
            ? Overlay(
                initialEntries: [
                  OverlayEntry(
                    builder: (context) => Scaffold(
                      body: Column(
                        children: [
                          SearchCsv(
                            filterUserList: filterUserDataList,
                            resetInitialList: resetInitialState,
                            generateCsv: generateUserCsv,
                          ),
                          SearchBelow(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      "#",
                                      style: TextStyle(
                                        fontSize: Sizes.size12,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "이름",
                                      style: TextStyle(
                                        fontSize: Sizes.size12,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "나이",
                                      style: TextStyle(
                                        fontSize: Sizes.size12,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "출생일",
                                      style: TextStyle(
                                        fontSize: Sizes.size12,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "성별",
                                      style: TextStyle(
                                        fontSize: Sizes.size12,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "핸드폰 번호",
                                      style: TextStyle(
                                        fontSize: Sizes.size12,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "거주 지역",
                                      style: TextStyle(
                                        fontSize: Sizes.size12,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "가입일",
                                      style: TextStyle(
                                        fontSize: Sizes.size12,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "마지막 방문일",
                                      style: TextStyle(
                                        fontSize: Sizes.size12,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "삭제",
                                      style: TextStyle(
                                        fontSize: Sizes.size12,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: [
                                  for (var i = 0; i < _userDataList.length; i++)
                                    DataRow(
                                      cells: [
                                        DataCell(
                                          Text(
                                            (i + 1).toString(),
                                            style: const TextStyle(
                                              fontSize: Sizes.size12,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            _userDataList[i]!.name.length > 10
                                                ? "${_userDataList[i]!.name.substring(0, 10)}.."
                                                : _userDataList[i]!.name,
                                            style: const TextStyle(
                                              fontSize: Sizes.size12,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            _userDataList[i]!.age,
                                            style: const TextStyle(
                                              fontSize: Sizes.size12,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            _userDataList[i]!.fullBirthday,
                                            style: const TextStyle(
                                              fontSize: Sizes.size12,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            _userDataList[i]!.gender,
                                            style: const TextStyle(
                                              fontSize: Sizes.size12,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            _userDataList[i]!.phone,
                                            style: const TextStyle(
                                              fontSize: Sizes.size12,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            _userDataList[i]!.fullRegion,
                                            style: const TextStyle(
                                              fontSize: Sizes.size12,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            _userDataList[i]!.registerDate,
                                            style: const TextStyle(
                                              fontSize: Sizes.size12,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            _userDataList[i]!.lastVisit!,
                                            style: const TextStyle(
                                              fontSize: Sizes.size12,
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
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              )
            : Center(
                child: LoadingAnimationWidget.inkDrop(
                  color: Colors.grey.shade600,
                  size: Sizes.size32,
                ),
              );
      },
    );
  }
}

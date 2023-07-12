import 'dart:convert';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/view/error_screen.dart';
import 'package:onldocc_admin/common/view_models/contract_config_vm.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/users/models/user_model.dart';
import 'package:onldocc_admin/features/users/repo/user_repo.dart';
import 'package:onldocc_admin/features/users/view_models/user_view_model.dart';

class UsersScreen extends ConsumerStatefulWidget {
  static const routeURL = "/users";
  static const routeName = "users";
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final double searchHeight = 35;
  List<UserModel?> _userDataList = [];
  final TextEditingController _searchUserController = TextEditingController();
  String? searchBy = "name";
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<OverlayState> overlayKey = GlobalKey<OverlayState>();
  OverlayEntry? overlayEntry;
  bool _csvHover = false;

  Future<void> getUserModelList(
      String userContractType, String userContractName) async {
    if (_searchUserController.text.isEmpty) {
      if (userContractType == "지역") {
        final userDataList =
            await ref.watch(userRepo).getRegionUserData(userContractName);
        setState(() {
          _userDataList = userDataList;
        });
      } else if (userContractType == "기관") {
        final userDataList =
            await ref.watch(userRepo).getCommunityUserData(userContractName);
        setState(() {
          _userDataList = userDataList;
        });
      } else if (userContractType == "마스터") {
        final userDataList = await ref.watch(userRepo).getAllUserData();
        setState(() {
          _userDataList = userDataList;
        });
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

  Future<void> searchUserModelList() async {
    final newUserDataList = ref.read(userProvider.notifier).filterTableRows(
          _userDataList,
          searchBy!,
          _searchUserController.text,
        );
    setState(() {
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
      userModel.registerDate
    ];
  }

  List<List<dynamic>> exportToFullList(List<UserModel?> userDataList) {
    List<List<dynamic>> list = [];

    for (var item in userDataList) {
      final itemList = exportToList(item!);
      list.add(itemList);
    }
    list[0] = [
      "이름",
      "나이",
      "출생일",
      "성별",
      "핸드폰 번호",
      "거주 지역",
      "가입일",
    ];
    return list;
  }

  void generateCsv() {
    final csvData = exportToFullList(_userDataList);
    String csvContent = '';
    for (var row in csvData) {
      for (var i = 0; i < row.length; i++) {
        if (row[i].contains(',')) {
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
        "${currentDate.year}-${currentDate.month}-${currentDate.day}";

    final String fileName = "오늘도청춘 회원관리 $formatDate.csv";

    final encodedUri = Uri.dataFromString(
      csvContent,
      encoding: Encoding.getByName("utf-8"),
    ).toString();
    final anchor = AnchorElement(href: encodedUri)
      ..setAttribute('download', fileName)
      ..click();
  }

  @override
  void dispose() {
    removeDeleteOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(contractConfigProvider).when(
          data: (data) {
            final userContractType = data.contractType;
            final userContractName = data.contractName;
            return Overlay(
              initialEntries: [
                OverlayEntry(
                  builder: (context) => Scaffold(
                    body: FutureBuilder(
                      future:
                          getUserModelList(userContractType, userContractName),
                      builder: (context, snapshot) {
                        return Column(
                          children: [
                            Container(
                              height: searchHeight + Sizes.size40,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: Sizes.size10,
                                  horizontal: Sizes.size32,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          Container(
                                            height: searchHeight,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                Sizes.size4,
                                              ),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton(
                                                value: searchBy,
                                                focusColor: Colors.white,
                                                dropdownColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: Sizes.size10,
                                                ),
                                                items: const [
                                                  DropdownMenuItem(
                                                    alignment:
                                                        AlignmentDirectional
                                                            .centerStart,
                                                    value: "name",
                                                    child: Text(
                                                      "이름",
                                                      style: TextStyle(
                                                        fontSize: Sizes.size13,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ),
                                                  DropdownMenuItem(
                                                    alignment:
                                                        AlignmentDirectional
                                                            .centerStart,
                                                    value: "phone",
                                                    child: Text(
                                                      "핸드폰 번호",
                                                      style: TextStyle(
                                                        fontSize: Sizes.size13,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                onChanged: (value) {
                                                  setState(() {
                                                    searchBy = value;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                          Gaps.h20,
                                          SizedBox(
                                            width: 250,
                                            height: searchHeight,
                                            child: TextFormField(
                                              onFieldSubmitted: (value) =>
                                                  searchUserModelList(),
                                              controller: _searchUserController,
                                              textAlignVertical:
                                                  TextAlignVertical.center,
                                              style: const TextStyle(
                                                fontSize: Sizes.size14,
                                                color: Colors.black87,
                                              ),
                                              decoration: InputDecoration(
                                                prefixIcon: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.search_outlined,
                                                      size: Sizes.size16,
                                                      color:
                                                          Colors.grey.shade400,
                                                    )
                                                  ],
                                                ),
                                                hintText: searchBy == "name"
                                                    ? "회원 이름을 검색해주세요."
                                                    : "핸드폰 번호를 검색해주세요.",
                                                hintStyle: TextStyle(
                                                  fontSize: Sizes.size13,
                                                  color: Colors.grey.shade400,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                                filled: true,
                                                fillColor: Colors.grey.shade50,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    Sizes.size3,
                                                  ),
                                                ),
                                                errorStyle: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    Sizes.size3,
                                                  ),
                                                  borderSide: BorderSide(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    Sizes.size3,
                                                  ),
                                                  borderSide: BorderSide(
                                                    color: Colors.grey.shade300,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    Sizes.size3,
                                                  ),
                                                  borderSide: BorderSide(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: Sizes.size20,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Gaps.h20,
                                          GestureDetector(
                                            onTap: searchUserModelList,
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 2),
                                              child: Container(
                                                width: 70,
                                                height: searchHeight,
                                                decoration: BoxDecoration(
                                                  color: _searchUserController
                                                          .text.isEmpty
                                                      ? Colors.grey.shade300
                                                      : Theme.of(context)
                                                          .primaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    Sizes.size3,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    "검색",
                                                    style: TextStyle(
                                                      color:
                                                          _searchUserController
                                                                  .text.isEmpty
                                                              ? Colors.black87
                                                              : Colors.white,
                                                      fontSize: Sizes.size13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          onHover: (event) {
                                            setState(() {
                                              _csvHover = true;
                                            });
                                          },
                                          onExit: (event) {
                                            setState(() {
                                              _csvHover = false;
                                            });
                                          },
                                          child: GestureDetector(
                                            onTap: generateCsv,
                                            child: Container(
                                              width: 150,
                                              height: searchHeight,
                                              decoration: BoxDecoration(
                                                color: _csvHover
                                                    ? Colors.grey.shade200
                                                    : Colors.white,
                                                border: Border.all(
                                                  color: Colors.grey.shade800,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  Sizes.size10,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "CSV 다운로드",
                                                  style: TextStyle(
                                                    color: Colors.grey.shade800,
                                                    fontSize: Sizes.size14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, constraints) => Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                  ),
                                  child: SingleChildScrollView(
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: Sizes.size32,
                                        ),
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minWidth: constraints.maxWidth,
                                          ),
                                          child: DataTable(
                                            columns: const [
                                              DataColumn(
                                                label: Text("이름"),
                                              ),
                                              DataColumn(
                                                label: Text("나이"),
                                              ),
                                              DataColumn(
                                                label: Text("출생일"),
                                              ),
                                              DataColumn(
                                                label: Text("성별"),
                                              ),
                                              DataColumn(
                                                label: Text("핸드폰 번호"),
                                              ),
                                              DataColumn(
                                                label: Text("거주 지역"),
                                              ),
                                              DataColumn(
                                                label: Text("가입일"),
                                              ),
                                              DataColumn(
                                                label: Text("삭제"),
                                              ),
                                            ],
                                            rows: [
                                              for (var userML in _userDataList)
                                                if (userML!.name != "탈퇴자")
                                                  DataRow(
                                                    cells: [
                                                      DataCell(
                                                        Text(userML.name),
                                                      ),
                                                      DataCell(
                                                        Text(userML.age),
                                                      ),
                                                      DataCell(
                                                        Text(userML
                                                            .fullBirthday),
                                                      ),
                                                      DataCell(
                                                        Text(userML.gender),
                                                      ),
                                                      DataCell(
                                                        Text(userML.phone),
                                                      ),
                                                      DataCell(
                                                        Text(userML.fullRegion),
                                                      ),
                                                      DataCell(
                                                        Text(userML
                                                            .registerDate),
                                                      ),
                                                      DataCell(
                                                        MouseRegion(
                                                          cursor:
                                                              SystemMouseCursors
                                                                  .click,
                                                          child:
                                                              GestureDetector(
                                                            onTap: () =>
                                                                showDeleteOverlay(
                                                                    context,
                                                                    userML
                                                                        .userId,
                                                                    userML
                                                                        .name),
                                                            child: const Icon(
                                                              Icons.delete,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                )
              ],
            );
          },
          error: (error, stackTrace) => const ErrorScreen(),
          loading: () => CircularProgressIndicator.adaptive(
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
  }
}

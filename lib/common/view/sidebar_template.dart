import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/repo/contract_config_repo.dart';
import 'package:onldocc_admin/common/view_models/contract_config_vm.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';

class SidebarTemplate extends ConsumerStatefulWidget {
  final int selectedMenuURL;
  final Widget child;

  const SidebarTemplate({
    super.key,
    required this.selectedMenuURL,
    required this.child,
  });

  @override
  ConsumerState<SidebarTemplate> createState() => _SidebarTemplateState();
}

class _SidebarTemplateState extends ConsumerState<SidebarTemplate> {
  final unselectedColor = Colors.black54;
  int _selectedMenu = 0;
  final contractTypeController = TextEditingController();
  final contractNameController = TextEditingController();

  List<String> _contractItems = [""];

  void setMenu() {
    setState(() {
      _selectedMenu = menuNotifier.selectedMenu;
    });
  }

  void setContractType(String value) async {
    contractNameController.text = "";
    ref.read(contractConfigProvider.notifier).setContractType(value);
    if (value == "지역") {
      final regionItems = await ref.read(contractRepo).getRegionItems();
      setState(() {
        _contractItems = regionItems!;
      });
    } else if (value == "기관") {
      final communityItems = await ref.read(contractRepo).getCommunityItems();
      setState(() {
        _contractItems = communityItems!;
      });
    }
  }

  void setContractName(String value) async {
    ref.read(contractConfigProvider.notifier).setContractName(value);
  }

  @override
  void initState() {
    super.initState();
    _selectedMenu = widget.selectedMenuURL;
    // _selectedMenu = menuNotifier.selectedMenu;
    menuNotifier.addListener(setMenu);
  }

  @override
  void dispose() {
    menuNotifier.removeListener(setMenu);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(adminProfileProvider).when(
          data: (data) {
            final profileRegion =
                data.master ? "마스터 계정" : "${data.region} ${data.smallRegion}";
            final size = MediaQuery.of(context).size;
            return Scaffold(
              body: Row(
                children: [
                  Drawer(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.zero,
                      ),
                    ),
                    child: Container(
                      color: const Color(0xFFF7FAFC),
                      width: size.width * 0.3,
                      height: size.height,
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView(
                              padding: EdgeInsets.zero,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: Sizes.size20,
                                      horizontal: Sizes.size14,
                                    ),
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          foregroundImage:
                                              NetworkImage(data.regionImage),
                                        ),
                                        Gaps.v20,
                                        Text(
                                          profileRegion,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (data.master)
                                          Column(
                                            children: [
                                              Gaps.v20,
                                              CustomDropdown(
                                                onChanged: setContractType,
                                                hintText: "지역 / 기관",
                                                hintStyle: const TextStyle(
                                                  fontSize: Sizes.size14,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                listItemStyle: const TextStyle(
                                                  fontSize: Sizes.size14,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                selectedStyle: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: Sizes.size14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                items: const ["지역", "기관"],
                                                controller:
                                                    contractTypeController,
                                              ),
                                              Gaps.v20,
                                              CustomDropdown(
                                                onChanged: setContractName,
                                                hintText: "세부 선택",
                                                hintStyle: const TextStyle(
                                                  fontSize: Sizes.size14,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                listItemStyle: const TextStyle(
                                                  fontSize: Sizes.size14,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                selectedStyle: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: Sizes.size14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                items: _contractItems,
                                                controller:
                                                    contractNameController,
                                              )
                                            ],
                                          )
                                      ],
                                    ),
                                  ),
                                ),
                                Gaps.v20,
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: Sizes.size4,
                                    horizontal: Sizes.size24,
                                  ),
                                  leading: Icon(
                                    _selectedMenu == 0
                                        ? Icons.emoji_people
                                        : Icons.emoji_people_outlined,
                                    size: Sizes.size20,
                                    color: _selectedMenu == 0
                                        ? Colors.black
                                        : unselectedColor,
                                  ),
                                  title: Text(
                                    "회원 관리",
                                    style: TextStyle(
                                      fontSize: Sizes.size16,
                                      fontWeight: FontWeight.w500,
                                      color: _selectedMenu == 0
                                          ? Theme.of(context).primaryColor
                                          : unselectedColor,
                                    ),
                                  ),
                                  onTap: () =>
                                      menuNotifier.setSelectedMenu(0, context),
                                ),
                                ExpansionTile(
                                  initiallyExpanded: true,
                                  iconColor: unselectedColor,
                                  tilePadding: const EdgeInsets.symmetric(
                                    vertical: Sizes.size4,
                                    horizontal: Sizes.size24,
                                  ),
                                  childrenPadding: const EdgeInsets.only(
                                    left: Sizes.size64,
                                    top: Sizes.size5,
                                    bottom: Sizes.size5,
                                  ),
                                  leading: Icon(
                                    Icons.auto_graph,
                                    size: Sizes.size20,
                                    color: unselectedColor,
                                  ),
                                  title: Text(
                                    "점수 관리",
                                    style: TextStyle(
                                      fontSize: Sizes.size16,
                                      fontWeight: FontWeight.w500,
                                      color: unselectedColor,
                                    ),
                                  ),
                                  children: [
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () => menuNotifier
                                            .setSelectedMenu(1, context),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: Sizes.size10,
                                              ),
                                              child: Text(
                                                "전체 점수",
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  fontWeight: _selectedMenu == 1
                                                      ? FontWeight.w500
                                                      : FontWeight.w400,
                                                  color: _selectedMenu == 1
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : unselectedColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () => menuNotifier
                                            .setSelectedMenu(2, context),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: Sizes.size10,
                                              ),
                                              child: Text(
                                                "회원별 걸음수",
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  fontWeight: _selectedMenu == 2
                                                      ? FontWeight.w500
                                                      : FontWeight.w400,
                                                  color: _selectedMenu == 2
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : unselectedColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () => menuNotifier
                                            .setSelectedMenu(3, context),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: Sizes.size10,
                                              ),
                                              child: Text(
                                                "회원별 일기",
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  fontWeight: _selectedMenu == 3
                                                      ? FontWeight.w500
                                                      : FontWeight.w400,
                                                  color: _selectedMenu == 3
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : unselectedColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: Sizes.size4,
                                    horizontal: Sizes.size24,
                                  ),
                                  leading: Icon(
                                    _selectedMenu == 4
                                        ? Icons.face
                                        : Icons.face_outlined,
                                    size: Sizes.size20,
                                    color: _selectedMenu == 4
                                        ? Colors.black
                                        : unselectedColor,
                                  ),
                                  title: Text(
                                    "감정 관리",
                                    style: TextStyle(
                                      fontSize: Sizes.size16,
                                      fontWeight: FontWeight.w500,
                                      color: _selectedMenu == 4
                                          ? Theme.of(context).primaryColor
                                          : unselectedColor,
                                    ),
                                  ),
                                  onTap: () =>
                                      menuNotifier.setSelectedMenu(4, context),
                                ),
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: Sizes.size4,
                                    horizontal: Sizes.size24,
                                  ),
                                  leading: Icon(
                                    _selectedMenu == 5
                                        ? Icons.event_available
                                        : Icons.event,
                                    size: Sizes.size20,
                                    color: _selectedMenu == 5
                                        ? Colors.black
                                        : unselectedColor,
                                  ),
                                  title: Text(
                                    "행사 관리",
                                    style: TextStyle(
                                      fontSize: Sizes.size16,
                                      fontWeight: FontWeight.w500,
                                      color: _selectedMenu == 5
                                          ? Theme.of(context).primaryColor
                                          : unselectedColor,
                                    ),
                                  ),
                                  onTap: () =>
                                      menuNotifier.setSelectedMenu(5, context),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                bottom: Sizes.size24,
                              ),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    ref
                                        .read(adminProfileProvider.notifier)
                                        .logOut(context);
                                  },
                                  child: Text(
                                    "로그아웃",
                                    style: TextStyle(
                                      fontSize: Sizes.size14,
                                      fontWeight: FontWeight.w500,
                                      color: unselectedColor,
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
                    child: Padding(
                      padding: const EdgeInsets.all(
                        Sizes.size10,
                      ),
                      child: widget.child,
                    ),
                  ),
                ],
              ),
            );
          },
          error: (error, stackTrace) => Text(error.toString()),
          loading: () => const CircularProgressIndicator.adaptive(),
        );
  }
}

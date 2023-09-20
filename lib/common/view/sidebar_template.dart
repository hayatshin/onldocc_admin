import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/models/contract_notifier.dart';
import 'package:onldocc_admin/common/repo/contract_config_repo.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
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
    contractNotifier.changeContractModel(contractType: value);

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
    } else {
      setState(() {
        _contractItems = ["전체"];
      });
    }
  }

  void setContractName(String value) async {
    contractNotifier.changeContractModel(contractName: value);
  }

  @override
  void initState() {
    super.initState();
    _selectedMenu = widget.selectedMenuURL;
    menuNotifier.addListener(setMenu);
  }

  @override
  void dispose() {
    menuNotifier.removeListener(setMenu);
    contractTypeController.dispose();
    contractNameController.dispose();

    super.dispose();
  }

  Future<AdminProfileModel> _initializeAuthProfile() async {
    AdminProfileModel adminProfile =
        await ref.read(adminProfileProvider.notifier).getAdminProfile();

    return adminProfile;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return FutureBuilder(
      future: _initializeAuthProfile(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          return Scaffold(
            body: Row(
              children: [
                SizedBox(
                  width: 270,
                  child: Drawer(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.zero,
                      ),
                    ),
                    child: Container(
                      width: size.width * 0.3,
                      height: size.height,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FAFC),
                        border: Border(
                          right: BorderSide(
                            color: Colors.grey.shade200,
                          ),
                        ),
                      ),
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
                                        color: Colors.grey.shade200,
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
                                          data.contractName,
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
                                                onChanged: (value) =>
                                                    setContractType(value),
                                                hintText: "지역 / 기관 선택",
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
                                                items: const ["전체", "지역", "기관"],
                                                controller:
                                                    contractTypeController,
                                              ),
                                              Gaps.v20,
                                              CustomDropdown(
                                                onChanged: (value) =>
                                                    setContractName(value),
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
                                    horizontal: Sizes.size24,
                                  ),
                                  leading: Icon(
                                    _selectedMenu == 0
                                        ? Icons.emoji_people_rounded
                                        : Icons.accessibility_new_rounded,
                                    size: Sizes.size20,
                                    color: _selectedMenu == 0
                                        ? Colors.black
                                        : unselectedColor,
                                  ),
                                  title: Text(
                                    "회원 관리",
                                    style: TextStyle(
                                      fontSize: Sizes.size15,
                                      fontWeight: FontWeight.w600,
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
                                      fontSize: Sizes.size15,
                                      fontWeight: FontWeight.w600,
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
                                                  fontSize: Sizes.size14,
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
                                                  fontSize: Sizes.size14,
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
                                                  fontSize: Sizes.size14,
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
                                    horizontal: Sizes.size24,
                                  ),
                                  leading: Icon(
                                    _selectedMenu == 4
                                        ? Icons.psychology_rounded
                                        : Icons.psychology_outlined,
                                    size: Sizes.size20,
                                    color: _selectedMenu == 4
                                        ? Colors.black
                                        : unselectedColor,
                                  ),
                                  title: Text(
                                    "회원별 인지 관리",
                                    style: TextStyle(
                                      fontSize: Sizes.size15,
                                      fontWeight: FontWeight.w600,
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
                                    horizontal: Sizes.size24,
                                  ),
                                  leading: Icon(
                                    _selectedMenu == 5
                                        ? Icons.event_available_rounded
                                        : Icons.calendar_today_rounded,
                                    size: Sizes.size20,
                                    color: _selectedMenu == 5
                                        ? Colors.black
                                        : unselectedColor,
                                  ),
                                  title: Text(
                                    "행사 관리",
                                    style: TextStyle(
                                      fontSize: Sizes.size15,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedMenu == 5
                                          ? Theme.of(context).primaryColor
                                          : unselectedColor,
                                    ),
                                  ),
                                  onTap: () =>
                                      menuNotifier.setSelectedMenu(5, context),
                                ),
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: Sizes.size24,
                                  ),
                                  leading: Icon(
                                    _selectedMenu == 6
                                        ? Icons.ondemand_video_rounded
                                        : Icons.tv_rounded,
                                    size: Sizes.size20,
                                    color: _selectedMenu == 6
                                        ? Colors.black
                                        : unselectedColor,
                                  ),
                                  title: Text(
                                    "청춘테레비 관리",
                                    style: TextStyle(
                                      fontSize: Sizes.size15,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedMenu == 6
                                          ? Theme.of(context).primaryColor
                                          : unselectedColor,
                                    ),
                                  ),
                                  onTap: () =>
                                      menuNotifier.setSelectedMenu(6, context),
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
                ),
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        return Container();
      },
    );
  }
}

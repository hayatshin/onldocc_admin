import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/models/contract_notifier.dart';
import 'package:onldocc_admin/common/models/contract_region_model.dart';
import 'package:onldocc_admin/common/repo/contract_config_repo.dart';
import 'package:onldocc_admin/common/view_models/contract_config_view_model.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';

const unselectedColor = Colors.black54;

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
  final contractTypeController = TextEditingController();
  final contractNameController = TextEditingController();
  final menuFontSize = Sizes.size12;

  List<ContractRegionModel> _contractItems = [ContractRegionModel.empty()];

  void setContractType(String value) async {
    if (value == "지역") {
      contractNameController.clear();

      final regionItems =
          await ref.read(contractConfigProvider.notifier).getRegionItems();

      setState(() {
        _contractItems = regionItems;
      });
    } else if (value == "기관") {
      contractNameController.clear();

      // final communityItems = await ref.read(contractRepo).getCommunityItems();
      // setState(() {
      //   _contractItems = communityItems!;
      // });
    } else {
      contractNameController.clear();
      selectContractRegion.value = ContractRegionModel.empty();

      setState(() {
        _contractItems = [ContractRegionModel.empty()];
      });
    }
  }

  void setContractName(String value) async {
    // contractNotifier.changeContractModel(contractName: value);
    selectContractRegion.value =
        _contractItems.firstWhere((element) => element.name == value);
  }

  @override
  void dispose() {
    contractTypeController.dispose();
    contractNameController.dispose();

    super.dispose();
  }

  Future<AdminProfileModel?> _initializeAuthProfile() async {
    // AdminProfileModel? adminProfile = ref.read(adminProfileProvider).value;
    AdminProfileModel? adminProfile =
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
          print("sidebar -> $data");
          return Scaffold(
            body: Row(
              children: [
                SizedBox(
                  width: size.width * 0.17,
                  child: Drawer(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.zero,
                      ),
                    ),
                    child: Container(
                      width: size.width * 0.2,
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
                                      vertical: Sizes.size14,
                                      horizontal: Sizes.size14,
                                    ),
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          foregroundImage:
                                              NetworkImage(data.image),
                                        ),
                                        Gaps.v14,
                                        Text(
                                          data.name,
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
                                                hintStyle: TextStyle(
                                                  fontSize: menuFontSize,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                listItemStyle: TextStyle(
                                                  fontSize: menuFontSize,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                selectedStyle: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: menuFontSize,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                items: const ["전체", "지역", "기관"],
                                                controller:
                                                    contractTypeController,
                                              ),
                                              Gaps.v5,
                                              CustomDropdown(
                                                onChanged: (value) =>
                                                    setContractName(value),
                                                hintText: "세부 선택",
                                                hintStyle: TextStyle(
                                                  fontSize: menuFontSize,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                listItemStyle: TextStyle(
                                                  fontSize: menuFontSize,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                selectedStyle: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: menuFontSize,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                items: _contractItems
                                                    .map((e) => e.name)
                                                    .toList(),
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
                                SingleSidebarTile(
                                  selected: menuNotifier.selectedMenu == 0,
                                  selectedIcon: Icons.emoji_people_rounded,
                                  unselectedIcon:
                                      Icons.accessibility_new_rounded,
                                  title: "회원 관리",
                                  action: () =>
                                      menuNotifier.setSelectedMenu(0, context),
                                ),
                                const ParentSidebarTile(
                                  icon: Icons.auto_graph,
                                  title: "점수 관리",
                                  children: [
                                    "전체 점수",
                                    "회원별 걸음수",
                                    "회원별 일기",
                                  ],
                                  standardIndex: 1,
                                ),
                                const ParentSidebarTile(
                                  icon: Icons.psychology_rounded,
                                  title: "회원별 인지 관리",
                                  children: [
                                    "문제 풀기",
                                    "온라인 치매 검사",
                                    "노인 우울척도 검사"
                                  ],
                                  standardIndex: 4,
                                ),
                                SingleSidebarTile(
                                  selected: menuNotifier.selectedMenu == 7,
                                  selectedIcon: Icons.event_available_rounded,
                                  unselectedIcon: Icons.calendar_today_rounded,
                                  title: "행사 관리",
                                  action: () =>
                                      menuNotifier.setSelectedMenu(7, context),
                                ),
                                SingleSidebarTile(
                                  selected: menuNotifier.selectedMenu == 8,
                                  selectedIcon: Icons.ondemand_video_rounded,
                                  unselectedIcon: Icons.tv_rounded,
                                  title: "재밌는 테레비 관리",
                                  action: () =>
                                      menuNotifier.setSelectedMenu(8, context),
                                ),
                                Gaps.v40,
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: Sizes.size24,
                              ),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    ref
                                        .read(adminProfileProvider.notifier)
                                        .logOut(context);
                                  },
                                  child: const Text(
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

class SingleSidebarTile extends StatelessWidget {
  final bool selected;
  final IconData selectedIcon;
  final IconData unselectedIcon;
  final String title;
  final void Function() action;
  const SingleSidebarTile({
    super.key,
    required this.selected,
    required this.selectedIcon,
    required this.unselectedIcon,
    required this.title,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Sizes.size24,
      ),
      leading: Icon(
        selected ? selectedIcon : unselectedIcon,
        size: Sizes.size20,
        color: selected ? Colors.black : unselectedColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: Sizes.size14,
          fontWeight: FontWeight.w600,
          color: selected ? Theme.of(context).primaryColor : unselectedColor,
        ),
      ),
      onTap: action,
    );
  }
}

class ParentSidebarTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final List<String> children;
  final int standardIndex;

  const ParentSidebarTile({
    super.key,
    required this.icon,
    required this.title,
    required this.children,
    required this.standardIndex,
  });

  @override
  State<ParentSidebarTile> createState() => _ParentSidebarTileState();
}

class _ParentSidebarTileState extends State<ParentSidebarTile> {
  int _selectedMenu = 0;

  @override
  void initState() {
    super.initState();
    menuNotifier.addListener(() {
      if (mounted) {
        setState(() {
          _selectedMenu = menuNotifier.selectedMenu;
        });
      }
    });
  }

  @override
  void dispose() {
    // menuNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
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
        widget.icon,
        size: Sizes.size20,
        color: unselectedColor,
      ),
      title: Text(
        widget.title,
        style: const TextStyle(
          fontSize: Sizes.size14,
          fontWeight: FontWeight.w600,
          color: unselectedColor,
        ),
      ),
      children: [
        for (int i = 0; i < widget.children.length; i++)
          ChildSidebarTile(
            selected: _selectedMenu == i + widget.standardIndex,
            title: widget.children[i],
            action: () =>
                menuNotifier.setSelectedMenu(i + widget.standardIndex, context),
          ),
      ],
    );
  }
}

class ChildSidebarTile extends StatelessWidget {
  final bool selected;
  final String title;
  final void Function() action;
  const ChildSidebarTile({
    super.key,
    required this.selected,
    required this.title,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: action,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: Sizes.size10,
              ),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: Sizes.size13,
                  fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                  color: selected
                      ? Theme.of(context).primaryColor
                      : unselectedColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

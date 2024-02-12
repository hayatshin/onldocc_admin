import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/models/contract_region_model.dart';
import 'package:onldocc_admin/common/view_models/contract_config_view_model.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:skeletons/skeletons.dart';

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
  final contractRegionController = TextEditingController();
  final contractCommunityController = TextEditingController();
  final menuFontSize = Sizes.size12;
  AdminProfileModel _adminProfileModel = AdminProfileModel.empty();

  List<ContractRegionModel> _contractRegionItems = [
    ContractRegionModel.empty()
  ];
  List<ContractRegionModel> _contractCommunityItems = [
    ContractRegionModel.empty()
  ];

  Future<void> _initializeAdminMasterSetting() async {
    AdminProfileModel? adminProfileModel =
        ref.read(adminProfileProvider).value ??
            await ref.read(adminProfileProvider.notifier).getAdminProfile();

    selectContractRegion.value = ContractRegionModel(
      name: adminProfileModel!.name,
      subdistrictId: adminProfileModel.subdistrictId,
      contractRegionId: adminProfileModel.contractRegionId,
      image: adminProfileModel.image,
    );

    if (adminProfileModel.master) {
      final regionItems =
          await ref.read(contractConfigProvider.notifier).getRegionItems();

      setState(() {
        _contractRegionItems = [
          ContractRegionModel.empty(),
          ...regionItems,
        ];
      });
    } else {
      final communityItems = await ref
          .read(contractConfigProvider.notifier)
          .getCommunityItems(adminProfileModel.subdistrictId);

      final communityList = [
        ContractRegionModel.total(adminProfileModel.contractRegionId,
            adminProfileModel.subdistrictId),
        ...communityItems
      ];

      communityListValueNotifier.value = communityList;

      setState(() {
        _contractCommunityItems = communityList;
      });
    }

    setState(() {
      _adminProfileModel = adminProfileModel;
    });
  }

  void setContractRegion(String value) async {
    final selectRegion =
        _contractRegionItems.firstWhere((element) => element.name == value);

    final communityItems = await ref
        .read(contractConfigProvider.notifier)
        .getCommunityItems(selectRegion.subdistrictId);

    selectContractRegion.value = selectRegion;

    setState(() {
      _contractCommunityItems = [
        ContractRegionModel.total(
            selectRegion.contractRegionId!, selectRegion.subdistrictId),
        ...communityItems
      ];
    });
  }

  void setContractCommunity(String value) async {
    selectContractRegion.value =
        _contractCommunityItems.firstWhere((element) => element.name == value);
  }

  @override
  void initState() {
    super.initState();

    _initializeAdminMasterSetting();
  }

  @override
  void dispose() {
    contractRegionController.dispose();
    contractCommunityController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
                                  Container(
                                    width: 48,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    child: Image.network(
                                      _adminProfileModel.image,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return const SkeletonAvatar(
                                          style: SkeletonAvatarStyle(
                                            shape: BoxShape.circle,
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, exception, stackTrace) {
                                        return const SkeletonAvatar(
                                          style: SkeletonAvatarStyle(
                                            shape: BoxShape.circle,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Gaps.v14,
                                  Text(
                                    _adminProfileModel.name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Gaps.v20,
                                  if (_adminProfileModel.master)
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "---- 지역 선택 ----",
                                              style: TextStyle(
                                                  fontSize: menuFontSize,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.blueGrey),
                                            ),
                                          ],
                                        ),
                                        Gaps.v5,
                                        CustomDropdown(
                                          onChanged: (value) =>
                                              setContractRegion(value),
                                          hintText: "지역 선택",
                                          decoration: CustomDropdownDecoration(
                                            hintStyle: TextStyle(
                                              fontSize: menuFontSize,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            listItemStyle: TextStyle(
                                              fontSize: menuFontSize,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          items: _contractRegionItems
                                              .map((e) => e.name)
                                              .toList(),
                                          // controller: contractRegionController,
                                          excludeSelected: false,
                                          initialItem:
                                              _contractRegionItems[0].name,
                                        ),
                                        Gaps.v5,
                                      ],
                                    ),
                                  Gaps.v10,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "---- 기관 선택 ----",
                                        style: TextStyle(
                                            fontSize: menuFontSize,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.blueGrey),
                                      ),
                                    ],
                                  ),
                                  Gaps.v5,
                                  CustomDropdown(
                                    onChanged: (value) =>
                                        setContractCommunity(value),
                                    decoration: CustomDropdownDecoration(
                                      listItemStyle: TextStyle(
                                        fontSize: menuFontSize,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    items: _contractCommunityItems
                                        .map((e) => e.name)
                                        .toList(),
                                    initialItem:
                                        _contractCommunityItems[0].name,
                                    // controller: contractCommunityController,
                                    excludeSelected: false,
                                  )
                                ],
                              ),
                            ),
                          ),
                          Gaps.v20,
                          SingleSidebarTile(
                            selected: menuNotifier.selectedMenu == 0,
                            selectedIcon: Icons.emoji_people_rounded,
                            unselectedIcon: Icons.accessibility_new_rounded,
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
                            children: ["문제 풀기", "온라인 치매 검사", "노인 우울척도 검사"],
                            standardIndex: 4,
                          ),
                          SingleSidebarTile(
                            selected: menuNotifier.selectedMenu == 7,
                            selectedIcon: Icons.notifications_active,
                            unselectedIcon: Icons.notifications_none,
                            title: "공지 관리",
                            action: () =>
                                menuNotifier.setSelectedMenu(7, context),
                          ),
                          SingleSidebarTile(
                            selected: menuNotifier.selectedMenu == 8,
                            selectedIcon: Icons.event_available_rounded,
                            unselectedIcon: Icons.calendar_today_rounded,
                            title: "행사 관리",
                            action: () =>
                                menuNotifier.setSelectedMenu(8, context),
                          ),
                          SingleSidebarTile(
                            selected: menuNotifier.selectedMenu == 9,
                            selectedIcon: Icons.ondemand_video_rounded,
                            unselectedIcon: Icons.tv_rounded,
                            title: "재밌는 테레비 관리",
                            action: () =>
                                menuNotifier.setSelectedMenu(9, context),
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

final communityListValueNotifier = ValueNotifier<List<ContractRegionModel>>([]);

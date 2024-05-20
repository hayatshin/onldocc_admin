import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/models/contract_region_model.dart';
import 'package:onldocc_admin/common/view_models/contract_config_view_model.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/palette.dart';

final unselectedColor = Palette().darkGray;

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

GlobalKey<_SidebarTemplateState> _sidebarKey =
    GlobalKey<_SidebarTemplateState>();

class _SidebarTemplateState extends ConsumerState<SidebarTemplate> {
  final contractRegionController = TextEditingController();
  final contractCommunityController = TextEditingController();
  AdminProfileModel _adminProfileModel = AdminProfileModel.empty();

  List<ContractRegionModel> _contractRegionItems = [
    ContractRegionModel.empty()
  ];
  List<ContractRegionModel> _contractCommunityItems = [
    ContractRegionModel.empty()
  ];
  String _selectRegion = "전체";
  String _selectCommunity = "전체";

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

  void setContractRegion(String? value) async {
    if (value != null) {
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
        _selectRegion = value;
      });
    }
  }

  void setContractCommunity(String? value) async {
    if (value != null) {
      selectContractRegion.value = _contractCommunityItems
          .firstWhere((element) => element.name == value);

      setState(() {
        _selectCommunity = value;
      });
    }
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
      key: _sidebarKey,
      body: Row(
        children: [
          Container(
            width: size.width * 0.17,
            color: Colors.white,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: Sizes.size14,
                          horizontal: Sizes.size14,
                        ),
                        child: Column(
                          children: [
                            Gaps.v20,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "인지케어",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: Sizes.size16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Gaps.h5,
                                Image.asset(
                                  "assets/images/icon_line.png",
                                  width: 45,
                                ),
                              ],
                            ),
                            Gaps.v32,
                            Container(
                              decoration: BoxDecoration(
                                color: Palette().bgLightBlue,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 15,
                                ),
                                child: Column(
                                  children: [
                                    if (_adminProfileModel.master)
                                      Column(
                                        children: [
                                          CustomDropdownMenu(
                                            type: "지역",
                                            items: _contractRegionItems.map(
                                                (ContractRegionModel item) {
                                              final lastName =
                                                  item.name.split(' ').last;
                                              return DropdownMenuItem<String>(
                                                value: item.name,
                                                child: Text(
                                                  lastName,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Palette().normalGray,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              );
                                            }).toList(),
                                            value: _selectRegion,
                                            onChangedFunction: (value) =>
                                                setContractRegion(value),
                                          ),
                                          Gaps.v10,
                                        ],
                                      ),
                                    CustomDropdownMenu(
                                      type: "기관",
                                      items: _contractCommunityItems
                                          .map((ContractRegionModel item) {
                                        final lastName =
                                            item.name.split(' ').last;
                                        return DropdownMenuItem<String>(
                                          value: item.name,
                                          child: Text(
                                            lastName,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Palette().normalGray,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                      value: _selectCommunity,
                                      onChangedFunction: (value) =>
                                          setContractCommunity,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gaps.v10,
                      const SingleSidebarTile(
                        index: 0,
                        assetPath: "assets/svg/pie-chart.svg",
                        title: "대시보드",
                      ),
                      const SingleSidebarTile(
                        index: 1,
                        assetPath: "assets/svg/people.svg",
                        title: "회원 관리",
                      ),
                      const SingleSidebarTile(
                        index: 2,
                        assetPath: "assets/svg/user.svg",
                        title: "회원별 데이터",
                      ),
                      const SingleSidebarTile(
                        index: 3,
                        assetPath: "assets/svg/medal-solid.svg",
                        title: "점수 관리",
                      ),
                      const SingleSidebarTile(
                        index: 4,
                        assetPath: "assets/svg/bell.svg",
                        title: "공지 관리",
                      ),
                      const SingleSidebarTile(
                        index: 5,
                        assetPath: "assets/svg/gift-box-with-a-bow.svg",
                        title: "행사 관리",
                      ),
                      ParentSidebarTile(
                        assetPath: "assets/svg/brain.svg",
                        title: "인지 검사 관리",
                        children: [
                          ChildTileModel(
                            index: 6,
                            tileText: "온라인 치매 검사",
                            tileColor: const Color(0xff696EFF),
                          ),
                          ChildTileModel(
                            index: 7,
                            tileText: "노인 우울척도 검사",
                            tileColor: const Color(0xffF8ACFF),
                          ),
                        ],
                      ),
                      ParentSidebarTile(
                        assetPath: "assets/svg/heart.svg",
                        title: "일상 관리",
                        children: [
                          ChildTileModel(
                            index: 8,
                            tileText: "영상 관리",
                            tileColor: const Color(0xffFFBA49),
                          ),
                          ChildTileModel(
                            index: 9,
                            tileText: "보호자 지정",
                            tileColor: const Color(0xff20A39E),
                          ),
                          ChildTileModel(
                            index: 10,
                            tileText: "화풀기",
                            tileColor: const Color(0xffEF5B5B),
                          ),
                        ],
                      ),
                      const SingleSidebarTile(
                        index: 11,
                        assetPath: "assets/svg/paper-plane.svg",
                        title: "친구 초대 관리",
                      ),
                      Gaps.v20,
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: Sizes.size24,
                      horizontal: Sizes.size20,
                    ),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          ref
                              .read(adminProfileProvider.notifier)
                              .logOut(context);
                        },
                        child: Row(
                          children: [
                            ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                Palette().darkPurple,
                                BlendMode.srcIn,
                              ),
                              child: SvgPicture.asset(
                                "assets/svg/sign-out.svg",
                                width: 15,
                              ),
                            ),
                            Gaps.h10,
                            Text(
                              "로그아웃",
                              style: TextStyle(
                                fontSize: Sizes.size12,
                                fontWeight: FontWeight.w800,
                                color: Palette().darkPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: menuList[menuNotifier.selectedMenu].child,
          )
        ],
      ),
    );
  }
}

class SingleSidebarTile extends StatelessWidget {
  final int index;
  final String assetPath;
  final String title;
  const SingleSidebarTile({
    super.key,
    required this.index,
    required this.assetPath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: menuNotifier,
      builder: (context, child) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => context.goNamed(menuList[index].routeName),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: 5,
            ),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: menuNotifier.selectedMenu == index
                    ? Palette().darkPurple
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Row(
                  children: [
                    ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        menuNotifier.selectedMenu == index
                            ? Palette().bgLightBlue
                            : unselectedColor,
                        BlendMode.srcIn,
                      ),
                      child: SvgPicture.asset(
                        assetPath,
                        width: 20,
                      ),
                    ),
                    Gaps.h14,
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: Sizes.size14,
                        fontWeight: FontWeight.w600,
                        color: menuNotifier.selectedMenu == index
                            ? Palette().bgLightBlue
                            : unselectedColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ParentSidebarTile extends StatefulWidget {
  final String assetPath;
  final String title;
  final List<ChildTileModel> children;

  const ParentSidebarTile({
    super.key,
    required this.assetPath,
    required this.title,
    required this.children,
  });

  @override
  State<ParentSidebarTile> createState() => _ParentSidebarTileState();
}

class _ParentSidebarTileState extends State<ParentSidebarTile> {
  bool expanded = true;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: true,
      iconColor: unselectedColor,
      onExpansionChanged: (value) {
        setState(() {
          expanded = value;
        });
      },
      tilePadding: const EdgeInsets.symmetric(
        horizontal: 30,
      ),
      childrenPadding: const EdgeInsets.symmetric(
        horizontal: Sizes.size5,
        vertical: Sizes.size5,
      ),
      leading: ColorFiltered(
        colorFilter: ColorFilter.mode(
          unselectedColor,
          BlendMode.srcIn,
        ),
        child: SvgPicture.asset(
          widget.assetPath,
          width: 20,
        ),
      ),
      title: Text(
        widget.title,
        style: TextStyle(
          fontSize: Sizes.size14,
          fontWeight: FontWeight.w600,
          color: unselectedColor,
        ),
      ),
      trailing: Icon(
        !expanded ? Icons.expand_more_rounded : Icons.expand_less_rounded,
        size: 15,
      ),
      children: [
        for (int i = 0; i < widget.children.length; i++)
          ChildSidebarTile(
            model: widget.children[i],
          ),
      ],
    );
  }
}

class ChildSidebarTile extends StatelessWidget {
  final ChildTileModel model;
  const ChildSidebarTile({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: menuNotifier,
      builder: (context, child) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => context.goNamed(menuList[model.index].routeName),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: menuNotifier.selectedMenu == model.index
                        ? Palette().darkPurple
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 60,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: model.tileColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Gaps.h14,
                        Text(
                          model.tileText,
                          style: TextStyle(
                            fontSize: Sizes.size13,
                            fontWeight: FontWeight.w600,
                            color: menuNotifier.selectedMenu == model.index
                                ? Palette().bgLightBlue
                                : unselectedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final communityListValueNotifier = ValueNotifier<List<ContractRegionModel>>([]);

class CustomDropdownMenu extends StatelessWidget {
  final String type;
  final List<DropdownMenuItem<String>> items;
  final String value;
  final Function(String?) onChangedFunction;
  const CustomDropdownMenu({
    super.key,
    required this.type,
    required this.items,
    required this.value,
    required this.onChangedFunction,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          type,
          style: TextStyle(
            fontSize: Sizes.size13,
            fontWeight: FontWeight.w700,
            color: Palette().darkPurple,
          ),
        ),
        SizedBox(
          width: size.width * 0.1,
          height: 35,
          child: DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              isExpanded: true,
              items: items,
              value: value,
              onChanged: (value) => onChangedFunction(value),
              buttonStyleData: ButtonStyleData(
                padding: const EdgeInsets.only(left: 14, right: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  border: Border.all(
                    color: Palette().lightGray,
                    width: 0.5,
                  ),
                ),
              ),
              iconStyleData: IconStyleData(
                icon: const Icon(
                  Icons.expand_more_rounded,
                ),
                iconSize: 14,
                iconEnabledColor: Palette().normalGray,
                iconDisabledColor: Palette().normalGray,
              ),
              dropdownStyleData: DropdownStyleData(
                elevation: 2,
                width: size.width * 0.1,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                scrollbarTheme: ScrollbarThemeData(
                  radius: const Radius.circular(10),
                  thumbVisibility: MaterialStateProperty.all(true),
                ),
              ),
              menuItemStyleData: const MenuItemStyleData(
                height: 25,
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ChildTileModel {
  final int index;
  final String tileText;
  final Color tileColor;

  ChildTileModel({
    required this.index,
    required this.tileText,
    required this.tileColor,
  });
}

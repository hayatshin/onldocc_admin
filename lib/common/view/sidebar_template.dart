import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/models/contract_region_model.dart';
import 'package:onldocc_admin/common/repo/contract_config_repo.dart';
import 'package:onldocc_admin/common/view_models/contract_config_view_model.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/constants/const.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/login/models/admin_profile_model.dart';
import 'package:onldocc_admin/features/login/view_models/admin_profile_view_model.dart';
import 'package:onldocc_admin/injicare_color.dart';
import 'package:onldocc_admin/injicare_font.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';

const double menuHeight = 50;
const double borderRadius = 13;

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

  bool _enableCognitionQuiz = true;
  bool _enableMedicalFeature = true;

  bool _openCognitionQuizDescription = false;
  bool _openMedicalFeatureDescription = false;

  void _initializeAppFeatures() async {
    AdminProfileModel? adminProfileModel =
        ref.read(adminProfileProvider).value ??
            await ref.read(adminProfileProvider.notifier).getAdminProfile();

    _enableCognitionQuiz = adminProfileModel.hasCognitionQuiz;
    _enableMedicalFeature = adminProfileModel.hasMedicalFeature;
  }

  void _updateCognitionQuiz(bool value) async {
    AdminProfileModel? adminProfileModel =
        ref.read(adminProfileProvider).value ??
            await ref.read(adminProfileProvider.notifier).getAdminProfile();

    setState(() {
      _enableCognitionQuiz = value;
    });
    await ref.read(contractRepo).updateContractRegionSetting(
        adminProfileModel.contractRegionId, "hasCognitionQuiz", value);
    if (!mounted) return;
    showTopCompletingSnackBar(context, "두뇌 문제 풀기 설정이 반영되었습니다");
  }

  void _updateMedicalFeature(bool value) async {
    AdminProfileModel? adminProfileModel =
        ref.read(adminProfileProvider).value ??
            await ref.read(adminProfileProvider.notifier).getAdminProfile();

    setState(() {
      _enableMedicalFeature = value;
    });
    await ref.read(contractRepo).updateContractRegionSetting(
        adminProfileModel.contractRegionId, "hasMedicalFeature", value);
    if (!mounted) return;
    showTopCompletingSnackBar(context, "건강 기능 설정이 반영되었습니다");
  }

  Future<void> _initializeAdminMasterSetting() async {
    AdminProfileModel? adminProfileModel =
        ref.read(adminProfileProvider).value ??
            await ref.read(adminProfileProvider.notifier).getAdminProfile();

    selectContractRegion.value = ContractRegionModel(
      name: adminProfileModel.name,
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
      // 마스터가 아닌 경우
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
        _selectCommunity = "전체";
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
    _initializeAppFeatures();
  }

  @override
  void dispose() {
    contractRegionController.dispose();
    contractCommunityController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: menuNotifier,
      builder: (context, child) {
        return Scaffold(
          key: _sidebarKey,
          body: Row(
            children: [
              Container(
                width: 250,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            Column(
                              children: [
                                Gaps.v32,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                          InjicareColor().primary50,
                                          BlendMode.srcIn),
                                      child: SvgPicture.asset(
                                        "assets/svg/injicare.svg",
                                        width: 30,
                                      ),
                                    ),
                                    Gaps.h10,
                                    Text(
                                      "인지케어",
                                      style: InjicareFont().body01.copyWith(
                                            color: InjicareColor().primary50,
                                          ),
                                    ),
                                  ],
                                ),
                                Gaps.v20,
                                if (!_adminProfileModel.master)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: InjicareColor().primary20,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "지역/기관 기능 설정",
                                            style: InjicareFont()
                                                .label02
                                                .copyWith(
                                                    color: InjicareColor()
                                                        .primary50),
                                          ),
                                          Gaps.v10,
                                          Column(
                                            children: [
                                              RegionFeatureSetting(
                                                setting: "두뇌 문제 풀기",
                                                enableSetting:
                                                    _enableCognitionQuiz,
                                                updateSetting:
                                                    _updateCognitionQuiz,
                                                openDescription:
                                                    _openCognitionQuizDescription,
                                                updateDescription: () {
                                                  setState(() {
                                                    _openCognitionQuizDescription =
                                                        !_openCognitionQuizDescription;
                                                  });
                                                },
                                              ),
                                              if (_openCognitionQuizDescription)
                                                Text(
                                                  "두뇌 문제 풀기 기능을 끄면 사용자는 문제를 풀지 않고도 일기를 작성할 수 있습니다",
                                                  style: InjicareFont()
                                                      .label03
                                                      .copyWith(
                                                          color: InjicareColor()
                                                              .gray70),
                                                )
                                                    .animate()
                                                    .slideY(
                                                        begin: -0.15,
                                                        end: 0,
                                                        duration: Duration(
                                                            milliseconds: 400))
                                                    .fadeIn(
                                                      duration: Duration(
                                                          milliseconds: 300),
                                                    ),
                                              Gaps.v10,
                                              RegionFeatureSetting(
                                                setting: "건강 기능",
                                                enableSetting:
                                                    _enableMedicalFeature,
                                                updateSetting:
                                                    _updateMedicalFeature,
                                                openDescription:
                                                    _openMedicalFeatureDescription,
                                                updateDescription: () {
                                                  setState(() {
                                                    _openMedicalFeatureDescription =
                                                        !_openMedicalFeatureDescription;
                                                  });
                                                },
                                              ),
                                              if (_openMedicalFeatureDescription)
                                                Text(
                                                  "사용자의 건강 메뉴 사용 여부를 설정합니다",
                                                  style: InjicareFont()
                                                      .label03
                                                      .copyWith(
                                                          color: InjicareColor()
                                                              .gray70),
                                                )
                                                    .animate()
                                                    .slideY(
                                                        begin: -0.15,
                                                        end: 0,
                                                        duration: Duration(
                                                            milliseconds: 400))
                                                    .fadeIn(
                                                      duration: Duration(
                                                          milliseconds: 300),
                                                    ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                Gaps.v10,
                                Container(
                                  decoration: BoxDecoration(
                                    color: Palette().lightPurple,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    child: Column(
                                      children: [
                                        if (_adminProfileModel.master)
                                          Column(
                                            children: [
                                              CustomDropdownMenu(
                                                type: "지역",
                                                items: _contractRegionItems,
                                                value: _selectRegion,
                                                onChangedFunction: (value) =>
                                                    setContractRegion(value),
                                              ),
                                              Gaps.v10,
                                            ],
                                          ),
                                        CustomDropdownMenu(
                                          type: "기관",
                                          items: _contractCommunityItems,
                                          value: _selectCommunity,
                                          onChangedFunction: (value) =>
                                              setContractCommunity(value),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Gaps.v20,
                            SingleSidebarTile(
                              index: 0,
                              assetPath: "assets/menu_svg/web-grid.svg",
                              title: "대시보드",
                              selected: menuNotifier.selectedMenu == 0,
                            ),
                            Gaps.v5,
                            SingleSidebarTile(
                              index: 1,
                              assetPath: "assets/menu_svg/people-fill.svg",
                              title: "회원 관리",
                              selected: menuNotifier.selectedMenu == 1,
                            ),
                            Gaps.v5,
                            SingleSidebarTile(
                              index: 2,
                              assetPath: "assets/menu_svg/flag.svg",
                              title: "점수 관리",
                              selected: menuNotifier.selectedMenu == 2,
                            ),
                            Gaps.v5,
                            SingleSidebarTile(
                              index: 3,
                              assetPath: "assets/menu_svg/bell-fill.svg",
                              title: "공지 관리",
                              selected: menuNotifier.selectedMenu == 3,
                            ),
                            Gaps.v5,
                            SingleSidebarTile(
                              index: 4,
                              assetPath: "assets/menu_svg/box-fill.svg",
                              title: "행사 관리",
                              selected: menuNotifier.selectedMenu == 4,
                            ),
                            if (_adminProfileModel.master)
                              Column(
                                children: [
                                  Gaps.v5,
                                  ParentSidebarTile(
                                    selected: menuNotifier.selectedMenu == 11 ||
                                        menuNotifier.selectedMenu == 12,
                                    assetPath: "assets/menu_svg/heart-fill.svg",
                                    title: "의료 관리",
                                    children: [
                                      ChildTileModel(
                                        index: 11,
                                        tileText: "건강 상담실",
                                      ),
                                      ChildTileModel(
                                        index: 12,
                                        tileText: "건강 이야기",
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            Gaps.v5,
                            ParentSidebarTile(
                              selected: menuNotifier.selectedMenu == 5 ||
                                  menuNotifier.selectedMenu == 6,
                              assetPath: "assets/menu_svg/head-side.svg",
                              title: "인지 관리",
                              children: [
                                ChildTileModel(
                                  index: 5,
                                  tileText: "일기 문제 풀기",
                                ),
                                ChildTileModel(
                                  index: 6,
                                  tileText: "자가 검사",
                                ),
                              ],
                            ),
                            Gaps.v5,
                            ParentSidebarTile(
                              selected: menuNotifier.selectedMenu == 7 ||
                                  menuNotifier.selectedMenu == 8 ||
                                  menuNotifier.selectedMenu == 9,
                              assetPath: "assets/menu_svg/cup2-fill.svg",
                              title: "일상 관리",
                              children: [
                                ChildTileModel(
                                  index: 7,
                                  tileText: "영상 관리",
                                ),
                                ChildTileModel(
                                  index: 8,
                                  tileText: "보호자 케어",
                                ),
                                ChildTileModel(
                                  index: 9,
                                  tileText: "화풀기",
                                ),
                              ],
                            ),
                            Gaps.v5,
                            SingleSidebarTile(
                              index: 10,
                              assetPath: "assets/menu_svg/telegram-fill.svg",
                              title: "친구 초대",
                              selected: menuNotifier.selectedMenu == 10,
                            ),
                            Gaps.v40,
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 10,
                            bottom: 16,
                            left: 16,
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
                                      InjicareColor().gray80,
                                      BlendMode.srcIn,
                                    ),
                                    child: SvgPicture.asset(
                                      "assets/svg/sign-out.svg",
                                      width: 13,
                                    ),
                                  ),
                                  Gaps.h10,
                                  Text(
                                    "로그아웃",
                                    style: InjicareFont().label02.copyWith(
                                          color: InjicareColor().gray80,
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
              ),
              Expanded(
                child: widget.child,
              )
            ],
          ),
        );
      },
    );
  }
}

class RegionFeatureSetting extends StatelessWidget {
  final String setting;
  final bool enableSetting;
  final Function(bool) updateSetting;
  final bool openDescription;
  final Function() updateDescription;
  const RegionFeatureSetting({
    super.key,
    required this.setting,
    required this.enableSetting,
    required this.updateSetting,
    required this.openDescription,
    required this.updateDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          setting,
          style: TextStyle(
            fontSize: Sizes.size13,
            fontWeight: FontWeight.w700,
            color: InjicareColor().gray90,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Row(
          children: [
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: enableSetting,
                onChanged: updateSetting,
                activeTrackColor: Colors.transparent,
                inactiveThumbColor: InjicareColor().gray80,
                activeColor: InjicareColor().primary50,
                inactiveTrackColor: Colors.transparent,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                trackOutlineColor: WidgetStateProperty.resolveWith(
                  (states) {
                    if (states.contains(WidgetState.selected)) {
                      return InjicareColor().primary50;
                    }
                    return InjicareColor().gray80;
                  },
                ),
              ),
            ),
            Gaps.h5,
            gestureDetectorWithMouseClick(
              function: updateDescription,
              child: Icon(
                !openDescription
                    ? Icons.expand_more_rounded
                    : Icons.expand_less_rounded,
                size: 14,
                color: Palette().normalGray,
              ),
            )
          ],
        )
      ],
    );
  }
}

class SingleSidebarTile extends StatelessWidget {
  final int index;
  final String assetPath;
  final String title;
  final bool selected;
  const SingleSidebarTile({
    super.key,
    required this.index,
    required this.assetPath,
    required this.title,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.goNamed(menuList[index].routeName);
        },
        child: Container(
          height: menuHeight,
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFA8C1FF).withOpacity(0.5)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    selected ? InjicareColor().gray100 : InjicareColor().gray80,
                    BlendMode.srcIn,
                  ),
                  child: SvgPicture.asset(
                    assetPath,
                    width: 18,
                  ),
                ),
                Gaps.h14,
                Text(
                  title,
                  style: InjicareFont().body06.copyWith(
                      color: selected
                          ? InjicareColor().gray100
                          : InjicareColor().gray80),
                ),
              ],
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
  final bool selected;

  const ParentSidebarTile({
    super.key,
    required this.assetPath,
    required this.title,
    required this.children,
    required this.selected,
  });

  @override
  State<ParentSidebarTile> createState() => _ParentSidebarTileState();
}

class _ParentSidebarTileState extends State<ParentSidebarTile> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: menuHeight,
          decoration: BoxDecoration(
            color: widget.selected ? Palette().lightPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        widget.selected
                            ? InjicareColor().gray100
                            : InjicareColor().gray80,
                        BlendMode.srcIn,
                      ),
                      child: SvgPicture.asset(
                        widget.assetPath,
                        width: 18,
                      ),
                    ),
                    Gaps.h14,
                    Text(
                      widget.title,
                      style: InjicareFont().body06.copyWith(
                          color: widget.selected
                              ? InjicareColor().gray100
                              : InjicareColor().gray80),
                    ),
                  ],
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        expanded = !expanded;
                      });
                    },
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        InjicareColor().gray70,
                        BlendMode.srcIn,
                      ),
                      child: expanded
                          ? SvgPicture.asset(
                              "assets/svg/arrow-down.svg",
                              width: 10,
                            )
                          : SvgPicture.asset(
                              "assets/svg/arrow-up.svg",
                              width: 10,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          for (int i = 0; i < widget.children.length; i++)
            ChildSidebarTile(
              model: widget.children[i],
              parentSelected: widget.selected,
            ),
      ],
    );
  }
}

class ChildSidebarTile extends StatelessWidget {
  final ChildTileModel model;
  final bool parentSelected;
  const ChildSidebarTile({
    super.key,
    required this.model,
    required this.parentSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 6,
      ),
      child: AnimatedBuilder(
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
                    height: menuHeight,
                    decoration: BoxDecoration(
                      color: menuNotifier.selectedMenu == model.index
                          ? const Color(0xFFA8C1FF).withOpacity(0.5)
                          : parentSelected
                              ? Palette().lightPurple
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            model.tileText,
                            style: TextStyle(
                              fontSize: Sizes.size13,
                              fontWeight: FontWeight.w600,
                              color: menuNotifier.selectedMenu == model.index
                                  ? InjicareColor().gray100
                                  : InjicareColor().gray80,
                            ),
                          ),
                          if (menuNotifier.selectedMenu == model.index)
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: InjicareColor().gray100),
                                ),
                              ],
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
      ),
    );
  }
}

final communityListValueNotifier = ValueNotifier<List<ContractRegionModel>>([]);

class CustomDropdownMenu extends StatelessWidget {
  final String type;
  final List<ContractRegionModel> items;
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
            color: InjicareColor().gray90,
          ),
        ),
        SizedBox(
          width: size.width * 0.1,
          height: buttonHeight,
          child: DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              isExpanded: true,
              items: items.map((ContractRegionModel item) {
                final lastName = item.name.split(' ').last;
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
              value: value,
              onChanged: (value) => onChangedFunction(value),
              buttonStyleData: ButtonStyleData(
                padding: const EdgeInsets.only(left: 14, right: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  border: Border.all(
                    color: InjicareColor().gray20,
                    width: 1,
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
                  thumbVisibility: WidgetStateProperty.all(true),
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

  ChildTileModel({
    required this.index,
    required this.tileText,
  });
}

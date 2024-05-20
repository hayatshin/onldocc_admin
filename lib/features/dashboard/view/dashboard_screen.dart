import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:onldocc_admin/common/view_a/default_screen.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/palette.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  static const routeURL = "/dashboard";
  static const routeName = "dashboard";
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _periodList = ["이번달", "지난달", "이번주", "지난주"];
  String _selectedPeriod = "이번달";

  @override
  Widget build(BuildContext context) {
    return DefaultScreen(
      menu: menuList[0],
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "기간 선택:",
                        style: TextStyle(
                          fontSize: Sizes.size14,
                          color: Palette().darkPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Gaps.h10,
                      PeriodDropdownMenu(
                        items: _periodList.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 12,
                                color: Palette().normalGray,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        value: _selectedPeriod,
                        onChangedFunction: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedPeriod = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  Gaps.h12,
                  Column(
                    children: [
                      Text(
                        "2024/05/01 ~ 2024/05/03",
                        style: TextStyle(
                          color: Palette().darkBlue,
                          fontWeight: FontWeight.w300,
                          fontSize: Sizes.size12,
                        ),
                      ),
                      Gaps.v2,
                    ],
                  ),
                ],
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      width: 1.5,
                      color: Palette().darkPurple,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    child: Row(
                      children: [
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Palette().darkPurple,
                            BlendMode.srcIn,
                          ),
                          child: SvgPicture.asset(
                            "assets/svg/download.svg",
                            width: 13,
                          ),
                        ),
                        Gaps.h10,
                        Text(
                          "리포트 출력하기",
                          style: TextStyle(
                            color: Palette().darkPurple,
                            fontWeight: FontWeight.w600,
                            fontSize: Sizes.size14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
          Gaps.v32,
          Container(
            decoration: BoxDecoration(
              color: Palette().darkPurple,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  HeaderBox(
                    headerText: "누적 회원가입 수",
                    headerColor: Palette().dashPink,
                    data: "820명",
                  ),
                  Container(
                    width: 0.5,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Palette().darkGray,
                    ),
                  ),
                  HeaderBox(
                    headerText: "기간 회원가입 수",
                    headerColor: Palette().dashBlue,
                    data: "122명",
                  ),
                  Container(
                    width: 0.5,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Palette().darkGray,
                    ),
                  ),
                  HeaderBox(
                    headerText: "기간 방문 횟수",
                    headerColor: Palette().dashGreen,
                    data: "2000번",
                  ),
                  Container(
                    width: 0.5,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Palette().darkGray,
                    ),
                  ),
                  HeaderBox(
                    headerText: "기간 방문자 수",
                    headerColor: Palette().dashYellow,
                    data: "153명",
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class HeaderBox extends StatelessWidget {
  final String headerText;
  final Color headerColor;
  final String data;

  const HeaderBox({
    super.key,
    required this.headerText,
    required this.headerColor,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Text(
            headerText,
            style: TextStyle(
              color: headerColor,
              fontSize: Sizes.size12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Gaps.v10,
        Text(
          data,
          style: const TextStyle(
            fontSize: Sizes.size20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class PeriodDropdownMenu extends StatelessWidget {
  final List<DropdownMenuItem<String>> items;
  final String value;
  final Function(String?) onChangedFunction;
  const PeriodDropdownMenu({
    super.key,
    required this.items,
    required this.value,
    required this.onChangedFunction,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
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
              borderRadius: BorderRadius.circular(30),
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
    );
  }
}

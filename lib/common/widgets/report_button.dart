import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/injicare_color.dart';
import 'package:onldocc_admin/injicare_font.dart';

class ReportButton extends StatelessWidget {
  final bool iconExists;
  final String buttonText;
  final Color buttonColor;
  final Function() action;
  const ReportButton({
    super.key,
    required this.iconExists,
    required this.buttonText,
    required this.buttonColor,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: action,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: InjicareColor().gray70),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 7,
            ),
            child: Row(
              children: [
                if (iconExists)
                  Row(
                    children: [
                      ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          InjicareColor().gray90,
                          BlendMode.srcIn,
                        ),
                        child: SvgPicture.asset(
                          "assets/svg/download.svg",
                          width: 13,
                        ),
                      ),
                      Gaps.h10,
                    ],
                  ),
                Text(
                  buttonText,
                  style: InjicareFont()
                      .body07
                      .copyWith(color: InjicareColor().gray90),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

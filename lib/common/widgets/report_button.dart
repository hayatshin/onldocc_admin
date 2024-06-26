import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';

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
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              width: 1.5,
              color: buttonColor,
            ),
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
                          buttonColor,
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
                  style: TextStyle(
                    color: buttonColor,
                    fontWeight: FontWeight.w600,
                    fontSize: Sizes.size14,
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

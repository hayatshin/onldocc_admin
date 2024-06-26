import 'package:flutter/material.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/features/dashboard/view/dashboard_screen.dart';
import 'package:onldocc_admin/palette.dart';

class PeriodButton extends StatefulWidget {
  const PeriodButton({super.key});

  @override
  State<PeriodButton> createState() => _PeriodButtonState();
}

class _PeriodButtonState extends State<PeriodButton> {
  @override
  Widget build(BuildContext context) {
    final periodList = ["이번달", "지난달", "이번주", "지난주"];
    String selectedPeriod = "이번달";

    return Row(
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
          items: periodList.map((String item) {
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
          value: selectedPeriod,
          onChangedFunction: (value) {
            if (value != null) {
              setState(() {
                selectedPeriod = value;
              });
            }
          },
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
    );
  }
}

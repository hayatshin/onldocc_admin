import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';

class PeriodButton extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  const PeriodButton({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<PeriodButton> createState() => _PeriodButtonState();
}

class _PeriodButtonState extends State<PeriodButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        Column(
          children: [
            Text(
              "${periodDateFormat(widget.startDate)} ~ ${periodDateFormat(widget.endDate)}",
              style: TextStyle(
                fontSize: Sizes.size14,
                color: Palette().darkBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
            Gaps.v2,
          ],
        ),
      ],
    );
  }
}

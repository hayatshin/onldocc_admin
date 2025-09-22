import 'package:flutter/material.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/injicare_color.dart';
import 'package:onldocc_admin/injicare_font.dart';
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
          "기간 선택",
          style: InjicareFont().body07.copyWith(color: InjicareColor().gray80),
        ),
        Gaps.h10,
        Column(
          children: [
            Text(
              "${periodDateFormat(widget.startDate)} ~ ${periodDateFormat(widget.endDate)}",
              style: InjicareFont().body06.copyWith(
                    color: InjicareColor().secondary50,
                  ),
            ),
            Gaps.v2,
          ],
        ),
      ],
    );
  }
}

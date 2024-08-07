import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class PeriodButton extends StatefulWidget {
  const PeriodButton({super.key});

  @override
  State<PeriodButton> createState() => _PeriodButtonState();
}

class _PeriodButtonState extends State<PeriodButton> {
  bool selected = false;
  final periodList = ["이번달", "지난달", "이번주", "지난주"];
  String selectedPeriod = "이번달";

  void _selectDateCalendar() {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return SafeArea(
          child: Center(
            child: Transform.translate(
              offset: const Offset(-100, -80),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                clipBehavior: Clip.hardEdge,
                child: SfDateRangePicker(
                  backgroundColor: Colors.white,
                  viewSpacing: 10,
                  headerStyle: const DateRangePickerHeaderStyle(),
                  onSelectionChanged: (dateRangePickerSelectionChangedArgs) {},
                  selectionMode: DateRangePickerSelectionMode.extendableRange,
                  initialSelectedRange: PickerDateRange(
                      DateTime.now().subtract(
                        const Duration(
                          days: 4,
                        ),
                      ),
                      DateTime.now().add(
                        const Duration(
                          days: 3,
                        ),
                      )),
                ),
              ),
            ),
          ),
        );
      },
    );
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _selectDateCalendar,
                child: Column(
                  children: [
                    Text(
                      "2024/05/01 ~ 2024/05/03",
                      style: TextStyle(
                        fontSize: Sizes.size14,
                        color: Palette().darkBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Gaps.v2,
                  ],
                ),
              ),
            ),
          ],
        ),

        // PeriodDropdownMenu(
        //   items: periodList.map((String item) {
        //     return DropdownMenuItem<String>(
        //       value: item,
        //       child: Text(
        //         item,
        //         style: TextStyle(
        //           fontSize: 12,
        //           color: Palette().normalGray,
        //         ),
        //         overflow: TextOverflow.ellipsis,
        //       ),
        //     );
        //   }).toList(),
        //   value: selectedPeriod,
        //   onChangedFunction: (value) {
        //     if (value != null) {
        //       setState(() {
        //         selectedPeriod = value;
        //       });
        //     }
        //   },
        // ),
      ],
    );
  }
}

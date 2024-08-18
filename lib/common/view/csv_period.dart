import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/view/search_period_order.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/utils.dart';

class CsvPeriod extends ConsumerStatefulWidget {
  final void Function() generateCsv;
  final String rankingType;
  final String userName;
  final void Function(DateRange) updateOrderPeriod;
  final TextEditingController sortPeriodControllder;

  const CsvPeriod({
    super.key,
    required this.generateCsv,
    required this.rankingType,
    required this.userName,
    required this.updateOrderPeriod,
    required this.sortPeriodControllder,
  });

  @override
  ConsumerState<CsvPeriod> createState() => _CsvPeriodState();
}

class _CsvPeriodState extends ConsumerState<CsvPeriod> {
  final double searchHeight = 35;
  bool _setCsvHover = false;
  bool _setBackHover = false;

  final DateRange selectedDateRange = DateRange(
    getThisWeekMonday(),
    DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    selectedDateRangeNotifier.value = DateRange(
      getThisWeekMonday(),
      DateTime.now(),
    );
  }

  @override
  void dispose() {
    // widget.sortPeriodControllder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: searchHeight + Sizes.size40,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: Sizes.size10,
          horizontal: Sizes.size32,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onHover: (event) {
                      setState(() {
                        _setBackHover = true;
                      });
                    },
                    onExit: (event) {
                      setState(() {
                        _setBackHover = false;
                      });
                    },
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: CircleAvatar(
                        backgroundColor:
                            _setBackHover ? Colors.grey.shade200 : Colors.white,
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
                Gaps.h40,
                Text(
                  "${widget.userName} 님의 ${widget.rankingType} 데이터",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Gaps.h40,
                SizedBox(
                  width: 200,
                  height: searchHeight,
                  child: DateRangeField(
                    pickerBuilder: datePickerBuilder,
                    decoration: const InputDecoration(
                        // label: Padding(
                        //   padding: const EdgeInsets.only(
                        //     left: Sizes.size10,
                        //   ),
                        //   child: Text(
                        //     daterangeToSlashString(selectedDateRangeNotifier
                        //             .value ??
                        //         DateRange(getThisWeekMonday(), DateTime.now())),
                        //     style: TextStyle(
                        //       fontSize: Sizes.size12,
                        //       color: Colors.grey.shade900,
                        //     ),
                        //   ),
                        // ),
                        ),
                    onDateRangeSelected: (DateRange? value) {
                      selectedDateRangeNotifier.value = value;
                      value == null
                          ? widget.updateOrderPeriod(selectedDateRange)
                          : widget.updateOrderPeriod(value);
                    },
                    selectedDateRange: selectedDateRangeNotifier.value,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onHover: (event) {
                      setState(() {
                        _setCsvHover = true;
                      });
                    },
                    onExit: (event) {
                      setState(() {
                        _setCsvHover = false;
                      });
                    },
                    child: GestureDetector(
                      onTap: widget.generateCsv,
                      child: Container(
                        width: 150,
                        height: searchHeight,
                        decoration: BoxDecoration(
                          color: _setCsvHover
                              ? Colors.grey.shade200
                              : Colors.white,
                          border: Border.all(
                            color: Colors.grey.shade800,
                          ),
                          borderRadius: BorderRadius.circular(
                            Sizes.size10,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "엑셀 다운로드",
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: Sizes.size14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget datePickerBuilder(
        BuildContext context, dynamic Function(DateRange?) onDateRangeChanged,
        [bool doubleMonth = true]) =>
    DateRangePickerWidget(
      height: 350,
      doubleMonth: doubleMonth,
      quickDateRanges: [
        QuickDateRange(dateRange: null, label: "선택 지우기"),
        QuickDateRange(
          label: '이번주',
          dateRange: DateRange(
            getThisWeekMonday(),
            DateTime.now(),
          ),
        ),
        QuickDateRange(
          label: '지난주',
          dateRange: DateRange(
            getThisWeekMonday().subtract(const Duration(days: 7)),
            getLastWeekSunday(),
          ),
        ),
        QuickDateRange(
          label: '이번달',
          dateRange: DateRange(
            getThisMonth1stday(),
            DateTime.now(),
          ),
        ),
        QuickDateRange(
          label: '지난달',
          dateRange: DateRange(
            getLastMonth1stday(),
            getLastMonthLastday(),
          ),
        ),
      ],
      minimumDateRangeLength: 2,
      initialDateRange: DateRange(
        getThisWeekMonday(),
        DateTime.now(),
      ),
      initialDisplayedDate: DateTime.now(),
      onDateRangeChanged: onDateRangeChanged,
    );

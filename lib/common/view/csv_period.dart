import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';

class CsvPeriod extends ConsumerStatefulWidget {
  final void Function() generateCsv;
  final String rankingType;
  final String userName;
  final void Function(String) updateOrderPeriod;
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
  final TextEditingController _sortPeriodControllder = TextEditingController();

  @override
  void dispose() {
    // widget.sortPeriodControllder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: 150,
                  height: searchHeight,
                  child: CustomDropdown(
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(
                      Sizes.size4,
                    ),
                    onChanged: (value) => widget.updateOrderPeriod(value),
                    hintText: "기간 선택",
                    hintStyle: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: Sizes.size14,
                      fontWeight: FontWeight.w400,
                    ),
                    listItemStyle: const TextStyle(
                      fontSize: Sizes.size14,
                      fontWeight: FontWeight.w400,
                    ),
                    selectedStyle: const TextStyle(
                      color: Colors.black87,
                      fontSize: Sizes.size14,
                      fontWeight: FontWeight.w500,
                    ),
                    items: const ["이번주", "이번달"],
                    controller: widget.sortPeriodControllder,
                  ),
                ),
                Gaps.h40,
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
                            "CSV 다운로드",
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';

class Csv extends ConsumerStatefulWidget {
  final void Function() generateCsv;
  final String rankingType;
  final String userName;

  const Csv({
    super.key,
    required this.generateCsv,
    required this.rankingType,
    required this.userName,
  });

  @override
  ConsumerState<Csv> createState() => _CsvState();
}

class _CsvState extends ConsumerState<Csv> {
  final double searchHeight = 35;
  bool _setCsvHover = false;
  bool _setBackHover = false;

  final TextEditingController _sortPeriodControllder = TextEditingController();

  @override
  void dispose() {
    _sortPeriodControllder.dispose();
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

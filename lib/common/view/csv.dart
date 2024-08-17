import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:onldocc_admin/common/view_models/menu_notifier.dart';
import 'package:onldocc_admin/common/widgets/report_button.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/palette.dart';

class Csv extends ConsumerStatefulWidget {
  final void Function() generateCsv;
  final String rankingType;
  final String userName;
  final Menu menu;

  const Csv({
    super.key,
    required this.generateCsv,
    required this.rankingType,
    required this.userName,
    required this.menu,
  });

  @override
  ConsumerState<Csv> createState() => _CsvState();
}

class _CsvState extends ConsumerState<Csv> {
  final double searchHeight = 35;
  final bool _setCsvHover = false;
  final bool _setBackHover = false;

  final TextEditingController _sortPeriodControllder = TextEditingController();

  @override
  void dispose() {
    _sortPeriodControllder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: searchHeight + Sizes.size40,
      // decoration: BoxDecoration(
      //   border: Border(
      //     bottom: BorderSide(
      //       color: widget.menu.colorButton!,
      //     ),
      //   ),
      // ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: Sizes.size10,
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
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: FaIcon(
                        FontAwesomeIcons.solidCircleLeft,
                        color: Palette().darkPurple,
                        size: 35,
                      ),
                    ),
                  ),
                ),
                Gaps.h40,
                if (widget.rankingType != "event")
                  Text(
                    "${widget.userName} 님의 ${widget.rankingType} 데이터",
                    style: TextStyle(
                      color: Palette().darkGray,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                if (widget.rankingType == "event")
                  Text(
                    widget.userName,
                    style: TextStyle(
                      color: Palette().darkGray,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
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
                    child: ReportButton(
                      iconExists: true,
                      buttonText: "CSV 다운로드",
                      buttonColor: Palette().darkPurple,
                      action: widget.generateCsv,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/common/widgets/report_button.dart';
import 'package:onldocc_admin/common/widgets/searchby_dropdown_button.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/palette.dart';

class SearchCsv extends ConsumerStatefulWidget {
  final void Function(String?, String) filterUserList;
  final void Function() resetInitialList;
  final void Function() generateCsv;
  const SearchCsv({
    super.key,
    required this.filterUserList,
    required this.resetInitialList,
    required this.generateCsv,
  });

  @override
  ConsumerState<SearchCsv> createState() => _SearchCsvState();
}

class _SearchCsvState extends ConsumerState<SearchCsv> {
  final TextEditingController _searchUserController = TextEditingController();
  final double searchHeight = 35;
  String _setSearchBy = "이름";

  void submitSearch() {
    if (_searchUserController.text.isEmpty) {
      widget.resetInitialList();
    } else {
      widget.filterUserList(_setSearchBy, _searchUserController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Visibility(
              visible: size.width > 1000,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "검색 기준:",
                          style: TextStyle(
                            color: Palette().darkBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Gaps.h20,
                        SearchByDropdownButton(
                          items: const ["이름", "핸드폰 번호"],
                          value: _setSearchBy,
                          onChangedFunction: (value) {
                            if (value != null) {
                              setState(() {
                                _setSearchBy = value;
                              });
                              _searchUserController.clear();
                            }
                          },
                        ),
                      ],
                    ),
                    Gaps.v16,
                    Row(
                      children: [
                        Container(
                          width: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Palette().lightGray.withOpacity(0.8),
                                spreadRadius: 2,
                                blurRadius: 2,
                                offset: const Offset(1, 1),
                              )
                            ],
                          ),
                          height: searchHeight,
                          child: TextFormField(
                            inputFormatters: _setSearchBy == "핸드폰 번호"
                                ? [MaskedInputFormatter("###-####-####")]
                                : null,
                            onFieldSubmitted: (value) => submitSearch(),
                            controller: _searchUserController,
                            textAlignVertical: TextAlignVertical.center,
                            style: TextStyle(
                              fontSize: Sizes.size14,
                              color: Palette().darkGray,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              prefixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_outlined,
                                    size: 20,
                                    color: Palette().darkBlue,
                                  )
                                ],
                              ),
                              hintText: _setSearchBy == "이름"
                                  ? "회원 이름을 검색해주세요."
                                  : "핸드폰 번호를 검색해주세요.",
                              hintStyle: TextStyle(
                                fontSize: Sizes.size13,
                                color: Palette().darkBlue.withOpacity(0.4),
                                fontWeight: FontWeight.w300,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              focusColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  Sizes.size3,
                                ),
                                borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Palette().darkBlue,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Palette().darkBlue,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: Sizes.size20,
                              ),
                            ),
                          ),
                        ),
                        Gaps.h14,
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: submitSearch,
                            child: Container(
                              width: 70,
                              height: searchHeight,
                              decoration: BoxDecoration(
                                color: Palette().darkBlue,
                                borderRadius: BorderRadius.circular(
                                  Sizes.size10,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  "검색",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: Sizes.size14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: size.width > 500,
              child: Align(
                alignment: Alignment.centerRight,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ReportButton(
                    iconExists: true,
                    buttonText: "엑셀 다운로드",
                    buttonColor: Palette().darkPurple,
                    action: widget.generateCsv,
                  ),
                ),
              ),
            )
          ],
        ),
        Gaps.v40,
      ],
    );
  }
}

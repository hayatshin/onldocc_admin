import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:onldocc_admin/common/widgets/report_button.dart';
import 'package:onldocc_admin/common/widgets/searchby_dropdown_button.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/injicare_color.dart';
import 'package:onldocc_admin/injicare_font.dart';
import 'package:onldocc_admin/palette.dart';

const double searchHeight = 40;

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
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "검색 기준",
                              style: InjicareFont()
                                  .body07
                                  .copyWith(color: InjicareColor().gray80),
                            ),
                            Gaps.h5,
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
                        Gaps.h16,
                        Container(
                          width: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: searchHeight,
                          child: TextFormField(
                            inputFormatters: _setSearchBy == "핸드폰 번호"
                                ? [MaskedInputFormatter("###-####-####")]
                                : null,
                            onFieldSubmitted: (value) => submitSearch(),
                            controller: _searchUserController,
                            textAlignVertical: TextAlignVertical.center,
                            style: InjicareFont().body07.copyWith(
                                  color: InjicareColor().gray80,
                                ),
                            decoration: InputDecoration(
                              hintText: _setSearchBy == "이름"
                                  ? "회원 이름을 검색해주세요."
                                  : "회원 핸드폰 번호를 검색해주세요.",
                              hintStyle: InjicareFont().body07.copyWith(
                                    color: InjicareColor().gray40,
                                  ),
                              filled: true,
                              fillColor: Colors.white,
                              focusColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: InjicareColor().gray20,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: InjicareColor().gray20,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: InjicareColor().gray20,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: InjicareColor().gray20,
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
                              width: searchHeight,
                              height: searchHeight,
                              decoration: BoxDecoration(
                                color: InjicareColor().gray70,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  "assets/svg/search-1.svg",
                                  width: 16,
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
        Gaps.v32,
      ],
    );
  }
}

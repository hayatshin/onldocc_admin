import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';

class SearchPeriod extends ConsumerStatefulWidget {
  final void Function(String?, String) filterUserList;
  final void Function() resetInitialList;
  final String constractType;
  final String contractName;
  final void Function() generateCsv;
  const SearchPeriod({
    super.key,
    required this.filterUserList,
    required this.resetInitialList,
    required this.constractType,
    required this.contractName,
    required this.generateCsv,
  });

  @override
  ConsumerState<SearchPeriod> createState() => _SearchPeriodState();
}

class _SearchPeriodState extends ConsumerState<SearchPeriod> {
  final TextEditingController _searchUserController = TextEditingController();
  final TextEditingController _sortbyController = TextEditingController();

  final double searchHeight = 35;
  String? _setSearchBy = "name";
  bool _setCsvHover = false;
  DateRange? _selectedDateRange;

  void submitSearch() {
    if (_searchUserController.text.isEmpty) {
      widget.resetInitialList();
    } else {
      widget.filterUserList(_setSearchBy, _searchUserController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: searchHeight * 2 + Sizes.size52,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: Sizes.size5,
          horizontal: Sizes.size32,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                        onChanged: (value) {},
                        hintText: "정렬 기준 선택",
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
                        items: const ["종합", "걸음수", "일기", "댓글"],
                        controller: _sortbyController,
                      ),
                    ),
                    Gaps.h14,
                    SizedBox(
                      width: 290,
                      height: searchHeight,
                      child: DateRangeField(
                        decoration: InputDecoration(
                          prefixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: Sizes.size16,
                                color: Colors.grey.shade400,
                              )
                            ],
                          ),
                          hintText: "기간을 선택해주세요.",
                          hintStyle: TextStyle(
                            fontSize: Sizes.size13,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w400,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              Sizes.size3,
                            ),
                          ),
                          errorStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
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
                            borderRadius: BorderRadius.circular(
                              Sizes.size3,
                            ),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              Sizes.size3,
                            ),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: Sizes.size20,
                          ),
                        ),
                        pickerBuilder: (context, onDateRangeChanged) =>
                            DateRangePickerWidget(
                          doubleMonth: true,
                          height: 350,
                          initialDateRange: _selectedDateRange,
                          onDateRangeChanged: onDateRangeChanged,
                        ),
                        onDateRangeSelected: (value) {
                          setState(() {
                            print(value);
                            _selectedDateRange = value;
                          });
                        },
                        selectedDateRange: _selectedDateRange,
                      ),
                    ),
                  ],
                ),
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
            Gaps.v14,
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Container(
                        height: searchHeight,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(
                            Sizes.size4,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            value: _setSearchBy,
                            focusColor: Colors.white,
                            dropdownColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: Sizes.size10,
                            ),
                            items: const [
                              DropdownMenuItem(
                                alignment: AlignmentDirectional.centerStart,
                                value: "name",
                                child: Text(
                                  "이름",
                                  style: TextStyle(
                                    fontSize: Sizes.size13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                alignment: AlignmentDirectional.centerStart,
                                value: "phone",
                                child: Text(
                                  "핸드폰 번호",
                                  style: TextStyle(
                                    fontSize: Sizes.size13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _setSearchBy = value;
                              });
                            },
                          ),
                        ),
                      ),
                      Gaps.h14,
                      SizedBox(
                        width: 250,
                        height: searchHeight,
                        child: TextFormField(
                          onFieldSubmitted: (value) => submitSearch(),
                          controller: _searchUserController,
                          textAlignVertical: TextAlignVertical.center,
                          style: const TextStyle(
                            fontSize: Sizes.size14,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_outlined,
                                  size: Sizes.size16,
                                  color: Colors.grey.shade400,
                                )
                              ],
                            ),
                            hintText: _setSearchBy == "name"
                                ? "회원 이름을 검색해주세요."
                                : "핸드폰 번호를 검색해주세요.",
                            hintStyle: TextStyle(
                              fontSize: Sizes.size13,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w400,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                Sizes.size3,
                              ),
                            ),
                            errorStyle: TextStyle(
                              color: Theme.of(context).primaryColor,
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
                              borderRadius: BorderRadius.circular(
                                Sizes.size3,
                              ),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                Sizes.size3,
                              ),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: Sizes.size20,
                            ),
                          ),
                        ),
                      ),
                      Gaps.h14,
                      GestureDetector(
                        onTap: submitSearch,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 2),
                          child: Container(
                            width: 70,
                            height: searchHeight,
                            decoration: BoxDecoration(
                              color: _searchUserController.text.isEmpty
                                  ? Colors.grey.shade300
                                  : Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(
                                Sizes.size3,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "검색",
                                style: TextStyle(
                                  color: _searchUserController.text.isEmpty
                                      ? Colors.black87
                                      : Colors.white,
                                  fontSize: Sizes.size13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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

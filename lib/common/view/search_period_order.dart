import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';

class SearchPeriodOrder extends ConsumerStatefulWidget {
  final void Function(String?, String) filterUserList;
  final void Function() resetInitialList;
  final void Function() generateCsv;
  final void Function(String) updateOrderStandard;
  final void Function(String) updateOrderPeriod;
  const SearchPeriodOrder({
    super.key,
    required this.filterUserList,
    required this.resetInitialList,
    required this.generateCsv,
    required this.updateOrderStandard,
    required this.updateOrderPeriod,
  });

  @override
  ConsumerState<SearchPeriodOrder> createState() => _SearchPeriodOrderState();
}

class _SearchPeriodOrderState extends ConsumerState<SearchPeriodOrder> {
  final TextEditingController _searchUserController = TextEditingController();
  final TextEditingController _sortbyController = TextEditingController();
  final TextEditingController _sortPeriodControllder = TextEditingController();

  final double searchHeight = 35;
  String? _setSearchBy = "name";
  bool _setCsvHover = false;

  void submitSearch() {
    if (_searchUserController.text.isEmpty) {
      widget.resetInitialList();
    } else {
      widget.filterUserList(_setSearchBy, _searchUserController.text);
    }
  }

  @override
  void dispose() {
    _searchUserController.dispose();
    _sortbyController.dispose();
    _sortPeriodControllder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
                    Visibility(
                      visible: size.width > 1100,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 200,
                            height: searchHeight,
                            child: CustomDropdown(
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(
                                Sizes.size4,
                              ),
                              onChanged: (value) =>
                                  widget.updateOrderStandard(value),
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
                              items: const ["종합 점수", "걸음수", "일기", "댓글"],
                              controller: _sortbyController,
                            ),
                          ),
                          Gaps.h14,
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
                              onChanged: (value) =>
                                  widget.updateOrderPeriod(value),
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
                              items: const ["이번주", "이번달", "지난달"],
                              controller: _sortPeriodControllder,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: size.width > 500,
                  child: Align(
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
                  ),
                )
              ],
            ),
            Gaps.v14,
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility(
                  visible: size.width > 1100,
                  child: Align(
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
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
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
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: size.width > 600,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "점수 계산 방법",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: Sizes.size12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text(
                        "걸음수: 1000보당 10점 (최대 10,000 걸음)",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: Sizes.size11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Text(
                        "일기: 1회 100점 / 댓글 1회 20점",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: Sizes.size11,
                          fontWeight: FontWeight.w400,
                        ),
                      )
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

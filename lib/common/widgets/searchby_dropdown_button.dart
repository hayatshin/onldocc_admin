import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:onldocc_admin/constants/const.dart';
import 'package:onldocc_admin/injicare_color.dart';
import 'package:onldocc_admin/injicare_font.dart';

class SearchByDropdownButton extends StatelessWidget {
  final List<String> items;
  final String value;
  final Function(String?) onChangedFunction;

  const SearchByDropdownButton({
    super.key,
    required this.items,
    required this.value,
    required this.onChangedFunction,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: buttonHeight,
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: InjicareFont().body07.copyWith(
                      color: InjicareColor().gray90,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          value: value,
          onChanged: (value) => onChangedFunction(value),
          buttonStyleData: ButtonStyleData(
            padding: const EdgeInsets.only(left: 10, right: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              border: Border.all(
                color: InjicareColor().gray20,
                width: 1,
              ),
            ),
          ),
          iconStyleData: IconStyleData(
            icon: const Icon(
              Icons.expand_more_rounded,
            ),
            iconSize: 14,
            iconEnabledColor: InjicareColor().gray90,
            iconDisabledColor: InjicareColor().gray90,
          ),
          dropdownStyleData: DropdownStyleData(
            elevation: 0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(10),
              thumbVisibility: WidgetStateProperty.all(true),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 30,
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
            ),
          ),
        ),
      ),
    );
  }
}

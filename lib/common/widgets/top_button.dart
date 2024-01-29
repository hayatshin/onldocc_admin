import 'package:flutter/material.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/constants/const.dart';

class TopButton extends StatefulWidget {
  final String text;
  final Function() actionFunction;
  const TopButton({
    super.key,
    required this.text,
    required this.actionFunction,
  });

  @override
  State<TopButton> createState() => _TopButtonState();
}

class _TopButtonState extends State<TopButton> {
  bool _feedHover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onHover: (event) {
        setState(() {
          _feedHover = true;
        });
      },
      onExit: (event) {
        setState(() {
          _feedHover = false;
        });
      },
      child: GestureDetector(
        onTap: widget.actionFunction,
        child: Container(
          width: 150,
          height: searchHeight,
          decoration: BoxDecoration(
            color: _feedHover ? Colors.grey.shade200 : Colors.white,
            border: Border.all(
              color: Colors.grey.shade800,
            ),
            borderRadius: BorderRadius.circular(
              Sizes.size10,
            ),
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: Sizes.size14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/palette.dart';

class ModalButton extends StatelessWidget {
  final String modalText;
  final Function() modalAction;
  const ModalButton({
    super.key,
    required this.modalText,
    required this.modalAction,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: modalAction,
        child: Container(
          decoration: BoxDecoration(
              color: Palette().lightGreen.withOpacity(0.3),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                width: 1.2,
                color: Palette().darkGreen,
              )),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 8,
            ),
            child: Text(
              modalText,
              style: TextStyle(
                color: Palette().darkGreen,
                fontSize: Sizes.size13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

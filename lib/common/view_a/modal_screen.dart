import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:onldocc_admin/common/widgets/report_button.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:onldocc_admin/palette.dart';

class ModalScreen extends StatelessWidget {
  final Size size;
  final Widget child;
  final String modalTitle;
  final String modalButtonOneText;
  final Function() modalButtonOneFunction;
  final String? modalButtonTwoText;
  final Function()? modalButtonTwoFunction;
  const ModalScreen({
    super.key,
    required this.size,
    required this.child,
    required this.modalTitle,
    required this.modalButtonOneText,
    required this.modalButtonOneFunction,
    this.modalButtonTwoText,
    this.modalButtonTwoFunction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.height * 0.8,
      width: size.width,
      decoration: BoxDecoration(
        color: Palette().modalBgLightGreen,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Sizes.size20),
          topRight: Radius.circular(Sizes.size20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: Sizes.size32,
          left: Sizes.size40,
          right: Sizes.size40,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: size.width * 0.5,
              height: 4,
              decoration: BoxDecoration(
                color: Palette().normalGray.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            Gaps.v40,
            Row(
              children: [
                Expanded(
                  child: Text(
                    modalTitle,
                    style: TextStyle(
                      color: Palette().darkGreen,
                      fontWeight: FontWeight.w700,
                      fontSize: Sizes.size16,
                    ),
                  ),
                ),
                Row(
                  children: [
                    ReportButton(
                      iconExists: false,
                      buttonText: modalButtonOneText,
                      buttonColor: Palette().darkGreen,
                      action: modalButtonOneFunction,
                    ),
                    if (modalButtonTwoText != null)
                      Row(
                        children: [
                          Gaps.h20,
                          ReportButton(
                            iconExists: false,
                            buttonText: modalButtonTwoText!,
                            buttonColor: Palette().darkGreen,
                            action: modalButtonTwoFunction!,
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
            Gaps.v20,
            Expanded(
              child: SingleChildScrollView(
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
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
      height: size.height * 0.85,
      width: size.width,
      decoration: BoxDecoration(
        color: Palette().bgLightBlue,
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
            Gaps.v20,
            Row(
              children: [
                Expanded(
                  child: SelectableText(
                    modalTitle,
                    style: TextStyle(
                      color: Palette().darkBlue,
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
                      buttonColor: Palette().darkBlue,
                      action: modalButtonOneFunction,
                    ),
                    if (modalButtonTwoText != null)
                      Row(
                        children: [
                          Gaps.h20,
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: modalButtonTwoFunction!,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    width: 1.5,
                                    color: Palette().darkBlue,
                                  ),
                                  color: Palette().darkBlue,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 7,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        modalButtonTwoText!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: Sizes.size14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                  ],
                ),
              ],
            ),
            Gaps.v40,
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

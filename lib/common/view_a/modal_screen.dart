import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/view/search_csv.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/injicare_color.dart';
import 'package:onldocc_admin/injicare_font.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';

class ModalScreen extends StatelessWidget {
  final Size size;
  final double widthPercentage;

  final Widget child;
  final String modalTitle;

  final String modalButtonOneText;
  final Function() modalButtonOneFunction;
  final String? modalButtonTwoText;
  final Function()? modalButtonTwoFunction;

  const ModalScreen({
    super.key,
    required this.size,
    required this.widthPercentage,
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
      width: size.width * widthPercentage,
      decoration: BoxDecoration(
        color: Palette().bgLightBlue,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          bottomLeft: Radius.circular(40),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  context.pop();
                },
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                      Color(0xFF2A343D), BlendMode.srcIn),
                  child: SvgPicture.asset(
                    "assets/svg/close.svg",
                    width: 16,
                  ),
                ),
              ),
            ),
            Gaps.v32,
            Row(
              children: [
                Expanded(
                  child: Text(
                    modalTitle,
                    style: TextStyle(
                      color: InjicareColor().gray100,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                  ),
                ),
              ],
            ),
            Gaps.v40,
            Expanded(
              child: SingleChildScrollView(
                child: child,
              ),
            ),
            Gaps.v10,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                gestureDetectorWithMouseClick(
                  function: () {
                    context.pop();
                  },
                  child: Container(
                    width: 200,
                    height: searchHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: InjicareColor().gray20,
                    ),
                    child: Center(
                      child: Text(
                        "닫기",
                        style: InjicareFont().body03.copyWith(
                              color: InjicareColor().gray80,
                            ),
                      ),
                    ),
                  ),
                ),
                Gaps.h10,
                Expanded(
                  child: gestureDetectorWithMouseClick(
                    function: modalButtonOneFunction,
                    child: Container(
                      height: searchHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: InjicareColor().secondary50,
                      ),
                      child: Center(
                        child: Text(
                          modalButtonOneText,
                          style: InjicareFont().body03.copyWith(
                                color: Colors.white,
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
    );
  }
}

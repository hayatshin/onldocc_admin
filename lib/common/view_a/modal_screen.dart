import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:onldocc_admin/common/view/search_csv.dart';
import 'package:onldocc_admin/constants/gaps.dart';
import 'package:onldocc_admin/injicare_color.dart';
import 'package:onldocc_admin/injicare_font.dart';
import 'package:onldocc_admin/palette.dart';
import 'package:onldocc_admin/utils.dart';

class ModalScreen extends StatefulWidget {
  final double widthPercentage;
  final Widget child;
  final String modalTitle;
  final String modalButtonOneText;
  final Function() modalButtonOneFunction;
  final String? modalButtonTwoText;
  final Function()? modalButtonTwoFunction;
  final bool scroll;
  final bool addBtn;
  final Function()? addAction;
  final String? snackBar;

  const ModalScreen({
    super.key,
    required this.widthPercentage,
    required this.child,
    required this.modalTitle,
    required this.modalButtonOneText,
    required this.modalButtonOneFunction,
    this.modalButtonTwoText,
    this.modalButtonTwoFunction,
    this.scroll = true,
    this.addBtn = false,
    this.addAction,
    this.snackBar,
  });

  @override
  State<ModalScreen> createState() => _ModalScreenState();
}

class _ModalScreenState extends State<ModalScreen> {
  bool _addPhotoBtn = false;

  void _updatePhotoBtn() {
    setState(() {
      _addPhotoBtn = !_addPhotoBtn;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width * widget.widthPercentage,
      decoration: BoxDecoration(
        color: Palette().bgLightBlue,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          bottomLeft: Radius.circular(40),
        ),
      ),
      child: Stack(
        children: [
          Padding(
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
                        widget.modalTitle,
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
                if (widget.scroll)
                  Expanded(
                    child: SingleChildScrollView(
                      child: widget.child,
                    ),
                  )
                else
                  Expanded(child: widget.child),
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
                        function: widget.modalButtonOneFunction,
                        child: Container(
                          height: searchHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: InjicareColor().secondary50,
                          ),
                          child: Center(
                            child: Text(
                              widget.modalButtonOneText,
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
          if (widget.addBtn)
            Positioned(
              top: 250,
              left: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _updatePhotoBtn,
                      child: SvgPicture.asset(
                        "assets/svg/plus-square.svg",
                        width: 30,
                      ),
                    ),
                  ),
                  if (_addPhotoBtn)
                    Column(
                      children: [
                        Gaps.v5,
                        Container(
                          width: 150,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: InjicareColor().gray20,
                              width: 1,
                            ),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Column(
                            children: [
                              Expanded(
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: widget.addAction!,
                                    child: SizedBox(
                                      width: 150,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "사진",
                                            style: InjicareFont()
                                                .body05
                                                .copyWith(
                                                  color: InjicareColor().gray80,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Row(
                              //   children: [
                              //     Expanded(
                              //       child: Container(
                              //         height: 1,
                              //         decoration: BoxDecoration(
                              //           color: InjicareColor().gray20,
                              //         ),
                              //       ),
                              //     )
                              //   ],
                              // ),
                              // Expanded(
                              //   child: MouseRegion(
                              //     cursor: SystemMouseCursors.click,
                              //     child: GestureDetector(
                              //       onTap: widget.videoAction!,
                              //       child: SizedBox(
                              //         width: 150,
                              //         child: Column(
                              //           mainAxisAlignment:
                              //               MainAxisAlignment.center,
                              //           children: [
                              //             Text(
                              //               "영상",
                              //               style: InjicareFont()
                              //                   .body05
                              //                   .copyWith(
                              //                     color: InjicareColor().gray80,
                              //                   ),
                              //             ),
                              //           ],
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

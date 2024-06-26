import 'package:flutter/material.dart';
import 'package:onldocc_admin/constants/const.dart';
import 'package:onldocc_admin/constants/sizes.dart';
import 'package:skeletons/skeletons.dart';

class SkeletonLoadingScreen extends StatelessWidget {
  const SkeletonLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(
        Sizes.size20,
      ),
      child: Column(
        children: [
          Container(
            height: buttonHeight,
          ),
          SkeletonParagraph(
            style: SkeletonParagraphStyle(
                lines: 3,
                spacing: 23,
                lineStyle: SkeletonLineStyle(
                  randomLength: true,
                  height: 23,
                  borderRadius: BorderRadius.circular(5),
                  minLength: MediaQuery.of(context).size.width / 3,
                  maxLength: MediaQuery.of(context).size.width / 2,
                )),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../constants/gaps.dart';
import '../../../constants/sizes.dart';

class DefaultPage extends StatelessWidget {
  const DefaultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.face,
                size: Sizes.size44,
                color: Colors.grey.shade800,
              ),
              Gaps.h20,
              Icon(
                Icons.face_3,
                size: Sizes.size40,
                color: Colors.grey.shade800,
              ),
            ],
          ),
          Gaps.v40,
          Text(
            "회원을 검색해주세요.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Sizes.size16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
